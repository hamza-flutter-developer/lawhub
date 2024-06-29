// ignore_for_file: file_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lawhub/LoginSignup_Pages/UserType.dart';
import 'package:lawhub/Utils/Utilities.dart';
import 'package:lawhub/widgets/Fonts.dart';
import 'package:lawhub/widgets/Themes.dart';
import 'package:pinput/pinput.dart';

import 'ChangePassword.dart';

class SignupOTPVerification extends StatefulWidget{

  final bool isForgottenPass;

  String verificationId;
  final String emailPhone;
  final String name;
  final String password;
  SignupOTPVerification({Key? key, required this.isForgottenPass, required this.emailPhone, required this.name, required this.verificationId, required this.password}) : super(key : key);

  @override
  State<SignupOTPVerification> createState() => _SignupOTPVerificationState();
}

class _SignupOTPVerificationState extends State<SignupOTPVerification> {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _signInWithPhoneNumber(String smsCode) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: smsCode,
      );
      await _auth.signInWithCredential(credential);
      AuthCredential credential1 = EmailAuthProvider.credential(email: '${widget.emailPhone}@gmail.com', password: widget.password);
      _auth.currentUser?.linkWithCredential(credential1);
      Navigator.push(context, MaterialPageRoute(builder: (context) => UserType(email: widget.emailPhone, name: widget.name, password: widget.password,)));
    } on FirebaseAuthException catch (e) {
      Utilities().getMessageFromErrorCode(e.code);
    }
  }

  Future<void> _verifyPhoneNumber(String smsCode) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: smsCode,
      );
      await _auth.signInWithCredential(credential);
      Navigator.push(context, MaterialPageRoute(builder: (context) => ChangePassword(phone: widget.emailPhone,)));
    } on FirebaseAuthException catch (e) {
      Utilities().getMessageFromErrorCode(e.code);
    }
  }

  Future<void> _resendCode() async {
    verificationCompleted(PhoneAuthCredential credential) async {
    }

    verificationFailed(FirebaseAuthException e) {

    }

    codeSent(String verificationId, int? resendToken) async {
      setState(() {
        widget.verificationId = verificationId;
        Utilities().successMsg('Verification code has been resent Successfully');
      });
    }

    codeAutoRetrievalTimeout(String verificationId) {
    }

    await _auth.verifyPhoneNumber(
      phoneNumber: widget.emailPhone,
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
        backgroundColor: Colors.blue,
        body: Column(
          children: [
            Padding(
              padding:
              EdgeInsets.only(top: 0.03 * MediaQuery.of(context).size.height),
              child: TopLogo(fontColor: Colors.white),
            ),
            Expanded(
                child: Container(
                    margin: EdgeInsets.only(
                        top: 0.0425 * MediaQuery.of(context).size.height),
                    width: double.infinity,
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(45),
                            topRight: Radius.circular(45)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black45,
                              blurRadius: 15.0,
                              spreadRadius: 5.0)
                        ]),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(
                              width: double.infinity,
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 0.08 *
                                        MediaQuery.of(context).size.width,
                                    top: 0.07 *
                                        MediaQuery.of(context).size.height
                                ),
                                child: const BoldFont(text: "Enter 6 Digit OTP Pin"),
                              )),
                          SizedBox(
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
                                        TextSpan(text: '${widget.emailPhone}\n',style: const TextStyle(
                                          fontFamily: 'roboto',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),),
                                        const TextSpan(text: 'OTP will expire in 1 minute.')
                                      ]
                                  ),
                                ),
                              )),
                          widget.isForgottenPass
                            ? Padding(
                            padding: EdgeInsets.symmetric(horizontal: 0.1 * MediaQuery.of(context).size.width, vertical: 0.05 * MediaQuery.of(context).size.height),
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
                                  _verifyPhoneNumber(value);
                                },
                              ),
                            ),
                          )
                            : Padding(
                              padding: EdgeInsets.symmetric(horizontal: 0.1 * MediaQuery.of(context).size.width, vertical: 0.05 * MediaQuery.of(context).size.height),
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
                                  _signInWithPhoneNumber(value);
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
                                    onPressed: () {
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
                    )))
          ],
        )
    );
  }
}