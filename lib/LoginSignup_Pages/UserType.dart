// ══════════════════════════════════════════════════════════════════════════════
// FILE: UserType.dart
// PURPOSE: Account type selection screen - User or Lawyer
// ══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lawhub/LoginSignup_Pages/UserSignup.dart';
import 'package:lawhub/widgets/Fonts.dart';
import 'package:lawhub/widgets/Themes.dart';
import 'LawyerSignup.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// UserType Widget (StatelessWidget)
/// ═══════════════════════════════════════════════════════════════════════════
/// This screen appears after email verification
/// Allows user to choose their account type:
/// - Regular User (looking for legal help)
/// - Lawyer (providing legal services)
///
/// StatelessWidget because it just displays options (no state to track)
class UserType extends StatelessWidget {
  final String email;
  final String name;
  final String password;

  UserType({
    super.key,
    required this.email,
    required this.name,
    required this.password,
  });

  String userType = '';

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E88E5),
              Color(0xFF1565C0),
              Color(0xFF0D47A1),
            ],
          ),
        ),
        child: Column(
          children: [
            // ── Logo ──
            Padding(
              padding: EdgeInsets.only(top: screenHeight * 0.05),
              child: TopLogo(fontColor: Colors.white),
            ),

            // ═══════════════════════════════════════════════════════════════
            // MAIN CONTENT CARD
            // ═══════════════════════════════════════════════════════════════
            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: screenHeight * 0.0425),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(76),
                      blurRadius: 30,
                      spreadRadius: 0,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // ─────────────────────────────────────────────────────
                      // TITLE SECTION
                      // ─────────────────────────────────────────────────────
                      Padding(
                        padding: EdgeInsets.only(
                          left: screenWidth * 0.08,
                          right: screenWidth * 0.08,
                          top: screenHeight * 0.05,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Choose Your Role",
                              style: TextStyle(
                                fontFamily: 'patua',
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A1A),
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Select how you'll be using LawHub",
                              style: TextStyle(
                                fontFamily: 'roboto',
                                fontSize: 15,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w400,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.06),

                      // ═════════════════════════════════════════════════════
                      // USER OPTION CARD
                      // ═════════════════════════════════════════════════════
                      /// ─────────────────────────────────────────────────────
                      /// USER CARD: For regular users seeking legal help
                      /// ─────────────────────────────────────────────────────
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.08,
                        ),
                        child: InkWell(
                          onTap: () {
                            userType = 'User';
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserSignup(
                                  email: email,
                                  name: name,
                                  password: password,
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF1565C0).withAlpha(51),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF1565C0).withAlpha(25),
                                  blurRadius: 20,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Icon container
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1565C0).withAlpha(25),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: const Icon(
                                    FontAwesomeIcons.userLarge,
                                    size: 28,
                                    color: Color(0xFF1565C0),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                // Text content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "I'm a User",
                                        style: TextStyle(
                                          fontFamily: 'roboto',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Color(0xFF1A1A1A),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Looking for legal help",
                                        style: TextStyle(
                                          fontFamily: 'roboto',
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Arrow icon
                                Icon(
                                  FontAwesomeIcons.chevronRight,
                                  size: 18,
                                  color: Colors.grey[400],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.025),

                      // ═════════════════════════════════════════════════════
                      // LAWYER OPTION CARD
                      // ═════════════════════════════════════════════════════
                      /// ─────────────────────────────────────────────────────
                      /// LAWYER CARD: For legal professionals
                      /// ─────────────────────────────────────────────────────
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.08,
                        ),
                        child: InkWell(
                          onTap: () {
                            userType = 'Lawyer';
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LawyerSignup(
                                  email: email,
                                  name: name,
                                  password: password,
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF1565C0).withAlpha(51),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF1565C0).withAlpha(25),
                                  blurRadius: 20,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Icon container
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1565C0).withAlpha(25),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: const Icon(
                                    FontAwesomeIcons.userTie,
                                    size: 28,
                                    color: Color(0xFF1565C0),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                // Text content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "I'm a Lawyer",
                                        style: TextStyle(
                                          fontFamily: 'roboto',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Color(0xFF1A1A1A),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Register as an advocate",
                                        style: TextStyle(
                                          fontFamily: 'roboto',
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Arrow icon
                                Icon(
                                  FontAwesomeIcons.chevronRight,
                                  size: 18,
                                  color: Colors.grey[400],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.04),
                    ],
                  ),
                ),
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
// 1. Decision Point Screen:
//    - Simple choice between two options
//    - Routes to different signup flows based on selection
//    - No data collection, just navigation
//
// 2. InkWell vs GestureDetector:
//    - InkWell provides Material ripple effect on tap
//    - GestureDetector has no visual feedback
//    - InkWell better for card-style buttons
//
// 3. Card Design Pattern:
//    - Icon in colored container (visual hierarchy)
//    - Title and subtitle (clear labeling)
//    - Arrow icon (indicates tap/navigation)
//    - Consistent padding and spacing
//
// 4. Navigation with Parameters:
//    - Passes email, name, password to next screen
//    - Both signup screens need same data
//    - Alternative: Could use state management (Provider, Riverpod, etc.)
//
// 5. StatelessWidget:
//    - No state to track (just displays options)
//    - More efficient than StatefulWidget
//    - Used when UI doesn't change based on internal data
//
// ══════════════════════════════════════════════════════════════════════════════