// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../Chat_Pages/ChatInbox.dart';

/// ============================================================
/// Chats — Data model
///
/// Holds all display fields for a single chat conversation entry.
/// milliSeconds is used to sort chats newest-first.
/// messageBy determines the "You:" / "User:" prefix logic.
/// ============================================================
class Chats {
  final String lawyerID;
  final String imageUrl;
  final String lawyerName;
  final String time;
  final String lastMsg;
  final int milliSeconds;
  final String messageBy;

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

/// ============================================================
/// LawyerChat — StatefulWidget
///
/// The chat list screen shown to a logged-in lawyer.
/// Displays all active conversations sorted newest-first.
/// Includes a live search bar to filter by user name.
///
/// Flow:
///   initState → checkUserChats()
///   → checks if LawyersChats doc exists
///   → if yes: fetchAllUserChats() + fetchLawyerData() per entry
///   → populates chatList → ListView renders each chat row
/// ============================================================
class LawyerChat extends StatefulWidget {
  const LawyerChat({super.key});

  @override
  State<LawyerChat> createState() => _LawyerChatState();
}

class _LawyerChatState extends State<LawyerChat>
    with TickerProviderStateMixin {

  // ─── ORIGINAL STATE VARIABLES (completely untouched) ───────────────────

  /// Controls the search text field
  final TextEditingController _searchController = TextEditingController();

  /// FocusNode for the search field — shows/hides Cancel button
  late FocusNode _focusNode;

  /// True when the search field is focused → shows Cancel button
  bool isCancelPressed = false;

  /// True while chat data is being fetched from Firestore
  bool isLoading = true;

  /// True if the lawyer has any chats in LawyersChats collection
  bool isChatsAvailable = false;

  /// The full list of chat conversations populated by checkUserChats()
  List<Chats> chatList = [];

  // ─── ANIMATION CONTROLLERS (UI only — zero impact on logic) ───────────

  /// Drives the page-level fade + slide entrance
  late AnimationController _entranceController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // ============================================================
  // initState — runs once when this widget is first created.
  //
  // 1. Sets up entrance animation.
  // 2. Sets up the FocusNode listener that shows the Cancel button.
  // 3. Calls the original checkUserChats() to fetch data.
  // ============================================================
  @override
  void initState() {
    super.initState();

    // Page entrance animation
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    ));
    _entranceController.forward();

