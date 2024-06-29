// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lawhub/User_Pages/UserAppBar&NavBar.dart';
import 'package:lawhub/LoginSignup_Pages/ForgetPassword.dart';
import 'package:lawhub/Utils/Utilities.dart';
import 'package:lawhub/widgets/Fonts.dart';
import 'package:lawhub/widgets/Themes.dart';
import '../Lawyer_Pages/LawyerAppBar&NavBar.dart';
import 'SignupPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}


class _LoginPageState extends State<LoginPage> {

  final TextEditingController _emailPhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _auth = FirebaseAuth.instance;

  bool isLoading = false;

  final _form = GlobalKey<FormState>();

  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();
  bool _obscured = true;

  void _toggleObscured() {
    setState(() {
      _obscured = !_obscured;
      if (emailFocusNode.hasPrimaryFocus) {
        return;
      }
      emailFocusNode.canRequestFocus = false;
    });
  }

  bool _isValidEmail(String email) {
    // Use a simple RegExp for email validation
    RegExp emailRegExp = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
    return emailRegExp.hasMatch(email);
  }

  bool _isValidPhoneNumber(String phoneNumber) {
    // Use a simple RegExp for phone number validation
    RegExp phoneRegExp = RegExp(r'^\+\d{12}$');
    return phoneRegExp.hasMatch(phoneNumber);
  }

  bool isEmailValid = false;
  bool isPhoneValid = false;

  int checkEmailPhone = 0;

  void loginUserEmail(){
    _auth.signInWithEmailAndPassword(email: _emailPhoneController.text, password: _passwordController.text).then((value) => {
      Utilities().successMsg("Authentication Successful"),
      Navigator.push(context, MaterialPageRoute(builder: (context) => const UserAppBarNavBar())),
      setState(() {
        checkEmailPhone = 0;
        isLoading = false;
      })
    }).onError((error, stackTrace) => {
      setState(() {
        checkEmailPhone = 0;
        isLoading = false;
      }),
      Utilities().errorMsg('Wrong Credentials')
    });
    }

  void loginLawyerEmail(){
    _auth.signInWithEmailAndPassword(email: _emailPhoneController.text, password: _passwordController.text).then((value) => {
      Utilities().successMsg("Authentication Successful"),
      Navigator.push(context, MaterialPageRoute(builder: (context) => const LawyerAppbarNavBar())),
      setState(() {
        checkEmailPhone = 0;
        isLoading = false;
      })
    }).onError((error, stackTrace) => {
      setState(() {
        checkEmailPhone = 0;
        isLoading = false;
      }),
      Utilities().errorMsg('Wrong Credentials')
    });
  }

  void loginUserPhone(String phone, String password, String firstPass){
    if(_emailPhoneController.text.toString() == phone && _passwordController.text.toString() == password) {
      _auth.signInWithEmailAndPassword(email: '$phone@gmail.com', password: firstPass).then((value) => {
        Utilities().successMsg("Authentication Successful"),
        Navigator.push(context, MaterialPageRoute(builder: (context) => const UserAppBarNavBar())),
        setState(() {
          checkEmailPhone = 0;
          isLoading = false;
        })
      }).onError((error, stackTrace) => {
        setState(() {
          checkEmailPhone = 0;
          isLoading = false;
        }),
        debugPrint(error.toString()),
        Utilities().errorMsg('Something went wrong, please try again later.'),
      });
    }
    else {
      setState(() {
        checkEmailPhone = 0;
        isLoading = false;
      });
      Utilities().errorMsg('Wrong Credentials');
    }
  }

