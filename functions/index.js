const functions = require("firebase-functions");
const admin = require("firebase-admin");
const cors = require("cors")({origin: true});

admin.initializeApp();

const db = admin.firestore();

const stripe = require("stripe")(
    process.env.STRIPE_SECRET_KEY ||
    (functions.config().stripe && functions.config().stripe.secret_key) ||
    "sk_test_PLACEHOLDER",
);

// ═══════════════════════════════════════════════════════
// POST /stripePaymentIntent
// ═══════════════════════════════════════════════════════
exports.stripePaymentIntent = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    if (req.method !== "POST") {
      return res.status(405).json({error: "Method not allowed"});
    }

    try {
      const {
        amount,
        currency = "usd",
        name = "",
        address = "",
        city = "",
        state = "",
        country = "",
        pin = "",
        email = "",
      } = req.body;

      if (!amount) {
        return res.status(400).json({error: "amount is required"});
      }

      let customer;
      if (email) {
        const existing = await stripe.customers.list({email, limit: 1});
        if (existing.data.length > 0) {
          customer = existing.data[0];
        } else {
          customer = await stripe.customers.create({
            email,
            name,
            address: {
              line1: address,
              city,
              state,
              postal_code: pin,
              country: country || undefined,
            },
          });
        }
      } else {
        customer = await stripe.customers.create({name});
      }

      const ephemeralKey = await stripe.ephemeralKeys.create(
          {customer: customer.id},
          {apiVersion: "2024-04-10"},
      );

      const paymentIntent = await stripe.paymentIntents.create({
        amount: parseInt(amount),
        currency: currency.toLowerCase(),
        customer: customer.id,
        automatic_payment_methods: {enabled: true},
        description: "LawHub Payment",
        shipping: {
          name,
          address: {
            line1: address,
            city,
            state,
            postal_code: pin,
            country: country || undefined,
          },
        },
      });

      return res.status(200).json({
        paymentIntent: paymentIntent.id,
        ephemeralKey: ephemeralKey.secret,
        customer: customer.id,
        clientSecret: paymentIntent.client_secret,
      });
    } catch (err) {
      console.error("Stripe error:", err.message);
      return res.status(500).json({error: err.message});
    }
  });
});

// ═══════════════════════════════════════════════════════
// POST /walletTransfer
//
// Body (JSON):
//   senderEmail    – sender's email/ID
//   recipientEmail – recipient's email/ID
//   amount         – number (full units, e.g. 500 = Rs.500)
//
// Atomically deducts from sender, credits recipient,
// creates transaction records, and sends notification.
// ═══════════════════════════════════════════════════════
exports.walletTransfer = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    if (req.method !== "POST") {
      return res.status(405).json({error: "Method not allowed"});
    }

    try {
      const {senderEmail, recipientEmail, amount} = req.body;

      if (!senderEmail || !recipientEmail || !amount) {
        return res.status(400).json({error: "Missing required fields"});
      }

      if (senderEmail === recipientEmail) {
        return res.status(400).json({error: "Cannot send money to yourself"});
      }

      const transferAmount = parseFloat(amount);
      if (isNaN(transferAmount) || transferAmount <= 0) {
        return res.status(400).json({error: "Invalid amount"});
      }

      // Look up sender and recipient profiles
      const [senderUser, senderLawyer, recipientUser, recipientLawyer] =
        await Promise.all([
          db.collection("Users").doc(senderEmail).get(),
          db.collection("Lawyers").doc(senderEmail).get(),
          db.collection("Users").doc(recipientEmail).get(),
          db.collection("Lawyers").doc(recipientEmail).get(),
        ]);

      const senderDoc = senderUser.exists ? senderUser : senderLawyer;
      const recipientDoc = recipientUser.exists ? recipientUser : recipientLawyer;

      if (!senderDoc.exists) {
        return res.status(404).json({error: "Sender not found"});
      }
      if (!recipientDoc.exists) {
        return res.status(404).json({error: "Recipient not found"});
      }

      const senderName = senderDoc.data().name || "Unknown";
      const senderImage = senderDoc.data().profilePic || "null";
      const recipientName = recipientDoc.data().name || "Unknown";
      const recipientImage = recipientDoc.data().profilePic || "null";

      const senderWalletRef = db.collection("Wallets").doc(senderEmail);
      const recipientWalletRef = db.collection("Wallets").doc(recipientEmail);

      // Atomic transfer
      await db.runTransaction(async (transaction) => {
        const senderWallet = await transaction.get(senderWalletRef);
        const recipientWallet = await transaction.get(recipientWalletRef);

        const senderBalance = senderWallet.exists ?
          (senderWallet.data().balance || 0) : 0;
        const recipientBalance = recipientWallet.exists ?
          (recipientWallet.data().balance || 0) : 0;

        if (senderBalance < transferAmount) {
          throw new Error("Insufficient balance");
        }

        // Update balances
        transaction.set(senderWalletRef, {
          balance: senderBalance - transferAmount,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        }, {merge: true});

        transaction.set(recipientWalletRef, {
          balance: recipientBalance + transferAmount,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        }, {merge: true});

        // Transaction records for sender
        transaction.create(
            senderWalletRef.collection("transactions").doc(), {
              type: "sent",
              amount: transferAmount,
              otherPartyEmail: recipientEmail,
              otherPartyName: recipientName,
              otherPartyImage: recipientImage,
              createdAt: admin.firestore.FieldValue.serverTimestamp(),
            });

        // Transaction records for recipient
        transaction.create(
            recipientWalletRef.collection("transactions").doc(), {
              type: "received",
              amount: transferAmount,
              otherPartyEmail: senderEmail,
              otherPartyName: senderName,
              otherPartyImage: senderImage,
              createdAt: admin.firestore.FieldValue.serverTimestamp(),
            });
      });

      // Send notification to recipient (outside transaction)
      const recipientIsUser = recipientUser.exists;
      const notifCollection = recipientIsUser ?
        "UsersNotifications" : "LawyersNotifications";
      const senderKey = recipientIsUser ? "lawyerID" : "userID";

      const notifRef = db.collection(notifCollection).doc(recipientEmail);
      const notifDoc = await notifRef.get();

      let counter = 1;
      if (notifDoc.exists && notifDoc.data().counter) {
        counter = notifDoc.data().counter + 1;
      }

      await notifRef.set({
        [`Notification${counter}`]: [
          {[senderKey]: senderEmail},
          {type: `sent you Rs.${transferAmount}`},
          {isSeen: false},
        ],
        counter: counter,
      }, {merge: true});

      return res.status(200).json({
        success: true,
        message: `Rs.${transferAmount} sent to ${recipientName}`,
        senderBalance: undefined,
      });
    } catch (err) {
      console.error("Transfer error:", err.message);
      if (err.message === "Insufficient balance") {
        return res.status(400).json({error: "Insufficient balance"});
      }
      return res.status(500).json({error: err.message});
    }
  });
});
