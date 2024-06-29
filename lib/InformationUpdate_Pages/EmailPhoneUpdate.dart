import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lawhub/InformationUpdate_Pages/EmailUpdateVerify.dart';
import 'package:lawhub/InformationUpdate_Pages/PhoneUpdateOTP.dart';
import 'package:lawhub/Utils/Utilities.dart';

class UserEmailPhoneUpdate extends StatefulWidget{
  final String emailPhone;
  final String password;
  final bool isForgottenPass;
  final bool isUser;
  const UserEmailPhoneUpdate({Key? key, required this.isForgottenPass, required this.isUser, required this.emailPhone, required this.password}) : super(key: key);

  @override
  State<UserEmailPhoneUpdate> createState() => _UserEmailPhoneUpdateState();
}

class _UserEmailPhoneUpdateState extends State<UserEmailPhoneUpdate> {

  final TextEditingController _emailPhoneController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final _form = GlobalKey<FormState>();

  bool isEmailValid = false;
  bool isPhoneValid = false;

  bool isPreEmailValid = false;
  @override
  void initState() {
    isPreEmailValid = _isValidEmail(widget.emailPhone);
    super.initState();
  }

  bool _isValidEmail(String email) {
    RegExp emailRegExp = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
    return emailRegExp.hasMatch(email);
  }

  bool _isValidPhoneNumber(String phoneNumber) {
    RegExp phoneRegExp = RegExp(r'^\+\d{12}$');
    return phoneRegExp.hasMatch(phoneNumber);
  }

  final textFieldFocusNode = FocusNode();

  bool isLoading = false;

  void changeUserEmailTOEmail() async {
    try {
      FirebaseAuth.instance.signInWithEmailAndPassword(email: widget.emailPhone, password: widget.password).then((userCredential) {
        userCredential.user?.verifyBeforeUpdateEmail(_emailPhoneController.text.toString()).then((value) {
          setState(() {
            isLoading = false;
          });
          Navigator.push(context, MaterialPageRoute(builder: (context) => UserEmailUpdateVerify(isUser: widget.isUser,isForgottenPass: false, isPasswordChange: false, oldEmail: widget.emailPhone, newEmail: _emailPhoneController.text.toString(), password: widget.password)));
        });


      });
    } catch (e) {
      Utilities().errorMsg(e.toString());
    }
  }

  void changeUserEmailTOPhone() async {
    try {
      FirebaseAuth.instance.signInWithEmailAndPassword(email: '${widget.emailPhone}@gmail.com', password: widget.password).then((userCredential) {
        userCredential.user?.verifyBeforeUpdateEmail(_emailPhoneController.text.toString()).then((value) {
          setState(() {
            isLoading = false;
          });
          Navigator.push(context, MaterialPageRoute(builder: (context) => UserEmailUpdateVerify(isUser: widget.isUser,isForgottenPass: false, isPasswordChange: false, oldEmail: widget.emailPhone, newEmail: _emailPhoneController.text.toString(), password: widget.password)));
        });


      });
    } catch (e) {
      Utilities().errorMsg(e.toString());
    }
  }

  String verificationId = '';