  void loginLawyerPhone(String phone, String password, String firstPass){
    if(_emailPhoneController.text.toString() == phone && _passwordController.text.toString() == password) {
      _auth.signInWithEmailAndPassword(email: '$phone@gmail.com', password: firstPass).then((value) => {
        Utilities().successMsg("Authentication Successful"),
        Navigator.push(context, MaterialPageRoute(builder: (context) => const LawyerAppbarNavBar())),
        setState(() {
          checkEmailPhone = 0;
          isLoading = false;
        })
      }).onError((error, stackTrace) => {
        setState(() {
          checkEmailPhone = 0;
          isLoading = false;
        }),
        Utilities().errorMsg('Something went wrong, please try again later.'),
      });
    }
    else {
      setState(() {
        checkEmailPhone = 0;
        isLoading = false;
      });
      Utilities().errorMsg('Wrong Credentials');
    }
  }

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
                      margin: EdgeInsets.only(
                          top: 0.15 * MediaQuery.of(context).size.height),
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
                                        MediaQuery.of(context).size.height),
                                child: const BoldFont(text: "Login"),
                              )),
                          SizedBox(
                              width: double.infinity,
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left:
                                  0.08 * MediaQuery.of(context).size.width,
                                ),
                                child: const NormalFont(
                                    text: "Please sign in to continue"),
                              )),
                          Padding(
                            padding: EdgeInsets.only(
                                top: 0.05 * MediaQuery.of(context).size.height),
                            child: Form(
                                key: _form,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
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
                                        focusNode: emailFocusNode,
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
                                            setState(() {
                                              isEmailValid = true;
                                              isPhoneValid = false;
                                            });
                                          }
                                          else if(_isValidPhoneNumber(_emailPhoneController.text.toString())){
                                            setState(() {
                                              isPhoneValid = true;
                                              isEmailValid = false;
                                            });
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      TextFormField(
                                        controller: _passwordController,
                                        textAlignVertical:
                                        TextAlignVertical.center,
                                        style: const TextStyle(
                                          fontSize: 15,
                                        ),
                                        obscureText: _obscured,
                                        focusNode: passwordFocusNode,
                                        decoration: InputDecoration(
                                          focusedBorder:
                                          const UnderlineInputBorder(
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
                                                    ? Icons
                                                    .visibility_off_rounded
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
                                    ],
                                  ),
                                )),
                          ),
                          SizedBox(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right:
                                  0.065 * MediaQuery.of(context).size.width,
                                ),
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const ForgetPassword()));
                                    },
                                    child: const Text(
                                      "Forgotten Password?",
                                      style: TextStyle(
                                        fontFamily: 'roboto',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ),
                              )),
                          GestureDetector(
                            onTap: () {
                              if (emailFocusNode.hasFocus) {
                                emailFocusNode.unfocus();
                              }
                              if (passwordFocusNode.hasFocus) {
                                passwordFocusNode.unfocus();
                              }
                            },
                            child: Padding(
                              padding: EdgeInsets.only(
                                  top: 0.03 * MediaQuery.of(context).size.height),
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (emailFocusNode.hasFocus) {
                                    emailFocusNode.unfocus();
                                  }
                                  if (passwordFocusNode.hasFocus) {
                                    passwordFocusNode.unfocus();
                                  }

                                  if(_form.currentState!.validate()) {
                                    setState(() {
                                      isLoading = true;
                                    });

                                    var  documentUserEmail = await FirebaseFirestore.instance.collection('Users').doc(_emailPhoneController.text).get();

                                    if(documentUserEmail.exists) {
                                      if(isEmailValid) {
                                        setState(() {
                                          checkEmailPhone = 0;
                                        });
                                        loginUserEmail();
                                      }
                                    }
                                    else {
                                      checkEmailPhone = checkEmailPhone + 1;
                                    }

                                    var  documentLawyerEmail = await FirebaseFirestore.instance.collection('Lawyers').doc(_emailPhoneController.text).get();

                                    if(documentLawyerEmail.exists) {
                                      if(isEmailValid) {
                                        setState(() {
                                          checkEmailPhone = 0;
                                        });
                                        loginLawyerEmail();
                                      }
                                    }
                                    else {
                                      checkEmailPhone = checkEmailPhone + 1;
                                    }


                                    var  documentUserPhone = await FirebaseFirestore.instance.collection('Users').doc("${_emailPhoneController.text}@gmail.com").get();

                                    if(documentUserPhone.exists) {
                                      if(isPhoneValid) {
                                        setState(() {
                                          checkEmailPhone = 0;
                                        });
                                        loginUserPhone(documentUserPhone.get('emailPhone').toString(),documentUserPhone.get('password').toString(),documentUserPhone.get('firstPass').toString());
                                      }
                                    }
                                    else {
                                      checkEmailPhone = checkEmailPhone + 1;
                                    }

                                    var  documentLawyerPhone = await FirebaseFirestore.instance.collection('Lawyers').doc("${_emailPhoneController.text}@gmail.com").get();

                                    if(documentLawyerPhone.exists){
                                      if(isPhoneValid) {
                                        setState(() {
                                          checkEmailPhone = 0;
                                        });
                                        loginLawyerPhone(documentLawyerPhone.get('emailPhone').toString(),documentLawyerPhone.get('password').toString(),documentLawyerPhone.get('firstPass').toString());
                                      }
                                    }
                                    else {
                                      checkEmailPhone = checkEmailPhone + 1;
                                    }

                                    if(checkEmailPhone == 4) {
                                      setState(() {
                                        isLoading = false;
                                      });
                                      Utilities().errorMsg(isEmailValid ? "No account found with the provided Email Address" : "No account found with the provided Phone Number");
                                      checkEmailPhone = 0;
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                    fixedSize: const Size(200, 20),
                                    backgroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15))),
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
                                    : const Text('Login',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'roboto',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    )),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don't have an Account?",
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
                                          builder: (context) =>
                                          const SignUpPage()));
                                },
                                child: const Text(
                                  "Sign up",
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
            ),
          ),
        ],
      ),
    );
  }
}
