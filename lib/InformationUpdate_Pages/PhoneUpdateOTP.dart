// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lawhub/InformationUpdate_Pages/PasswordChange.dart';
import 'package:pinput/pinput.dart';
import '../Utils/Utilities.dart';
import '../widgets/Fonts.dart';
import 'InfoUpdated.dart';

class UserPhoneUpdateOTP extends StatefulWidget{
  final bool isForgottenPass;
  final bool isUser;
  final String oldPhone;
  final String newPhone;
  final String password;
  String verificationID;
  UserPhoneUpdateOTP({Key? key, required this.isUser, required this.isForgottenPass, required this.newPhone, required this.verificationID, required this.password, required this.oldPhone}) : super(key: key);

  @override
  State<UserPhoneUpdateOTP> createState() => _UserPhoneUpdateOTPState();
}

class _UserPhoneUpdateOTPState extends State<UserPhoneUpdateOTP> {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> updateUserPhoneNumber(String smsCode) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationID,
        smsCode: smsCode,
      );
      updateUserDocument();
      updateUserDocumentFavourite();
      deleteOldPhone();
      await _auth.signInWithCredential(credential);
      AuthCredential credential1 = EmailAuthProvider.credential(email: '${widget.newPhone}@gmail.com', password: widget.password);
      _auth.currentUser?.linkWithCredential(credential1);
      updateUserDocument();
      updateUserDocumentFavourite();
      Navigator.push(context, MaterialPageRoute(builder: (context) => UserInfoUpdated(text: 'Phone', isUser: widget.isUser)));

    } on FirebaseAuthException catch (e) {
      Utilities().getMessageFromErrorCode(e.code);
    }
  }

  Future<void> deleteOldPhone() async {
    debugPrint(widget.oldPhone);
    FirebaseAuth.instance.signInWithEmailAndPassword(email: "${widget.oldPhone}@gmail.com".toString(), password: widget.password).then((value) {
      User? user = FirebaseAuth.instance.currentUser;
      user?.delete();
    });
  }

  Future<void> updateUserDocument() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    firestore.collection("Users").doc('${widget.oldPhone}@gmail.com').get().then((doc) {
      firestore.collection("Users").doc('${widget.newPhone}@gmail.com').set(doc.data()!).then((value) {
        firestore.collection("Users").doc('${widget.oldPhone}@gmail.com').delete();
        firestore.collection("Users").doc('${widget.newPhone}@gmail.com').update({'id': '${widget.newPhone}@gmail.com', 'emailPhone': widget.newPhone});
      }).onError((error, stackTrace) {
        debugPrint("TRY AGAIN PLEASE");
      });
    });

  }

  Future<void> updateUserDocumentFavourite() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    firestore.collection("Favourite").doc('${widget.oldPhone}@gmail.com').get().then((doc) {
      firestore.collection("Favourite").doc('${widget.newPhone}@gmail.com').set(doc.data()!).then((value) {
        firestore.collection("Favourite").doc('${widget.oldPhone}@gmail.com').delete();
      }).onError((error, stackTrace) {
        debugPrint("TRY AGAIN PLEASE");
      });
    });

  }

  Future<void> updateLawyerPhoneNumber(String smsCode) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationID,
        smsCode: smsCode,
      );
      updateLawyerDocument();
      updateFavouriteDocumentsLawyer();
      updateArticlesLawyerDocument();
      deleteOldPhone();
      await _auth.signInWithCredential(credential);
      AuthCredential credential1 = EmailAuthProvider.credential(email: '${widget.newPhone}@gmail.com', password: widget.password);
      _auth.currentUser?.linkWithCredential(credential1);
      updateLawyerDocument();
      updateFavouriteDocumentsLawyer();
      updateArticlesLawyerDocument();
      Navigator.push(context, MaterialPageRoute(builder: (context) => UserInfoUpdated(text: 'Phone', isUser: widget.isUser)));

    } on FirebaseAuthException catch (e) {
      Utilities().getMessageFromErrorCode(e.code);
    }
  }

  Future<void> updateLawyerDocument() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    firestore.collection("Lawyers").doc('${widget.oldPhone}@gmail.com').get().then((doc) {
      firestore.collection("Lawyers").doc('${widget.newPhone}@gmail.com').set(doc.data()!).then((value) {
        firestore.collection("Lawyers").doc('${widget.oldPhone}@gmail.com').delete();
        firestore.collection("Lawyers").doc('${widget.newPhone}@gmail.com').update({'id': '${widget.newPhone}@gmail.com', 'emailPhone': widget.newPhone});
      }).onError((error, stackTrace) {
        debugPrint("TRY AGAIN PLEASE");
      });
    });

  }

  void updateFavouriteDocumentsLawyer() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Favourite').get();
      List<QueryDocumentSnapshot> documents = querySnapshot.docs;

      for (var doc in documents) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

        for(int i = 1; i <= data?['counter']; i++){
          if(data?['LawyerID$i'] == '${widget.oldPhone}@gmail.com') {
            await FirebaseFirestore.instance.collection('Favourite').doc(doc.id).update({
              'LawyerID$i': '${widget.newPhone}@gmail.com',
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error updating documents: $e');
      // Handle the error accordingly
    }
  }

  Future<void> updateArticlesLawyerDocument() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    firestore.collection("Articles").doc('${widget.oldPhone}@gmail.com').get().then((doc) {
      firestore.collection("Articles").doc('${widget.newPhone}@gmail.com').set(doc.data()!).then((value) {
        firestore.collection("Articles").doc('${widget.oldPhone}@gmail.com').delete();
      }).onError((error, stackTrace) {
        debugPrint("TRY AGAIN PLEASE");
      });
    });

  }

  Future<void> _verifyPhoneNumber(String smsCode) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationID,
        smsCode: smsCode,
      );
      await _auth.signInWithCredential(credential);
      Navigator.push(context, MaterialPageRoute(builder: (context) => UserPasswordChangePhone(isUser: widget.isUser, phone: widget.oldPhone)));
    } on FirebaseAuthException catch (e) {
      Utilities().getMessageFromErrorCode(e.code);
    }
  }

  bool isLoading = false;

  Future<void> _resendCode() async {
    verificationCompleted(PhoneAuthCredential credential) async {
    }

    verificationFailed(FirebaseAuthException e) {
      setState(() {
        isLoading = false;
      });

    }

    codeSent(String verificationId, int? resendToken) async {
      setState(() {
        isLoading = false;
        widget.verificationID = verificationId;
        Utilities().successMsg('Verification code has been resent Successfully');
      });
    }

    codeAutoRetrievalTimeout(String verificationId) {
    }

    await _auth.verifyPhoneNumber(
      phoneNumber: widget.oldPhone,
      timeout: const Duration(seconds: 60),
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  final defaultPinTheme = PinTheme(
      height: 45,
      width: 40,
      textStyle: const TextStyle(
          fontSize: 18,
          fontFamily: 'roboto'
      ),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
                color: Colors.black45,
                blurRadius: 5.0,
                spreadRadius: 0.5)
          ]
      )

  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          toolbarHeight: 70,
          leadingWidth: 40,
          backgroundColor: Colors.blue,
          leading: Padding(
            padding: const EdgeInsets.only(top: 8,left: 10),
            child: IconButton(
              icon: const Icon(FontAwesomeIcons.angleLeft, color: Colors.white,),
              onPressed: () {
                // Navigate back to the previous page or screen
                Navigator.of(context).pop();
              },
            ),
          ),
          title: widget.isForgottenPass
          ? const Padding(
            padding: EdgeInsets.only(top: 13),
            child: Text(
              "Forgotten Password",
              style: TextStyle(
                  fontFamily: 'roboto',
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white),
            ),
          )
          : const Padding(
            padding: EdgeInsets.only(top: 13),
            child: Text(
              "Phone Update",
              style: TextStyle(
                  fontFamily: 'roboto',
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white),
            ),
          ),
          centerTitle: true,


          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25)),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.only(
                      left: 0.08 *
                          MediaQuery.of(context).size.width,
                      top: 0.05 *
                          MediaQuery.of(context).size.height
                  ),
                  child: const BoldFont(text: "Enter 6 Digit OTP Pin"),
                )),
            widget.isForgottenPass
            ? SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.only(
                    left:
                    0.08 * MediaQuery.of(context).size.width,
                  ),
                  child: RichText(
                    text: TextSpan(
                        style: const TextStyle(
                            color: Colors.black,
                            fontFamily: 'roboto',
                            fontSize: 16,
                            height: 1.5
                        ),
                        children: <TextSpan>[
                          const TextSpan(text: 'One-time Passcode has been sent to your Phone,\n'),
                          TextSpan(text: '${widget.oldPhone}\n',style: const TextStyle(
                            fontFamily: 'roboto',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),),
                          const TextSpan(text: 'OTP will expire in 1 minute.')
                        ]
                    ),
                  ),
                ))
            : SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.only(
                    left:
                    0.08 * MediaQuery.of(context).size.width,
                  ),
                  child: RichText(
                    text: TextSpan(
                        style: const TextStyle(
                            color: Colors.black,
                            fontFamily: 'roboto',
                            fontSize: 16,
                            height: 1.5
                        ),
                        children: <TextSpan>[
                          const TextSpan(text: 'One-time Passcode has been sent to your Phone,\n'),
                          TextSpan(text: '${widget.newPhone}\n',style: const TextStyle(
                            fontFamily: 'roboto',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),),
                          const TextSpan(text: 'OTP will expire in 1 minute.')
                        ]
                    ),
                  ),
                )),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 0.1 * MediaQuery.of(context).size.width, vertical: 0.03 * MediaQuery.of(context).size.height),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: Pinput(
                  keyboardType: TextInputType.number,
                  length: 6,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration!.copyWith(
                          boxShadow: [
                            const BoxShadow(
                                color: Colors.blue,
                                blurRadius: 5.0,
                                spreadRadius: 0.5)
                          ]
                      )
                  ),
                  onCompleted: (value) {
                    if(widget.isForgottenPass) {
                      _verifyPhoneNumber(value);
                    }
                    else {
                      if(widget.isUser) {
                        updateUserPhoneNumber(value);
                      }
                      else {
                        updateLawyerPhoneNumber(value);
                      }
                    }
                  },

                ),
              ),
            ),
            SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 0.08 *
                        MediaQuery.of(context).size.width,
                  ),
                  child: const NormalFont(
                      text:
                      "didn’t receive the code? "),
                )),
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 0.08 *
                      MediaQuery.of(context).size.width,
                ),
                child: Row(
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(50, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          alignment: Alignment.centerLeft),
                      onPressed: ()  {
                        _resendCode();
                      },
                      child: const Text(
                        "Click here to Resend One-Time Passcode",
                        style: TextStyle(
                          fontFamily: 'roboto',
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.blue,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      )

    );
  }
}