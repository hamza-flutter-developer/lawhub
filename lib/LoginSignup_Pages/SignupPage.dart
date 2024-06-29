import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lawhub/LoginSignup_Pages/SignupOTPVerification.dart';
import 'package:lawhub/Utils/Utilities.dart';
import 'package:lawhub/LoginSignup_Pages/VerifyEmail.dart';
import 'package:lawhub/widgets/Fonts.dart';
import 'package:lawhub/widgets/Themes.dart';
import 'LoginPage.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailPhoneController = TextEditingController();
  final TextEditingController _passwordController  = TextEditingController();
  final TextEditingController _confirmPasswordController  = TextEditingController();

  final _form = GlobalKey<FormState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isLoading = false;

  void _sendVerificationEmail() async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailPhoneController.text,
        password: _passwordController.text,
      );
      User? user = userCredential.user;
      if (user != null) {
        await user.sendEmailVerification();
        setState(() {
          isLoading = false;
          Navigator.push(context, MaterialPageRoute(builder: (context) => VerifyEmail(email: _emailPhoneController.text.toString(), name: _nameController.text.toString())));
        });
      }
    } on FirebaseAuthException catch (e) {
      if(e.code == "ERROR_EMAIL_ALREADY_IN_USE" || e.code == "account-exists-with-different-credential" || e.code == "email-already-in-use") {
        _auth.signInWithEmailAndPassword(email: _emailPhoneController.text, password: _passwordController.text);
        setState(() {
          User? userCheck = _auth.currentUser;
          debugPrint(_auth.currentUser?.email);
          if(!userCheck!.emailVerified) {
            userCheck.sendEmailVerification();
            setState(() {
              isLoading = false;
              Navigator.push(context, MaterialPageRoute(builder: (context) => VerifyEmail(email: _emailPhoneController.text.toString(), name: _nameController.text.toString())));
            });
          }
          else {
            Utilities().getMessageFromErrorCode(e.code);
            setState(() {
              isLoading = false;
            });
          }
        });
      }
      else {
        Utilities().getMessageFromErrorCode(e.code);
        setState(() {
          isLoading = false;
        });
      }
    }
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
        Navigator.push(context, MaterialPageRoute(builder: (context) => SignupOTPVerification(isForgottenPass: false,emailPhone: _emailPhoneController.text.toString(), name: _nameController.text.toString(), verificationId: verificationId,password: _passwordController.text)));
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

  final textFieldFocusNode = FocusNode();
  bool _obscured = true;

  void _toggleObscured() {
    setState(() {
      _obscured = !_obscured;
      if (textFieldFocusNode.hasPrimaryFocus) {
        return;
      }
      textFieldFocusNode.canRequestFocus = false;
    });
  }

  final textFieldFocusNode2 = FocusNode();
  bool _obscured2 = true;

  void _toggleObscured2() {
    setState(() {
      _obscured2 = !_obscured2;
      if (textFieldFocusNode2.hasPrimaryFocus) {
        return;
      }
      textFieldFocusNode2.canRequestFocus = false;
    });
  }

  bool isEmailValid = false;
  bool isPhoneValid = false;

  bool _isValidEmail(String email) {
    RegExp emailRegExp = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
    return emailRegExp.hasMatch(email);
  }

  bool _isValidPhoneNumber(String phoneNumber) {
    RegExp phoneRegExp = RegExp(r'^\+\d{12}$');
    return phoneRegExp.hasMatch(phoneNumber);
  }

  final textFieldFocusNode0 = FocusNode();
  final textFieldFocusNode1 = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blue,
        body: Stack(
          children: [
            Padding(
              padding:
              EdgeInsets.only(top: 0.03 * MediaQuery.of(context).size.height),
              child: TopLogo(fontColor: Colors.white),
            ),
            SafeArea(
                child: CustomScrollView(
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Container(
                          margin: EdgeInsets.only(top: 0.15 * MediaQuery.of(context).size.height),
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
                                    child: const BoldFont(text: "Complete Profile"),
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
                                        "Please Provide the Following information \nto complete account creation"),
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
                                            controller: _nameController,
                                            textAlignVertical: TextAlignVertical.center,
                                            style: const TextStyle(
                                              fontSize: 15,
                                            ),
                                            focusNode: textFieldFocusNode0,
                                            decoration: const InputDecoration(
                                              focusedBorder: UnderlineInputBorder(
                                                borderSide:
                                                BorderSide(color: Colors.black),
                                              ),
                                              prefixIcon: Icon(
                                                FontAwesomeIcons.userLarge,
                                                size: 18,
                                              ),
                                              prefixIconColor: Colors.black,
                                              prefixIconConstraints: BoxConstraints(
                                                minWidth: 65,
                                              ),
                                              hintText: "Full Name",
                                              focusColor: Colors.black,
                                            ),
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return "Enter Name";
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          TextFormField(
                                            controller: _emailPhoneController,
                                            textAlignVertical: TextAlignVertical.center,
                                            style: const TextStyle(
                                              fontSize: 15,
                                            ),
                                            focusNode: textFieldFocusNode1,
                                            keyboardType: TextInputType.emailAddress,
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
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          TextFormField(
                                            controller: _passwordController,
                                            textAlignVertical: TextAlignVertical.center,
                                            style: const TextStyle(
                                              fontSize: 15,
                                            ),
                                            obscureText: _obscured,
                                            focusNode: textFieldFocusNode,
                                            decoration: InputDecoration(
                                              focusedBorder: const UnderlineInputBorder(
                                                borderSide:
                                                BorderSide(color: Colors.black),
                                              ),
                                              prefixIcon: const Icon(
                                                Icons.lock,
                                                size: 22,
                                              ),
                                              prefixIconColor: Colors.black,
                                              prefixIconConstraints:
                                              const BoxConstraints(
                                                minWidth: 65,
                                              ),
                                              hintText: "Password",
                                              focusColor: Colors.black,
                                              suffixIcon: Padding(
                                                padding: const EdgeInsets.fromLTRB(
                                                    0, 0, 10, 0),
                                                child: GestureDetector(
                                                  onTap: _toggleObscured,
                                                  child: Icon(
                                                    _obscured
                                                        ? Icons.visibility_off_rounded
                                                        : Icons.visibility_rounded,
                                                    size: 18,
                                                  ),
                                                ),
                                              ),
                                              suffixIconColor: Colors.black,
                                            ),
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return "Enter Password";
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          TextFormField(
                                            controller: _confirmPasswordController,
                                            textAlignVertical: TextAlignVertical.center,
                                            style: const TextStyle(
                                              fontSize: 15,
                                            ),
                                            obscureText: _obscured2,
                                            focusNode: textFieldFocusNode2,
                                            decoration: InputDecoration(
                                              focusedBorder: const UnderlineInputBorder(
                                                borderSide:
                                                BorderSide(color: Colors.black),
                                              ),
                                              prefixIcon: const Icon(
                                                Icons.lock,
                                                size: 22,
                                              ),
                                              prefixIconColor: Colors.black,
                                              prefixIconConstraints:
                                              const BoxConstraints(
                                                minWidth: 65,
                                              ),
                                              hintText: "Confirm Password",
                                              focusColor: Colors.black,
                                              suffixIcon: Padding(
                                                padding: const EdgeInsets.fromLTRB(
                                                    0, 0, 10, 0),
                                                child: GestureDetector(
                                                  onTap: _toggleObscured2,
                                                  child: Icon(
                                                    _obscured2
                                                        ? Icons.visibility_off_rounded
                                                        : Icons.visibility_rounded,
                                                    size: 18,
                                                  ),
                                                ),
                                              ),
                                              suffixIconColor: Colors.black,
                                            ),
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return "Enter Confirm Password";
                                              }
                                              else if(_passwordController.text.toString() != _confirmPasswordController.text.toString()) {
                                                return "Password do not match";
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
                                  if (textFieldFocusNode2.hasFocus) {
                                    textFieldFocusNode2.unfocus();
                                  }
                                  if (textFieldFocusNode0.hasFocus) {
                                    textFieldFocusNode0.unfocus();
                                  }
                                  if (textFieldFocusNode1.hasFocus) {
                                    textFieldFocusNode1.unfocus();
                                  }
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
                                          onPressed: ()  async {
                                            if (textFieldFocusNode2.hasFocus) {
                                              textFieldFocusNode2.unfocus();
                                            }
                                            if (textFieldFocusNode0.hasFocus) {
                                              textFieldFocusNode0.unfocus();
                                            }
                                            if (textFieldFocusNode1.hasFocus) {
                                              textFieldFocusNode1.unfocus();
                                            }
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
                                              if(isPhoneValid) {
                                                var  documentUser = await FirebaseFirestore.instance.collection('Users').doc('${_emailPhoneController.text}@gmail.com').get();
                                                var  documentLawyer = await FirebaseFirestore.instance.collection('Lawyers').doc('${_emailPhoneController.text}@gmail.com').get();
                                                if(documentUser.exists || documentLawyer.exists) {
                                                  setState(() {
                                                    isLoading  = false;
                                                  });
                                                  Utilities().errorMsg('Phone no already used. Go to login page.');
                                                }
                                                else {
                                                  _verifyPhoneNumber();
                                                }

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
                              const Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Already have a Account?",
                                    style: TextStyle(
                                      fontFamily: 'roboto',
                                      fontWeight: FontWeight.w300,
                                      fontSize: 15,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => const LoginPage()));
                                    },
                                    child: const Text(
                                      "Login",
                                      style: TextStyle(
                                          fontFamily: 'roboto',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.blue),
                                    ),
                                  )
                                ],
                              )
                            ],
                          )),
                    )
                  ],
                ))
          ],
        ));
  }
}
