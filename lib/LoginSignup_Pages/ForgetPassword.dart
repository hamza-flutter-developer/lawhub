import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lawhub/LoginSignup_Pages/LoginPage.dart';
import 'package:lawhub/Utils/Utilities.dart';
import 'package:lawhub/widgets/Fonts.dart';

import '../widgets/Themes.dart';
import 'SignupOTPVerification.dart';

class ForgetPassword extends StatefulWidget{
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final TextEditingController _emailPhoneController = TextEditingController();

  final _auth = FirebaseAuth.instance;

  final _form = GlobalKey<FormState>();

  bool isEmailValid = false;

  bool isPhoneValid = false;

  final textFieldFocusNode = FocusNode();

  bool _isValidEmail(String email) {
    RegExp emailRegExp = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
    return emailRegExp.hasMatch(email);
  }

  bool _isValidPhoneNumber(String phoneNumber) {
    RegExp phoneRegExp = RegExp(r'^\+\d{12}$');
    return phoneRegExp.hasMatch(phoneNumber);
  }

  bool isLoading = false;

  void _sendVerificationEmail() async {
    _auth.sendPasswordResetEmail(email: _emailPhoneController.text).then((value) => {
      setState(() {
        isLoading = false;
      }),
      Utilities().successMsg('We have sent you email to recover password, please check email'),
      Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage())),
    }).onError((error, stackTrace) => {
      setState(() {
        isLoading = false;
      }),
      Utilities().errorMsg('Something went wrong, please try again later'),
    });
  }

  String verificationId = '';

  Future<void> _verifyPhoneNumber() async {
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
        this.verificationId = verificationId;
        Navigator.push(context, MaterialPageRoute(builder: (context) => SignupOTPVerification(isForgottenPass: true,emailPhone: _emailPhoneController.text.toString(), name: '', verificationId: verificationId,password: '')));
      });
    }

    codeAutoRetrievalTimeout(String verificationId) {
    }

    await _auth.verifyPhoneNumber(
      phoneNumber: _emailPhoneController.text,
      timeout: const Duration(seconds: 60),
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

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
                            child: const BoldFont(text: "Forget Password"),
                          )),
                      SizedBox(
                          width: double.infinity,
                          child: Padding(
                            padding: EdgeInsets.only(
                              left:
                              0.08 * MediaQuery.of(context).size.width,
                            ),
                            child: const NormalFont(
                                text:
                                "Please Provide your account's Email or Phone No \nfor which you want to reset your password"),
                          )),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 0.05 * MediaQuery.of(context).size.height),
                        child: Form(
                            key: _form,
                            child: Padding(
                              padding:
                              EdgeInsets.symmetric(
                                  horizontal: 0.1 *
                                      MediaQuery.of(context).size.width),
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _emailPhoneController,
                                    textAlignVertical: TextAlignVertical.center,
                                    style: const TextStyle(
                                      fontSize: 15,
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    focusNode: textFieldFocusNode,
                                    decoration: const InputDecoration(
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide:
                                        BorderSide(color: Colors.black),
                                      ),
                                      prefixIcon: Icon(
                                        Icons.email,
                                        size: 22,
                                      ),
                                      prefixIconColor: Colors.black,
                                      prefixIconConstraints: BoxConstraints(
                                        minWidth: 65,
                                      ),
                                      hintText: "Email/Phone No",
                                      focusColor: Colors.black,
                                    ),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return "Enter Email/Phone No";
                                      }
                                      else if(!_isValidEmail(_emailPhoneController.text.toString()) && !_isValidPhoneNumber(_emailPhoneController.text.toString())) {
                                        return "xyz@example.com OR +92XXXXXXXXXX";
                                      }
                                      if(_isValidEmail(_emailPhoneController.text.toString())){
                                        isEmailValid = true;
                                        isPhoneValid = false;
                                      }
                                      else if(_isValidPhoneNumber(_emailPhoneController.text.toString())){
                                        isPhoneValid = true;
                                        isEmailValid = false;
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            )),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (textFieldFocusNode.hasFocus) {
                            textFieldFocusNode.unfocus();
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: 0.03 * MediaQuery.of(context).size.height),
                          child: SizedBox(
                            width: 300,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    if (textFieldFocusNode.hasFocus) {
                                      textFieldFocusNode.unfocus();
                                    }
                                    if (_form.currentState!.validate()) {
                                      setState(() {
                                        isLoading = true;
                                      });
                                      if(isEmailValid) {
                                        _sendVerificationEmail();
                                      }
                                      else if(isPhoneValid) {
                                        _verifyPhoneNumber();
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                      fixedSize: const Size(200, 20),
                                      backgroundColor: Colors.blue,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(15))),
                                  child: isLoading
                                      ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                          color: Colors.blue,
                                          height: 20,
                                          width: 20,
                                          child: const SpinKitCircle(color: Colors.white,size: 20)),
                                      const SizedBox(width: 5,),
                                      const Text('Loading',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'roboto',
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          )),
                                    ],
                                  )
                                      : const Text('Next',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'roboto',
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      )),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
            ),
          ],
        ));
  }
}