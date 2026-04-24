// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../Utils/Utilities.dart';
import 'UserRequestSubmitted.dart';

/// ============================================================
/// UserSendRequest — StatefulWidget
///
/// This screen allows a logged-in user to write and submit a
/// legal case request to a specific lawyer.
///
/// Parameters received from the previous screen:
///   userData   → Map containing the current user's data (id, etc.)
///   lawyerData → Map containing the selected lawyer's data (id, etc.)
///
/// Flow:
///   1. User types a case description (min 100 characters)
///   2. Taps "Send" → validates form → checks Firestore
///   3. If lawyer's Requests doc exists → sendRequest()
///      If not → sendFirstRequest() then sendRequest()
///   4. On success → addNotification() + navigate to UserRequestSubmitted
/// ============================================================
class UserSendRequest extends StatefulWidget {
  final Map<String, dynamic> userData;
  final Map<String, dynamic> lawyerData;

  const UserSendRequest({
    super.key,
    required this.userData,
    required this.lawyerData,
  });

  @override
  State<UserSendRequest> createState() => _UserSendRequestState();
}

class _UserSendRequestState extends State<UserSendRequest>
    with TickerProviderStateMixin {

  // ─── ORIGINAL STATE VARIABLES (completely untouched) ───────────────────

  /// Controls the case description text field
  final TextEditingController _caseDescription = TextEditingController();

  /// FocusNode used to detect/dismiss keyboard on Send tap
  final caseDescriptionFocusNode = FocusNode();

  /// GlobalKey used by Form to trigger validation
  final _form = GlobalKey<FormState>();

  /// True while async Firestore calls run → shows spinner on button
  bool isLoading = false;

  /// Shortcut reference to the Requests Firestore collection
  final fireStoreRequests =
  FirebaseFirestore.instance.collection('Requests');

  /// Shortcut reference to the LawyersNotifications collection
  final fireStoreNotification =
  FirebaseFirestore.instance.collection('LawyersNotifications');

  // ─── ANIMATION CONTROLLERS (UI only — zero impact on logic) ───────────

  /// Drives the page-level fade + upward slide on screen open
  late AnimationController _entranceController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // ============================================================
  // initState — runs once when this widget is first created.
  //
  // Sets up a gentle fade + slide entrance animation and starts
  // it immediately so the screen feels alive on open.
  // ============================================================
  @override
  void initState() {
    super.initState();

    // Entrance: 650ms fade + gentle upward slide
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _fadeAnim = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    ));

    // Play the entrance animation as soon as the screen opens
    _entranceController.forward();
  }

  // ============================================================
  // dispose — clean up controllers to avoid memory leaks
  // ============================================================
  @override
  void dispose() {
    _entranceController.dispose();
    _caseDescription.dispose();
    caseDescriptionFocusNode.dispose();
    super.dispose();
  }

  // ╔══════════════════════════════════════════════════════════╗
  //  ALL METHODS BELOW ARE 100% ORIGINAL LOGIC
  //  Only comments have been added — no code was changed.
  // ╚══════════════════════════════════════════════════════════╝

  // ============================================================
  // sendFirstRequest  ← ORIGINAL LOGIC
  //
  // Called only when the lawyer has no Requests document yet.
  // Creates the document with counter=0 so sendRequest() can
  // safely read and increment it immediately after.
  // ============================================================
  void sendFirstRequest() {
    fireStoreRequests.doc(widget.lawyerData['id']).set({'counter': 0});
  }

  // ============================================================
  // sendRequest  ← ORIGINAL LOGIC
  //
  // Reads the lawyer's current request counter from Firestore,
  // increments it, then writes the new request as "RequestN".
  //
  // On success:
  //   → calls addNotification() to alert the lawyer
  //   → sets isLoading = false
  //   → navigates to UserRequestSubmitted screen
  //
  // On error:
  //   → sets isLoading = false
  //   → shows error snackbar via Utilities().errorMsg()
  // ============================================================
  void sendRequest() async {
    var doc = await FirebaseFirestore.instance
        .collection('Requests')
        .doc(widget.lawyerData['id'])
        .get();
    int counter = doc['counter'];
    counter++;
    DocumentReference documentReference =
    fireStoreRequests.doc(widget.lawyerData['id']);
    await documentReference.update({
      'Request$counter': [
        {'userID': widget.userData['id']},
        {'caseDescription': _caseDescription.text.toString()},
        {'status': 'pending'},
      ],
      'counter': counter,
    }).then((value) => {
      addNotification(),
      setState(() {
        isLoading = false;
        setState(() {});
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
            const UserRequestSubmitted(text: 'Request'),
          ),
        );
      }),
    }).onError((error, stackTrace) => {
      setState(() {
        isLoading = false;
      }),
      Utilities().errorMsg('Something Went Wrong'),
    });
  }

  // ============================================================
  // addNotification  ← ORIGINAL LOGIC
  //
  // Writes a notification into the LawyersNotifications collection
  // so the lawyer sees an in-app alert about the new request.
  //
  //   If doc exists  → increment counter, add "NotificationN" field
  //   If doc missing → create the doc with Notification1 and counter=1
  // ============================================================
  void addNotification() async {
    var doc = await FirebaseFirestore.instance
        .collection('LawyersNotifications')
        .doc(widget.lawyerData['id'])
        .get();
    if (doc.exists) {
      int counter = doc['counter'];
      counter++;
      DocumentReference documentReference =
      fireStoreNotification.doc(widget.lawyerData['id']);
      await documentReference.update({
        'Notification$counter': [
          {'userID': widget.userData['id']},
          {'type': 'sends you request'},
          {'isSeen': false},
        ],
        'counter': counter,
      });
    } else {
      fireStoreNotification.doc(widget.lawyerData['id']).set({
        'Notification1': [
          {'userID': widget.userData['id']},
          {'type': 'sends you request'},
          {'isSeen': false},
        ],
        'counter': 1,
      });
    }
  }

  // ============================================================
  // build — constructs the full visual UI tree
  //
  // Structure:
  //   Scaffold
  //   └── gradient background
  //       └── SafeArea
  //           └── FadeTransition + SlideTransition (entrance)
  //               ├── _buildAppBar()
  //               ├── scrollable body
  //               │   ├── lawyer info card
  //               │   ├── section label
  //               │   └── Form with TextFormField
  //               └── _buildSendButton() (pinned at bottom)
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        // ── Deep navy gradient background (matches app theme) ────────────
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A1628),
              Color(0xFF0D2137),
              Color(0xFF0B3558),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Column(
                children: [
                  // ── Custom glassmorphic AppBar ───────────────────────
                  _buildAppBar(context),

                  // ── Scrollable body ──────────────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 28),

                          // Lawyer info summary card
                          _buildLawyerCard(),

                          const SizedBox(height: 28),

                          // Section label
                          const Text(
                            'Case Description',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Minimum 100 characters',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // ── ORIGINAL Form + TextFormField ────────────
                          _buildDescriptionField(),

                          const SizedBox(height: 100), // space for button
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // ── Send / Loading button pinned at the bottom ─────────────────────
      floatingActionButton: _buildSendButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // ============================================================
  // _buildAppBar — custom glassmorphic top bar
  //
  // Back button: Navigator.of(context).pop() — same as original.
  // Title: "Send Request" — same as original.
  // ============================================================
  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.13)),
        ),
        child: Row(
          children: [
            // Back button — same original Navigator.pop() call
            IconButton(
              icon: const Icon(
                FontAwesomeIcons.angleLeft,
                color: Colors.white,
                size: 18,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            const Expanded(
              child: Center(
                child: Text(
                  'Send Request',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 48), // mirrors icon button width
          ],
        ),
      ),
    );
  }

  // ============================================================
  // _buildLawyerCard — small info card showing the lawyer's name
  //
  // Purely decorative UI card. No logic.
  // Reads lawyerData['name'] to show who the request is going to.
  // ============================================================
  Widget _buildLawyerCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1E88E5).withOpacity(0.15),
              border: Border.all(
                color: const Color(0xFF1E88E5).withOpacity(0.4),
              ),
            ),
            child: const Icon(
              FontAwesomeIcons.userTie,
              color: Color(0xFF1E88E5),
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sending request to',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.lawyerData['name'] ?? 'Lawyer',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // _buildDescriptionField — glassmorphic card wrapping the Form
  //
  // ORIGINAL logic fully preserved:
  //   • GlobalKey _form for validation
  //   • _caseDescription controller
  //   • caseDescriptionFocusNode
  //   • validator: empty check + minimum 100 characters check
  //   • maxLines: 4
  //   • InputDecoration hint text
  // ============================================================
  Widget _buildDescriptionField() {
    return Form(
      key: _form, // ← original GlobalKey, untouched
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextFormField(
            // ── ORIGINAL: all field properties untouched ──────────────
            controller: _caseDescription,
            textAlignVertical: TextAlignVertical.center,
            focusNode: caseDescriptionFocusNode,
            style: const TextStyle(fontSize: 15, color: Colors.white),
            maxLines: 4,
            decoration: const InputDecoration(
              focusedBorder: InputBorder.none,
              border: InputBorder.none,
              hintText: 'Please Explain Your Legal Concern',
              hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
              focusColor: Colors.black,
            ),
            // ── ORIGINAL validator — untouched ─────────────────────────
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please Enter Your Legal Concern';
              } else if (value.length < 100) {
                return 'Please Enter up to 100 Characters';
              }
              return null;
            },
          ),
        ),
      ),
    );
  }

  // ============================================================
  // _buildSendButton — animated gradient Send / Loading button
  //
  // onTap logic is IDENTICAL to the original floatingActionButton:
  //   1. Unfocus keyboard if open
  //   2. Validate form with _form.currentState!.validate()
  //   3. Set isLoading = true
  //   4. Check if Requests doc exists → sendRequest() or
  //      sendFirstRequest() + sendRequest()
  //
  // Added (UI only):
  //   • AnimatedContainer shrinks width while loading
  //   • Gradient background + glow shadow
  // ============================================================
  Widget _buildSendButton(BuildContext context) {
    return GestureDetector(
      // ── ORIGINAL: unfocus keyboard on tap outside button ──────────────
      onTap: () {
        if (caseDescriptionFocusNode.hasFocus) {
          caseDescriptionFocusNode.unfocus();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: isLoading ? 160 : double.infinity,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1565C0).withOpacity(0.45),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () async {
                // ── ORIGINAL onTap logic — untouched ───────────────────
                if (caseDescriptionFocusNode.hasFocus) {
                  caseDescriptionFocusNode.unfocus();
                }
                if (_form.currentState!.validate()) {
                  setState(() {
                    isLoading = true;
                  });
                  var doc = await FirebaseFirestore.instance
                      .collection('Requests')
                      .doc(widget.lawyerData['id'])
                      .get();
                  if (doc.exists) {
                    sendRequest();
                  } else {
                    sendFirstRequest();
                    sendRequest();
                  }
                }
              },
              child: Center(
                child: isLoading
                // ── ORIGINAL: spinner + "Loading" text ───────────────
                    ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SpinKitCircle(color: Colors.white, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Loading',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'roboto',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
                // ── ORIGINAL: "Send" label ────────────────────────────
                    : const Text(
                  'Send',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'roboto',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}