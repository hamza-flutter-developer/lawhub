// ══════════════════════════════════════════════════════════════════════════════
// FILE: UserAppBar&NavBar.dart
// PURPOSE: Main navigation container for User app with bottom nav and app bar
// ══════════════════════════════════════════════════════════════════════════════

// ignore_for_file: file_names

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lawhub/User_Pages/UserFavourite.dart';
import 'package:lawhub/User_Pages/UserProfile.dart';
import '../AI_Pages/LegalChatbot.dart';
import '../Drawer_Pages/Drawer.dart';
import 'UserChat.dart';
import 'UserHomePage.dart';
import 'UserNotifications.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// UserAppBarNavBar Widget (StatefulWidget)
/// ═══════════════════════════════════════════════════════════════════════════
/// Main navigation container for the User app
/// Features:
/// - Bottom navigation bar (4 tabs: Home, Chat, Favorite, Profile)
/// - Top app bar with drawer menu and notifications
/// - Real-time notification checking (every 3 seconds)
/// - Loads user data and lawyer list from Firestore
/// - Manages page navigation state
class UserAppBarNavBar extends StatefulWidget {
  const UserAppBarNavBar({super.key});

  @override
  State<UserAppBarNavBar> createState() => _UserAppBarNavBarState();
}

class _UserAppBarNavBarState extends State<UserAppBarNavBar> {
  // ─────────────────────────────────────────────────────────────────────────
  // STATE VARIABLES
  // ─────────────────────────────────────────────────────────────────────────

  /// Timer for periodic notification checking
  Timer? timer;

  /// Current user's data from Firestore
  late Map<String, dynamic> userData;

  /// List of all verified lawyers
  List<Map<String, dynamic>> dataList = [];

  /// Loading states
  bool isLoading = true; // Main app loading
  bool isLoadingRequest = true; // Notification loading
  bool isRequestAvailable = false; // Has unread notifications
  int _unreadCount = 0;

  /// List of page widgets for bottom navigation
  late List<Widget> _pages;

  /// Current selected tab index (0 = Home, 1 = Chat, 2 = Favorite, 3 = Profile)
  int _currentIndex = 0;
  int _chatRebuildKey = 0;

  // ═════════════════════════════════════════════════════════════════════════
  // NOTIFICATION CHECKING - YOUR EXISTING LOGIC (UNCHANGED)
  // ═════════════════════════════════════════════════════════════════════════

  /// ───────────────────────────────────────────────────────────────────────
  /// FUNCTION: checkNotifications()
  /// PURPOSE: Checks if user has any unread notifications
  /// LOGIC: Loops through all notifications and checks 'isSeen' status
  /// ───────────────────────────────────────────────────────────────────────
  Future<void> checkNotifications(Map<String, dynamic> userData) async {
    var documentCheck = await FirebaseFirestore.instance
        .collection('UsersNotifications')
        .doc(userData['id'])
        .get();

    if (documentCheck.exists) {
      fetchAllNotifications().then((data) {
        int counter = data['counter'];
        int unseenCount = 0;

        for (int i = 1; i <= counter; i++) {
          if (!data['Notification$i'][2]['isSeen']) {
            unseenCount++;
          }
        }

        setState(() {
          isLoadingRequest = false;
          _unreadCount = unseenCount;
          isRequestAvailable = unseenCount > 0;
        });
      });
    } else {
      // No notification document exists
      setState(() {
        isLoadingRequest = false;
        isRequestAvailable = false;
      });
    }
  }