  Future<void> changeUserPhoneNumber() async {
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
        Navigator.push(context, MaterialPageRoute(builder: (context) => UserPhoneUpdateOTP(isForgottenPass: false,isUser: widget.isUser, oldPhone: widget.emailPhone, newPhone: _emailPhoneController.text.toString(), verificationID: verificationId,password: widget.password)));
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

  void sendPasswordUpdateEmail() async {
    _auth.sendPasswordResetEmail(email: _emailPhoneController.text).then((value) => {
      setState(() {
        isLoading = false;
      }),
      Utilities().successMsg('We have sent you email to recover password, please check email'),
    Navigator.push(context, MaterialPageRoute(builder: (context) => UserEmailUpdateVerify(isUser: widget.isUser,isForgottenPass: true, isPasswordChange: false, oldEmail: '', newEmail: _emailPhoneController.text.toString(), password: ''))),
    }).onError((error, stackTrace) => {
      setState(() {
        isLoading = false;
      }),
      Utilities().errorMsg('Something went wrong, please try again later'),
    });
  }

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
        Navigator.push(context, MaterialPageRoute(builder: (context) => UserPhoneUpdateOTP(isUser: widget.isUser, isForgottenPass: true,oldPhone: _emailPhoneController.text.toString(),password: '',newPhone: '',verificationID: verificationId,)));
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
                  : isPreEmailValid
                    ? const Padding(
            padding: EdgeInsets.only(top: 13),
            child: Text(
              "Email Update",
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
      body: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            widget.isForgottenPass
              ? const SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 30,
                    top: 40,
                    bottom: 10,
                  ),
                  child: Text(
                    "Please Enter your Email/Phone:",
                    style: TextStyle(
                      fontFamily: 'roboto',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ))
              : isPreEmailValid
                ? const SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 30,
                    top: 40,
                    bottom: 10,
                  ),
                  child: Text(
                    "Please Enter your New Email:",
                    style: TextStyle(
                      fontFamily: 'roboto',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ))
                : const SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 30,
                    top: 40,
                    bottom: 10,
                  ),
                  child: Text(
                    "Please Enter your New Phone:",
                    style: TextStyle(
                      fontFamily: 'roboto',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )),
            widget.isForgottenPass
            ? Padding(
              padding: EdgeInsets.only(
                  top: 0.02 * MediaQuery.of(context).size.height),
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
            )
            : isPreEmailValid
              ? Padding(
              padding: EdgeInsets.only(
                  top: 0.02 * MediaQuery.of(context).size.height),
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
                            hintText: "Email",
                            focusColor: Colors.black,
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Enter Email";
                            }
                            else if(_isValidPhoneNumber(_emailPhoneController.text.toString())) {
                              return "Please Enter a valid Email";
                            }
                            else if(!_isValidEmail(_emailPhoneController.text.toString())) {
                              return "xyz@example.com";
                            }
                            if(_isValidEmail(_emailPhoneController.text.toString())){
                              isEmailValid = true;
                              isPhoneValid = false;
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  )),
            )
              : Padding(
              padding: EdgeInsets.only(
                  top: 0.02 * MediaQuery.of(context).size.height),
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
                              Icons.phone,
                              size: 22,
                            ),
                            prefixIconColor: Colors.black,
                            prefixIconConstraints: BoxConstraints(
                              minWidth: 65,
                            ),
                            hintText: "Phone No",
                            focusColor: Colors.black,
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Enter Phone No";                            }
                            else if(_isValidEmail(_emailPhoneController.text.toString())) {
                              return "Please Enter a valid Phone No";
                            }
                            else if(!_isValidPhoneNumber(_emailPhoneController.text.toString())) {
                              return "+92XXXXXXXXXX";
                            }
                            if(_isValidPhoneNumber(_emailPhoneController.text.toString())){
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
          ],
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: () {
          if (textFieldFocusNode.hasFocus) {
            textFieldFocusNode.unfocus();
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
                    if (_form.currentState!.validate()) {
                      setState(() {
                        isLoading = true;
                      });
                      if(isEmailValid) {
                        if(widget.isForgottenPass) {
                          sendPasswordUpdateEmail();
                        }
                        else {
                          var  documentUser = await FirebaseFirestore.instance.collection('Users').doc(_emailPhoneController.text).get();
                          var  documentLawyer = await FirebaseFirestore.instance.collection('Lawyers').doc(_emailPhoneController.text).get();
                          if(documentUser.exists || documentLawyer.exists) {
                            setState(() {
                              isLoading  = false;
                            });
                            Utilities().errorMsg('Email already used');
                          }
                          else {
                            changeUserEmailTOEmail();
                          }
                        }
                      }
                      else{
                        if(widget.isForgottenPass) {
                          _verifyPhoneNumber();
                        }
                        else {
                          var  documentUser = await FirebaseFirestore.instance.collection('Users').doc('${_emailPhoneController.text}@gmail.com').get();
                          var  documentLawyer = await FirebaseFirestore.instance.collection('Lawyers').doc('${_emailPhoneController.text}@gmail.com').get();
                          if(documentUser.exists || documentLawyer.exists) {
                            setState(() {
                              isLoading  = false;
                            });
                            Utilities().errorMsg('Phone no already used');
                          }
                          else {
                            changeUserPhoneNumber();
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