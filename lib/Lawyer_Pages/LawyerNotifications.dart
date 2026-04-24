// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// ============================================================
/// LawyerNotificationPage — StatefulWidget
///
/// Shows all notifications received by the lawyer.
/// Notifications are fetched from LawyersNotifications collection
/// and marked as seen (isSeen=true) as soon as this screen opens.
///
/// Parameter:
///   lawyerData → Map with the lawyer's data (id, name, etc.)
///
/// Flow on load:
///   1. checkNotification()        → fetches and builds notificationList
///   2. checkNotificationSeenStatus() → marks all unseen as seen
/// ============================================================
class LawyerNotificationPage extends StatefulWidget {
  final Map<String, dynamic> lawyerData;
  const LawyerNotificationPage({Key? key, required this.lawyerData})
      : super(key: key);

  @override
  State<LawyerNotificationPage> createState() =>
      _LawyerNotificationPageState();
}

class _LawyerNotificationPageState extends State<LawyerNotificationPage>
    with TickerProviderStateMixin {

  // ─── ORIGINAL STATE VARIABLES (completely untouched) ───────────────────

  /// True while Firestore data is being fetched
  bool isLoading = true;

  /// True if the lawyer has at least one notification
  bool isNotificationAvailable = true;

  /// The list of notification maps built from Firestore data
  List<Map<String, dynamic>> notificationList = [];

  // ─── ANIMATION CONTROLLERS (UI only — zero impact on logic) ───────────

  /// Drives the page-level fade + upward slide entrance
  late AnimationController _entranceController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // ============================================================
  // initState — runs once when this widget is first created.
  //
  // 1. Sets up and starts the entrance animation.
  // 2. Calls original checkNotification() to populate the list.
  // 3. Calls original checkNotificationSeenStatus() to mark all seen.
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

    // ORIGINAL: fetch notifications + mark them seen
    checkNotification();
    checkNotificationSeenStatus();
  }

  // ============================================================
  // dispose — clean up animation controller
  // ============================================================
  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  // ╔══════════════════════════════════════════════════════════╗
  //  ALL METHODS BELOW ARE 100% ORIGINAL LOGIC
  //  Only comments have been added — no code was changed.
  // ╚══════════════════════════════════════════════════════════╝

  // ============================================================
  // checkNotification  ← ORIGINAL LOGIC
  //
  // Checks if the lawyer's notifications doc exists.
  //   Not exists → isNotificationAvailable=false
  //   Exists     → loops counter…1 (newest first) building
  //                notificationList entries.
  //     userID == 'admin@gmail.com' → LAWHUB Team entry (no profile fetch)
  //     else                        → fetchUserData() to get name + avatar
  // ============================================================
  Future<void> checkNotification() async {
    var doc = await FirebaseFirestore.instance
        .collection('LawyersNotifications')
        .doc(widget.lawyerData['id'])
        .get();
    if (!doc.exists) {
      setState(() {
        isLoading = false;
        isNotificationAvailable = false;
      });
    } else {
      fetchAllNotifications().then((data) {
        setState(() {
          int counter = data['counter'];
          // Loop newest-first (counter down to 1)
          for (int i = counter; i >= 1; i--) {
            String type = data['Notification$i'][1]['type'];
            if (data['Notification$i'][0]['userID'] != 'admin@gmail.com') {
              // Fetch real user profile for non-admin notifications
              fetchUserData(data['Notification$i'][0]['userID']).then((value) {
                setState(() {
                  notificationList.add({
                    'index': i,
                    'imageUrl': value['profilePic'],
                    'senderName': value['name'],
                    'type': type,
                  });
                });
              });
            } else {
              // Admin notification — show LAWHUB Team branding
              setState(() {
                notificationList.add({
                  'index': i,
                  'imageUrl': 'null',
                  'senderName': 'LAWHUB Team',
                  'type': type,
                });
              });
            }
          }
        });
        setState(() {
          isLoading = false;
          isNotificationAvailable = true;
        });
      }).catchError((error) {
        setState(() { isLoading = false; });
      });
    }
  }

  // ============================================================
  // fetchAllNotifications  ← ORIGINAL LOGIC
  //
  // Reads the lawyer's LawyersNotifications document and returns
  // the snapshot for reading notification fields.
  // ============================================================
  Future<DocumentSnapshot> fetchAllNotifications() async {
    return await FirebaseFirestore.instance
        .collection('LawyersNotifications')
        .doc(widget.lawyerData['id'])
        .get();
  }

  // ============================================================
  // fetchUserData  ← ORIGINAL LOGIC
  //
  // Reads a user's document from the Users collection by userID.
  // Returns the snapshot so checkNotification() can read
  // 'name' and 'profilePic'.
  // ============================================================
  Future<DocumentSnapshot> fetchUserData(String userID) async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(userID)
        .get();
    if (!snapshot.exists) {
      snapshot = await FirebaseFirestore.instance
          .collection('Lawyers')
          .doc(userID)
          .get();
    }
    return snapshot;
  }

  // ============================================================
  // checkNotificationSeenStatus  ← ORIGINAL LOGIC
  //
  // Loops all notifications and marks any unseen ones as seen
  // by calling updateNotificationSeenStatus() for each.
  // This runs in parallel with checkNotification() so the bell
  // in the AppBar clears as soon as the user opens this screen.
  // ============================================================
  Future<void> checkNotificationSeenStatus() async {
    fetchAllNotifications().then((data) {
      setState(() {
        int counter = data['counter'];
        for (int i = 1; i <= counter; i++) {
          if (!data['Notification$i'][2]['isSeen']) {
            String userID = data['Notification$i'][0]['userID'];
            String type   = data['Notification$i'][1]['type'];
            updateNotificationSeenStatus(i, userID, type, counter);
          }
        }
        setState(() { isLoading = false; });
      });
    }).catchError((error) {
      setState(() { isLoading = false; });
    });
  }

  // ============================================================
  // updateNotificationSeenStatus  ← ORIGINAL LOGIC
  //
  // Writes isSeen=true for a specific notification entry.
  // Uses the notification index to target the correct field name.
  // ============================================================
  Future<void> updateNotificationSeenStatus(
      int index, String userId, String type, int counter) async {
    FirebaseFirestore.instance
        .collection('LawyersNotifications')
        .doc(widget.lawyerData['id'])
        .update({
      'Notification$index': [
        {'userID': userId},
        {'type': type},
        {'isSeen': true},
      ],
      'counter': counter,
    });
  }

  // ============================================================
  // build — constructs the full UI tree
  //
  // Structure:
  //   Scaffold (white background)
  //   ├── custom glassmorphic AppBar
  //   └── body:
  //       isLoading               → spinner
  //       isNotificationAvailable → FadeTransition + list
  //       else                    → empty state
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: isLoading
          ? const Center(
        child: SpinKitCircle(color: Color(0xFF1E88E5), size: 34),
      )
          : isNotificationAvailable
          ? FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: _buildNotificationList(),
        ),
      )
          : FadeTransition(
        opacity: _fadeAnim,
        child: _buildEmptyState(),
      ),
    );
  }

  // ============================================================
  // _buildAppBar — styled AppBar matching the rest of the app
  //
  // Back button: Navigator.of(context).pop() — same as original.
  // Title: "Notification" — same as original.
  // ============================================================
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60.0),
      child: AppBar(
        toolbarHeight: 70,
        leadingWidth: 40,
        backgroundColor: const Color(0xFF1565C0),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(top: 8, left: 10),
          child: IconButton(
            icon: const Icon(FontAwesomeIcons.angleLeft, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(), // ← original logic
          ),
        ),
        title: const Padding(
          padding: EdgeInsets.only(top: 13),
          child: Text(
            'Notification',
            style: TextStyle(
              fontFamily: 'roboto',
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // _buildNotificationList — scrollable list of notification cards
  //
  // ORIGINAL logic:
  //   notificationList sorted by index descending (newest first)
  //   Each item passed to _buildNotificationCard()
  // ============================================================
  Widget _buildNotificationList() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section header ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
            child: Row(
              children: [
                const Text(
                  'All Notifications',
                  style: TextStyle(
                    fontFamily: 'roboto',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(width: 10),
                // Count badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E88E5).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFF1E88E5).withOpacity(0.3)),
                  ),
                  child: Text(
                    '${notificationList.length}',
                    style: const TextStyle(
                      color: Color(0xFF1E88E5),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Notification list ──────────────────────────────────
          ListView.builder(
            // ORIGINAL: sort newest-first
            itemCount: notificationList.length,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              notificationList.sort(
                      (a, b) => b['index'].compareTo(a['index']));
              final itemData = notificationList[index];
              return _buildNotificationCard(itemData);
            },
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ============================================================
  // _buildNotificationCard — single notification row card
  //
  // ORIGINAL avatar logic fully preserved:
  //   imageUrl == 'null' && senderName == 'LAWHUB Team'
  //     → AssetImage("assets/images/Lawhub.png")
  //   imageUrl == 'null' (other)
  //     → grey CircleAvatar with person icon
  //   imageUrl != 'null'
  //     → NetworkImage avatar
  //
  // UI: white card with left blue accent bar + shadow
  // ============================================================
  Widget _buildNotificationCard(Map<String, dynamic> itemData) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
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
        child: Row(
          children: [

            // ── Blue left accent bar ────────────────────────────
            Container(
              width: 4,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFF1E88E5),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                ),
              ),
            ),

            const SizedBox(width: 14),

            // ── Avatar ─────────────────────────────────────────
            // ORIGINAL: 3-way conditional for avatar source
            SizedBox(
              width: 48,
              height: 48,
              child: itemData['imageUrl'] == 'null' || itemData['imageUrl'] == null
                  ? itemData['senderName'] == 'LAWHUB Team'
                  ? const CircleAvatar(
                backgroundImage:
                AssetImage('assets/images/Lawhub.png'),
              )
                  : CircleAvatar(
                backgroundColor: Colors.grey[200],
                child: const Icon(Icons.person,
                    color: Colors.grey, size: 28),
              )
                  : CircleAvatar(
                backgroundImage:
                NetworkImage(itemData['imageUrl']),
              ),
            ),

            const SizedBox(width: 14),

            // ── Sender name + notification type ────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── ORIGINAL: senderName ─────────────────────
                    Text(
                      itemData['senderName'],
                      style: const TextStyle(
                        fontFamily: 'roboto',
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // ── ORIGINAL: type text ───────────────────────
                    Text(
                      itemData['type'],
                      style: TextStyle(
                        fontFamily: 'roboto',
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bell icon on right edge
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(
                Icons.notifications_rounded,
                color: const Color(0xFF1E88E5).withOpacity(0.4),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // _buildEmptyState — shown when isNotificationAvailable=false
  //
  // ORIGINAL: "No Notifications Yet" text centered.
  // UI: adds an icon above the text for a friendlier feel.
  // ============================================================
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 60,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No Notifications Yet',
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
}