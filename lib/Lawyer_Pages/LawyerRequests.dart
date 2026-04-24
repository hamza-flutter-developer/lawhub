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

  Requests({
    required this.imageUrl,
    required this.senderName,
    required this.description,
    required this.status,
    required this.userID,
  });
}

class LawyerRequests extends StatefulWidget {
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

  late String lawyerId;

  bool isLoadingRequest = true;
  bool isRequestAvailable = false;
  bool isLoadingAccept = false;
  bool isLoadingReject = false;

  List<Requests> requestsList = [];

  Future<DocumentSnapshot> fetchAllRequests() async {
    return await FirebaseFirestore.instance
        .collection('Requests')
        .doc(widget.userData['id'])
        .get();
  }

  Future<DocumentSnapshot> fetchUserData(String userID) async {
    return await FirebaseFirestore.instance
        .collection('Users')
        .doc(userID)
        .get();
  }

  Future<void> checkRequests() async {
    var documentCheck = await FirebaseFirestore.instance
        .collection('Requests')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get();

    if (documentCheck.exists) {
      final data = await fetchAllRequests();
      int counter = data['counter'];
      int pendingCount = 0;

      for (int i = 1; i <= counter; i++) {
        if (data['Request$i'][2]['status'] == 'pending') {
          pendingCount++;
          String description = data['Request$i'][1]['caseDescription'];
          String userID = data['Request$i'][0]['userID'];
          fetchUserData(userID).then((value) {
            if (mounted) {
              setState(() {
                requestsList.add(Requests(
                  userID: value['id'],
                  imageUrl: value['profilePic'],
                  senderName: value['name'],
                  description: description,
                  status: 'pending',
                ));
              });
            }
          });
        }
      }
      if (mounted) {
        setState(() {
          isLoadingRequest = false;
          isRequestAvailable = pendingCount > 0;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          isLoadingRequest = false;
          isRequestAvailable = false;
        });
      }
    }
  }

  // ─────────────────────────────────────────────
  // ACCEPT REQUEST
  // ─────────────────────────────────────────────

  Future<void> updateRequestStatusAccept(String userID, int index) async {
    try {
      final data = await fetchAllRequests();
      int counter = data['counter'];

      for (int i = 1; i <= counter; i++) {
        if (data['Request$i'][0]['userID'] == userID &&
            data['Request$i'][2]['status'] == 'pending') {

          // Step 1: Update status
          await FirebaseFirestore.instance
              .collection('Requests')
              .doc(widget.userData['id'])
              .update({
            'Request$i': [
              {'userID': data['Request$i'][0]['userID']},
              {'caseDescription': data['Request$i'][1]['caseDescription']},
              {'status': 'accept'},
            ],
            'counter': counter,
          });

          // ✅ Step 2,3,4,5: Each awaited one by one — no race condition
          // ✅ lawyerId passed as parameter to every function — never null
          await addNotification(userID, 'accepts your request.', lawyerId);
          await addLawyersChat(userID, lawyerId);
          await addUsersChat(userID, lawyerId);
          await addChatRoom(userID, lawyerId);

          break;
        }
      }

      if (mounted) {
        setState(() {
          isLoadingAccept = false;
          requestsList[index].status = 'accept';
        });
      }
    } catch (e) {
      debugPrint('Accept error: $e');
      if (mounted) setState(() => isLoadingAccept = false);
    }
  }

  // ─────────────────────────────────────────────
  // REJECT REQUEST
  // ─────────────────────────────────────────────

  Future<void> updateRequestStatusReject(String userID, int index) async {
    try {
      final data = await fetchAllRequests();
      int counter = data['counter'];

      for (int i = 1; i <= counter; i++) {
        if (data['Request$i'][0]['userID'] == userID &&
            data['Request$i'][2]['status'] == 'pending') {
          await FirebaseFirestore.instance
              .collection('Requests')
              .doc(widget.userData['id'])
              .update({
            'Request$i': [
              {'userID': data['Request$i'][0]['userID']},
              {'caseDescription': data['Request$i'][1]['caseDescription']},
              {'status': 'reject'},
            ],
            'counter': counter,
          });

          await addNotification(userID, 'rejects your request.', lawyerId);
          break;
        }
      }

      if (mounted) {
        setState(() {
          isLoadingReject = false;
          requestsList[index].status = 'reject';
        });
      }
    } catch (e) {
      debugPrint('Reject error: $e');
      if (mounted) setState(() => isLoadingReject = false);
    }
  }

  // ─────────────────────────────────────────────
  // ADD NOTIFICATION
  // ✅ lawyerIdParam = explicit parameter, never null
  // ─────────────────────────────────────────────

