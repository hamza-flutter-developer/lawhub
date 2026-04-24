// ══════════════════════════════════════════════════════════════════════════════
// FILE: ChatInbox.dart  (UPDATED — AI Smart Call integration)
// CHANGES FROM ORIGINAL:
//   1. Video call button added to AppBar (top right)
//   2. New bubble types: 'ai_definition' and 'call_summary'
//   3. ai_definition only shown to client (isUser == true)
//   4. call_summary shown to both client and lawyer
//   5. All original logic is 100% preserved
// ══════════════════════════════════════════════════════════════════════════════

// ignore_for_file: file_names

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lawhub/Chat_Pages/ImageDisplay.dart';
import 'package:lawhub/Call_Pages/CallScreen.dart';   // ← NEW IMPORT
import '../User_Pages/UserStartCase.dart';

class UserInbox extends StatefulWidget {
  final bool isUser;
  final String userId;
  final String lawyerId;
  final String imgUrl;
  final String name;

  const UserInbox({
    Key? key,
    required this.userId,
    required this.lawyerId,
    required this.imgUrl,
    required this.name,
    required this.isUser,
  }) : super(key: key);

  @override
  State<UserInbox> createState() => _UserInboxState();
}

class _UserInboxState extends State<UserInbox> {
  // ─── ORIGINAL STATE VARIABLES (completely untouched) ───────────────────
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final textFieldFocusNode = FocusNode();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = false;
  String? imgUrl;
  bool isImageShow = false;
  String? imageToDisplay;
  File? _image;
  final picker = ImagePicker();
  final fireStoreUserChat =
  FirebaseFirestore.instance.collection('UsersChats');
  final fireStoreLawyerChat =
  FirebaseFirestore.instance.collection('LawyersChats');

