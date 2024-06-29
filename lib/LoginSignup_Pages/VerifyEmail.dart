import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lawhub/LoginSignup_Pages/UserType.dart';
import 'package:lawhub/Utils/Utilities.dart';
import 'package:lawhub/widgets/Themes.dart';

class VerifyEmail extends StatefulWidget{
  final String email;
  final String name;
  const VerifyEmail({super.key, required this.email, required this.name});

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Timer _verificationTimer;

  bool isResend = false;

  @override
  void initState() {
    super.initState();
    _verificationTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkEmailVerificationStatus();
    });
  }

  Future<void> _checkEmailVerificationStatus() async {
    User? user = _auth.currentUser;

    if (user != null) {
      user.reload();
      user = _auth.currentUser; // Refresh user data
      if (user!.emailVerified) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => UserType(email: widget.email, name: widget.name, password: '',)));
        _verificationTimer.cancel();
      }
    }
  }

  @override
  void dispose() {
    _verificationTimer.cancel();
    super.dispose();
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
                      Padding(
                        padding: EdgeInsets.only(top: 0.07 * MediaQuery.of(context).size.height),
                        child: Center(
                          child: SizedBox(
                              width: 0.65 * MediaQuery.of(context).size.width,
                              height: 0.65 * MediaQuery.of(context).size.width,
                              child: Image.asset("assets/images/email.jpg"),),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 0.02 * MediaQuery.of(context).size.height),
                        child: const Center(child: Text('Confirm your Email Address', style: TextStyle(
                          fontFamily: "roboto",
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),)),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 0.02 * MediaQuery.of(context).size.height),
                        child: const Center(child: Text("We sent a Confirmation Email to:", style: TextStyle(
                          fontFamily: "roboto",
                          fontSize: 16,
                        ),)),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 0.015 * MediaQuery.of(context).size.height),
                        child: Center(child: Text(widget.email, style: const TextStyle(
                          fontFamily: "roboto",
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),)),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 0.015 * MediaQuery.of(context).size.height),
                        child: const Center(child: Text("Check your email and click on the", style: TextStyle(
                          fontFamily: "roboto",
                          fontSize: 16,
                        ),)),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 0.000 * MediaQuery.of(context).size.height),
                        child: const Center(child: Text("confirmation link to continue.", style: TextStyle(
                          fontFamily: "roboto",
                          fontSize: 16,
                        ),)),
                      ),
                      const Expanded(child: SizedBox()),
                      Padding(
                        padding: EdgeInsets.only(bottom: 0.015 * MediaQuery.of(context).size.height),
                        child: TextButton(
                          onPressed: () async {
                            try {
                              await _auth.currentUser?.sendEmailVerification();
                              Utilities().successMsg("Confirmation Email resent to ${widget.email}");
                            } catch (e){
                              Utilities().errorMsg("Service not available please try again after 1 minute");
                            }
                          },
                          child: const Text('Resend Email',
                              style: TextStyle(
                                color: Colors.blue,
                                fontFamily: 'roboto',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              )),
              
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                    ],
                  )),
            ),
          ],
        ));
  }
}