  Future<void> addNotification(
      String userID, String type, String lawyerIdParam) async {
    try {
      final col = FirebaseFirestore.instance.collection('UsersNotifications');
      var doc = await col.doc(userID).get();
      if (doc.exists) {
        int counter = doc['counter'] + 1;
        await col.doc(userID).update({
          'Notification$counter': [
            {'lawyerID': lawyerIdParam},
            {'type': type},
            {'isSeen': false},
          ],
          'counter': counter,
        });
      } else {
        await col.doc(userID).set({
          'Notification1': [
            {'lawyerID': lawyerIdParam},
            {'type': type},
            {'isSeen': false},
          ],
          'counter': 1,
        });
      }
      debugPrint('✅ Notification saved: $lawyerIdParam → $userID');
    } catch (e) {
      debugPrint('❌ addNotification error: $e');
    }
  }

  // ─────────────────────────────────────────────
  // ADD LAWYERS CHAT
  // ✅ lawyerIdParam = explicit parameter, never null
  // ✅ Duplicate check prevents double entries
  // ─────────────────────────────────────────────

  Future<void> addLawyersChat(String userID, String lawyerIdParam) async {
    try {
      int minute = DateTime.now().minute;
      int hour = DateTime.now().hour;
      int day = DateTime.now().day;
      int month = DateTime.now().month;
      int milliSeconds = DateTime.now().millisecondsSinceEpoch;

      final col = FirebaseFirestore.instance.collection('LawyersChats');
      var doc = await col.doc(lawyerIdParam).get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        int counter = data['counter'];

        // Duplicate check
        for (int i = 1; i <= counter; i++) {
          if (data['userID$i'][0].toString() == userID) {
            debugPrint('⚠️ LawyersChat: $userID already exists — skipping');
            return;
          }
        }

        counter++;
        await col.doc(lawyerIdParam).update({
          'userID$counter': [userID, minute, hour, day, month, milliSeconds, 'Start Chatting', 'null'],
          'counter': counter,
        });
        debugPrint('✅ LawyersChat: added userID$counter = $userID');
      } else {
        await col.doc(lawyerIdParam).set({
          'userID1': [userID, minute, hour, day, month, milliSeconds, 'Start Chatting', 'null'],
          'counter': 1,
        });
        debugPrint('✅ LawyersChat: created first entry for $userID');
      }
    } catch (e) {
      debugPrint('❌ addLawyersChat error: $e');
    }
  }

  // ─────────────────────────────────────────────
  // ADD USERS CHAT
  // ✅ lawyerIdParam = explicit parameter, never null
  // ✅ Duplicate check prevents double entries
  // ─────────────────────────────────────────────

  Future<void> addUsersChat(String userID, String lawyerIdParam) async {
    try {
      int minute = DateTime.now().minute;
      int hour = DateTime.now().hour;
      int day = DateTime.now().day;
      int month = DateTime.now().month;
      int milliSeconds = DateTime.now().millisecondsSinceEpoch;

      final col = FirebaseFirestore.instance.collection('UsersChats');
      var doc = await col.doc(userID).get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        int counter = data['counter'];

        // Duplicate check
        for (int i = 1; i <= counter; i++) {
          if (data['lawyerID$i'][0].toString() == lawyerIdParam) {
            debugPrint('⚠️ UsersChat: $lawyerIdParam already exists for $userID — skipping');
            return;
          }
        }

        counter++;
        await col.doc(userID).update({
          'lawyerID$counter': [lawyerIdParam, minute, hour, day, month, milliSeconds, 'Start Chatting', 'null'],
          'counter': counter,
        });
        debugPrint('✅ UsersChat: added lawyerID$counter = $lawyerIdParam for $userID');
      } else {
        await col.doc(userID).set({
          'lawyerID1': [lawyerIdParam, minute, hour, day, month, milliSeconds, 'Start Chatting', 'null'],
          'counter': 1,
        });
        debugPrint('✅ UsersChat: created first entry $lawyerIdParam for $userID');
      }
    } catch (e) {
      debugPrint('❌ addUsersChat error: $e');
    }
  }

  // ─────────────────────────────────────────────
  // ADD CHAT ROOM
  // ─────────────────────────────────────────────

  Future<void> addChatRoom(String userID, String lawyerIdParam) async {
    try {
      await FirebaseFirestore.instance
          .collection('ChatRooms')
          .doc('$lawyerIdParam$userID')
          .set({});
      debugPrint('✅ ChatRoom created: $lawyerIdParam$userID');
    }  catch (e, stackTrace) {
  debugPrint('❌ addUsersChat error: $e');
  debugPrint('❌ Stack: $stackTrace');
}
  }

  // ─────────────────────────────────────────────
  // INIT STATE
  // ─────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    lawyerId = widget.userData['id'];
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (mounted) {
        setState(() {
          if (_focusNode.hasFocus) isCancelPressed = true;
        });
      }
    });
    checkRequests();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _searchController.dispose();
    super.dispose();
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
              padding: const EdgeInsets.only(left: 25, right: 25, top: 15),
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
                        style: const TextStyle(fontFamily: 'roboto', fontSize: 15),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 5),
                          border: InputBorder.none,
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                          ),
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(left: 15, right: 15),
                            child: Icon(Icons.search, size: 20, color: Colors.grey),
                          ),
                          prefixIconConstraints: const BoxConstraints(minHeight: 10),
                          hintText: 'Search...',
                          hintStyle: const TextStyle(fontFamily: 'roboto', fontSize: 18, color: Colors.grey),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: InkWell(
                              onTap: () { _searchController.clear(); setState(() {}); },
                              child: const Icon(Icons.clear, size: 19, color: Colors.grey),
                            ),
                          ),
                          suffixIconConstraints: const BoxConstraints(minHeight: 10),
                        ),
                        onChanged: (value) => setState(() {}),
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
                          setState(() { _focusNode.unfocus(); isCancelPressed = false; });
                        },
                        child: const Text('Cancel', style: TextStyle(color: Colors.blue)),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.only(left: 30, top: 20, bottom: 15),
                child: Text("Requests", style: TextStyle(fontFamily: 'roboto', fontSize: 22, fontWeight: FontWeight.bold)),
              ),
            ),

            isLoadingRequest
                ? Container(
              height: 500,
              width: double.infinity,
              color: Colors.white,
              child: const Center(child: SpinKitCircle(color: Colors.blue, size: 34)),
            )
                : isRequestAvailable
                ? ListView.builder(
              itemCount: requestsList.length,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                var itemData = requestsList[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (selected == index) {
                        isExpanded = !isExpanded;
                      } else {
                        selected = index;
                        isExpanded = true;
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 15, right: 20, left: 20),
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.all(Radius.circular(25)),
                        boxShadow: [BoxShadow(color: Colors.black12.withOpacity(0.35), blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 25,
                                child: ClipOval(
                                  child: (itemData.imageUrl != 'null' && itemData.imageUrl != null)
                                      ? Image.network(itemData.imageUrl, height: 70, width: 70, fit: BoxFit.cover)
                                      : const Icon(Icons.person, size: 35, color: Colors.grey),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(itemData.senderName, style: const TextStyle(fontFamily: 'roboto', fontWeight: FontWeight.bold, fontSize: 17)),
                                    const SizedBox(height: 5),
                                    Text(
                                      (selected == index && isExpanded)
                                          ? itemData.description
                                          : itemData.description.length > 52
                                          ? '${itemData.description.substring(0, 52)}... Tap to view more'
                                          : itemData.description,
                                      textAlign: TextAlign.justify,
                                      style: const TextStyle(fontFamily: 'roboto', fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (selected == index && isExpanded) ...[
                            const SizedBox(height: 10),
                            if (itemData.status == 'pending')
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    onPressed: isLoadingReject ? null : () async {
                                      setState(() => isLoadingReject = true);
                                      await updateRequestStatusReject(itemData.userID, index);
                                      if (mounted) setState(() => isLoadingReject = false);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      fixedSize: const Size(100, 40),
                                      backgroundColor: Colors.deepOrangeAccent,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                    ),
                                    child: isLoadingReject
                                        ? const SizedBox(height: 20, width: 20, child: SpinKitCircle(color: Colors.white, size: 20))
                                        : const Text('Reject', style: TextStyle(color: Colors.white, fontFamily: 'roboto', fontSize: 16, fontWeight: FontWeight.bold)),
                                  ),
                                  ElevatedButton(
                                    onPressed: isLoadingAccept ? null : () async {
                                      setState(() => isLoadingAccept = true);
                                      await updateRequestStatusAccept(itemData.userID, index);
                                      if (mounted) setState(() => isLoadingAccept = false);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      fixedSize: const Size(100, 40),
                                      backgroundColor: Colors.lightGreen,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                    ),
                                    child: isLoadingAccept
                                        ? const SizedBox(height: 20, width: 20, child: SpinKitCircle(color: Colors.white, size: 20))
                                        : const Text('Accept', style: TextStyle(color: Colors.white, fontFamily: 'roboto', fontSize: 16, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              )
                            else if (itemData.status == 'accept')
                              const SizedBox(
                                height: 30,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(FontAwesomeIcons.circleCheck, color: Colors.lightGreen, size: 20),
                                    SizedBox(width: 10),
                                    Text('Accepted', style: TextStyle(fontFamily: 'roboto', fontSize: 16, color: Colors.lightGreen)),
                                  ],
                                ),
                              )
                            else
                              const SizedBox(
                                height: 30,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(FontAwesomeIcons.circleXmark, color: Colors.deepOrangeAccent, size: 20),
                                    SizedBox(width: 10),
                                    Text('Rejected', style: TextStyle(fontFamily: 'roboto', fontSize: 16, color: Colors.deepOrangeAccent)),
                                  ],
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            )
                : Padding(
              padding: const EdgeInsets.only(top: 10),
              child: SizedBox(
                width: double.infinity,
                child: Center(
                  child: Text('No Requests Yet', style: TextStyle(fontFamily: 'roboto', fontSize: 16, color: Colors.grey.shade500)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}