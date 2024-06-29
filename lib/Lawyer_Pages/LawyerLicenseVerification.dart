// ignore_for_file: file_names

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lawhub/Utils/Utilities.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'LawyerLicenseDetailsSubmitted.dart';

class LawyerLicenseVerification extends StatefulWidget{
  const LawyerLicenseVerification({super.key});

  @override
  State<LawyerLicenseVerification> createState() => _LawyerLicenseVerificationState();
}

class _LawyerLicenseVerificationState extends State<LawyerLicenseVerification> {

  bool isLoading = true;

  final TextEditingController _licenseNumberController = TextEditingController();

  FocusNode licenseNumberFocusNode = FocusNode();

  late String isVerified;

  Future<void> fetchLawyerVerificationStatus() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('Lawyers').doc(FirebaseAuth.instance.currentUser!.email.toString()).get();
    isVerified =  doc['isVerified'];
    setState(() {
      isLoading = false;
    });
  }

  Future<void> uploadLicense(String imageUrl) async {

    int dayInt = DateTime.now().day;
    int monthInt = DateTime.now().month;

    String dateTimeText;
    String date = dayInt < 10 ? '0$dayInt' : '$dayInt';
    String month = checkMonth(monthInt);
    String year = (DateTime.now().year).toString();
    dateTimeText = '$month $date, $year';

    var doc = await FirebaseFirestore.instance.collection('LawyersLicense').doc('admin@gmail.com').get();
    if(doc.exists) {
      int counter = doc['counter'];
      counter++;
      await FirebaseFirestore.instance.collection('LawyersLicense').doc('admin@gmail.com').update({
        'Lawyer$counter': {
          'lawyerId': FirebaseAuth.instance.currentUser!.email.toString(),
          'barCouncil': barCouncilText,
          'licenseNumber': _licenseNumberController.text.toString(),
          'courtEnrollment': licenseText,
          'licenseImage': imageUrl,
          'dateTime': dateTimeText,
          'status': 'Submitted'
        },
        'counter': counter
      });
    }
    else {
      await FirebaseFirestore.instance.collection('LawyersLicense').doc('admin@gmail.com').set({
        'Lawyer1': {
          'lawyerId': FirebaseAuth.instance.currentUser!.email.toString(),
          'barCouncil': barCouncilText,
          'licenseNumber': _licenseNumberController.text.toString(),
          'courtEnrollment': licenseText,
          'licenseImage': imageUrl,
          'dateTime': dateTimeText,
          'status': 'Submitted'
        },
        'counter': 1
      });
    }

    updateLawyerStatus();
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

  Future<void> updateLawyerStatus() async {
    await FirebaseFirestore.instance.collection('Lawyers').doc(FirebaseAuth.instance.currentUser!.email.toString()).update({
      'isVerified': 'Submitted'
    });
    setState(() {
      isLoadingSubmit = false;
    });
    // ignore: use_build_context_synchronously
    Navigator.push(context, MaterialPageRoute(builder: (context) => const LawyerLicenseDetailsSubmitted()));
  }

  final barCouncilList = [
    {'id': 1, 'name': 'Islamabad Bar Council'},
    {'id': 2, 'name': 'Punjab Bar Council'},
    {'id': 3, 'name': 'KPK Bar Council'},
    {'id': 4, 'name': 'Balochistan Bar Council'},
    {'id': 5, 'name': 'Sindh Bar Council'},
    {'id': 6, 'name': 'Gilgit Baltistan Bar Council'},
    {'id': 7, 'name': 'Supreme Court'},
  ];
  String? barCouncil;
  String? barCouncilText;

  final licenseList = [
    {'id': 1, 'name': 'Lower Court'},
    {'id': 2, 'name': 'High Court'},
    {'id': 3, 'name': 'Supreme Court'},
  ];
  String? license;
  String? licenseText;

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
          .child('lawyers_license')
          .child(filename);
      await ref.putFile(imageFile!);
      String imageUrl = await ref.getDownloadURL();
      uploadLicense(imageUrl);
    } catch (e) {
      debugPrint("Error sending image");
    }
  }

  bool isLoadingSubmit = false;

  @override
  void initState() {
    super.initState();
    fetchLawyerVerificationStatus();
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
                "License Verification",
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
        body: isLoading
            ? Center(
          child: Container(
              color: Colors.white,
              child: const SpinKitCircle(
                  color: Colors.blue, size: 34) ),
        )
            : SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                const SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 30,
                        top: 40,
                      ),
                      child: Text(
                        "License Verification:",
                        style: TextStyle(
                          fontFamily: 'roboto',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )),
                const SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 30,
                        right: 30,
                        top: 5,
                      ),
                      child: Text(
                        "Provide your legal practice license details below to get verified",
                        style: TextStyle(
                          fontFamily: 'roboto',
                          fontSize: 16,
                        ),
                      ),
                    )),
                isVerified == 'Verified'
                    ? const SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 30,
                        top: 20,
                      ),
                      child: Row(
                        children: [
                          Text(
                            "Status:",
                            style: TextStyle(
                              fontFamily: 'roboto',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 10,),
                          Text(
                            "Verified",
                            style: TextStyle(
                              fontFamily: 'roboto',
                              fontSize: 16,
                            ),
                          ),
                        ],
                      )
                    ))
                    : isVerified == 'Submitted'
                      ? const SizedBox(
                    width: double.infinity,
                    child: Padding(
                        padding: EdgeInsets.only(
                          left: 30,
                          top: 20,
                        ),
                        child: Row(
                          children: [
                            Text(
                              "Status:",
                              style: TextStyle(
                                fontFamily: 'roboto',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 10,),
                            Text(
                              "Submitted",
                              style: TextStyle(
                                fontFamily: 'roboto',
                                fontSize: 16,
                              ),
                            ),
                          ],
                        )
                    ))
                      : const SizedBox(
                    width: double.infinity,
                    child: Padding(
                        padding: EdgeInsets.only(
                          left: 30,
                          top: 20,
                        ),
                        child: Row(
                          children: [
                            Text(
                              "Status:",
                              style: TextStyle(
                                fontFamily: 'roboto',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 10,),
                            Text(
                              "Not Verified",
                              style: TextStyle(
                                fontFamily: 'roboto',
                                fontSize: 16,
                              ),
                            ),
                          ],
                        )
                    )),
                isVerified == 'Submitted'
                  ? const SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 30,
                        right: 30,
                        top: 20,
                      ),
                      child: Text(
                        "Thank you for submitting your license details. Your account is now under verification by our admin team. Please allow some time for the verification process. Once verified, you'll gain full access to client interactions and opportunities. We appreciate your patience.",
                        style: TextStyle(
                          fontFamily: 'roboto',
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ))
                  : isVerified == 'Verified'
                      ? const SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 30,
                        right: 30,
                        top: 20,
                      ),
                      child: Text(
                        "Congratulations! Your license has been successfully verified. You now have full access to client interactions and opportunities.",
                        style: TextStyle(
                          fontFamily: 'roboto',
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ))
                      : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Bar Council",
                            style: TextStyle(
                                fontFamily: 'roboto',
                                fontSize: 15,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                          const SizedBox(height: 10,),
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
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 30, right: 10),
                                child: Center(
                                  child: DropdownButton(
                                    iconSize: 24.5,
                                    hint: Text(
                                      "Select Bar Council",
                                      style: TextStyle(
                                        fontFamily: 'roboto',
                                        fontSize: 16,
                                        color: Colors.grey.shade500,),
                                    ),
                                    isExpanded: true,
                                    underline: const SizedBox(),
                                    value: barCouncil,
                                    items: barCouncilList.map((e) {
                                      return DropdownMenuItem(
                                        value: e['id'].toString(),
                                        child: Text(e['name'].toString()),
                                      );
                                    }).toList(),
                                    onChanged: (newValue) {
                                      setState(() {
                                        barCouncil = newValue.toString();
                                        barCouncilText = barCouncilList[int.parse(barCouncil.toString()) - 1]['name'].toString();
                                      });
                                    },
                                  ),
                                ),
                              )
                          ),
                          const SizedBox(height: 20,),
                          const Text(
                            "License Number",
                            style: TextStyle(
                                fontFamily: 'roboto',
                                fontSize: 15,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                          const SizedBox(height: 10,),
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
                            child: Padding(
                                padding: const EdgeInsets.only(left: 30),
                                child: TextFormField(
                                  controller: _licenseNumberController,
                                  textAlignVertical: TextAlignVertical.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                  decoration: InputDecoration(
                                      enabledBorder: const UnderlineInputBorder(
                                          borderSide: BorderSide.none
                                      ),
                                      focusedBorder: const UnderlineInputBorder(
                                          borderSide: BorderSide.none
                                      ),
                                      hintText: 'Ex: 1234',
                                      hintStyle: TextStyle(
                                        fontFamily: 'roboto',
                                        fontSize: 16,
                                        color: Colors.grey.shade500,
                                      )
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Enter Name";
                                    }
                                    return null;
                                  },
                                )
                            ),
                          ),
                          const SizedBox(height: 20,),
                          const Text(
                            "Court Enrollment",
                            style: TextStyle(
                                fontFamily: 'roboto',
                                fontSize: 15,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                          const SizedBox(height: 10,),
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
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 30, right: 10),
                                child: Center(
                                  child: DropdownButton(
                                    iconSize: 24.5,
                                    hint: Text(
                                      "Select Court",
                                      style: TextStyle(
                                        fontFamily: 'roboto',
                                        fontSize: 16,
                                        color: Colors.grey.shade500,),
                                    ),
                                    isExpanded: true,
                                    underline: const SizedBox(),
                                    value: license,
                                    items: licenseList.map((e) {
                                      return DropdownMenuItem(
                                        value: e['id'].toString(),
                                        child: Text(e['name'].toString()),
                                      );
                                    }).toList(),
                                    onChanged: (newValue) {
                                      setState(() {
                                        license = newValue.toString();
                                        licenseText = licenseList[int.parse(license.toString()) - 1]['name'].toString();
                                      });
                                    },
                                  ),
                                ),
                              )),
                          const SizedBox(height: 20,),
                          const Text(
                            "License Scan or Photo",
                            style: TextStyle(
                                fontFamily: 'roboto',
                                fontSize: 15,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                          const SizedBox(height: 10,),
                          _image == null
                              ? InkWell(
                            onTap: () {
                              getImage();
                            },
                            child: Container(
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
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const SizedBox(width: 30,),
                                      Text('Add License', style: TextStyle(
                                        fontFamily: 'roboto',
                                        fontSize: 16,
                                        color: Colors.grey.shade500,
                                      ),),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 15),
                                    child: Icon(FontAwesomeIcons.image,size: 20,color: Colors.grey.shade500),
                                  )
                                ],
                              ),
                            ),
                          )
                              : InkWell(
                              onTap: () {
                                getImage();
                              },
                              child: SizedBox(
                                height: 400,
                                width: 300,
                                child: Image.file(
                                  _image!,
                                  fit: BoxFit.cover,
                                ),
                              )
                          ),


                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (licenseNumberFocusNode.hasFocus) {
                          licenseNumberFocusNode.unfocus();
                        }
                      },
                      child: SizedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () async {
                                if (licenseNumberFocusNode.hasFocus) {
                                  licenseNumberFocusNode.unfocus();
                                }
                                if(_licenseNumberController.text.isNotEmpty && _image != null && barCouncilText!.isNotEmpty && licenseText!.isNotEmpty) {
                                  setState(() {
                                    isLoadingSubmit = true;
                                  });
                                  uploadImageToFirebase(_image);
                                }
                                else {
                                  Utilities().errorMsg('Please fill all details');
                                }
                              },
                              child: Container(
                                height: 40,
                                width: 200,
                                decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(15)
                                ),
                                child: isLoadingSubmit
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
                                    : const Center(child: Text('Submit',
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
                )
              ],
            ),
          ),
        )
    );
  }
}