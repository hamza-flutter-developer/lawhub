// ignore_for_file: file_names

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lawhub/Lawyer_Pages/LawyerAppBar&NavBar.dart';
import 'package:lawhub/User_Pages/UserAppBar&NavBar.dart';
import 'package:lawhub/Utils/Utilities.dart';
import 'InfoUpdated.dart';

class UserEmailUpdateVerify extends StatefulWidget{
  final bool isUser;
  final bool isPasswordChange;
  final bool isForgottenPass;
  final String oldEmail;
  final String newEmail;
  final String password;
  const UserEmailUpdateVerify({Key? key, required this.isUser, required this.isForgottenPass, required this.oldEmail, required this.newEmail, required this.password, required this.isPasswordChange}) : super(key: key);

  @override
  State<UserEmailUpdateVerify> createState() => _UserEmailUpdateVerifyState();
}

class _UserEmailUpdateVerifyState extends State<UserEmailUpdateVerify> {

  bool isResend = false;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _checkEmailVerificationStatusUser() async {
    FirebaseAuth.instance.signInWithEmailAndPassword(email: widget.newEmail, password: widget.password).then((userCredential) {
      updateDocumentUser();
      updateDocumentUserFavourite();
      Navigator.push(context, MaterialPageRoute(builder: (context) => UserInfoUpdated(text: 'Email', isUser: widget.isUser)));
    }).onError((error, stackTrace) {
      setState(() {
        isLoading = false;
      });
      Utilities().errorMsg('Your Email in not verified please verify your Email!');
    });
  }

