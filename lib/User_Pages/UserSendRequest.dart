// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../Utils/Utilities.dart';
import 'UserRequestSubmitted.dart';

class UserSendRequest extends StatefulWidget{
  final Map<String, dynamic> userData;
  final Map<String, dynamic> lawyerData;
  const UserSendRequest({super.key, required this.userData, required this.lawyerData});

  @override
  State<UserSendRequest> createState() => _UserSendRequestState();
}

class _UserSendRequestState extends State<UserSendRequest> {

  final TextEditingController _caseDescription = TextEditingController();

  final caseDescriptionFocusNode = FocusNode();

  final _form = GlobalKey<FormState>();

  bool isLoading = false;

  final fireStoreRequests  = FirebaseFirestore.instance.collection('Requests');

  void sendFirstRequest() {
    fireStoreRequests.doc(widget.lawyerData['id']).set({'counter': 0});
  }

  void sendRequest() async {
    var doc = await FirebaseFirestore.instance.collection('Requests').doc(widget.lawyerData['id']).get();
    int counter = doc['counter'];
    counter++;
    DocumentReference documentReference =
    fireStoreRequests.doc(widget.lawyerData['id']);
    await documentReference.update({
      'Request$counter': [
        {'userID': widget.userData['id']},
        {'caseDescription': _caseDescription.text.toString()},
        {'status': 'pending'},
      ],
      'counter': counter,
    }).then((value) => {
      addNotification(),
      setState(() {
        isLoading = false;
        setState(() {
        });
        Navigator.push(context, MaterialPageRoute(builder: (context) => const UserRequestSubmitted(text: 'Request',)));
      }),
    }).onError((error, stackTrace) => {
      setState(() {
        isLoading = false;
      }),
      Utilities().errorMsg('Something Went Wrong'),
    });
  }

  final fireStoreNotification  = FirebaseFirestore.instance.collection('LawyersNotifications');

  void addNotification() async {
    var doc = await FirebaseFirestore.instance.collection('LawyersNotifications').doc(widget.lawyerData['id']).get();
    if(doc.exists) {
      int counter = doc['counter'];
      counter++;
      DocumentReference documentReference =
      fireStoreNotification.doc(widget.lawyerData['id']);
      await documentReference.update({
        'Notification$counter': [
          {'userID': widget.userData['id']},
          {'type': 'sends you request'},
          {'isSeen': false},
        ],
        'counter': counter,
      });
    }
    else {
      fireStoreNotification.doc(widget.lawyerData['id']).set({'Notification1': [
        {'userID': widget.userData['id']},
        {'type': 'sends you request'},
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
                "Send Request",
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
                Form(
                  key: _form,
                  child: Padding(
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
                            hintText: "Please Explain Your Legal Concern",
                            focusColor: Colors.black,
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please Enter Your Legal Concern";
                            }
                            else if(value.length < 100){
                              return "Please Enter up to 100 Characters";
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
      floatingActionButton: GestureDetector(
        onTap: () {
          if (caseDescriptionFocusNode.hasFocus) {
            caseDescriptionFocusNode.unfocus();
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
                      if (caseDescriptionFocusNode.hasFocus) {
                        caseDescriptionFocusNode.unfocus();
                      }
                      if (_form.currentState!.validate()) {
                        setState(() {
                          isLoading = true;
                        });
                        var doc = await FirebaseFirestore.instance.collection('Requests').doc(widget.lawyerData['id']).get();
                        if(doc.exists) {
                          sendRequest();
                        }
                        else {
                          sendFirstRequest();
                          sendRequest();
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
                      child: const Center(child: Text('Send',
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