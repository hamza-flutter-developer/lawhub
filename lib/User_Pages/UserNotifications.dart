// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// ============================================================================
// USER NOTIFICATION PAGE - MAIN WIDGET
// ============================================================================
// This page displays all notifications for the logged-in user.
// Notifications are sent by lawyers when they respond to user requests.
// Shows: Lawyer profile picture, name, and notification type.
class UserNotificationPage extends StatefulWidget{
  final Map<String, dynamic> userData;  // Logged-in user's complete data

  const UserNotificationPage({Key? key, required this.userData}) : super(key: key);

  @override
  State<UserNotificationPage> createState() => _UserNotificationPageState();
}

class _UserNotificationPageState extends State<UserNotificationPage> with SingleTickerProviderStateMixin {

  // ============================================================================
  // STATE VARIABLES
  // ============================================================================

  // Loading state - TRUE while fetching notifications from Firebase
  bool isLoading = true;

  // Notification availability - TRUE if user has any notifications
  bool isNotificationAvailable = true;

  // List to store all notification data (profile pic, name, type)
  // Each item format: {'index': 1, 'imageUrl': '...', 'senderName': 'John', 'type': 'Accepted'}
  List<Map<String, dynamic>> notificationList = [];

  // Animation controller for smooth page transitions
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // ============================================================================
  // CHECK NOTIFICATION
  // ============================================================================
  // This function checks if user has any notifications in Firebase.
  // If notifications exist, it fetches them all and builds the notification list.
  //
  // HOW IT WORKS:
  // 1. Query Firebase for user's notification document
  // 2. If document doesn't exist → User has no notifications
  // 3. If document exists → Fetch all notifications
  // 4. For each notification, fetch the lawyer's profile data
  // 5. Build a list combining notification data + lawyer data
  Future<void> checkNotification() async {
    // Query Firebase for user's notifications document
    var doc = await FirebaseFirestore.instance
        .collection('UsersNotifications')
        .doc(widget.userData['id'])
        .get();

    if(!doc.exists) {
      // Document doesn't exist - user has no notifications yet
      setState(() {
        isLoading = false;
        isNotificationAvailable = false;
      });
    }
    else {
      // Document exists - fetch all notifications
      fetchAllNotifications().then((data) {
        int counter = data['counter'];  // Total number of notifications

        // Loop through notifications in REVERSE order (newest first)
        // i starts from counter and goes down to 1
        for (int i = counter; i >= 1; i--) {
          // Extract notification type (e.g., "Accepted", "Rejected", "Replied")
          String type = data['Notification$i'][1]['type'];

          // Fetch the lawyer's profile data who sent this notification
          fetchLawyerData(data['Notification$i'][0]['lawyerID']).then((value) {
            setState(() {
              // Add complete notification object to list
              notificationList.add({
                'index': i,                      // Notification number (for sorting)
                'imageUrl': value['profilePic'], // Lawyer's profile picture
                'senderName': value['name'],     // Lawyer's name
                'type': type                     // Notification type
              });
            });
          });
        }

        setState(() {
          isLoading = false;
          isNotificationAvailable = true;
        });
      }).catchError((error) {
        // If any error occurs during fetching
        setState(() {
          isLoading = false;
        });
      });
    }
  }

