// ignore_for_file: file_names

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lawhub/Chat_Pages/ImageDisplay.dart';

import '../User_Pages/UserStartCase.dart';


class UserInbox extends StatefulWidget{
  final bool isUser;
  final String userId;
  final String lawyerId;
  final String imgUrl;
  final String name;
  const UserInbox({Key? key, required this.userId, required this.lawyerId, required this.imgUrl, required this.name, required this.isUser}) : super(key: key);


  @override
  State<UserInbox> createState() => _UserInboxState();
}
class _UserInboxState extends State<UserInbox> {
  
  final TextEditingController _messageController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  final textFieldFocusNode = FocusNode();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;

  String? imgUrl;

  bool isImageShow = false;

  String? imageToDisplay;

  void sendTextMessage() async {
   if(_messageController.text.isNotEmpty){
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

     Map<String, dynamic> message = {
       'senderId': FirebaseAuth.instance.currentUser!.email.toString(),
       'message': _messageController.text,
       'type': 'text',
       'time': FieldValue.serverTimestamp(),
       'timeToDisplay': dateTime,
     };

     updateUserLastMessage(_messageController.text);
     updateLawyerLastMessage(_messageController.text);

    _messageController.clear();
     await _firestore
         .collection('ChatRooms')
         .doc("${widget.lawyerId}${widget.userId}")
         .collection('Chats')
         .add(message);
   }
   else {
     debugPrint("Enter Some Text");
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

  File? _image;

  final picker = ImagePicker();

  Future getImageGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      // ignore: use_build_context_synchronously
      Navigator.push(context, MaterialPageRoute(builder: (context) => ImageDisplay(img: _image, lawyerId: widget.lawyerId, userId: widget.userId)));
    } else {
    }
  }

