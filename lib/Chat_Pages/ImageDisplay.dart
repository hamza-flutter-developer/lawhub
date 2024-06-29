// ignore_for_file: library_private_types_in_public_api

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ImageDisplay extends StatefulWidget {
  final String lawyerId;
  final String userId;
  final File? img;
  const ImageDisplay({super.key, required this.img, required this.lawyerId, required this.userId});

  @override
  _ImageDisplayState createState() => _ImageDisplayState();
}

class _ImageDisplayState extends State<ImageDisplay> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoadingUpload = false;

  void sendImageMessage(String img) async {
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
      'message': img,
      'type': 'image',
      'time': FieldValue.serverTimestamp(),
      'timeToDisplay': dateTime,
    };
    updateUserLastMessage('Image');
    updateLawyerLastMessage('Image');

    await _firestore
        .collection('ChatRooms')
        .doc("${widget.lawyerId}${widget.userId}")
        .collection('Chats')
        .add(message).then((value) {
          setState(() {
            isLoadingUpload = false;
          });
      Navigator.pop(context);
    });
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

  Future uploadImageToFirebase(File? imageFile) async {
    try {
      String filename = DateTime.now().millisecondsSinceEpoch.toString();
      firebase_storage.Reference ref = firebase_storage
          .FirebaseStorage.instance
          .ref()
          .child('chat_documents')
          .child(filename);
      await ref.putFile(imageFile!);
      String imageUrl = await ref.getDownloadURL();

      sendImageMessage(imageUrl);

    } catch (e) {
      debugPrint("Error sending image");
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: Image.file(
        widget.img!,
        width: double.infinity,
        height: 500,
        fit: BoxFit.cover,
      ),),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                fixedSize: const Size(100, 20),
                backgroundColor: Colors.deepOrangeAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15))),
            child: const Text('Cancel',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'roboto',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                )),
          ),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                isLoadingUpload = true;
              });
              uploadImageToFirebase(widget.img);
            },
            style: ElevatedButton.styleFrom(
                fixedSize: const Size(100, 20),
                backgroundColor: Colors.lightGreen,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15))),
            child: isLoadingUpload
                ? Container(
                color: Colors.lightGreen,
                height: 20,
                width: 20,
                child: const SpinKitCircle(color: Colors.white,size: 20))
                : const Text('Send',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'roboto',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                )),
          ),
        ],
      )
    );
  }
}