  // ============================================================================
  // FETCH ALL NOTIFICATIONS
  // ============================================================================
  // Retrieves user's complete notifications document from Firebase.
  //
  // FIREBASE STRUCTURE:
  // Collection: UsersNotifications
  // Document: user_id_123
  // {
  //   counter: 3,
  //   Notification1: [
  //     {lawyerID: "lawyer_abc"},
  //     {type: "Accepted"},
  //     {isSeen: false}
  //   ],
  //   Notification2: [...],
  //   Notification3: [...]
  // }
  Future<DocumentSnapshot> fetchAllNotifications() async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('UsersNotifications')
        .doc(widget.userData['id'])
        .get();
    return userSnapshot;
  }

  // ============================================================================
  // FETCH LAWYER DATA
  // ============================================================================
  // Gets complete profile information for a lawyer who sent a notification.
  // This is needed because notification documents only store lawyer IDs,
  // not their full profile data (name, picture, etc.)
  //
  // PARAMETERS:
  // lawyerID - The unique ID of the lawyer
  //
  // RETURNS:
  // DocumentSnapshot containing lawyer's complete profile
  Future<DocumentSnapshot> fetchLawyerData(String lawyerID) async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('Lawyers')
        .doc(lawyerID)
        .get();
    if (!snapshot.exists) {
      snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(lawyerID)
          .get();
    }
    return snapshot;
  }

  // ============================================================================
  // CHECK NOTIFICATION SEEN STATUS
  // ============================================================================
  // Marks all unseen notifications as "seen" when user opens this page.
  // This updates the isSeen field in Firebase from false → true.
  //
  // WHY WE NEED THIS:
  // To track which notifications are new/unread vs already viewed.
  // Can be used to show notification badges, counts, etc.
  //
  // PROCESS:
  // 1. Fetch all notifications
  // 2. Loop through each one
  // 3. If isSeen = false, call update function
  // 4. Update sets isSeen = true in Firebase
  Future<void> checkNotificationSeenStatus() async {
    fetchAllNotifications().then((data) {
      setState(() {
        int counter = data['counter'];  // Total notifications

        // Loop through all notifications
        for (int i = 1; i <= counter; i++) {
          // Check if this notification hasn't been seen yet
          if(!data['Notification$i'][2]['isSeen']) {
            // Extract data needed for update
            String userID = data['Notification$i'][0]['lawyerID'];
            String type = data['Notification$i'][1]['type'];

            // Update this notification's seen status to true
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

  // ============================================================================
  // UPDATE NOTIFICATION SEEN STATUS
  // ============================================================================
  // Updates a single notification's isSeen field to true in Firebase.
  //
  // PARAMETERS:
  // index   - Notification number (1, 2, 3, etc.)
  // userId  - Lawyer ID who sent the notification
  // type    - Notification type (Accepted, Rejected, etc.)
  // counter - Total notification count
  //
  // FIREBASE UPDATE:
  // Changes: isSeen: false → isSeen: true
  Future<void> updateNotificationSeenStatus(int index, String userId, String type, int counter) async {
    FirebaseFirestore.instance
        .collection('UsersNotifications')
        .doc(widget.userData['id'])
        .update({
      'Notification$index': [
        {'lawyerID': userId},
        {'type': type},
        {'isSeen': true},  // ← Changed from false to true
      ],
      'counter': counter,
    });
  }

  // ============================================================================
  // INITIALIZATION
  // ============================================================================
  // Called once when page loads. Fetches notifications and marks them as seen.
  @override
  void initState() {
    super.initState();

    // Fetch all notifications from Firebase
    checkNotification();

    // Mark all unseen notifications as seen
    checkNotificationSeenStatus();

    // Initialize animation controller (600ms duration)
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Setup fade animation (opacity 0% → 100%)
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    // Setup slide animation (slides from right side)
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),  // Start 30% from right
      end: Offset.zero,              // End at normal position
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    _animationController.forward();
  }

  // ============================================================================
  // CLEANUP
  // ============================================================================
  // Dispose of animation controller when page is closed to free memory
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ============================================================================
  // BUILD NOTIFICATION CARD
  // ============================================================================
  // Creates a single notification card showing lawyer info and notification type.
  //
  // PARAMETERS:
  // itemData - Map containing: imageUrl, senderName, type
  // index    - Card position in list (for staggered animation)
  //
  // CARD DESIGN:
  // ┌────────────────────────────┐
  // │ [Avatar]  John Doe         │
  // │           Request Accepted │
  // └────────────────────────────┘
  Widget _buildNotificationCard(Map<String, dynamic> itemData, int index) {
    // Staggered animation - each card appears slightly after the previous one
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(50 * (1 - value), 0),  // Slide from right
          child: Opacity(
            opacity: value,  // Fade in
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 15, right: 20, left: 20),
        child: Container(
          // Modern card design with gradient and shadow
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.blue.shade50.withOpacity(0.3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 2,
              )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ========================================================
                // LAWYER AVATAR
                // ========================================================
                // Circular profile picture with gradient border
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade300, Colors.blue.shade600],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: itemData['imageUrl'] == 'null' || itemData['imageUrl'] == null
                    // If no profile picture, show default icon
                        ? Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.grey,
                        size: 35,
                      ),
                    )
                    // If profile picture exists, show it
                        : ClipOval(
                      child: Image.network(
                        itemData['imageUrl'],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 15),

                // ========================================================
                // NOTIFICATION CONTENT
                // ========================================================
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Lawyer name (bold)
                      Text(
                        itemData['senderName'],
                        style: const TextStyle(
                          fontFamily: 'roboto',
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Notification type with icon
                      Row(
                        children: [
                          // Icon based on notification type
                          Icon(
                            _getNotificationIcon(itemData['type']),
                            size: 16,
                            color: _getNotificationColor(itemData['type']),
                          ),
                          const SizedBox(width: 6),
                          // Notification type text
                          Expanded(
                            child: Text(
                              itemData['type'],
                              style: TextStyle(
                                fontFamily: 'roboto',
                                fontSize: 15,
                                color: Colors.grey.shade700,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ========================================================
                // CHEVRON ICON (Shows it's tappable)
                // ========================================================
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey.shade400,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // GET NOTIFICATION ICON
  // ============================================================================
  // Returns appropriate icon based on notification type.
  // This makes it easy to visually distinguish notification types.
  //
  // ICON MAPPING:
  // "Accepted"  → Check circle (success)
  // "Rejected"  → Cancel/close (error)
  // "Replied"   → Message (communication)
  // Other       → Bell (default notification)
  IconData _getNotificationIcon(String type) {
    if (type.toLowerCase().contains('accept')) {
      return Icons.check_circle_outline_rounded;
    } else if (type.toLowerCase().contains('reject')) {
      return Icons.cancel_outlined;
    } else if (type.toLowerCase().contains('repl')) {
      return Icons.message_outlined;
    }
    return Icons.notifications_outlined;
  }

  // ============================================================================
  // GET NOTIFICATION COLOR
  // ============================================================================
  // Returns appropriate color based on notification type.
  // Provides visual feedback about notification status.
  //
  // COLOR MAPPING:
  // "Accepted"  → Green (positive)
  // "Rejected"  → Red (negative)
  // "Replied"   → Blue (neutral/info)
  // Other       → Orange (general notification)
  Color _getNotificationColor(String type) {
    if (type.toLowerCase().contains('accept')) {
      return Colors.green.shade600;
    } else if (type.toLowerCase().contains('reject')) {
      return Colors.red.shade600;
    } else if (type.toLowerCase().contains('repl')) {
      return Colors.blue.shade600;
    }
    return Colors.orange.shade600;
  }

  // ============================================================================
  // BUILD METHOD - MAIN UI
  // ============================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Light gray background instead of pure white
      backgroundColor: Colors.grey.shade50,

      // ====================================================================
      // MODERN APP BAR
      // ====================================================================
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0),
        child: Container(
          decoration: BoxDecoration(
            // Gradient background instead of solid blue
            gradient: LinearGradient(
              colors: [Colors.blue.shade600, Colors.blue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            // Rounded bottom corners
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
            // Subtle shadow for depth
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: AppBar(
            toolbarHeight: 70,
            leadingWidth: 60,
            backgroundColor: Colors.transparent,  // Transparent to show gradient
            elevation: 0,  // Remove default shadow

            // Back button with rounded container
            leading: Padding(
              padding: const EdgeInsets.only(top: 8, left: 10),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),

            // Title with icon
            title: Padding(
              padding: const EdgeInsets.only(top: 13),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Notification bell icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.notifications_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // "Notifications" text
                  const Text(
                    "Notifications",
                    style: TextStyle(
                      fontFamily: 'roboto',
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            centerTitle: true,
          ),
        ),
      ),

      // ====================================================================
      // BODY - THREE STATES
      // ====================================================================
      body: isLoading
      // ================================================================
      // STATE 1: LOADING
      // ================================================================
      // Shows spinning loader while fetching notifications from Firebase
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Spinning circle loader
            const SpinKitCircle(
              color: Colors.blue,
              size: 50,
            ),
            const SizedBox(height: 20),
            // Loading text
            Text(
              'Loading notifications...',
              style: TextStyle(
                fontFamily: 'roboto',
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      )
          : isNotificationAvailable
      // ============================================================
      // STATE 2: NOTIFICATIONS AVAILABLE
      // ============================================================
      // Shows list of all notifications with animations
          ? FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),  // Smooth scrolling
            child: Column(
              children: [
                // Section header with modern design
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 25, bottom: 15),
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    children: [
                      // Decorative line
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue.shade400, Colors.blue.shade600],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // "All Notifications" text
                      const Text(
                        "All Notifications",
                        style: TextStyle(
                          fontFamily: 'roboto',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      // Notification count badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue.shade300, Colors.blue.shade500],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${notificationList.length}',
                          style: const TextStyle(
                            fontFamily: 'roboto',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ====================================================
                // NOTIFICATION LIST
                // ====================================================
                // ListView showing all notification cards
                ListView.builder(
                  itemBuilder: (context, index) {
                    // Sort notifications by index (newest first)
                    // Higher index = newer notification
                    notificationList.sort((a, b) => b['index'].compareTo(a['index']));

                    var itemData = notificationList[index];

                    // Build notification card with animation
                    return _buildNotificationCard(itemData, index);
                  },
                  itemCount: notificationList.length,
                  physics: const NeverScrollableScrollPhysics(),  // Disable internal scrolling
                  shrinkWrap: true,  // Take only needed space
                ),

                // Bottom padding to prevent last item from being cut off
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      )
      // ============================================================
      // STATE 3: NO NOTIFICATIONS
      // ============================================================
      // Shows empty state when user has no notifications
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Large bell icon (empty state illustration)
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_off_outlined,
                size: 80,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 30),

            // "No Notifications Yet" text
            Text(
              'No Notifications Yet',
              style: TextStyle(
                fontFamily: 'roboto',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 10),

            // Subtext explaining why it's empty
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Text(
                'When lawyers respond to your requests,\nyou\'ll see notifications here',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'roboto',
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}