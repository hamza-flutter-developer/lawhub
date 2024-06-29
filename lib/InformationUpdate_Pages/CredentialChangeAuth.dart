// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lawhub/InformationUpdate_Pages/EmailPhoneUpdate.dart';
import 'package:lawhub/InformationUpdate_Pages/PasswordChange.dart';
import '../Utils/Utilities.dart';
import 'EmailUpdateVerify.dart';

class UserCredentialChangeAuth extends StatefulWidget{
  final bool isEmailPhoneChange;
  final bool isUser;
  const UserCredentialChangeAuth({Key? key, required this.isUser, required this.isEmailPhoneChange}) : super(key: key);

  @override
  State<UserCredentialChangeAuth> createState() => _UserCredentialChangeAuthState();
}

class _UserCredentialChangeAuthState extends State<UserCredentialChangeAuth> {

  final TextEditingController _emailPhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _form = GlobalKey<FormState>();

  final textFieldFocusNode = FocusNode();
  final textFieldFocusNode1 = FocusNode();
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

  bool isLoading = false;

  final _auth = FirebaseAuth.instance;

  void loginUserChangeEmail(){
    _auth.signInWithEmailAndPassword(email: _emailPhoneController.text, password: _passwordController.text).then((value) => {
      setState(() {
        isLoading = false;
      }),
    Navigator.push(context, MaterialPageRoute(builder: (context) => UserEmailPhoneUpdate(isForgottenPass: false, isUser: widget.isUser, emailPhone: _emailPhoneController.text.toString(),password: _passwordController.text.toString(),))),
    }).onError((error, stackTrace) => {
      setState(() {
        isLoading = false;
      }),
      Utilities().errorMsg('Wrong Credentials'),
    });
  }

  void loginUserEmailChangePassword(){
    _auth.signInWithEmailAndPassword(email: _emailPhoneController.text, password: _passwordController.text).then((value) => {
      setState(() {
        isLoading = false;
      }),
      _auth.sendPasswordResetEmail(email: _emailPhoneController.text).then((value) => {
        setState(() {
          isLoading = false;
        }),
        Utilities().successMsg('We have sent you email to change your password, please check email'),
      Navigator.push(context, MaterialPageRoute(builder: (context) => UserEmailUpdateVerify(isUser: widget.isUser,isForgottenPass: false, isPasswordChange: true, oldEmail: _emailPhoneController.text.toString(), newEmail: '', password: _passwordController.text))),
      }).onError((error, stackTrace) => {
        setState(() {
          isLoading = false;
        }),
        Utilities().errorMsg('Something went wrong, please try again later'),
      }),
      }).onError((error, stackTrace) => {
        setState(() {
          isLoading = false;
        }),
        Utilities().errorMsg('Wrong Credentials'),
    });
  }

  void loginUserPhoneChangePhone(String phone, String password, String firstPass){
    if(_emailPhoneController.text.toString() == phone && _passwordController.text.toString() == password) {
      _auth.signInWithEmailAndPassword(email: '$phone@gmail.com', password: firstPass).then((value) => {
        Navigator.push(context, MaterialPageRoute(builder: (context) => UserEmailPhoneUpdate(isForgottenPass: false, isUser: widget.isUser, emailPhone: _emailPhoneController.text.toString(),password: _passwordController.text.toString(),))),
        setState(() {
          isLoading = false;
        })
      }).onError((error, stackTrace) => {
        setState(() {
          isLoading = false;
        }),
        debugPrint(error.toString()),
        Utilities().errorMsg('Something went wrong, please try again later.'),
      });
    }
    else {
      setState(() {
        isLoading = false;
      });
      Utilities().errorMsg('Wrong Credentials');
    }
  }

