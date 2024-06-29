// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LawyerNotificationPage extends StatefulWidget{
  final Map<String, dynamic> lawyerData;
  const LawyerNotificationPage({Key? key, required this.lawyerData}) : super(key: key);

  @override
  State<LawyerNotificationPage> createState() => _LawyerNotificationPageState();
}

class _LawyerNotificationPageState extends State<LawyerNotificationPage> {

  bool isLoading = true;
  bool isNotificationAvailable = true;

  Future<void> checkNotification() async {
    var doc = await FirebaseFirestore.instance.collection('LawyersNotifications').doc(widget.lawyerData['id']).get();
    if(!doc.exists) {
      setState(() {
        isLoading = false;
        isNotificationAvailable = false;
      });
    }
    else {
      fetchAllNotifications().then((data) {
        setState(() {
          int counter = data['counter'];
          for (int i = counter; i >= 1; i--) {
            String type = data['Notification$i'][1]['type'];
            if(data['Notification$i'][0]['userID'] != 'admin@gmail.com') {
              fetchUserData(data['Notification$i'][0]['userID']).then((value) {
                setState(() {
                  notificationList.add({'index': i, 'imageUrl': value['profilePic'], 'senderName': value['name'], 'type': type});
                });
              });
            }
            else {
              setState(() {
                notificationList.add({'index': i, 'imageUrl': 'null', 'senderName': 'LAWHUB Team', 'type': type});
              });
            }
          }
        });
        setState(() {
          isLoading = false;
          isNotificationAvailable = true;
        });
      }).catchError((error) {
        setState(() {
          isLoading = false;
        });
      });
    }
  }

  Future<DocumentSnapshot> fetchAllNotifications() async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('LawyersNotifications')
        .doc(widget.lawyerData['id'])
        .get();
    return userSnapshot;
  }

  List<Map<String, dynamic>> notificationList = [];

  Future<DocumentSnapshot> fetchUserData(String userID) async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(userID)
        .get();
    return userSnapshot;
  }

  Future<void> checkNotificationSeenStatus() async {
    fetchAllNotifications().then((data) {
      setState(() {
        int counter = data['counter'];
        for (int i = 1; i <= counter; i++) {
          if(!data['Notification$i'][2]['isSeen']) {
            String userID = data['Notification$i'][0]['userID'];
            String type = data['Notification$i'][1]['type'];
            updateNotificationSeenStatus(i, userID, type, counter);
          }
        }
        setState(() {
          isLoading = false;
        });
      });
    }).catchError((error) {
      setState(() {
        isLoading = false;
      });
    });
  }

  Future<void> updateNotificationSeenStatus(int index, String userId, String type, int counter) async {
    FirebaseFirestore.instance.collection('LawyersNotifications').doc(widget.lawyerData['id']).update({
      'Notification$index': [
        {'userID': userId},
        {'type': type},
        {'isSeen': true},
      ],
      'counter': counter,
    });
  }

  @override
  void initState() {
    super.initState();
    checkNotification();
    checkNotificationSeenStatus();
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
              "Notification",
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
        : isNotificationAvailable
          ? SingleChildScrollView(
        physics: const ScrollPhysics(),
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
                    "All Notifications",
                    style: TextStyle(
                      fontFamily: 'roboto',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )),
            ListView.builder(
              itemBuilder: (context, index) {
                notificationList.sort((a, b) => b['index'].compareTo(a['index']));
                var itemData = notificationList[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 15, right: 20, left: 20),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.all(Radius.circular(25)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12.withOpacity(0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ]
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center, // Align items vertically center
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 5, right: 15),
                            child: SizedBox(
                              width: 50, // Fixed width for the avatar
                              height: 50, // Fixed height for the avatar
                              child: itemData['imageUrl'] == 'null'
                                  ? itemData['senderName'] == 'LAWHUB Team'
                                    ? const CircleAvatar(
                                backgroundImage: AssetImage("assets/images/Lawhub.png"),
                              )
                                    : CircleAvatar(
                                backgroundColor: Colors.grey[300],
                                child: const Icon(Icons.person, color: Colors.grey, size: 30),
                              )
                                  : CircleAvatar(
                                backgroundImage: NetworkImage(itemData['imageUrl']),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  itemData['senderName'],
                                  style: const TextStyle(
                                    fontFamily: 'roboto',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  itemData['type'],
                                  style: const TextStyle(
                                    fontFamily: 'roboto',
                                    fontSize: 16,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              itemCount: notificationList.length,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
            )

          ],
        ),
      )
          : Padding(
        padding: const EdgeInsets.only(top: 10),
        child: SizedBox(
          width: double.infinity,
          child: Center(
            child: Text('No Notifications Yet', style: TextStyle(
                fontFamily: 'roboto',
                fontSize: 16,
                color: Colors.grey.shade500),),
          ),),
      )
    );
  }
}