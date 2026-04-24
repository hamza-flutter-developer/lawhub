// ══════════════════════════════════════════════════════════════════════════════
// FILE: UserChat.dart
// PURPOSE: Chat list screen showing all user's conversations with lawyers
// ══════════════════════════════════════════════════════════════════════════════

// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lawhub/Chat_Pages/ChatInbox.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// UserChat Widget (StatefulWidget)
/// ═══════════════════════════════════════════════════════════════════════════
/// Displays list of all chats with lawyers:
/// - Search functionality
/// - Shows last message preview
/// - Sorted by most recent
/// - Displays timestamp (time or date)
/// - Empty state when no chats
class UserChat extends StatefulWidget {
  const UserChat({super.key});

  @override
  State<UserChat> createState() => _UserChatState();
}

/// ═══════════════════════════════════════════════════════════════════════════
/// Chats Data Class
/// ═══════════════════════════════════════════════════════════════════════════
/// Simple data structure to hold chat information
/// Think of it as a "container" for organizing chat data
class Chats {
  final String lawyerID;
  final String imageUrl;
  final String lawyerName;
  final String time;
  final String lastMsg;
  final int milliSeconds; // For sorting (most recent first)
  final String messageBy; // Who sent the last message

  Chats({
    required this.lawyerID,
    required this.imageUrl,
    required this.lawyerName,
    required this.time,
    required this.lastMsg,
    required this.milliSeconds,
    required this.messageBy,
  });
}

class _UserChatState extends State<UserChat> {
  // ─────────────────────────────────────────────────────────────────────────
  // STATE VARIABLES
  // ─────────────────────────────────────────────────────────────────────────

  /// Search functionality
  final TextEditingController _searchController = TextEditingController();
  late FocusNode _focusNode;
  bool isCancelPressed = false;

  /// Loading and data states
  bool isLoading = true;
  bool isChatsAvailable = false;
  List<Chats> chatList = [];

  // ═════════════════════════════════════════════════════════════════════════
  // FIRESTORE DATA FETCHING - YOUR EXISTING LOGIC (UNCHANGED)
  // ═════════════════════════════════════════════════════════════════════════

