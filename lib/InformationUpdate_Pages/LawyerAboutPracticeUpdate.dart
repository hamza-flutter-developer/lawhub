// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lawhub/InformationUpdate_Pages/InfoUpdated.dart';

import '../Lawyer_Pages/LawyerAppBar&NavBar.dart';

class LawyerAboutPracticeUpdate extends StatefulWidget{
  final Map<String, dynamic> userData;
  final bool isUser;
  const LawyerAboutPracticeUpdate({super.key, required this.isUser, required this.userData});

  @override
  State<LawyerAboutPracticeUpdate> createState() => _LawyerAboutPracticeUpdateState();
}

class _LawyerAboutPracticeUpdateState extends State<LawyerAboutPracticeUpdate> {

  late TextEditingController _aboutPracticeController = TextEditingController(text: widget.userData['aboutPractice']);

  final textFieldFocusNode = FocusNode();

  final _form = GlobalKey<FormState>();

  bool isLoading = false;

  void _updateLawyerInformation() async {
    await FirebaseFirestore.instance.collection('Lawyers').doc(widget.userData['id']).update({'aboutPractice': _aboutPracticeController.text.toString()}).then((value) {
      setState(() {
        isLoading = false;
      });
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  UserInfoUpdated(text: 'About Practice', isUser: widget.isUser)));
    });

  }

  @override
  void initState() {
    if(_aboutPracticeController.text.toString() == 'Not Set') {
      _aboutPracticeController = TextEditingController();
    }
    super.initState();
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
                "About Practice Update",
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
                        "Please Explain About Your Practice:",
                        style: TextStyle(
                          fontFamily: 'roboto',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )),
                Padding(
                  padding: const EdgeInsets.all(30),
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
                      child: Form(
                        key: _form,
                        child: TextFormField(
                          controller: _aboutPracticeController,
                          textAlignVertical: TextAlignVertical.center,
                          focusNode: textFieldFocusNode,
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                          maxLines: 4,
                          decoration: const InputDecoration(
                            focusedBorder: InputBorder.none,
                            border: InputBorder.none,
                            hintText: "Enter About your Practice",
                            focusColor: Colors.black,
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please Enter About your Practice";
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      floatingActionButton:
      GestureDetector(
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
                  onTap: () {
                    if (textFieldFocusNode.hasFocus) {
                      textFieldFocusNode.unfocus();
                    }
                    if(_form.currentState!.validate()) {
                      setState(() {
                        isLoading = true;
                      });
                      _updateLawyerInformation();
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
      ),
    );
  }
}