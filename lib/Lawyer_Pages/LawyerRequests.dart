// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Requests {
  final String userID;
  final String imageUrl;
  final String senderName;
  final String description;
  late String status;

  Requests({required this.imageUrl, required this.senderName, required this.description, required this.status, required this.userID});
}

class LawyerRequests extends StatefulWidget{
  final Map<String, dynamic> userData;
  const LawyerRequests({super.key, required this.userData});

  @override
  State<LawyerRequests> createState() => _LawyerRequestsState();
}

class _LawyerRequestsState extends State<LawyerRequests> {


  final TextEditingController _searchController = TextEditingController();
  late FocusNode _focusNode;
  bool isCancelPressed = false;

  int selected = -1;
  bool isExpanded = false;

  String? lawyerId;

  bool isLoadingRequest = true;
  bool isRequestAvailable = false;

  bool isLoadingAccept = false;

  bool isLoadingReject = false;

  Future<void> checkRequests() async {
    var documentCheck = await FirebaseFirestore.instance.collection('Requests').doc(FirebaseAuth.instance.currentUser!.email).get();
    if (documentCheck.exists) {
      setState(() {
        fetchAllRequests().then((data) {
          int check = 0;
          int counter = data['counter'];
          int i = 1;
          for (i = 1; i <= counter; i++)  {
            if(data['Request$i'][2]['status'] == 'pending') {
              check++;
              String description = data['Request$i'][1]['caseDescription'];
              fetchUserData(data['Request$i'][0]['userID']).then((value) {
                setState(() {
                  requestsList.add(Requests(userID: value['id'], imageUrl: value['profilePic'], senderName: value['name'], description: description, status: 'pending'));
                });
              });
            }
          }
          if(check > 0) {
            setState(() {
              isLoadingRequest = false;
              isRequestAvailable = true;
            });
          }
          else {
            setState(() {
              isLoadingRequest = false;
              isRequestAvailable = false;
            });
          }
        });
      });
    }
    else {
      setState(() {
        isLoadingRequest = false;
        isRequestAvailable = false;
      });
    }
  }