  /// ───────────────────────────────────────────────────────────────────────
  /// FUNCTION: checkUserChats()
  /// PURPOSE: Checks if user has any chats and loads them
  /// ───────────────────────────────────────────────────────────────────────
  /// FLOW:
  /// 1. Check if UsersChats document exists
  /// 2. If not → Show empty state
  /// 3. If yes → Fetch all chat data and lawyer details
  Future<void> checkUserChats() async {
    var documentCheck = await FirebaseFirestore.instance
        .collection('UsersChats')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get();

    if (!documentCheck.exists) {
      setState(() {
        isLoading = false;
        isChatsAvailable = false;
      });
    } else {
      setState(() {
        isChatsAvailable = true;
        fetchAllUserChats().then((data) {
          setState(() {
            /// Loop through all chats and format the data
            for (int i = 1; i <= data['counter']; i++) {
              String dateTime;

              // Format timestamp (show time if today, date if older)
              if (data['lawyerID$i'][3] == DateTime.now().day &&
                  data['lawyerID$i'][4] == DateTime.now().month) {
                String minute = data['lawyerID$i'][1] < 10
                    ? '0${data['lawyerID$i'][1]}'
                    : '${data['lawyerID$i'][1]}';
                String hour = data['lawyerID$i'][2] >= 12
                    ? '${data['lawyerID$i'][2] - 12}'
                    : '${data['lawyerID$i'][2]}';
                String amPm = data['lawyerID$i'][2] >= 12 ? 'PM' : 'AM';
                dateTime = '$hour:$minute $amPm';
              } else {
                String date = data['lawyerID$i'][3] < 10
                    ? '0${data['lawyerID$i'][3]}'
                    : '${data['lawyerID$i'][3]}';
                dateTime = '${checkMonth(data['lawyerID$i'][4])}, $date';
              }

              // Fetch lawyer details for each chat
              fetchLawyerData(data['lawyerID$i'][0]).then((value) {
                setState(() {
                  chatList.add(Chats(
                    lawyerID: value['id'],
                    imageUrl: value['profilePic'],
                    lawyerName: value['name'],
                    time: dateTime,
                    lastMsg: data['lawyerID$i'][6],
                    milliSeconds: data['lawyerID$i'][5],
                    messageBy: data['lawyerID$i'][7],
                  ));
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

  /// Fetches user's chat document from Firestore
  Future<Map<String, dynamic>> fetchAllUserChats() async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('UsersChats')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get();

    Map<String, dynamic> userChatsData =
    userSnapshot.data() as Map<String, dynamic>;
    return userChatsData;
  }

  /// Fetches lawyer profile data
  Future<DocumentSnapshot> fetchLawyerData(String lawyerID) async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('Lawyers')
        .doc(lawyerID)
        .get();
    return userSnapshot;
  }

  /// ───────────────────────────────────────────────────────────────────────
  /// FUNCTION: checkMonth()
  /// PURPOSE: Converts month number to 3-letter abbreviation
  /// ───────────────────────────────────────────────────────────────────────
  String checkMonth(int index) {
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

  // ═════════════════════════════════════════════════════════════════════════
  // INITIALIZATION
  // ═════════════════════════════════════════════════════════════════════════

  @override
  void initState() {
    checkUserChats();
    _focusNode = FocusNode();

    /// Listen for search field focus changes
    _focusNode.addListener(() {
      setState(() {
        if (_focusNode.hasFocus) {
          isCancelPressed = true;
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ═════════════════════════════════════════════════════════════════════════
  // BUILD METHOD: Creates the UI
  // ═════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: Column(
          children: [
            // ═══════════════════════════════════════════════════════════════
            // SEARCH BAR
            // ═══════════════════════════════════════════════════════════════
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 15),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(13),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _focusNode,
                        style: const TextStyle(
                          fontFamily: 'roboto',
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding:
                          const EdgeInsets.symmetric(vertical: 12),
                          border: InputBorder.none,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: const Color(0xFF1565C0).withAlpha(128),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(left: 20, right: 15),
                            child: Icon(Icons.search_rounded,
                                size: 22, color: Colors.grey),
                          ),
                          prefixIconConstraints:
                          const BoxConstraints(minHeight: 10),
                          hintText: 'Search chats...',
                          hintStyle: TextStyle(
                            fontFamily: 'roboto',
                            fontSize: 16,
                            color: Colors.grey[400],
                          ),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: InkWell(
                              onTap: () {
                                _searchController.clear();
                                setState(() {});
                              },
                              child: Icon(
                                Icons.clear_rounded,
                                size: 20,
                                color: Colors.grey[400],
                              ),
                            ),
                          ),
                          suffixIconConstraints:
                          const BoxConstraints(minHeight: 10),
                        ),
                        onChanged: (String value) {
                          setState(() {});
                        },
                      ),
                    ),
                  ),

                  /// Cancel button (appears when searching)
                  Visibility(
                    visible: isCancelPressed,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: InkWell(
                        onTap: () {
                          _searchController.clear();
                          setState(() {
                            _focusNode.unfocus();
                            isCancelPressed = false;
                          });
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Color(0xFF1565C0),
                            fontFamily: 'roboto',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ═══════════════════════════════════════════════════════════════
            // PAGE TITLE
            // ═══════════════════════════════════════════════════════════════
            const SizedBox(
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.only(left: 24, top: 24, bottom: 16),
                child: Text(
                  "Messages",
                  style: TextStyle(
                    fontFamily: 'roboto',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ),

            // ═══════════════════════════════════════════════════════════════
            // CHAT LIST OR LOADING/EMPTY STATE
            // ═══════════════════════════════════════════════════════════════
            isLoading
                ? Container(
              height: 500,
              width: double.infinity,
              color: Colors.transparent,
              child: const Center(
                child: SpinKitCircle(
                  color: Color(0xFF1565C0),
                  size: 40,
                ),
              ),
            )
                : isChatsAvailable
                ? ListView.builder(
              itemBuilder: (context, index) {
                /// Sort by most recent first
                chatList.sort((a, b) =>
                    b.milliSeconds.compareTo(a.milliSeconds));
                var itemData = chatList[index];

                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: 12,
                    right: 20,
                    left: 20,
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserInbox(
                            userId: FirebaseAuth
                                .instance.currentUser!.email
                                .toString(),
                            lawyerId: itemData.lawyerID,
                            imgUrl: itemData.imageUrl,
                            name: itemData.lawyerName,
                            isUser: true,
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(13),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // ── Lawyer Profile Picture ──
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF1565C0)
                                      .withAlpha(51),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.grey[200],
                              child: ClipOval(
                                child: Image.network(
                                  itemData.imageUrl,
                                  height: 56,
                                  width: 56,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) {
                                    return Icon(
                                      Icons.person,
                                      size: 32,
                                      color: Colors.grey[400],
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 16),

                          // ── Chat Info ──
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        itemData.lawyerName,
                                        style: const TextStyle(
                                          fontFamily: 'roboto',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Color(0xFF1A1A1A),
                                        ),
                                        overflow:
                                        TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      itemData.time,
                                      style: TextStyle(
                                        fontFamily: 'roboto',
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),

                                // ── Last Message Preview ──
                                itemData.messageBy == 'null'
                                    ? Text(
                                  itemData.lastMsg,
                                  style: TextStyle(
                                    fontFamily: 'roboto',
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow:
                                  TextOverflow.ellipsis,
                                )
                                    : itemData.messageBy ==
                                    FirebaseAuth.instance
                                        .currentUser!.email
                                        .toString()
                                    ? Text(
                                  'You: ${itemData.lastMsg}',
                                  style: TextStyle(
                                    fontFamily: 'roboto',
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow:
                                  TextOverflow.ellipsis,
                                )
                                    : Text(
                                  itemData.lastMsg,
                                  style: const TextStyle(
                                    fontFamily: 'roboto',
                                    fontSize: 14,
                                    color: Color(0xFF1A1A1A),
                                    fontWeight:
                                    FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow:
                                  TextOverflow.ellipsis,
                                ),
                              ],
                            ),
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
              padding: const EdgeInsets.only(top: 100),
              child: Column(
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No messages yet',
                    style: TextStyle(
                      fontFamily: 'roboto',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start a conversation with a lawyer',
                    style: TextStyle(
                      fontFamily: 'roboto',
                      fontSize: 15,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// ══════════════════════════════════════════════════════════════════════════════
// KEY CONCEPTS IN THIS FILE:
// ══════════════════════════════════════════════════════════════════════════════
//
// 1. Data Class Pattern:
//    - Chats class is a simple container for organizing data
//    - Named parameters make code more readable
//    - Similar to a "struct" in other languages
//
// 2. Sorting Lists:
//    - .sort() method modifies list in place
//    - Comparator function (a, b) determines order
//    - b.compareTo(a) = descending (newest first)
//    - a.compareTo(b) = ascending (oldest first)
//
// 3. Conditional Rendering:
//    - isLoading ? LoadingWidget : ContentWidget
//    - Shows different UI based on state
//    - Provides good user experience
//
// 4. DateTime Formatting:
//    - Shows "9:30 PM" if message from today
//    - Shows "Jan, 15" if message from another day
//    - Improves readability
//
// 5. ListView.builder:
//    - Only builds visible items (efficient for long lists)
//    - shrinkWrap: true = size to fit content
//    - NeverScrollableScrollPhysics = disable list scrolling (parent scrolls)
//
// 6. Search with FocusNode:
//    - FocusNode tracks if field is active
//    - addListener() runs code when focus changes
//    - Used to show/hide Cancel button
//
// 7. Empty State Pattern:
//    - Shows helpful message when no data
//    - Icon + text = better UX than just text
//    - Guides user on what to do next
//
// ══════════════════════════════════════════════════════════════════════════════