import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lawhub/LoginSignup_Pages/LoginPage.dart';
import 'package:lawhub/Utils/Utilities.dart';
import 'package:lawhub/widgets/Fonts.dart';
import '../widgets/Themes.dart';

class ChangePassword extends StatefulWidget{
  final String phone;
  const ChangePassword({super.key, required this.phone});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {

  final TextEditingController _passwordController  = TextEditingController();
  final TextEditingController _confirmPasswordController  = TextEditingController();

  final _form = GlobalKey<FormState>();

  bool isLoading = false;

  final textFieldFocusNode = FocusNode();
  bool _obscured = true;
  void _toggleObscured() {
    setState(() {
      _obscured = !_obscured;
      if (textFieldFocusNode.hasPrimaryFocus) {
        return; // If focus is on text field, don't unfocused
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
        return; // If focus is on text field, don't unfocused
      }
      textFieldFocusNode2.canRequestFocus =
      false; // Prevents focus if tap on eye
    });
  }

  void _updateUserPassword(String password) async {
    await FirebaseFirestore.instance.collection('Users').doc('${widget.phone}@gmail.com').update({'password': password});
    Utilities().successMsg('Your Password has been successfully changed');
    setState(() {
      isLoading = false;
    });
    Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  void _updateLawyerPassword(String password) async {
    await FirebaseFirestore.instance.collection('Lawyers').doc('${widget.phone}@gmail.com').update({'password': password});
    Utilities().successMsg('Your Password has been successfully changed');
    setState(() {
      isLoading = false;
    });
    Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
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
                                  child: const BoldFont(text: "New Password"),
                                )),
                            SizedBox(
                                width: double.infinity,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    left:
                                    0.08 * MediaQuery.of(context).size.width,
                                  ),
                                  child: const NormalFont(
                                      text: "Your identity has been verified! \nSet your new password"),
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
                            ),
                            GestureDetector(
                              onTap: () {
                                if (textFieldFocusNode.hasFocus) {
                                  textFieldFocusNode.unfocus();
                                }
                                if (textFieldFocusNode2.hasFocus) {
                                  textFieldFocusNode2.unfocus();
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
                                          if (textFieldFocusNode.hasFocus) {
                                            textFieldFocusNode.unfocus();
                                          }
                                          if (textFieldFocusNode2.hasFocus) {
                                            textFieldFocusNode2.unfocus();
                                          }
                                          if (_form.currentState!.validate()) {
                                            setState(() {
                                              isLoading = true;
                                            });

                                            var documentUser = await FirebaseFirestore.instance.collection('Users').doc('${widget.phone}@gmail.com').get();
                                            if(documentUser.exists) {
                                              _updateUserPassword(_confirmPasswordController.text.toString());
                                            }

                                            var documentLawyer = await FirebaseFirestore.instance.collection('Lawyers').doc('${widget.phone}@gmail.com').get();
                                            if(documentLawyer.exists) {
                                              _updateLawyerPassword(_confirmPasswordController.text.toString());
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
                            const SizedBox()
                          ],
                        )
                    ),
                  )
                ],
              ),
            )
          ],
        ),


    );
  }
}