  /// ───────────────────────────────────────────────────────────────────────
  /// FUNCTION: fetchAllNotifications()
  /// PURPOSE: Retrieves user's notification document from Firestore
  /// RETURNS: DocumentSnapshot containing all notifications
  /// ───────────────────────────────────────────────────────────────────────
  Future<DocumentSnapshot> fetchAllNotifications() async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('UsersNotifications')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get();
    return userSnapshot;
  }

  /// ───────────────────────────────────────────────────────────────────────
  /// FUNCTION: fetchUserData()
  /// PURPOSE: Loads current user's profile data from Firestore
  /// RETURNS: Map containing user data (name, email, profile pic, etc.)
  /// ───────────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> fetchUserData() async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get();

    Map<String, dynamic> userData =
    userSnapshot.data() as Map<String, dynamic>;
    return userData;
  }

  /// ───────────────────────────────────────────────────────────────────────
  /// FUNCTION: fetchAllLawyerData()
  /// PURPOSE: Loads all verified lawyers from Firestore
  /// RETURNS: List of lawyer data maps
  /// FILTER: Only includes lawyers with isVerified = 'Verified'
  /// ───────────────────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> fetchAllLawyerData(
      String collectionName) async {
    List<Map<String, dynamic>> dataList = [];

    try {
      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection(collectionName).get();

      // Filter only verified lawyers
      for (var doc in querySnapshot.docs
          .where((e) => e['isVerified'] == 'Verified')) {
        dataList.add(doc.data() as Map<String, dynamic>);
      }
    } catch (error) {
      debugPrint('Error fetching data: $error');
    }

    return dataList;
  }

  // ═════════════════════════════════════════════════════════════════════════
  // LIFECYCLE METHODS
  // ═════════════════════════════════════════════════════════════════════════

  @override
  void initState() {
    super.initState();

    userData = {};

    /// ─────────────────────────────────────────────────────────────────────
    /// INITIALIZATION FLOW:
    /// 1. Fetch user data
    /// 2. Fetch all verified lawyers
    /// 3. Check for notifications
    /// 4. Initialize pages
    /// 5. Start periodic notification checking
    /// ─────────────────────────────────────────────────────────────────────
    fetchUserData().then((data) {
      setState(() {
        userData = data;
        fetchAllLawyerData('Lawyers').then((data) {
          checkNotifications(userData).then((value) {
            dataList = data;
            isLoading = false;
            _initializePages();
          });
        });
      });
    });

    /// Start timer to check notifications every 3 seconds
    timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      checkNotifications(userData);
    });
  }

  @override
  void dispose() {
    /// Cancel timer to prevent memory leaks
    timer?.cancel();
    super.dispose();
  }

  /// ───────────────────────────────────────────────────────────────────────
  /// FUNCTION: _initializePages()
  /// PURPOSE: Creates list of page widgets for bottom navigation
  /// NOTE: Called after data is loaded to pass data to pages
  /// ───────────────────────────────────────────────────────────────────────
  void _initializePages() {
    _pages = [
      HomeScreen(dataList: dataList, userData: userData),
      const ChatScreen(),
      FavoriteScreen(dataList: dataList, userData: userData),
      ProfileScreen(userData: userData),
    ];
  }

  // ═════════════════════════════════════════════════════════════════════════
  // BUILD METHOD: Creates the UI
  // ═════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ═══════════════════════════════════════════════════════════════════════
      // MODERN APP BAR
      // ═══════════════════════════════════════════════════════════════════════
      /// Different app bar for Profile screen (index 3)
      appBar: _currentIndex != 3
          ? _buildMainAppBar(context)
          : _buildProfileAppBar(context),

      // ═══════════════════════════════════════════════════════════════════════
      // NAVIGATION DRAWER
      // ═══════════════════════════════════════════════════════════════════════
      drawer: isLoading
          ? const SizedBox()
          : drawer(
        imageURL: userData['profilePic'],
        userName: userData['name'],
        userEmail: userData['emailPhone'],
      ),

      // ═══════════════════════════════════════════════════════════════════════
      // FAB: AI Chatbot
      // ═══════════════════════════════════════════════════════════════════════
      floatingActionButton: _currentIndex != 3
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LegalChatbot(
                      isLawyer: false,
                      isVerified: false,
                    ),
                  ),
                );
              },
              backgroundColor: const Color(0xFF1565C0),
              elevation: 6,
              child: const Icon(FontAwesomeIcons.robot,
                  color: Colors.white, size: 22),
            )
          : null,

      // ═══════════════════════════════════════════════════════════════════════
      // BODY: Current Page
      // ═══════════════════════════════════════════════════════════════════════
      body: isLoading
          ? Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8F9FA),
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: const Center(
          child: SpinKitCircle(
            color: Color(0xFF1565C0),
            size: 50,
          ),
        ),
      )
          : _currentIndex == 1
              ? ChatScreen(key: ValueKey(_chatRebuildKey))
              : _pages[_currentIndex],

      // ═══════════════════════════════════════════════════════════════════════
      // MODERN BOTTOM NAVIGATION BAR - FIXED VERSION
      // ═══════════════════════════════════════════════════════════════════════
      bottomNavigationBar: _buildModernBottomNav(),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // UI BUILDER HELPER METHODS
  // ═════════════════════════════════════════════════════════════════════════

  /// ───────────────────────────────────────────────────────────────────────
  /// HELPER: _buildMainAppBar()
  /// PURPOSE: Creates main app bar with drawer and notifications
  /// USED: For Home, Chat, and Favorite screens
  /// ───────────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildMainAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(65.0),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.topRight,
            colors: [
              Color(0xFF1E88E5),
              Color(0xFF1565C0),
            ],
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x401565C0),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Builder(
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.only(top: 8, left: 8),
                child: IconButton(
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  icon: const Icon(
                    FontAwesomeIcons.bars,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              );
            },
          ),
          title: const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              "LAWHUB",
              style: TextStyle(
                fontFamily: "patua",
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(top: 8, right: 8),
              child: _buildNotificationIcon(),
            ),
          ],
        ),
      ),
    );
  }

  /// ───────────────────────────────────────────────────────────────────────
  /// HELPER: _buildProfileAppBar()
  /// PURPOSE: Creates minimal app bar for Profile screen
  /// ───────────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildProfileAppBar(BuildContext context) {
    return const PreferredSize(
      preferredSize: Size.fromHeight(0.0),
      child: SizedBox.shrink(),
    );
  }

  /// ───────────────────────────────────────────────────────────────────────
  /// HELPER: _buildNotificationIcon()
  /// PURPOSE: Shows appropriate notification icon based on state
  /// STATES: Loading (spinner), Has unread (bell with indicator), No unread (bell)
  /// ───────────────────────────────────────────────────────────────────────
  Widget _buildNotificationIcon() {
    if (isLoadingRequest) {
      // Still checking for notifications
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: SizedBox(
          width: 24,
          height: 24,
          child: SpinKitCircle(
            color: Colors.white,
            size: 24,
          ),
        ),
      );
    } else if (isRequestAvailable) {
      // Has unread notifications - show indicator
      return Stack(
        children: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserNotificationPage(
                    userData: userData,
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.notifications_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(2),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              decoration: BoxDecoration(
                color: const Color(0xFFFF5252),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Text(
                _unreadCount > 9 ? '9+' : '$_unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      );
    } else {
      // No unread notifications
      return IconButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserNotificationPage(
                userData: userData,
              ),
            ),
          );
        },
        icon: const Icon(
          Icons.notifications_outlined,
          color: Colors.white,
          size: 26,
        ),
      );
    }
  }

  /// ───────────────────────────────────────────────────────────────────────
  /// HELPER: _buildModernBottomNav() - FIXED VERSION
  /// PURPOSE: Creates modern bottom navigation bar with gradient
  /// FIX: Removed fixed height, added SafeArea to prevent overflow
  /// ───────────────────────────────────────────────────────────────────────
  Widget _buildModernBottomNav() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.topRight,
          colors: [
            Color(0xFF1E88E5),
            Color(0xFF1565C0),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withAlpha(64),
            blurRadius: 15,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: FontAwesomeIcons.house,
                  label: 'Home',
                  index: 0,
                ),
                _buildNavItem(
                  icon: FontAwesomeIcons.comments,
                  label: 'Chats',
                  index: 1,
                ),
                _buildNavItem(
                  icon: FontAwesomeIcons.heart,
                  label: 'Favorite',
                  index: 2,
                ),
                _buildNavItem(
                  icon: FontAwesomeIcons.user,
                  label: 'Profile',
                  index: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ───────────────────────────────────────────────────────────────────────
  /// HELPER: _buildNavItem()
  /// PURPOSE: Creates individual navigation tab item
  /// FEATURES: Active indicator, smooth transitions, tap feedback
  /// ───────────────────────────────────────────────────────────────────────
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    bool isActive = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentIndex = index;
            if (index == 1) _chatRebuildKey++;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? Colors.white.withAlpha(25) : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: isActive ? 24 : 22,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'roboto',
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: Colors.white,
                  fontSize: isActive ? 12 : 11,
                ),
              ),
              if (isActive)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// PAGE WRAPPER WIDGETS