  Future getImageCamera() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      // ignore: use_build_context_synchronously
      Navigator.push(context, MaterialPageRoute(builder: (context) => ImageDisplay(img: _image, lawyerId: widget.lawyerId, userId: widget.userId)));
    } else {
    }
  }

  final fireStoreUserChat  = FirebaseFirestore.instance.collection('UsersChats');

  Future updateUserLastMessage(String message) async {
    int minute = DateTime.now().minute;
    int hour = DateTime.now().hour;
    int day = DateTime.now().day;
    int month = DateTime.now().month;
    int milliSeconds = DateTime.now().millisecondsSinceEpoch;

    var doc = await FirebaseFirestore.instance.collection('UsersChats').doc(widget.userId).get();
    int counter = doc['counter'];
    for(int i = 1; i <= counter; i++) {
      if(doc['lawyerID$i'][0] == widget.lawyerId){
        DocumentReference documentReference =
        fireStoreUserChat.doc(widget.userId);
        await documentReference.update({
          'lawyerID$i': [widget.lawyerId, minute, hour, day, month, milliSeconds, message, FirebaseAuth.instance.currentUser!.email.toString()],
          'counter': counter,
        });
      }
    }
  }

  final fireStoreLawyerChat  = FirebaseFirestore.instance.collection('LawyersChats');

  Future updateLawyerLastMessage(String message) async {
    int minute = DateTime.now().minute;
    int hour = DateTime.now().hour;
    int day = DateTime.now().day;
    int month = DateTime.now().month;
    int milliSeconds = DateTime.now().millisecondsSinceEpoch;

    var doc = await FirebaseFirestore.instance.collection('LawyersChats').doc(widget.lawyerId).get();
    int counter = doc['counter'];
    for(int i = 1; i <= counter; i++) {
      if(doc['userID$i'][0] == widget.userId){
        DocumentReference documentReference =
        fireStoreLawyerChat.doc(widget.lawyerId);
        await documentReference.update({
          'userID$i': [widget.userId, minute, hour, day, month, milliSeconds, message, FirebaseAuth.instance.currentUser!.email.toString()],
          'counter': counter,
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    textFieldFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    textFieldFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isImageShow
        ? Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: InkWell(
          onTap: () {
            setState(() {
              isImageShow = false;
            });
          },
          child: const Padding(padding: EdgeInsets.only(top: 10, left: 10), child: Icon(FontAwesomeIcons.x, color: Colors.white,size: 20,),),
        )
      ),
      body: Center(child: Image.network(
        imageToDisplay!,
        width: double.infinity,
        height: 500,
        fit: BoxFit.cover,
      ),),
    )
        : Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0),
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
          title: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: SizedBox(
              width: 300,
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(widget.imgUrl),
                    radius: 25,
                  ),
                  const SizedBox(width: 10,),
                  Text(widget.name,style: const TextStyle(
                      fontFamily: 'roboto',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white
                  ),),
                ],
              ),
            ),
          ),

          actions: [
            widget.isUser
                ? Padding(
              padding: const EdgeInsets.only(top: 8,right: 8),
              child: PopupMenuButton(
                icon: const Icon(FontAwesomeIcons.ellipsisVertical,color: Colors.white,),
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem(
                      value: 'start',
                      child: Text('Start Case'),
                    ),
                  ];
                },
                onSelected: (value) {
                  if (value == 'start') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserStartCase(lawyerId: widget.lawyerId),
                      ),
                    );
                  }

                },
              ),
            )
                : const SizedBox()
          ],
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25)),
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
              child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('ChatRooms')
                      .doc("${widget.lawyerId}${widget.userId}")
                      .collection('Chats')
                      .orderBy('time', descending: true)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.data != null) {
                      return ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        itemCount: snapshot.data?.docs.length,
                        itemBuilder: (context, index) {
                          String message = snapshot.data?.docs[index]['message'];
                          String time = snapshot.data?.docs[index]['timeToDisplay'];
                          return snapshot.data?.docs[index]['senderId'] == FirebaseAuth.instance.currentUser!.email.toString()
                              ? snapshot.data?.docs[index]['type'] == 'text'
                              ? Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.all(8),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          topRight: Radius.circular(12),
                                          bottomLeft: Radius.circular(12),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12.withOpacity(0.35),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          )
                                        ]
                                    ),
                                    child: Text(
                                      message,
                                      style: const TextStyle(fontFamily: 'roboto',
                                          fontSize: 15,
                                          color: Colors.white),
                                    ),
                                  ),
                                  Padding(padding: const EdgeInsets.only(right: 5), child: Text(time, style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54
                                  ),),),
                                  const SizedBox(height: 5,)
                                ],
                              )
                            ),
                          )
                              : InkWell(
                            onTap: () {
                              setState(() {
                                imageToDisplay = message;
                                isImageShow = true;
                              });
                            },
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                        height: 350,
                                        width: 250,
                                        margin: const EdgeInsets.all(8),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                            color: Colors.blue,
                                            borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(12),
                                              topRight: Radius.circular(12),
                                              bottomLeft: Radius.circular(12),
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black12.withOpacity(0.35),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              )
                                            ]
                                        ),
                                        child: isLoading ? const SpinKitCircle(color: Colors.white,size: 30) : Image.network(message, fit: BoxFit.fitHeight,)
                                    ),
                                    Padding(padding: const EdgeInsets.only(right: 5), child: Text(time, style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54
                                    ),),),
                                    const SizedBox(height: 5,)
                                  ],
                                )
                              ),
                            )
                          )
                              : snapshot.data?.docs[index]['type'] == 'text'
                              ? Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.all(8),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          topRight: Radius.circular(12),
                                          bottomRight: Radius.circular(12),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12.withOpacity(0.35),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          )
                                        ]
                                    ),
                                    child: Text(message,
                                      style: const TextStyle(fontFamily: 'roboto',
                                          fontSize: 15,
                                          color: Colors.black),),
                                  ),
                                  Padding(padding: const EdgeInsets.only(left: 5), child: Text(time, style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54
                                  ),),),
                                  const SizedBox(height: 5,)
                                ],
                              )
                            ),
                          )
                              : InkWell(
                            onTap: () {
                              setState(() {
                                imageToDisplay = message;
                                isImageShow = true;
                              });
                            },
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                        height: 350,
                                        width: 250,
                                        margin: const EdgeInsets.all(8),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(12),
                                              topRight: Radius.circular(12),
                                              bottomRight: Radius.circular(12),
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black12.withOpacity(0.35),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              )
                                            ]
                                        ),
                                        child: Image.network(message, fit: BoxFit.fitHeight,)
                                    ),
                                    Padding(padding: const EdgeInsets.only(left: 5), child: Text(time, style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54
                                    ),),),
                                    const SizedBox(height: 5,)
                                  ],
                                )
                              ),
                            ),
                          );
                        },
                      );
                    }
                    else {
                      return Container();
                    }
                  }
              )
          ),
          Container(
            width: double.infinity,
            height: 50,
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(18),
                  topLeft: Radius.circular(18)
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return Container(
                          height: 130,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(topRight: Radius.circular(10),topLeft: Radius.circular(10)), // Removes rounded edges
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                InkWell(
                                  onTap: () {
                                    if(textFieldFocusNode.hasFocus){
                                      textFieldFocusNode.unfocus();
                                    }
                                    Navigator.pop(context);
                                    getImageCamera();
                                  },
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Padding(padding: EdgeInsets.only(left: 25), child: Text('Camera', style: TextStyle(fontFamily: 'roboto',
                                        fontSize: 15,),),),
                                      Padding(padding: EdgeInsets.only(right: 25),child: Icon(FontAwesomeIcons.cameraRetro, size: 25,),)
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10,),
                                Padding(padding: const EdgeInsets.symmetric(horizontal: 25), child: Container(
                                  decoration: const BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                            color: Colors.black,
                                            width: 0.7,
                                          )
                                      )
                                  ),
                                ),),
                                const SizedBox(height: 10,),
                                InkWell(
                                  onTap: () {
                                    if(textFieldFocusNode.hasFocus){
                                      textFieldFocusNode.unfocus();
                                    }
                                    Navigator.pop(context);
                                    getImageGallery();
                                  },
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Padding(padding: EdgeInsets.only(left: 25), child: Text('Photos', style: TextStyle(fontFamily: 'roboto',
                                        fontSize: 15,),),),
                                      Padding(padding: EdgeInsets.only(right: 25),child: Icon(FontAwesomeIcons.image, size: 25,),)
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Container(
                    height: 25,
                    width: 60,
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: Colors.white,
                          width: 0.7,
                        ),
                      ),
                    ),
                    child: const Icon(FontAwesomeIcons.camera,size: 23,color: Colors.white,),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    focusNode: textFieldFocusNode,
                    style: const TextStyle(
                        fontFamily: 'roboto',
                        fontSize: 16,
                        color: Colors.white
                    ),
                    cursorColor: Colors.white,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: const InputDecoration(
                      hintText: "Write Message",
                      hintStyle: TextStyle(
                          fontFamily: 'roboto', fontSize: 15, color: Colors.white),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(bottom: 11.5,left: 10),

                    ),
                  ),
                ),

                SizedBox(
                  height: 40,
                  width: 60,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: IconButton(
                      icon: const Icon(FontAwesomeIcons.circleArrowUp,size: 25,color: Colors.white,),
                      onPressed: () => sendTextMessage(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