  @override
  void initState() {
    super.initState();
    textFieldFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    textFieldFocusNode.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ALL ORIGINAL METHODS — completely unchanged
  // ══════════════════════════════════════════════════════════════════════════

  void sendTextMessage() async {
    if (_messageController.text.isNotEmpty) {
      int minuteInt = DateTime.now().minute;
      int hourInt = DateTime.now().hour;
      int dayInt = DateTime.now().day;
      int monthInt = DateTime.now().month;
      String minute = minuteInt < 10 ? '0$minuteInt' : '$minuteInt';
      String hour = hourInt >= 12 ? '${hourInt - 12}' : '$hourInt';
      String amPm = hourInt >= 12 ? 'PM' : 'AM';
      String date = dayInt < 10 ? '0$dayInt' : '$dayInt';
      String month = checkMonth(monthInt);
      String dateTime = '$date $month $hour:$minute $amPm';

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
    } else {
      debugPrint("Enter Some Text");
    }
  }

  String checkMonth(int index) {
    switch (index) {
      case 1:  return 'Jan';
      case 2:  return 'Feb';
      case 3:  return 'Mar';
      case 4:  return 'Apr';
      case 5:  return 'May';
      case 6:  return 'Jun';
      case 7:  return 'Jul';
      case 8:  return 'Aug';
      case 9:  return 'Sep';
      case 10: return 'Oct';
      case 11: return 'Nov';
      case 12: return 'Dec';
      default: return '';
    }
  }

  Future getImageGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() { _image = File(pickedFile.path); });
      // ignore: use_build_context_synchronously
      Navigator.push(context, MaterialPageRoute(
        builder: (context) => ImageDisplay(
          img: _image,
          lawyerId: widget.lawyerId,
          userId: widget.userId,
        ),
      ));
    }
  }

  Future getImageCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() { _image = File(pickedFile.path); });
      // ignore: use_build_context_synchronously
      Navigator.push(context, MaterialPageRoute(
        builder: (context) => ImageDisplay(
          img: _image,
          lawyerId: widget.lawyerId,
          userId: widget.userId,
        ),
      ));
    }
  }

  Future updateUserLastMessage(String message) async {
    int minute       = DateTime.now().minute;
    int hour         = DateTime.now().hour;
    int day          = DateTime.now().day;
    int month        = DateTime.now().month;
    int milliSeconds = DateTime.now().millisecondsSinceEpoch;
    var doc = await FirebaseFirestore.instance
        .collection('UsersChats')
        .doc(widget.userId)
        .get();
    int counter = doc['counter'];
    for (int i = 1; i <= counter; i++) {
      if (doc['lawyerID$i'][0] == widget.lawyerId) {
        await fireStoreUserChat.doc(widget.userId).update({
          'lawyerID$i': [
            widget.lawyerId, minute, hour, day, month,
            milliSeconds, message,
            FirebaseAuth.instance.currentUser!.email.toString()
          ],
          'counter': counter,
        });
      }
    }
  }

  Future updateLawyerLastMessage(String message) async {
    int minute       = DateTime.now().minute;
    int hour         = DateTime.now().hour;
    int day          = DateTime.now().day;
    int month        = DateTime.now().month;
    int milliSeconds = DateTime.now().millisecondsSinceEpoch;
    var doc = await FirebaseFirestore.instance
        .collection('LawyersChats')
        .doc(widget.lawyerId)
        .get();
    int counter = doc['counter'];
    for (int i = 1; i <= counter; i++) {
      if (doc['userID$i'][0] == widget.userId) {
        await fireStoreLawyerChat.doc(widget.lawyerId).update({
          'userID$i': [
            widget.userId, minute, hour, day, month,
            milliSeconds, message,
            FirebaseAuth.instance.currentUser!.email.toString()
          ],
          'counter': counter,
        });
      }
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return isImageShow ? _buildImageViewer() : _buildChatScaffold();
  }

  Widget _buildImageViewer() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: InkWell(
          onTap: () => setState(() { isImageShow = false; }),
          child: const Padding(
            padding: EdgeInsets.only(top: 10, left: 10),
            child: Icon(FontAwesomeIcons.x, color: Colors.white, size: 20),
          ),
        ),
      ),
      body: Center(
        child: Image.network(
          imageToDisplay!,
          width: double.infinity,
          height: 500,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildChatScaffold() {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFF0A1628),
      body: Column(
        children: [
          SafeArea(bottom: false, child: _buildAppBar()),
          Expanded(child: _buildMessageStream()),
          _buildInputBar(),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // APP BAR — UPDATED: added video call button (top right)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildAppBar() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.08))),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            // Back button — original
            IconButton(
              icon: const Icon(FontAwesomeIcons.angleLeft,
                  color: Colors.white, size: 18),
              onPressed: () => Navigator.of(context).pop(),
            ),

            // Avatar + name — original
            CircleAvatar(
              backgroundImage: (widget.imgUrl != 'null' && widget.imgUrl.isNotEmpty)
                  ? NetworkImage(widget.imgUrl)
                  : null,
              radius: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.name,
                style: const TextStyle(
                  fontFamily: 'roboto',
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // ── NEW: Video call button ──────────────────────────────────
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E88E5).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: const Color(0xFF1E88E5).withOpacity(0.5)),
                ),
                child: const Icon(Icons.videocam_rounded,
                    color: Color(0xFF1E88E5), size: 20),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CallScreen(
                      userId: widget.userId,
                      lawyerId: widget.lawyerId,
                      isUser: widget.isUser,
                      otherPersonName: widget.name,
                      otherPersonImage: widget.imgUrl,

                    ),
                  ),
                );
              },
            ),

            // Original popup menu (user side only)
            widget.isUser
                ? PopupMenuButton<String>(
              icon: const Icon(FontAwesomeIcons.ellipsisVertical,
                  color: Colors.white),
              color: const Color(0xFF1B2A3B),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'start',
                  child: Text('Start Case',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
              onSelected: (value) {
                if (value == 'start') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          UserStartCase(lawyerId: widget.lawyerId),
                    ),
                  );
                }
              },
            )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // MESSAGE STREAM — UPDATED: handles ai_definition and call_summary types
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildMessageStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('ChatRooms')
          .doc("${widget.lawyerId}${widget.userId}")
          .collection('Chats')
          .orderBy('time', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          return ListView.builder(
            controller: _scrollController,
            reverse: true,
            itemCount: snapshot.data?.docs.length,
            itemBuilder: (context, index) {
              final doc      = snapshot.data!.docs[index];
              String message = doc['message'];
              String time    = doc['timeToDisplay'];
              String type    = doc['type'];
              bool isMe      = doc['senderId'] ==
                  FirebaseAuth.instance.currentUser!.email.toString();

              // ── NEW: AI definition bubble (client only) ────────────────
              if (type == 'ai_definition') {
                // Only show to client (isUser == true)
                if (!widget.isUser) return const SizedBox.shrink();
                return _buildAIDefinitionBubble(message, time);
              }

              // ── NEW: Call summary bubble (both sides) ──────────────────
              if (type == 'call_summary') {
                return _buildCallSummaryBubble(message, time);
              }

              // ── ORIGINAL: text and image bubbles ──────────────────────
              bool isTextType = type == 'text';
              if (isMe) {
                return isTextType
                    ? _buildSentTextBubble(message, time)
                    : _buildSentImageBubble(message, time);
              } else {
                return isTextType
                    ? _buildReceivedTextBubble(message, time)
                    : _buildReceivedImageBubble(message, time);
              }
            },
          );
        } else {
          return Container();
        }
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // NEW BUBBLE: AI Legal Term Definition (client chat only)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildAIDefinitionBubble(String message, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A3A5C), Color(0xFF0D2137)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF1E88E5).withOpacity(0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E88E5).withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E88E5).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: const Color(0xFF1E88E5).withOpacity(0.4)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome,
                          color: Color(0xFF1E88E5), size: 12),
                      SizedBox(width: 4),
                      Text(
                        'AI Legal Assistant',
                        style: TextStyle(
                          color: Color(0xFF1E88E5),
                          fontFamily: 'roboto',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  time,
                  style: const TextStyle(
                      color: Colors.white38,
                      fontFamily: 'roboto',
                      fontSize: 10),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Message content (term + definition)
            Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'roboto',
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // NEW BUBBLE: Call Summary (shown to both client and lawyer)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildCallSummaryBubble(String message, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1B3A2A), Color(0xFF0D2137)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF66BB6A).withOpacity(0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF66BB6A).withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Green header bar
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF66BB6A).withOpacity(0.15),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
                border: Border(
                  bottom: BorderSide(
                      color: const Color(0xFF66BB6A).withOpacity(0.3)),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.summarize_rounded,
                      color: Color(0xFF66BB6A), size: 16),
                  const SizedBox(width: 8),
                  const Text(
                    'AI Call Summary',
                    style: TextStyle(
                      color: Color(0xFF66BB6A),
                      fontFamily: 'roboto',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    time,
                    style: const TextStyle(
                        color: Colors.white38,
                        fontFamily: 'roboto',
                        fontSize: 10),
                  ),
                ],
              ),
            ),

            // Summary content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'roboto',
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ORIGINAL BUBBLE BUILDERS — 100% unchanged
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildSentTextBubble(String message, String time) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 8, left: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(0, 6, 0, 2),
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E88E5),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(message,
                  style: const TextStyle(
                      fontFamily: 'roboto', fontSize: 15, color: Colors.white)),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(time,
                  style: const TextStyle(fontSize: 11, color: Colors.white38)),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildSentImageBubble(String message, String time) {
    return InkWell(
      onTap: () => setState(() {
        imageToDisplay = message;
        isImageShow = true;
      }),
      child: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                height: 220,
                width: 200,
                margin: const EdgeInsets.fromLTRB(0, 6, 0, 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E88E5),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  child: isLoading
                      ? const Center(
                      child: SpinKitCircle(color: Colors.white, size: 30))
                      : Image.network(message, fit: BoxFit.cover),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(time,
                    style: const TextStyle(
                        fontSize: 11, color: Colors.white38)),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceivedTextBubble(String message, String time) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 8, right: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(0, 6, 0, 2),
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1B2E45),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(message,
                  style: const TextStyle(
                      fontFamily: 'roboto', fontSize: 15, color: Colors.white)),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(time,
                  style: const TextStyle(fontSize: 11, color: Colors.white38)),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildReceivedImageBubble(String message, String time) {
    return InkWell(
      onTap: () => setState(() {
        imageToDisplay = message;
        isImageShow = true;
      }),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 220,
                width: 200,
                margin: const EdgeInsets.fromLTRB(0, 6, 0, 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2E45),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  child: Image.network(message, fit: BoxFit.cover),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(time,
                    style: const TextStyle(
                        fontSize: 11, color: Colors.white38)),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ORIGINAL INPUT BAR — completely unchanged
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildInputBar() {
    return SafeArea(
      top: false,
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        decoration: BoxDecoration(
          color: const Color(0xFF0D2137),
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (context) => Container(
                    height: 140,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B2A3B),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            if (textFieldFocusNode.hasFocus) {
                              textFieldFocusNode.unfocus();
                            }
                            Navigator.pop(context);
                            getImageCamera();
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Camera',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'roboto',
                                        fontSize: 15)),
                                Icon(FontAwesomeIcons.cameraRetro,
                                    size: 22, color: Colors.white70),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Divider(
                              color: Colors.white.withOpacity(0.15), height: 1),
                        ),
                        InkWell(
                          onTap: () {
                            if (textFieldFocusNode.hasFocus) {
                              textFieldFocusNode.unfocus();
                            }
                            Navigator.pop(context);
                            getImageGallery();
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Photos',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'roboto',
                                        fontSize: 15)),
                                Icon(FontAwesomeIcons.image,
                                    size: 22, color: Colors.white70),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: Container(
                height: 56,
                width: 52,
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                        color: Colors.white.withOpacity(0.1), width: 1),
                  ),
                ),
                child: const Center(
                  child: Icon(FontAwesomeIcons.camera,
                      size: 20, color: Colors.white60),
                ),
              ),
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                focusNode: textFieldFocusNode,
                style: const TextStyle(
                    fontFamily: 'roboto', fontSize: 15, color: Colors.white),
                cursorColor: Colors.white,
                textAlignVertical: TextAlignVertical.center,
                decoration: const InputDecoration(
                  hintText: 'Write Message',
                  hintStyle: TextStyle(
                      fontFamily: 'roboto', fontSize: 15, color: Colors.white38),
                  border: InputBorder.none,
                  contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(FontAwesomeIcons.circleArrowUp,
                  size: 26, color: Color(0xFF1E88E5)),
              onPressed: sendTextMessage,
            ),
          ],
        ),
      ),
    );
  }
}