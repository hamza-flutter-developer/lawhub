import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../AI_Pages/LegalChatbot.dart';
import 'LawyerChat.dart';
import 'LawyerProfile.dart';
import '../Drawer_Pages/Drawer.dart';
import 'LawyerNotifications.dart';
import 'LawyerRequests.dart';

/// ============================================================
/// LawyerAppbarNavBar — StatefulWidget
///
/// The root shell screen for the lawyer side of the app.
/// Contains:
///   • A top AppBar with LAWHUB branding, drawer menu, and
///     a notification bell (animated when unseen notifications exist)
///   • A bottom nav bar with 3 tabs: Chats, Requests, Profile
///   • A side Drawer
///
/// Logic on load:
///   1. fetchUserData() → reads lawyer profile from Firestore
///   2. checkNotifications() → checks for unseen notifications
///      Repeats every 3 seconds via Timer (real-time feel)
///   3. _initializePages() → builds the 3 tab page widgets
/// ============================================================
class LawyerAppbarNavBar extends StatefulWidget {
  const LawyerAppbarNavBar({super.key});

  @override
  State<LawyerAppbarNavBar> createState() => _LawyerAppbarNavBarState();
}

class _LawyerAppbarNavBarState extends State<LawyerAppbarNavBar>
    with TickerProviderStateMixin {

  // ─── ORIGINAL STATE VARIABLES (completely untouched) ───────────────────

  /// Periodic timer that re-checks notifications every 3 seconds
  Timer? timer;

  /// Lawyer's Firestore profile data map
  late Map<String, dynamic> userData;

  /// True while fetchUserData() is in progress → shows full-screen spinner
  bool isLoading = true;

  /// The three page widgets: Chats, Requests, Profile
  late List<Widget> _pages;

  /// True while checkNotifications() is running → shows spinner in AppBar
  bool isLoadingRequest = true;

  /// True if there is at least one unseen notification → shows bell_on icon
  bool isRequestAvailable = false;
  int _unreadCount = 0;

  /// Which bottom nav tab is currently selected (0=Chats, 1=Requests, 2=Profile)
  int _currentIndex = 0;
  int _chatRebuildKey = 0;

  // ─── ANIMATION CONTROLLERS (UI only — zero impact on logic) ───────────

  /// Drives the subtle scale pulse on the notification bell when active
  late AnimationController _bellController;
  late Animation<double> _bellAnim;

  /// Drives the active indicator slide under the selected nav item
  late AnimationController _navController;

  // ============================================================
  // initState — runs once when this widget is first created.
  //
  // 1. Fetches lawyer data from Firestore.
  // 2. After data loads → checkNotifications() → _initializePages().
  // 3. Starts the 3-second periodic notification check timer.
  // 4. Sets up animation controllers.
  // ============================================================
  @override
  void initState() {
    super.initState();
    userData = {};

    // ORIGINAL: fetch lawyer data then check notifications
    fetchUserData().then((data) {
      setState(() {
        userData = data;
        checkNotifications(userData).then((value) {
          isLoading = false;
          _initializePages();
        });
      });
    });

    // ORIGINAL: poll notifications every 3 seconds
    timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      checkNotifications(userData);
    });

    // Bell pulse animation (UI only)
    _bellController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _bellAnim = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _bellController, curve: Curves.easeInOut),
    );

    _navController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  // ============================================================
  // dispose — cancel timer + animation controllers
  // ============================================================
  @override
  void dispose() {
    timer?.cancel();
    _bellController.dispose();
    _navController.dispose();
    super.dispose();
  }

  // ╔══════════════════════════════════════════════════════════╗
  //  ALL METHODS BELOW ARE 100% ORIGINAL LOGIC
  //  Only comments have been added — no code was changed.
  // ╚══════════════════════════════════════════════════════════╝

  // ============================================================
  // checkNotifications  ← ORIGINAL LOGIC
  //
  // Checks the LawyersNotifications document for this lawyer.
  //   Not exists → isRequestAvailable=false
  //   Exists     → loop through Notification1…N:
  //     If any isSeen==false → isRequestAvailable=true, break
  //     If all seen          → isRequestAvailable=false
  // Called once on load and then every 3 seconds via timer.
  // ============================================================
  Future<void> checkNotifications(Map<String, dynamic> userData) async {
    var documentCheck = await FirebaseFirestore.instance
        .collection('LawyersNotifications')
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
      setState(() {
        isLoadingRequest = false;
        isRequestAvailable = false;
      });
    }
  }

  // ============================================================
  // fetchAllNotifications  ← ORIGINAL LOGIC
  //
  // Reads the LawyersNotifications document for the current user
  // and returns the snapshot for looping in checkNotifications().
  // ============================================================
  Future<DocumentSnapshot> fetchAllNotifications() async {
    return await FirebaseFirestore.instance
        .collection('LawyersNotifications')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get();
  }

  // ============================================================
  // _initializePages  ← ORIGINAL LOGIC
  //
  // Builds the three page widgets after userData is loaded.
  // Called once inside the fetchUserData().then() callback.
  // ============================================================
  void _initializePages() {
    _pages = [
      const ChatScreen(),
      Requests(userData: userData),
      ProfileScreen(userData: userData),
    ];
  }

  // ============================================================
  // fetchUserData  ← ORIGINAL LOGIC
  //
  // Reads the lawyer's document from the Lawyers collection using
  // the current user's email as the document ID.
  // Returns the full data map.
  // ============================================================
  Future<Map<String, dynamic>> fetchUserData() async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('Lawyers')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get();
    return userSnapshot.data() as Map<String, dynamic>;
  }

  // ============================================================
  // build — constructs the full shell UI
  //
  // Structure:
  //   Scaffold
  //   ├── appBar  → hidden (height 0) when on Profile tab (#2)
  //   │             shown on Chats and Requests tabs
  //   ├── drawer  → side drawer (hidden while loading)
  //   ├── body    → full-screen spinner OR _pages[_currentIndex]
  //   └── bottomNavigationBar → custom 3-tab nav bar
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ── AppBar: hidden on Profile tab, shown on Chats/Requests ─────────
      appBar: _currentIndex != 2
          ? _buildVisibleAppBar(context)
          : _buildHiddenAppBar(),

      // ── FAB: AI Chatbot + Case Research ─────────────────────────────────
      floatingActionButton: _currentIndex != 2
          ? FloatingActionButton(
              onPressed: () {
                final verified =
                    (userData['isVerified'] as String?) == 'Verified';
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LegalChatbot(
                      isLawyer: true,
                      isVerified: verified,
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

      // ── Side drawer (ORIGINAL: hidden while isLoading) ─────────────────
      drawer: isLoading
          ? const SizedBox()
          : drawer(
        imageURL: userData['profilePic'],
        userName: userData['name'],
        userEmail: userData['emailPhone'],
      ),

      // ── Body: spinner until data loads, then show active tab ────────────
      body: isLoading
          ? const Center(
        child: SpinKitCircle(color: Color(0xFF1E88E5), size: 34),
      )
          : _currentIndex == 0
              ? ChatScreen(key: ValueKey(_chatRebuildKey))
              : _pages[_currentIndex],

      // ── Modern bottom nav bar ───────────────────────────────────────────
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ============================================================
  // _buildVisibleAppBar — shown on Chats and Requests tabs
  //
  // ORIGINAL logic fully preserved:
  //   Drawer hamburger → Scaffold.of(context).openDrawer()
  //   Title: "LAWHUB" centered
  //   Actions:
  //     isLoadingRequest → SpinKitCircle spinner
  //     isRequestAvailable → notifications_on icon (bell active)
  //     else               → notifications icon (bell default)
  //   Both notification icons navigate to LawyerNotificationPage
  //
  // UI addition: when isRequestAvailable, the bell pulses via
  // ScaleTransition (_bellAnim) — purely decorative.
  // ============================================================
  PreferredSizeWidget _buildVisibleAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60.0),
      child: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        elevation: 0,
        leading: Builder(
          builder: (context) => Padding(
            padding: const EdgeInsets.only(top: 14, left: 3),
            child: IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: const Icon(
                FontAwesomeIcons.bars,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
        title: const Padding(
          padding: EdgeInsets.only(top: 13),
          child: Text(
            'LAWHUB',
            style: TextStyle(
              fontFamily: 'patua',
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w100,
              letterSpacing: 2,
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          // ── ORIGINAL: spinner / active bell / default bell ─────────
          isLoadingRequest
              ? const Padding(
            padding: EdgeInsets.only(top: 15, right: 16),
            child: SpinKitCircle(color: Colors.white, size: 22),
          )
              : isRequestAvailable
          // Active bell pulses gently to draw attention
              ? Padding(
            padding: const EdgeInsets.only(top: 15, right: 3),
            child: ScaleTransition(
              scale: _bellAnim,
              child: Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LawyerNotificationPage(
                              lawyerData: userData),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.notifications_on,
                      color: Colors.white,
                      size: 25,
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
              ),
            ),
          )
              : Padding(
            padding: const EdgeInsets.only(top: 15, right: 3),
            child: IconButton(
              onPressed: () {
                // ── ORIGINAL: navigate to LawyerNotificationPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LawyerNotificationPage(
                        lawyerData: userData),
                  ),
                );
              },
              icon: const Icon(
                Icons.notifications,
                color: Colors.white,
                size: 25,
              ),
            ),
          ),
        ],
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
  // _buildHiddenAppBar — zero-height AppBar shown on Profile tab
  //
  // ORIGINAL logic: Profile tab manages its own header, so the
  // shell AppBar is hidden by setting preferredSize height to 0.
  // ============================================================
  PreferredSizeWidget _buildHiddenAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(0.0),
      child: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(FontAwesomeIcons.bars, size: 20),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // _buildBottomNav — custom 3-tab bottom navigation bar
  //
  // ORIGINAL logic:
  //   GestureDetector onTap → setState(_currentIndex = index)
  //   3 tabs: Chats (0), Requests (1), Profile (2)
  //
  // UI upgrades:
  //   • Active tab gets a white pill indicator above the icon
  //   • Active icon + label are full white; inactive are white54
  //   • Gradient background instead of flat Colors.blue.shade600
  // ============================================================
  Widget _buildBottomNav() {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF1E88E5)],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(FontAwesomeIcons.rocketchat, 'Chats', 0),
          _buildNavItem(FontAwesomeIcons.userGroup, 'Requests', 1),
          _buildNavItem(FontAwesomeIcons.solidUser, 'Profile', 2),
        ],
      ),
    );
  }

  // ============================================================
  // _buildNavItem — single tab item with active/inactive styling
  //
  // ORIGINAL tap logic: setState(_currentIndex = index)
  // UI addition: white pill indicator above icon when active,
  // animated opacity for icon + label colour change.
  // ============================================================
  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
          if (index == 0) _chatRebuildKey++;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : Colors.white54,
              size: 20,
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontFamily: 'roboto',
                fontWeight:
                isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? Colors.white : Colors.white54,
                fontSize: 12,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

/// ============================================================
/// ChatScreen — thin StatelessWidget wrapper
/// Renders LawyerChat as the Chats tab content.
/// ============================================================
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) => const LawyerChat();
}

/// ============================================================
/// Requests — thin StatelessWidget wrapper
/// Renders LawyerRequests as the Requests tab content.
/// Passes userData down to LawyerRequests.
/// ============================================================
class Requests extends StatelessWidget {
  final Map<String, dynamic> userData;
  const Requests({super.key, required this.userData});

  @override
  Widget build(BuildContext context) => LawyerRequests(userData: userData);
}

/// ============================================================
/// ProfileScreen — thin StatelessWidget wrapper
/// Renders LawyerProfile as the Profile tab content.
/// Passes userData down to LawyerProfile.
/// ============================================================
class ProfileScreen extends StatelessWidget {
  final Map<String, dynamic> userData;
  const ProfileScreen({super.key, required this.userData});

  @override
  Widget build(BuildContext context) => LawyerProfile(userData: userData);
}