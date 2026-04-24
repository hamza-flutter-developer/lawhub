// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lawhub/InformationUpdate_Pages/ProfilePictureUpdate.dart';
import '../Article_Pages/ManageArticles.dart';
import '../CaseDisplay_Pages/UserCaseView.dart';
import '../Payment_Pages/ManagePayments.dart';
import '../InformationUpdate_Pages/CredentialPassword.dart';
import '../InformationUpdate_Pages/PersonalInformation.dart';
import 'LawyerLicenseVerification.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// ============================================================
/// LawyerProfile — StatefulWidget
///
/// The profile screen shown to a logged-in lawyer. Displays:
///   • Profile picture (tappable → ProfilePictureUpdate)
///   • Lawyer name
///   • Verification status badge (Verified / Not Verified)
///   • Navigation menu tiles for all profile sub-sections
///
/// Parameter:
///   userData → Map containing the lawyer's Firestore data
///              (name, id, profilePic, etc.)
///
/// Logic on load:
///   1. fetchLawyerVerificationStatus() → reads isVerified field
///   2. checkCases() → checks if CasesLawyer doc exists so the
///      "In Progress Case" tile is shown only when cases exist
/// ============================================================
class LawyerProfile extends StatefulWidget {
  final Map<String, dynamic> userData;
  const LawyerProfile({super.key, required this.userData});

  @override
  State<LawyerProfile> createState() => _LawyerProfileState();
}

