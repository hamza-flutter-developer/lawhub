// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lawhub/Chat_Pages/ChatInbox.dart';

class UserChat extends StatefulWidget{
  const UserChat({super.key});

  @override
  State<UserChat> createState() => _UserChatState();
}

class Chats {
  final String lawyerID;
  final String imageUrl;
  final String lawyerName;
  final String time;
  final String lastMsg;
  final int milliSeconds;
  final String messageBy;

  Chats({required this.lawyerID, required this.imageUrl, required this.lawyerName, required this.time, required this.lastMsg, required this.milliSeconds, required this.messageBy});
}

class _UserChatState extends State<UserChat> {

  final TextEditingController _searchController = TextEditingController();
  late FocusNode _focusNode;
  bool isCancelPressed = false;

  bool isLoading = true;
  bool isChatsAvailable = false;

  Future<void> checkUserChats() async {
    var documentCheck = await FirebaseFirestore.instance.collection('UsersChats').doc(FirebaseAuth.instance.currentUser!.email).get();
    if(!documentCheck.exists) {
      setState(() {
        isLoading = false;
        isChatsAvailable = false;
      });
    }
    else {
      setState(() {
        isChatsAvailable = true;
        fetchAllUserChats().then((data) {
          setState(() {
            for (int i = 1; i <= data['counter']; i++) {
              String dateTime;
              if(data['lawyerID$i'][3] == DateTime.now().day && data['lawyerID$i'][4] == DateTime.now().month) {
                String minute = data['lawyerID$i'][1] < 10 ? '0${data['lawyerID$i'][1]}' : '${data['lawyerID$i'][1]}';
                String hour = data['lawyerID$i'][2] >= 12 ? '${data['lawyerID$i'][2] - 12}' : '${data['lawyerID$i'][2]}';
                String amPm = data['lawyerID$i'][2] >= 12 ? 'PM' : 'AM';
                dateTime = '$hour:$minute $amPm';
              } else {
                String date = data['lawyerID$i'][3] < 10 ? '0${data['lawyerID$i'][3]}' : '${data['lawyerID$i'][3]}';
                dateTime = '${checkMonth(data['lawyerID$i'][4])}, $date';
              }
              fetchLawyerData(data['lawyerID$i'][0]).then((value) {
                setState(() {
                  chatList.add(Chats(lawyerID: value['id'], imageUrl: value['profilePic'], lawyerName: value['name'], time: dateTime, lastMsg: data['lawyerID$i'][6], milliSeconds: data['lawyerID$i'][5], messageBy: data['lawyerID$i'][7]));
                });
              });
            }
            setState(() {
              isLoading = false;
            });
          });
        });
      });
    }
  }

  Future<Map<String, dynamic>> fetchAllUserChats() async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('UsersChats')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get();

    Map<String, dynamic> userChatsData = userSnapshot.data() as Map<String, dynamic>;
    return userChatsData;
  }

  Future<DocumentSnapshot> fetchLawyerData(String lawyerID) async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('Lawyers')
        .doc(lawyerID)
        .get();
    return userSnapshot;
  }

  List<Chats> chatList = [];

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

  @override
  void initState() {
    checkUserChats();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        if(_focusNode.hasFocus) {
          isCancelPressed = true;
        }
      });
    });
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
                  ),
                  child: Text(
                    "Chats",
                    style: TextStyle(
                      fontFamily: 'roboto',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )),
            const SizedBox(
              height: 15,
            ),
            isLoading
                ? Container(
                height: 500,
                width: double.infinity,
                color: Colors.white,
                child: const Center(child: SpinKitCircle(
                    color: Colors.blue, size: 34),) )
                : isChatsAvailable
                  ? ListView.builder(itemBuilder: (context, index) {
                    chatList.sort((a, b) => b.milliSeconds.compareTo(a.milliSeconds),);
              var itemData = chatList[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 15,right: 20,left: 20),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserInbox(userId: FirebaseAuth.instance.currentUser!.email.toString(),lawyerId: itemData.lawyerID,imgUrl: itemData.imageUrl, name: itemData.lawyerName, isUser: true,)));
                  },
                  child: Container(
                    width: 270,
                    height: 65,
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: CircleAvatar(
                                radius: 25,
                                child: ClipOval(
                                  child: Image.network(itemData.imageUrl,
                                    height: 70,
                                    width: 70,
                                    fit: BoxFit.cover,
                                  ),

                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(itemData.lawyerName,style: const TextStyle(
                                    fontFamily: 'roboto',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  itemData.messageBy == 'null'
                                  ? Text(itemData.lastMsg,style: const TextStyle(
                                    fontFamily: 'roboto',
                                    fontSize: 14,
                                  ),)
                                  : itemData.messageBy == FirebaseAuth.instance.currentUser!.email.toString()
                                    ? Text('You: ${itemData.lastMsg}',style: const TextStyle(
                                    fontFamily: 'roboto',
                                    fontSize: 14,
                                  ),)
                                    : Text('Lawyer: ${itemData.lastMsg}',style: const TextStyle(
                                    fontFamily: 'roboto',
                                    fontSize: 14,
                                  ),)
                                ],
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 25,right: 20),
                          child: Text(itemData.time),
                        ),

                      ],
                    ),
                  ),
                ),
              );
            },
              itemCount: chatList.length,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
            )
                  : Padding(
              padding: const EdgeInsets.only(top: 10),
              child: SizedBox(child: Text('No chats available', style: TextStyle(
                  fontFamily: 'roboto',
                  fontSize: 16,
                  color: Colors.grey.shade500),),),
            )
          ],
        ),
      ),

    );
  }
}