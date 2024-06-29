// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lawhub/InformationUpdate_Pages/InfoUpdated.dart';

class UserPasswordChangePhone extends StatefulWidget{
  final bool isUser;
  final String phone;
  const UserPasswordChangePhone({Key? key, required this.isUser, required this.phone}) : super(key: key);

  @override
  State<UserPasswordChangePhone> createState() => _UserPasswordChangePhoneState();
}

class _UserPasswordChangePhoneState extends State<UserPasswordChangePhone> {

  final TextEditingController _passwordController  = TextEditingController();
  final TextEditingController _confirmPasswordController  = TextEditingController();

  final _form = GlobalKey<FormState>();

  final textFieldFocusNode = FocusNode();
  bool _obscured = true;
  void _toggleObscured() {
    setState(() {
      _obscured = !_obscured;
      if (textFieldFocusNode.hasPrimaryFocus) {
        return;
      }
      textFieldFocusNode.canRequestFocus =
      false; // Prevents focus if tap on eye
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
      textFieldFocusNode2.canRequestFocus =
      false;
    });
  }

  bool isLoading = false;

  void _updateUserPassword(String password) async {
    await FirebaseFirestore.instance.collection('Users').doc('${widget.phone}@gmail.com').update({'password': password});
    setState(() {
      isLoading = false;
    });
    Navigator.push(context, MaterialPageRoute(builder: (context) => UserInfoUpdated(text: 'Password', isUser: widget.isUser)));
  }

  void _updateLawyerPassword(String password) async {
    await FirebaseFirestore.instance.collection('Lawyers').doc('${widget.phone}@gmail.com').update({'password': password});
    setState(() {
      isLoading = false;
    });
    Navigator.push(context, MaterialPageRoute(builder: (context) => UserInfoUpdated(text: 'Password', isUser: widget.isUser)));
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
          title: const Padding(
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
      body: SingleChildScrollView(
        child: SizedBox(
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
                      bottom: 30,
                    ),
                    child: Text(
                      "Change Password:",
                      style: TextStyle(
                        fontFamily: 'roboto',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )),
              Form(
                  key: _form,
                  child: Padding(
                    padding:
                    EdgeInsets.symmetric(
                        horizontal: 0.1 *
                            MediaQuery.of(context).size.width),
                    child: Column(
                      children: [
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
                            hintText: "New Password",
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
            ],
          ),
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: () {
          if (textFieldFocusNode.hasFocus) {
            textFieldFocusNode.unfocus();
          }
          if (textFieldFocusNode2.hasFocus) {
            textFieldFocusNode2.unfocus();
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
                  onTap: () {
                    setState(() {
                      isLoading = true;
                    });
                    if (textFieldFocusNode.hasFocus) {
                      textFieldFocusNode.unfocus();
                    }
                    if (textFieldFocusNode2.hasFocus) {
                      textFieldFocusNode2.unfocus();
                    }
                    if(widget.isUser) {
                      _updateUserPassword(_confirmPasswordController.text.toString());
                    }
                    else {
                      _updateLawyerPassword(_confirmPasswordController.text.toString());
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