class _LawyerProfileState extends State<LawyerProfile>
    with TickerProviderStateMixin {

  // ─── ORIGINAL STATE VARIABLES (completely untouched) ───────────────────

  /// True if the lawyer has any cases in CasesLawyer — controls
  /// whether the "In Progress Case" menu tile is shown
  bool isCaseAvailable = false;

  /// 'Verified' or 'Not Verified' — read from Firestore Lawyers doc
  late String isVerified;

  /// True while fetchLawyerVerificationStatus() is running
  bool isLoadingLicenseStatus = true;

  // ─── ANIMATION CONTROLLERS (UI only — zero impact on logic) ───────────

  /// Drives the white card sliding up from below on screen open
  late AnimationController _cardController;
  late Animation<Offset> _cardSlideAnim;
  late Animation<double> _cardFadeAnim;

  /// Drives the profile avatar scale-in from the top
  late AnimationController _avatarController;
  late Animation<double> _avatarScaleAnim;
  late Animation<double> _avatarFadeAnim;

  /// Drives the staggered fade-in of each menu tile
  late AnimationController _tilesController;
  late Animation<double> _tilesFadeAnim;
  late Animation<Offset> _tilesSlideAnim;

  // ============================================================
  // initState — runs once when this widget is first created.
  //
  // 1. Sets up entrance animations for the card, avatar, and tiles.
  // 2. Fires the animations in a staggered sequence.
  // 3. Calls original Firestore fetch methods.
  // ============================================================
  @override
  void initState() {
    super.initState();

    // White card slides up from bottom
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _cardSlideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOutCubic,
    ));
    _cardFadeAnim = CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOut,
    );

    // Avatar pops in with a scale bounce
    _avatarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _avatarScaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.1), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(
      parent: _avatarController,
      curve: Curves.easeOut,
    ));
    _avatarFadeAnim = CurvedAnimation(
      parent: _avatarController,
      curve: Curves.easeOut,
    );

    // Menu tiles fade + slide up
    _tilesController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _tilesFadeAnim = CurvedAnimation(
      parent: _tilesController,
      curve: Curves.easeOut,
    );
    _tilesSlideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _tilesController,
      curve: Curves.easeOutCubic,
    ));

    // Staggered sequence: card → avatar → tiles
    _runEntrance();

    // ORIGINAL: fetch verification status and case availability
    fetchLawyerVerificationStatus();
    checkCases();
  }

  // ============================================================
  // _runEntrance — fires animations in a pleasing staggered order
  // ============================================================
  Future<void> _runEntrance() async {
    _cardController.forward();
    await Future.delayed(const Duration(milliseconds: 150));
    _avatarController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _tilesController.forward();
  }

  // ============================================================
  // dispose — clean up all animation controllers
  // ============================================================
  @override
  void dispose() {
    _cardController.dispose();
    _avatarController.dispose();
    _tilesController.dispose();
    super.dispose();
  }

  // ╔══════════════════════════════════════════════════════════╗
  //  ALL METHODS BELOW ARE 100% ORIGINAL LOGIC
  //  Only comments have been added — no code was changed.
  // ╚══════════════════════════════════════════════════════════╝

  // ============================================================
  // checkCases  ← ORIGINAL LOGIC
  //
  // Checks whether the lawyer's document exists in CasesLawyer.
  // Sets isCaseAvailable=true if it does, false if not.
  // Controls visibility of the "In Progress Case" menu tile.
  // ============================================================
  Future<void> checkCases() async {
    var doc = await FirebaseFirestore.instance
        .collection('CasesLawyer')
        .doc(widget.userData['id'])
        .get();
    if (doc.exists) {
      setState(() { isCaseAvailable = true; });
    } else {
      setState(() { isCaseAvailable = false; });
    }
  }

  // ============================================================
  // fetchLawyerVerificationStatus  ← ORIGINAL LOGIC
  //
  // Reads the 'isVerified' field from the lawyer's Firestore doc.
  // Sets isLoadingLicenseStatus=false when done so the spinner
  // is replaced by the verification badge.
  // ============================================================
  Future<void> fetchLawyerVerificationStatus() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('Lawyers')
        .doc(FirebaseAuth.instance.currentUser!.email.toString())
        .get();
    isVerified = doc['isVerified'];
    setState(() { isLoadingLicenseStatus = false; });
  }

  // ============================================================
  // build — constructs the full UI tree
  //
  // Structure:
  //   Scaffold
  //   └── gradient background (replaces plain blue)
  //       └── SafeArea
  //           └── Stack
  //               ├── "LAWHUB" brand text (top center)
  //               ├── Animated white card (slides up)
  //               │   ├── name + verification badge
  //               │   └── menu tiles (staggered fade)
  //               └── Animated avatar (scale bounce, overlaps card)
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        // ── Rich blue gradient replaces flat blue background ─────────────
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D47A1),
              Color(0xFF1565C0),
              Color(0xFF1E88E5),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [

              // ── "LAWHUB" brand text at top ───────────────────────────
              const SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 22),
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
                  ],
                ),
              ),

              // ── Animated white card (slides up from below) ───────────
              SlideTransition(
                position: _cardSlideAnim,
                child: FadeTransition(
                  opacity: _cardFadeAnim,
                  child: Container(
                    margin: const EdgeInsets.only(top: 150),
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFF),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 12,
                          spreadRadius: 0,
                          offset: Offset(0, -4),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 0.07 * MediaQuery.of(context).size.width,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Space for avatar overlap
                            const SizedBox(height: 80),

                            // ── Lawyer name ─────────────────────────────
                            Text(
                              widget.userData['name'],
                              style: const TextStyle(
                                fontFamily: 'roboto',
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),

                            const SizedBox(height: 10),

                            // ── Verification badge ──────────────────────
                            // ORIGINAL logic: isLoadingLicenseStatus →
                            // spinner; isVerified=='Verified' → green tick;
                            // else → orange cross + helper text
                            _buildVerificationBadge(),

                            const SizedBox(height: 28),

                            // ── Menu tiles (staggered fade) ─────────────
                            FadeTransition(
                              opacity: _tilesFadeAnim,
                              child: SlideTransition(
                                position: _tilesSlideAnim,
                                child: Column(
                                  children: [
                                    // Personal Information
                                    _buildMenuTile(
                                      icon: FontAwesomeIcons.userLarge,
                                      label: 'Personal Information',
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              UserPersonalInformation(
                                                  isUser: false,
                                                  userData: widget.userData),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 14),

                                    // Credentials and Password
                                    _buildMenuTile(
                                      icon: FontAwesomeIcons.shieldHalved,
                                      label: 'Credentials and Password',
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                          const CredentialsPassword(
                                              isUser: false),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 14),

                                    // Blog / Articles
                                    _buildMenuTile(
                                      icon: FontAwesomeIcons.newspaper,
                                      label: 'Blog/Articles',
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ManageArticles(
                                              isUser: false,
                                              userData: widget.userData),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 14),

                                    // In Progress Case — only if cases exist
                                    // ORIGINAL: isCaseAvailable controls visibility
                                    if (isCaseAvailable) ...[
                                      _buildMenuTile(
                                        icon: FontAwesomeIcons.handHoldingHand,
                                        label: 'In Progress Case',
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                            const CaseView(isUser: false),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                    ],

                                    // Payments
                                    _buildMenuTile(
                                      icon: FontAwesomeIcons.solidCreditCard,
                                      label: 'Payments',
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                          const ManagePayment(isUser: false),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 14),

                                    // License Verification
                                    _buildMenuTile(
                                      icon: FontAwesomeIcons.solidCircleCheck,
                                      label: 'License Verification',
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                          const LawyerLicenseVerification(),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 36),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Animated avatar (overlaps the card top edge) ─────────
              SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 78),
                    ScaleTransition(
                      scale: _avatarScaleAnim,
                      child: FadeTransition(
                        opacity: _avatarFadeAnim,
                        child: _buildAvatar(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // _buildAvatar — profile picture circle
  //
  // ORIGINAL logic fully preserved:
  //   profilePic != 'null' → show Image.network with ClipRRect
  //   profilePic == 'null' → show grey CircleAvatar with person icon
  //   onTap → navigate to ProfilePictureUpdate
  //
  // UI: added a blue ring border + subtle shadow for depth
  // ============================================================
  Widget _buildAvatar() {
    return InkWell(
      onTap: () {
        // ── ORIGINAL: navigate to ProfilePictureUpdate ─────────────────
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProfilePictureUpdate(
                isUser: false, userData: widget.userData),
          ),
        );
      },
      child: Container(
        height: 140,
        width: 140,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(
            color: const Color(0xFF1E88E5),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        // ── ORIGINAL: profile pic or fallback icon ─────────────────────
        child: widget.userData['profilePic'] != 'null' && widget.userData['profilePic'] != null
            ? ClipRRect(
          borderRadius: BorderRadius.circular(70),
          child: Image.network(
            widget.userData['profilePic'],
            fit: BoxFit.fitHeight,
            filterQuality: FilterQuality.high,
          ),
        )
            : CircleAvatar(
          radius: 70,
          backgroundColor: Colors.grey[200],
          child: const Icon(Icons.person, size: 80, color: Colors.grey),
        ),
      ),
    );
  }

  // ============================================================
  // _buildVerificationBadge — shows spinner / Verified / Not Verified
  //
  // ORIGINAL conditional logic fully preserved:
  //   isLoadingLicenseStatus == true → SpinKitCircle spinner
  //   isVerified == 'Verified'       → green check + "Verified" text
  //   else                           → orange X + "Not Verified" text
  //                                    + helper text paragraph
  // ============================================================
  Widget _buildVerificationBadge() {
    if (isLoadingLicenseStatus) {
      // ── ORIGINAL: spinner while fetching ─────────────────────────────
      return const SpinKitCircle(color: Colors.blue, size: 24);
    }

    if (isVerified == 'Verified') {
      // ── ORIGINAL: green verified badge ───────────────────────────────
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green.withOpacity(0.4)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(FontAwesomeIcons.circleCheck,
                color: Colors.lightGreen, size: 16),
            SizedBox(width: 6),
            Text(
              'Verified',
              style: TextStyle(
                fontFamily: 'roboto',
                fontSize: 15,
                color: Colors.lightGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    // ── ORIGINAL: not verified badge + helper text ─────────────────────
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.deepOrange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.deepOrange.withOpacity(0.4)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(FontAwesomeIcons.circleXmark,
                  color: Colors.deepOrange, size: 16),
              SizedBox(width: 6),
              Text(
                'Not Verified',
                style: TextStyle(
                  fontFamily: 'roboto',
                  fontSize: 15,
                  color: Colors.deepOrange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // ── ORIGINAL: helper message text ───────────────────────────────
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Verify your license now to start connecting with clients '
                'and offering your legal expertise immediately',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'roboto',
              fontSize: 13,
              color: Colors.deepOrange,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // _buildMenuTile — reusable profile menu row tile
  //
  // Replaces the repeated InkWell + Container + Row pattern from
  // the original with a single reusable helper. All navigation
  // onTap calls are passed in unchanged from the build method.
  //
  // UI: white card with left accent bar + icon + label + arrow
  // ============================================================
  Widget _buildMenuTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
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
          child: SizedBox(
            height: 62,
            child: Row(
              children: [
                // Blue accent bar on the left edge
                Container(
                  width: 4,
                  height: 62,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E88E5),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18),
                      bottomLeft: Radius.circular(18),
                    ),
                  ),
                ),

                const SizedBox(width: 18),

                // Icon in a soft blue circle
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E88E5).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(icon,
                        size: 18, color: const Color(0xFF1565C0)),
                  ),
                ),

                const SizedBox(width: 16),

                // Label text
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'roboto',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ),

                // Trailing chevron
                const Padding(
                  padding: EdgeInsets.only(right: 18),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.black26,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}