  void loginUserPhoneChangePassword(String phone, String password, String firstPass){
    if(_emailPhoneController.text.toString() == phone && _passwordController.text.toString() == password) {
      _auth.signInWithEmailAndPassword(email: '$phone@gmail.com', password: firstPass).then((value) => {
        Navigator.push(context, MaterialPageRoute(builder: (context) => UserPasswordChangePhone(isUser: widget.isUser, phone: _emailPhoneController.text.toString()))),
        setState(() {
          isLoading = false;
        })
      }).onError((error, stackTrace) => {
        setState(() {
          isLoading = false;
        }),
        debugPrint(error.toString()),
        Utilities().errorMsg('Something went wrong, please try again later.'),
      });
    }
    else {
      setState(() {
        isLoading = false;
      });
      Utilities().errorMsg('Wrong Credentials');
    }
  }

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
              icon: const Icon(FontAwesomeIcons.angleLeft,color: Colors.white,),
              onPressed: () {
                // Navigate back to the previous page or screen
                Navigator.of(context).pop();
              },
            ),
          ),
          title: widget.isEmailPhoneChange
            ? const Padding(
            padding: EdgeInsets.only(top: 13),
            child: Text(
              "Email/Phone Update",
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
              "Password Update",
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
      body: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 30,
                    top: 40,
                    bottom: 10,
                  ),
                  child: Text(
                    "Please Enter your Login Credential:",
                    style: TextStyle(
                      fontFamily: 'roboto',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )),
            Padding(
              padding: EdgeInsets.only(
                  top: 0.02 * MediaQuery.of(context).size.height),
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
                          focusNode: textFieldFocusNode1,
                          style: const TextStyle(
                            fontSize: 15,
                          ),
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
                          focusNode: textFieldFocusNode,
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
                        Navigator.push(context, MaterialPageRoute(builder: (context) => UserEmailPhoneUpdate(isForgottenPass: true, isUser: widget.isUser, emailPhone: '',password: '',)));
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
          ],
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: () {
          if (textFieldFocusNode.hasFocus) {
            textFieldFocusNode.unfocus();
          }
          if (textFieldFocusNode1.hasFocus) {
            textFieldFocusNode1.unfocus();
          }
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 35),
          child: SizedBox(
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () async {
                    if (textFieldFocusNode.hasFocus) {
                      textFieldFocusNode.unfocus();
                    }
                    if (textFieldFocusNode1.hasFocus) {
                      textFieldFocusNode1.unfocus();
                    }
                    if (_form.currentState!.validate()) {
                      setState(() {
                        isLoading = true;
                      });
                      if(isEmailValid) {
                        if(widget.isEmailPhoneChange) {
                          loginUserChangeEmail();
                        }
                        else {
                          loginUserEmailChangePassword();
                        }
                      }
                      else{
                        if(widget.isEmailPhoneChange) {
                          var  documentUser = await FirebaseFirestore.instance.collection('Users').doc("${_emailPhoneController.text}@gmail.com").get();
                          if(documentUser.exists) {
                            loginUserPhoneChangePhone(documentUser.get('emailPhone').toString(),documentUser.get('password').toString(),documentUser.get('firstPass').toString());
                          }
                          var  documentLawyers = await FirebaseFirestore.instance.collection('Lawyers').doc("${_emailPhoneController.text}@gmail.com").get();
                          if(documentLawyers.exists) {
                            loginUserPhoneChangePhone(documentLawyers.get('emailPhone').toString(),documentLawyers.get('password').toString(),documentLawyers.get('firstPass').toString());
                          }
                        }
                        else {
                          var documentUserPhone = await FirebaseFirestore.instance.collection('Users').doc("${_emailPhoneController.text}@gmail.com").get();
                          if(documentUserPhone.exists) {
                            loginUserPhoneChangePassword(documentUserPhone.get('emailPhone').toString(),documentUserPhone.get('password').toString(),documentUserPhone.get('firstPass').toString());
                          }
                          var documentLawyerPhone = await FirebaseFirestore.instance.collection('Lawyers').doc("${_emailPhoneController.text}@gmail.com").get();
                          if(documentLawyerPhone.exists) {
                            loginUserPhoneChangePassword(documentLawyerPhone.get('emailPhone').toString(),documentLawyerPhone.get('password').toString(),documentLawyerPhone.get('firstPass').toString());
                          }
                          else {
                            setState(() {
                              isLoading = false;
                            });
                            Utilities().errorMsg('Wrong Credentials');
                          }
                        }
                      }
                    }
                  },
                    child: isLoading
                        ? Container(
                        height: 40,
                        width: 300,
                        decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(15)
                        ),
                        child: Row(
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
                    )
                        : Container(
                      height: 40,
                      width: 300,
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(15)
                      ),
                      child: const Center(child: Text('Next',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'roboto',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          )),),
                    )
                )
              ],
            ),
          ),
        ),
      ),

    );
  }
}