  Future<DocumentSnapshot> fetchAllRequests() async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('Requests')
        .doc(widget.userData['id'])
        .get();
    return userSnapshot;
  }

  Future<DocumentSnapshot> fetchUserData(String userID) async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(userID)
        .get();
    return userSnapshot;
  }

  List<Requests> requestsList = [];

  Future<void> updateRequestStatusAccept(String userID, int index) async {
    fetchAllRequests().then((data) {
      setState(() {
        int counter = data['counter'];
        for (int i = 1; i <= counter; i++) {
          if(data['Request$i'][0]['userID'] == userID) {
            FirebaseFirestore.instance.collection('Requests').doc(widget.userData['id']).update({
              'Request$i': [
                {'userID': data['Request$i'][0]['userID']},
                {'caseDescription': data['Request$i'][1]['caseDescription']},
                {'status': 'accept'},
              ],
              'counter': counter,
            }).then((value) {
              addNotification(userID, 'accepts your request.');
              addLawyersChat(userID);
              addUsersChat(userID);
              addChatRoom(userID);
            });
          }
          else {
            FirebaseFirestore.instance.collection('Requests').doc(widget.userData['id']).update({
              'Request$i': [
                {'userID': data['Request$i'][0]['userID']},
                {'caseDescription': data['Request$i'][1]['caseDescription']},
                {'status': data['Request$i'][2]['status']},
              ],
              'counter': counter,
            });
          }
        }
        setState(() {
          isLoadingAccept = false;
          requestsList[index].status = 'accept';
          setState(() {

          });
        });
      });
    }).catchError((error) {
      setState(() {
        isLoadingAccept = false;
      });
    });
  }

  Future<void> updateRequestStatusReject(String userID, int index) async {
    fetchAllRequests().then((data) {
      setState(() {
        int counter = data['counter'];
        for (int i = 1; i <= counter; i++) {
          if(data['Request$i'][0]['userID'] == userID) {
            FirebaseFirestore.instance.collection('Requests').doc(widget.userData['id']).update({
              'Request$i': [
                {'userID': data['Request$i'][0]['userID']},
                {'caseDescription': data['Request$i'][1]['caseDescription']},
                {'status': 'reject'},
              ],
              'counter': counter,
            }).then((value) {
              addNotification(userID, 'rejects your request.');
            });
          }
          else {
            FirebaseFirestore.instance.collection('Requests').doc(widget.userData['id']).update({
              'Request$i': [
                {'userID': data['Request$i'][0]['userID']},
                {'caseDescription': data['Request$i'][1]['caseDescription']},
                {'status': data['Request$i'][2]['status']},
              ],
              'counter': counter,
            });
          }
        }
        setState(() {
          isLoadingReject = false;
          requestsList[index].status = 'reject';
          setState(() {

          });
        });
      });
    }).catchError((error) {
      setState(() {
        isLoadingReject = false;
      });
    });
  }

  final fireStoreNotification  = FirebaseFirestore.instance.collection('UsersNotifications');

  void addNotification(String userID, String type) async {
    var doc = await FirebaseFirestore.instance.collection('UsersNotifications').doc(userID).get();
    if(doc.exists) {
      int counter = doc['counter'];
      counter++;
      DocumentReference documentReference =
      fireStoreNotification.doc(userID);
      await documentReference.update({
        'Notification$counter': [
          {'lawyerID': lawyerId},
          {'type': type},
          {'isSeen': false},
        ],
        'counter': counter,
      });
    }
    else {
      fireStoreNotification.doc(userID).set({'Notification1': [
        {'lawyerID': lawyerId},
        {'type': type},
        {'isSeen': false},
      ],'counter': 1});
    }
  }

  final fireStoreLawyerChat  = FirebaseFirestore.instance.collection('LawyersChats');

  int minute = DateTime.now().minute;
  int hour = DateTime.now().hour;
  int day = DateTime.now().day;
  int month = DateTime.now().month;
  int milliSeconds = DateTime.now().millisecondsSinceEpoch;

  void addLawyersChat(String userID) async {
    var doc = await FirebaseFirestore.instance.collection('LawyersChats').doc(lawyerId).get();
    if(doc.exists) {
      int counter = doc['counter'];
      counter++;
      DocumentReference documentReference =
      fireStoreLawyerChat.doc(lawyerId);
      await documentReference.update({
        'userID$counter': [userID, minute, hour, day, month, milliSeconds, 'Start Chatting', 'null'],
        'counter': counter,
      });
    }
    else {
      fireStoreLawyerChat.doc(lawyerId).set({
        'userID1': [userID, minute, hour, day, month, milliSeconds, 'Start Chatting', 'null'],
        'counter': 1,
      });
    }
  }

  final fireStoreUserChat  = FirebaseFirestore.instance.collection('UsersChats');

  void addUsersChat(String userID) async {
    var doc = await FirebaseFirestore.instance.collection('UsersChats').doc(userID).get();
    if(doc.exists) {
      int counter = doc['counter'];
      counter++;
      DocumentReference documentReference =
      fireStoreUserChat.doc(userID);
      await documentReference.update({
        'lawyerID$counter': [lawyerId, minute, hour, day, month, milliSeconds, 'Start Chatting', 'null'],
        'counter': counter,
      });
    }
    else {
      fireStoreUserChat.doc(userID).set({
        'lawyerID1': [lawyerId, minute, hour, day, month, milliSeconds, 'Start Chatting', 'null'],
        'counter': 1
      });
    }
  }

  final fireStoreChatRoom  = FirebaseFirestore.instance.collection('ChatRooms');

  void addChatRoom(String userID) async {
    fireStoreChatRoom.doc('$lawyerId$userID').set({
    });
  }

  @override
  void initState() {
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        if(_focusNode.hasFocus) {
          isCancelPressed = true;
        }
      });
    });
    lawyerId = widget.userData['id'];
    checkRequests();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: Column(
          children: [
            Padding(
                padding: const EdgeInsets.only(left: 25,right: 25,top: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                        ),
                        child: TextField(
                          controller: _searchController,
                          focusNode: _focusNode,
                          style: const TextStyle(
                            fontFamily: 'roboto',
                            fontSize:15,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 5),
                            border: InputBorder.none,
                            focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.grey
                                ),
                                borderRadius: BorderRadius.all(Radius.circular(30))),
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(left: 15, right: 15),
                              child: Icon(Icons.search, size: 20, color: Colors.grey),
                            ),
                            prefixIconConstraints: const BoxConstraints(minHeight: 10),
                            hintText: 'Search...',
                            hintStyle: const TextStyle(
                                fontFamily: 'roboto',
                                fontSize: 18,
                                color: Colors.grey),
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 15),
                              child: InkWell(
                                onTap: () {
                                  _searchController.clear();
                                  setState(() {

                                  });
                                },
                                child: const Icon(
                                  Icons.clear,
                                  size: 19,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            suffixIconConstraints: const BoxConstraints(minHeight: 10),
                          ),
                          onChanged: (String value) {
                            setState(() {

                            });
                          },
                        ),
                      ),
                    ),
                    Visibility(
                      visible: isCancelPressed,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: InkWell(
                          onTap: () {
                            _searchController.clear();
                            setState(() {
                              _focusNode.unfocus();
                              isCancelPressed = false;
                              setState(() {

                              });
                            });
                          },
                          child: const Text('Cancel', style: TextStyle(color: Colors.blue)),
                        ),
                      ),
                    ),
                  ],
                )
            ),
            const SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.only(
                      left: 30,
                      top: 20,
                      bottom: 15
                  ),
                  child: Text(
                    "Requests",
                    style: TextStyle(
                      fontFamily: 'roboto',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )),
            isLoadingRequest
                ? Container(
                height: 500,
                width: double.infinity,
                color: Colors.white,
                child: const Center(child: SpinKitCircle(
                    color: Colors.blue, size: 34),) )
                : isRequestAvailable
                  ? ListView.builder(
              itemBuilder: (context, index) {
                var itemData = requestsList[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      isExpanded = !isExpanded;
                      selected = index;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 15, right: 20, left: 20),
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.all(Radius.circular(25)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12.withOpacity(0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 25,
                                child: ClipOval(
                                  child: Image.network(
                                    itemData.imageUrl,
                                    height: 70,
                                    width: 70,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      itemData.senderName,
                                      style: const TextStyle(
                                        fontFamily: 'roboto',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      selected == index
                                          ? isExpanded
                                          ? itemData.description
                                          : '${itemData.description.substring(0, 52)}... Tap to view more'
                                          : '${itemData.description.substring(0, 52)}... Tap to view more',
                                      textAlign: TextAlign.justify,
                                      style: const TextStyle(
                                        fontFamily: 'roboto',
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (selected == index)
                            isExpanded
                                ? const SizedBox(height: 10)
                                : const SizedBox(),
                          if (selected == index)
                            isExpanded
                                ? itemData.status == 'pending'
                                ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    updateRequestStatusReject(itemData.userID, index).then((value) {
                                      setState(() {
                                        isLoadingReject = true;
                                      });
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                      fixedSize: const Size(100, 40),
                                      backgroundColor: Colors.deepOrangeAccent,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                                  child: isLoadingReject
                                      ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: SpinKitCircle(color: Colors.white, size: 20))
                                      : const Text('Reject', style: TextStyle(color: Colors.white, fontFamily: 'roboto', fontSize: 16, fontWeight: FontWeight.bold)),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    updateRequestStatusAccept(itemData.userID, index).then((value) {
                                      setState(() {
                                        isLoadingAccept = true;
                                      });
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                      fixedSize: const Size(100, 40),
                                      backgroundColor: Colors.lightGreen,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                                  child: isLoadingAccept
                                      ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: SpinKitCircle(color: Colors.white, size: 20))
                                      : const Text('Accept', style: TextStyle(color: Colors.white, fontFamily: 'roboto', fontSize: 16, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            )
                                : itemData.status == 'accept'
                                ? const SizedBox(
                              height: 30,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(FontAwesomeIcons.circleCheck, color: Colors.lightGreen, size: 20),
                                  SizedBox(width: 10),
                                  Text(
                                    'Accepted',
                                    style: TextStyle(fontFamily: 'roboto', fontSize: 16, color: Colors.lightGreen),
                                  ),
                                ],
                              ),
                            )
                                : const SizedBox(
                              height: 30,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(FontAwesomeIcons.circleXmark, color: Colors.deepOrangeAccent, size: 20),
                                  SizedBox(width: 10),
                                  Text(
                                    'Rejected',
                                    style: TextStyle(fontFamily: 'roboto', fontSize: 16, color: Colors.deepOrangeAccent),
                                  ),
                                ],
                              ),
                            )
                                : const SizedBox(),
                        ],
                      )
                    ),
                  ),
                );
              },
              itemCount: requestsList.length,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
            )
                  : Padding(
              padding: const EdgeInsets.only(top: 10),
              child: SizedBox(
                width: double.infinity,
                child: Center(
                  child: Text('No Requests Yet', style: TextStyle(
                      fontFamily: 'roboto',
                      fontSize: 16,
                      color: Colors.grey.shade500),),
                ),),
            )

          ],
        ),
      )

    );
  }
}