// ══════════════════════════════════════════════════════════════════════════════
/// These widgets wrap the actual page content and pass data

// ignore: must_be_immutable
class HomeScreen extends StatelessWidget {
  final Map<String, dynamic> userData;
  List<Map<String, dynamic>> dataList;
  HomeScreen({super.key, required this.dataList, required this.userData});

  @override
  Widget build(BuildContext context) {
    return UserHomePage(
      dataList: dataList,
      userData: userData,
    );
  }
}

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const UserChat();
  }
}

// ignore: must_be_immutable
class FavoriteScreen extends StatelessWidget {
  List<Map<String, dynamic>> dataList;
  final Map<String, dynamic> userData;
  FavoriteScreen({super.key, required this.dataList, required this.userData});

  @override
  Widget build(BuildContext context) {
    return UserFav(
      dataList: dataList,
      userData: userData,
    );
  }
}

class ProfileScreen extends StatelessWidget {
  final Map<String, dynamic> userData;
  const ProfileScreen({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return UserProfile(
      userData: userData,
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// KEY CONCEPTS IN THIS FILE:
// ══════════════════════════════════════════════════════════════════════════════
//
// 1. Timer.periodic():
//    - Runs checkNotifications() every 3 seconds
//    - Must be cancelled in dispose() to prevent memory leaks
//    - Used for real-time notification updates
//
// 2. Nested Async Calls:
//    - fetchUserData() → fetchAllLawyerData() → checkNotifications()
//    - Uses .then() to chain operations
//    - Each step depends on previous step completing
//
// 3. Bottom Navigation Pattern:
//    - _currentIndex tracks which tab is active
//    - _pages list contains page widgets
//    - setState() rebuilds to show new page
//
// 4. Conditional App Bar:
//    - Different app bar for Profile screen
//    - Uses ternary operator: condition ? ifTrue : ifFalse
//    - PreferredSize allows custom height
//
// 5. Notification States:
//    - isLoadingRequest: Checking for notifications
//    - isRequestAvailable: Has unread notifications
//    - Changes icon based on state (spinner → bell with dot → bell)
//
// 6. Data Flow:
//    - Parent (this widget) loads data
//    - Passes data to child pages via constructor
//    - Child pages receive and use data
//
// 7. QuerySnapshot Filtering:
//    - .where() filters documents by field value
//    - Only shows verified lawyers
//    - Returns filtered list
//
// 8. Stack for Badge:
//    - Stack overlays widgets
//    - Positioned places badge on notification icon
//    - Creates "unread indicator" effect
//
// 9. SafeArea Fix:
//    - Wraps bottom nav content to respect device safe areas
//    - Prevents overflow on devices with navigation bars
//    - Automatically adjusts padding for notches/home indicators
//
// ══════════════════════════════════════════════════════════════════════════════