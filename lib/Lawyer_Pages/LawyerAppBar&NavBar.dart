import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'LawyerChat.dart';
import 'LawyerProfile.dart';
import '../Drawer_Pages/Drawer.dart';
import 'LawyerNotifications.dart';
import 'LawyerRequests.dart';

class LawyerAppbarNavBar extends StatefulWidget{
  const LawyerAppbarNavBar({super.key});

  @override
  State<LawyerAppbarNavBar> createState() => _LawyerAppbarNavBarState();
}

class _LawyerAppbarNavBarState extends State<LawyerAppbarNavBar> {

  Timer? timer;

  late Map<String, dynamic> userData;
  bool isLoading = true;
  late List<Widget> _pages;

  bool isLoadingRequest = true;
  bool isRequestAvailable = false;

  Future<void> checkNotifications(Map<String, dynamic> userData) async {
    var documentCheck = await FirebaseFirestore.instance.collection('LawyersNotifications').doc(userData['id']).get();
    if (documentCheck.exists) {
      fetchAllNotifications().then((data) {
        int counter = data['counter'];
        int i = 1;
        for (i = 1; i <= counter; i++) {
          if(!data['Notification$i'][2]['isSeen']) {
            setState(() {
              isLoadingRequest = false;
              isRequestAvailable = true;
            });
            break;
          }
        }
        if(i > counter) {
          setState(() {
            isLoadingRequest = false;
            isRequestAvailable = false;
          });
        }
      });
    }
    else {
      setState(() {
        isLoadingRequest = false;
        isRequestAvailable = false;
      });
    }
  }

  Future<DocumentSnapshot> fetchAllNotifications() async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('LawyersNotifications')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get();
    return userSnapshot;
  }

  @override
  void initState() {
    super.initState();
    userData = {};
    fetchUserData().then((data) {
      setState(() {
        userData = data;
        checkNotifications(userData).then((value) {
          isLoading = false;
          _initializePages();
        });
      });
    });
    timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      checkNotifications(userData);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
  void _initializePages() {
    _pages = [
      const ChatScreen(),
      Requests(userData: userData,),
      ProfileScreen(userData: userData),
    ];
  }

  Future<Map<String, dynamic>> fetchUserData() async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('Lawyers')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get();

    Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
    return userData;
  }

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      (_currentIndex != 2)
          ? PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          backgroundColor: Colors.blue,
          leading: Builder(builder: (context) {
            return Padding(
              padding: const EdgeInsets.only(top: 14, left: 3),
              child: IconButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                icon: const Icon(
                  FontAwesomeIcons.bars,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            );
          },

          ),
          title: const Padding(
            padding: EdgeInsets.only(top: 13),
            child: Text(
              "LAWHUB",
              style: TextStyle(
                  fontFamily: "patua",
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w100),
            ),
          ),
          centerTitle: true,
          actions: [
            isLoadingRequest
            ? const Padding(
              padding: EdgeInsets.only(top: 15, right: 16),
              child: SpinKitCircle(color: Colors.white,size: 24),
            )
            : isRequestAvailable
                ? Padding(
              padding: const EdgeInsets.only(top: 15, right: 3),
              child: IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LawyerNotificationPage(lawyerData: userData,)));
                  },
                  icon: const Icon(
                    Icons.notifications_on,
                    color: Colors.white,
                    size: 25,
                  )),
            )
                : Padding(
              padding: const EdgeInsets.only(top: 15, right: 3),
              child: IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LawyerNotificationPage(lawyerData: userData,)));
                  },
                  icon: const Icon(
                    Icons.notifications,
                    color: Colors.white,
                    size: 25,
                  )),
            ),


          ],
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25)),
          ),
        ),
      )
          : PreferredSize(
        preferredSize: const Size.fromHeight(0.0),
        child: AppBar(
          backgroundColor: Colors.blue,
          leading: Builder(builder: (context) {
            return Padding(
              padding: const EdgeInsets.only(top: 14, left: 3),
              child: IconButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                icon: const Icon(
                  FontAwesomeIcons.bars,
                  size: 20,
                ),
              ),
            );
          },

          ),
          title: const Padding(
            padding: EdgeInsets.only(top: 13),
            child: Text(
              "LAWHUB",
              style: TextStyle(
                  fontFamily: "patua",
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w100),
            ),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(top: 12, right: 3),
              child: IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.notifications,
                    size: 25,
                  )),
            )
          ],
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(-25),
                bottomRight: Radius.circular(-25)),
          ),
        ),
      ),
      drawer: isLoading ? const SizedBox() : drawer(imageURL: userData['profilePic'],userName: userData['name'], userEmail: userData['emailPhone'],),
      body: isLoading
          ? Container(
          height: double.infinity,
          width: double.infinity,
          color: Colors.white,
          child: const Center(child: SpinKitCircle(
              color: Colors.blue, size: 34),) )
          : _pages[_currentIndex],
      bottomNavigationBar: Container(
        height: 55,
        decoration: BoxDecoration(
          color: Colors.blue.shade600,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
              height: 55,
              width: 60,
              child: buildNavItem(FontAwesomeIcons.rocketchat, 'Chats', 0),
            ),
            SizedBox(
              height: 55,
              width: 60,
              child: buildNavItem(FontAwesomeIcons.userGroup, 'Requests', 1),
            ),
            SizedBox(
              height: 55,
              width: 60,
              child: buildNavItem(FontAwesomeIcons.solidUser, 'Profile', 2),
            )
          ],
        ),
      ),
    );
  }
  Widget buildNavItem(IconData icon, String label, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'roboto',
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LawyerChat();
  }
}

class Requests extends StatelessWidget{
  final Map<String, dynamic> userData;
  const Requests({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return LawyerRequests(userData: userData,);
  }
}

class ProfileScreen extends StatelessWidget {
  final Map<String, dynamic> userData;
  const ProfileScreen({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return LawyerProfile(userData: userData,);
  }
}