// ignore_for_file: file_names

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';

import 'UserRequestSubmitted.dart';

class UserStartCase extends StatefulWidget{
  final String lawyerId;
  const UserStartCase({super.key, required this.lawyerId});

  @override
  State<UserStartCase> createState() => _UserStartCaseState();
}

class _UserStartCaseState extends State<UserStartCase> {

  final TextEditingController _caseDescription = TextEditingController();

  final caseDescriptionFocusNode = FocusNode();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _form = GlobalKey<FormState>();

  bool isLoading = false;

  File? _image;

  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    } else {
    }
  }

  Future uploadImageToFirebase(File? imageFile) async {
    try {
      String filename = DateTime.now().millisecondsSinceEpoch.toString();
      firebase_storage.Reference ref = firebase_storage
          .FirebaseStorage.instance
          .ref()
          .child('case_payment')
          .child(filename);
      await ref.putFile(imageFile!);
      String imageUrl = await ref.getDownloadURL();
      uploadToCases(imageUrl);
    } catch (e) {
      debugPrint("Error sending image");
    }
  }

  void uploadToCases(String img) async {

    int minuteInt = DateTime.now().minute;
    int hourInt = DateTime.now().hour;
    int dayInt = DateTime.now().day;
    int monthInt = DateTime.now().month;

    String dateTime;
    String minute = minuteInt < 10 ? '0$minuteInt' : '$minuteInt';
    String hour = hourInt >= 12 ? '${hourInt - 12}' : '$hourInt';
    String amPm = hourInt >= 12 ? 'PM' : 'AM';
    String date = dayInt < 10 ? '0$dayInt' : '$dayInt';
    String month = checkMonth(monthInt);
    dateTime = '$date $month $hour:$minute $amPm';


    Map<String, dynamic> data = {
      'status': 'pending',
      'userId': FirebaseAuth.instance.currentUser!.email.toString(),
      'lawyerId': widget.lawyerId,
      'caseDescription': _caseDescription.text,
      'paymentSS': img,
      'startDate': dateTime,
      'givenRatingFeedback': false
    };

    var documentCheckLawyer = await FirebaseFirestore.instance.collection('CasesLawyer').doc(widget.lawyerId).get();
    if(documentCheckLawyer.exists) {
      int counter = documentCheckLawyer['counter'];
      counter++;
      await _firestore
          .collection('CasesLawyer')
          .doc(widget.lawyerId)
          .update({
        'counter': counter,
        'case$counter': data
      });
    }
    else {
      await _firestore
          .collection('CasesLawyer')
          .doc(widget.lawyerId)
          .set({
        'counter': 1,
        'case1': data
      });
    }
    addNotification(widget.lawyerId, 'requests to Start Case');

    var documentCheckUser = await FirebaseFirestore.instance.collection('CasesUser').doc(FirebaseAuth.instance.currentUser!.email.toString()).get();
    if(documentCheckUser.exists) {
      int counter = documentCheckUser['counter'];
      counter++;
      await _firestore
          .collection('CasesUser')
          .doc(FirebaseAuth.instance.currentUser!.email.toString())
          .update({
        'counter': counter,
        'case$counter': data
      }).then((value) {
        setState(() {
          isLoading = false;
        });
        Navigator.push(context, MaterialPageRoute(builder: (context) => const UserRequestSubmitted(text: 'Case',)));
      });
    }
    else {
      await _firestore
          .collection('CasesUser')
          .doc(FirebaseAuth.instance.currentUser!.email.toString())
          .set({
        'counter': 1,
        'case1': data
      }).then((value) {
        setState(() {
          isLoading = false;
        });
        Navigator.push(context, MaterialPageRoute(builder: (context) => const UserRequestSubmitted(text: 'Case',)));
      });
    }

  }

  String checkMonth(int index){
    switch (index) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
  }

  final fireStoreNotification  = FirebaseFirestore.instance.collection('LawyersNotifications');

  void addNotification(String userID, String type) async {
    var doc = await FirebaseFirestore.instance.collection('LawyersNotifications').doc(userID).get();
    if(doc.exists) {
      int counter = doc['counter'];
      counter++;
      DocumentReference documentReference =
      fireStoreNotification.doc(userID);
      await documentReference.update({
        'Notification$counter': [
          {'userID': FirebaseAuth.instance.currentUser!.email.toString()},
          {'type': type},
          {'isSeen': false},
        ],
        'counter': counter,
      });
    }
    else {
      fireStoreNotification.doc(userID).set({'Notification1': [
        {'userID': FirebaseAuth.instance.currentUser!.email.toString()},
        {'type': type},
        {'isSeen': false},
      ],'counter': 1});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
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
            title: const Padding(
              padding: EdgeInsets.only(top: 13),
              child: Text(
                "Start Case",
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
        body: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Form(
              key: _form,
              child: Column(
                children: [
                  const SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 30,
                          top: 30,
                          bottom: 15,
                        ),
                        child: Text(
                          "Case Description:",
                          style: TextStyle(
                            fontFamily: 'roboto',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 7,
                            offset: const Offset(1, 1), // changes position of shadow
                          )
                        ],),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: TextFormField(
                          controller: _caseDescription,
                          textAlignVertical: TextAlignVertical.center,
                          focusNode: caseDescriptionFocusNode,
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                          maxLines: 4,
                          decoration: const InputDecoration(
                            focusedBorder: InputBorder.none,
                            border: InputBorder.none,
                            hintText: "Enter Title of your Article",
                            focusColor: Colors.black,
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please Enter Title your Article";
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 30,
                          top: 30,
                          bottom: 15,
                        ),
                        child: Text(
                          "Upload Screenshot of Advance Payment",
                          style: TextStyle(
                            fontFamily: 'roboto',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )),
                  _image == null
                  ? InkWell(
                    onTap: () {
                      getImage();
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 300,
                          height: 49,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 7,
                                offset: const Offset(1, 1), // changes position of shadow
                              )
                            ],),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  SizedBox(width: 20,),
                                  Text('Chose Image', style: TextStyle(
                                      fontFamily: 'roboto',
                                      fontSize: 16
                                  ),),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: 20),
                                child: Icon(FontAwesomeIcons.image,size: 20,),
                              )
                            ],
                          ),
                        ),
                        Padding(padding: const EdgeInsets.only(top: 5), child: Text('Please Upload Screenshot of Advance Payment', style: TextStyle(color: Colors.red.shade800, fontSize: 12),),)
                      ],
                    ),
                  )
                  : InkWell(
                    onTap: () {
                      getImage();
                    },
                    child: Padding(padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Center(child: Image.file(
                        _image!,
                        width: double.infinity,
                        height: 300,
                        fit: BoxFit.cover,
                      ),),),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  GestureDetector(
                    onTap: () {
                      if (caseDescriptionFocusNode.hasFocus) {
                        caseDescriptionFocusNode.unfocus();
                      }
                    },
                    child: SizedBox(
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () async {
                              if (caseDescriptionFocusNode.hasFocus) {
                                caseDescriptionFocusNode.unfocus();
                              }
                              if(_form.currentState!.validate()) {
                                if(_image != null) {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  uploadImageToFirebase(_image);
                                }
                              }
                            },
                            child: Container(
                              height: 40,
                              width: 300,
                              decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(15)
                              ),
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
                                  : const Center(child: Text('Next',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'roboto',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  )),),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
    );
  }
}