  Future<void> updateDocumentUser() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    firestore.collection("Users").doc(widget.oldEmail).get().then((doc) {
      if (doc.exists) {
        var data = doc.data();
        firestore.collection("Users").doc(widget.newEmail).set(data!).then((value) {
          firestore.collection("Users").doc(widget.oldEmail).delete();
        });
        firestore.collection("Users").doc(widget.newEmail).update({'id': widget.newEmail, 'emailPhone': widget.newEmail});
      }
      else{
        debugPrint('Something went Wrong');
      }
    });
  }

  Future<void> updateDocumentUserFavourite() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    firestore.collection("Favourite").doc(widget.oldEmail).get().then((doc) {
      if (doc.exists) {
        var data = doc.data();
        firestore.collection("Favourite").doc(widget.newEmail).set(data!).then((value) {
          firestore.collection("Favourite").doc(widget.oldEmail).delete();
        });
      }
      else{
        debugPrint('Something went Wrong');
      }
    });
  }

  Future<void> _checkEmailVerificationStatusLawyer() async {
    FirebaseAuth.instance.signInWithEmailAndPassword(email: widget.newEmail, password: widget.password).then((userCredential) {
      updateDocumentLawyer();
      updateFavouriteDocumentsLawyer();
      updateDocumentLawyerArticle();
      Navigator.push(context, MaterialPageRoute(builder: (context) => UserInfoUpdated(text: 'Email', isUser: widget.isUser)));
      updateDocumentLawyer();
    }).onError((error, stackTrace) {
      setState(() {
        isLoading = false;
      });
      Utilities().errorMsg('Your Email in not verified please verify your Email!');
    });
  }

  Future<void> updateDocumentLawyer() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    firestore.collection("Lawyers").doc(widget.oldEmail).get().then((doc) {
      if (doc.exists) {
        var data = doc.data();
        firestore.collection("Lawyers").doc(widget.newEmail).set(data!).then((value) {
          firestore.collection("Lawyers").doc(widget.oldEmail).delete();
        });
        firestore.collection("Lawyers").doc(widget.newEmail).update({'id': widget.newEmail, 'emailPhone': widget.newEmail});
      }
      else{
        debugPrint('Something went Wrong');
      }
    });
  }

  void updateFavouriteDocumentsLawyer() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Favourite').get();
      List<QueryDocumentSnapshot> documents = querySnapshot.docs;

      for (var doc in documents) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

        for(int i = 1; i <= data?['counter']; i++){
          if(data?['LawyerID$i'] == widget.oldEmail) {
            await FirebaseFirestore.instance.collection('Favourite').doc(doc.id).update({
              'LawyerID$i': widget.newEmail,
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error updating documents: $e');
      // Handle the error accordingly
    }
  }

  Future<void> updateDocumentLawyerArticle() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    firestore.collection("Articles").doc(widget.oldEmail).get().then((doc) {
      if (doc.exists) {
        var data = doc.data();
        firestore.collection("Articles").doc(widget.newEmail).set(data!).then((value) {
          firestore.collection("Articles").doc(widget.oldEmail).delete();
        });
      }
      else{
        debugPrint('Something went Wrong');
      }
    });
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
              icon: const Icon(FontAwesomeIcons.angleLeft, color: Colors.white,),
              onPressed: () {
                // Navigate back to the previous page or screen
                Navigator.of(context).pop();
              },
            ),
          ),
          title: widget.isPasswordChange
            ? const Padding(
            padding: EdgeInsets.only(top: 13),
            child: Text(
              "Password Update",
              style: TextStyle(
                  fontFamily: 'roboto',
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white),
            ),
          )
            : widget.isForgottenPass
              ? const Padding(
            padding: EdgeInsets.only(top: 13),
            child: Text(
              "Password Update",
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
              "Email Update",
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
      body: Column(
        children: [
          widget.isPasswordChange
          ? Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 0.07 * MediaQuery.of(context).size.height),
                child: Center(
                  child: SizedBox(
                      width: 0.65 * MediaQuery.of(context).size.width,
                      height: 0.65 * MediaQuery.of(context).size.width,
                      child: Image.asset("assets/images/Email.jpg")),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 0.02 * MediaQuery.of(context).size.height),
                child: const Center(child: Text('Check your Email', style: TextStyle(
                  fontFamily: "roboto",
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),)),
              ),
              Padding(
                padding: EdgeInsets.only(top: 0.02 * MediaQuery.of(context).size.height),
                child: const Center(child: Text("We sent a Email to:", style: TextStyle(
                  fontFamily: "roboto",
                  fontSize: 16,
                ),)),
              ),
              Padding(
                padding: EdgeInsets.only(top: 0.015 * MediaQuery.of(context).size.height),
                child: Center(child: Text(widget.oldEmail, style: const TextStyle(
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
                child: const Center(child: Text("link to continue.", style: TextStyle(
                  fontFamily: "roboto",
                  fontSize: 16,
                ),)),
              ),
            ],
          )
          : widget.isForgottenPass
            ? Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 0.07 * MediaQuery.of(context).size.height),
                child: Center(
                  child: SizedBox(
                      width: 0.65 * MediaQuery.of(context).size.width,
                      height: 0.65 * MediaQuery.of(context).size.width,
                      child: Image.asset("assets/images/Email.jpg")),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 0.02 * MediaQuery.of(context).size.height),
                child: const Center(child: Text('Check your Email', style: TextStyle(
                  fontFamily: "roboto",
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),)),
              ),
              Padding(
                padding: EdgeInsets.only(top: 0.02 * MediaQuery.of(context).size.height),
                child: const Center(child: Text("We sent a Email to:", style: TextStyle(
                  fontFamily: "roboto",
                  fontSize: 16,
                ),)),
              ),
              Padding(
                padding: EdgeInsets.only(top: 0.015 * MediaQuery.of(context).size.height),
                child: Center(child: Text(widget.newEmail, style: const TextStyle(
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
                child: const Center(child: Text("link to continue.", style: TextStyle(
                  fontFamily: "roboto",
                  fontSize: 16,
                ),)),
              ),
            ],
          )
            : Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 0.07 * MediaQuery.of(context).size.height),
                child: Center(
                  child: SizedBox(
                      width: 0.65 * MediaQuery.of(context).size.width,
                      height: 0.65 * MediaQuery.of(context).size.width,
                      child: Image.asset("assets/images/Email.jpg")),
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
                child: Center(child: Text(widget.newEmail, style: const TextStyle(
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
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 0.015 * MediaQuery.of(context).size.height),
            child: TextButton(
              onPressed: () {
                setState(() {
                  isLoading = true;
                });
                if(widget.isPasswordChange) {
                  FirebaseAuth auth = FirebaseAuth.instance;
                  auth.signInWithEmailAndPassword(email: widget.oldEmail, password: widget.password).then((value) => {
                    setState(() {
                      isLoading = false;
                    }),
                    auth.sendPasswordResetEmail(email: widget.oldEmail).then((value) => {
                      setState(() {
                        isLoading = false;
                      }),
                      Utilities().successMsg('Email has been resent Successfully'),
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
                else if(widget.isForgottenPass){
                  FirebaseAuth auth = FirebaseAuth.instance;
                  auth.sendPasswordResetEmail(email: widget.newEmail).then((value) => {
                    setState(() {
                      isLoading = false;
                    }),
                    Utilities().successMsg('Email has been resent Successfully'),
                  }).onError((error, stackTrace) => {
                    setState(() {
                      isLoading = false;
                    }),
                    Utilities().errorMsg('Something went wrong, please try again later'),
                  });
                }
                else {
                  FirebaseAuth.instance.signInWithEmailAndPassword(email: widget.oldEmail, password: widget.password).then((userCredential) {
                    userCredential.user?.verifyBeforeUpdateEmail(widget.newEmail).then((value) {
                      setState(() {
                        isLoading = false;
                      });
                      Utilities().successMsg('Verification Email has been resent Successfully');
                    });


                  });
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
      ),
      floatingActionButton: Padding(
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
                    if(widget.isUser){
                      if(widget.isPasswordChange) {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const UserAppBarNavBar()));
                      }
                      else if(widget.isForgottenPass) {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const UserAppBarNavBar()));
                      }
                      else {
                        _checkEmailVerificationStatusUser();
                      }
                    }
                    else {
                      if(widget.isPasswordChange) {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const LawyerAppbarNavBar()));
                      }
                      else if(widget.isForgottenPass) {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const LawyerAppbarNavBar()));
                      }
                      else {
                        _checkEmailVerificationStatusLawyer();
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
    );
  }
}