    // ORIGINAL: FocusNode listener that toggles Cancel button visibility
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        if (_focusNode.hasFocus) {
          isCancelPressed = true;
        }
      });
    });

    // ORIGINAL: start fetching chat data
    checkUserChats();
  }

  // ============================================================
  // dispose — clean up controllers to avoid memory leaks
  // ============================================================
  @override
  void dispose() {
    _entranceController.dispose();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ╔══════════════════════════════════════════════════════════╗
  //  ALL METHODS BELOW ARE 100% ORIGINAL LOGIC
  //  Only comments have been added — no code was changed.
  // ╚══════════════════════════════════════════════════════════╝

  // ============================================================
  // checkUserChats  ← ORIGINAL LOGIC
  //
  // Checks if the lawyer has a document in LawyersChats.
  //   Not exists → isLoading=false, isChatsAvailable=false
  //   Exists     → isChatsAvailable=true, then fetches all chats:
  //     For each entry builds a dateTime string (today=time, else=date)
  //     then calls fetchLawyerData() to get user profile data
  //     and adds a Chats entry to chatList.
  // ============================================================
  Future<void> checkUserChats() async {
    var documentCheck = await FirebaseFirestore.instance
        .collection('LawyersChats')
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
            for (int i = 1; i <= data['counter']; i++) {
              // Build human-readable time string
              String dateTime;
              if (data['userID$i'][3] == DateTime.now().day &&
                  data['userID$i'][4] == DateTime.now().month) {
                // Same day → show HH:MM AM/PM
                String minute = data['userID$i'][1] < 10
                    ? '0${data['userID$i'][1]}'
                    : '${data['userID$i'][1]}';
                String hour = data['userID$i'][2] >= 12
                    ? '${data['userID$i'][2] - 12}'
                    : '${data['userID$i'][2]}';
                String amPm = data['userID$i'][2] >= 12 ? 'PM' : 'AM';
                dateTime = '$hour:$minute $amPm';
              } else {
                // Different day → show "Mon, DD"
                String date = data['userID$i'][3] < 10
                    ? '0${data['userID$i'][3]}'
                    : '${data['userID$i'][3]}';
                dateTime = '${checkMonth(data['userID$i'][4])}, $date';
              }
              // Fetch user profile data (name, profilePic, id)
              fetchLawyerData(data['userID$i'][0]).then((value) {
                setState(() {
                  chatList.add(Chats(
                    lawyerID: value['id'],
                    imageUrl: value['profilePic'],
                    lawyerName: value['name'],
                    time: dateTime,
                    lastMsg: data['userID$i'][6],
                    milliSeconds: data['userID$i'][5],
                    messageBy: data['userID$i'][7],
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

  // ============================================================
  // fetchAllUserChats  ← ORIGINAL LOGIC
  //
  // Reads the lawyer's LawyersChats document and returns the full
  // data map containing all userID1, userID2…userIDN entries.
  // ============================================================
  Future<Map<String, dynamic>> fetchAllUserChats() async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('LawyersChats')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get();
    return userSnapshot.data() as Map<String, dynamic>;
  }

  // ============================================================
  // fetchLawyerData  ← ORIGINAL LOGIC (note: fetches from Users)
  //
  // Fetches the user's document from the Users collection using
  // their userID as the document key. Returns the full snapshot
  // (name, profilePic, id are read in checkUserChats).
  // ============================================================
  Future<DocumentSnapshot> fetchLawyerData(String userID) async {
    return await FirebaseFirestore.instance
        .collection('Users')
        .doc(userID)
        .get();
  }

  // ============================================================
  // checkMonth  ← ORIGINAL LOGIC
  //
  // Converts a numeric month (1–12) to a 3-letter abbreviation
  // shown in the chat list timestamp when the message is not today.
  // ============================================================
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

  // ============================================================
  // build — constructs the full UI tree
  //
  // Structure:
  //   Scaffold (dark navy background)
  //   └── SafeArea
  //       └── FadeTransition + SlideTransition (entrance)
  //           ├── header section ("Chats" title)
  //           ├── search bar
  //           └── body:
  //               isLoading          → full-screen spinner
  //               isChatsAvailable   → ListView of chat rows
  //               else               → "No chats available" message
  // ============================================================
  @override
  Widget build(BuildContext context) {
    // ORIGINAL: filter chatList by search text (case-insensitive)
    final filtered = _searchController.text.isEmpty
        ? chatList
        : chatList
        .where((c) => c.lawyerName
        .toLowerCase()
        .contains(_searchController.text.toLowerCase()))
        .toList();

    // Sort newest-first — ORIGINAL sort logic
    filtered.sort((a, b) => b.milliSeconds.compareTo(a.milliSeconds));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Header ────────────────────────────────────────────
                _buildHeader(),

                // ── Search bar ────────────────────────────────────────
                _buildSearchBar(),

                const SizedBox(height: 8),

                // ── Body: spinner / list / empty state ────────────────
                Expanded(child: _buildBody(filtered)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // _buildHeader — "Chats" title section
  //
  // Purely visual. Replaces the plain Text widget with a styled
  // header that has a count badge showing number of conversations.
  // ============================================================
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Row(
        children: [
          const Text(
            'Chats',
            style: TextStyle(
              color: Color(0xFF1A1A2E),
              fontFamily: 'roboto',
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(width: 10),
          if (!isLoading && chatList.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF1E88E5).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFF1E88E5).withOpacity(0.4)),
              ),
              child: Text(
                '${chatList.length}',
                style: const TextStyle(
                  color: Color(0xFF1E88E5),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // _buildSearchBar — search field + Cancel button
  //
  // ORIGINAL logic fully preserved:
  //   _searchController drives filtering in build()
  //   _focusNode shows/hides Cancel button via isCancelPressed
  //   Cancel: clears text, unfocuses, sets isCancelPressed=false
  //   Clear X: clears text + triggers setState
  //   onChanged: triggers setState (re-filters list)
  // ============================================================
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                // ── ORIGINAL: controller + focusNode + onChanged ──────
                controller: _searchController,
                focusNode: _focusNode,
                style: const TextStyle(
                  fontFamily: 'roboto',
                  fontSize: 15,
                  color: Color(0xFF1A1A2E),
                ),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 12),
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.search,
                      size: 20, color: Colors.grey),
                  hintText: 'Search...',
                  hintStyle: const TextStyle(
                    fontFamily: 'roboto',
                    fontSize: 15,
                    color: Colors.grey,
                  ),
                  // ── ORIGINAL: clear X button ───────────────────────
                  suffixIcon: _searchController.text.isNotEmpty
                      ? InkWell(
                    onTap: () {
                      _searchController.clear();
                      setState(() {});
                    },
                    child: const Icon(Icons.clear,
                        size: 18, color: Colors.grey),
                  )
                      : null,
                ),
                // ── ORIGINAL: onChanged triggers setState to re-filter
                onChanged: (value) => setState(() {}),
              ),
            ),
          ),

          // ── ORIGINAL: Cancel button appears when field is focused ──
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: isCancelPressed
                ? Padding(
              padding: const EdgeInsets.only(left: 12),
              child: InkWell(
                onTap: () {
                  // ── ORIGINAL Cancel logic ──────────────────────
                  _searchController.clear();
                  setState(() {
                    _focusNode.unfocus();
                    isCancelPressed = false;
                  });
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Color(0xFF1E88E5),
                    fontFamily: 'roboto',
                    fontSize: 15,
                  ),
                ),
              ),
            )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // _buildBody — renders spinner / list / empty state
  //
  // ORIGINAL logic:
  //   isLoading          → SpinKitCircle spinner
  //   isChatsAvailable   → ListView.builder of chat rows
  //   else               → "No chats available" text
  // ============================================================
  Widget _buildBody(List<Chats> filtered) {
    if (isLoading) {
      // ── ORIGINAL: full-screen spinner ─────────────────────────────
      return const Center(
        child: SpinKitCircle(color: Color(0xFF1E88E5), size: 34),
      );
    }

    if (!isChatsAvailable) {
      // ── ORIGINAL: no chats message ────────────────────────────────
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline_rounded,
                size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No chats available',
              style: TextStyle(
                fontFamily: 'roboto',
                fontSize: 16,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      );
    }

    // ── ORIGINAL: ListView of chat rows ───────────────────────────
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        return _buildChatRow(filtered[index]);
      },
    );
  }

  // ============================================================
  // _buildChatRow — renders a single conversation list item
  //
  // ORIGINAL logic fully preserved:
  //   onTap → Navigator.push to UserInbox with all original params
  //   messageBy == 'null'      → show lastMsg as-is
  //   messageBy == currentUser → show "You: lastMsg"
  //   else                     → show "User: lastMsg"
  //
  // UI: glassmorphic card, circular avatar, name + preview + time
  // ============================================================
  Widget _buildChatRow(Chats itemData) {
    // ORIGINAL: determine last message prefix
    final String currentEmail =
    FirebaseAuth.instance.currentUser!.email.toString();
    final String preview = itemData.messageBy == 'null'
        ? itemData.lastMsg
        : itemData.messageBy == currentEmail
        ? 'You: ${itemData.lastMsg}'
        : 'User: ${itemData.lastMsg}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            // ── ORIGINAL: navigate to UserInbox ───────────────────────
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => UserInbox(
                  userId: itemData.lawyerID,
                  lawyerId: currentEmail,
                  imgUrl: itemData.imageUrl,
                  name: itemData.lawyerName,
                  isUser: false,
                ),
              ),
            );
          },
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              child: Row(
                children: [

                  // ── Avatar ───────────────────────────────────────────
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF1E88E5).withOpacity(0.4),
                        width: 1.5,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        itemData.imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  // ── Name + last message preview ───────────────────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          itemData.lawyerName,
                          style: const TextStyle(
                            fontFamily: 'roboto',
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          preview,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'roboto',
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Timestamp ─────────────────────────────────────────
                  Text(
                    itemData.time,
                    style: TextStyle(
                      fontFamily: 'roboto',
                      fontSize: 12,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}