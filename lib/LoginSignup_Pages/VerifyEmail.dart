// ══════════════════════════════════════════════════════════════════════════════
// FILE: VerifyEmail.dart
// PURPOSE: Email verification waiting screen - polls Firebase for verification
// ══════════════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lawhub/LoginSignup_Pages/UserType.dart';
import 'package:lawhub/Utils/Utilities.dart';
import 'package:lawhub/widgets/Themes.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// VerifyEmail Widget (StatefulWidget)
/// ═══════════════════════════════════════════════════════════════════════════
/// This screen:
/// - Shows email verification instructions
/// - Polls Firebase every 3 seconds to check verification status
/// - Auto-navigates when email is verified
/// - Allows resending verification email
class VerifyEmail extends StatefulWidget {
  final String email;
  final String name;
  const VerifyEmail({super.key, required this.email, required this.name});

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail>
    with SingleTickerProviderStateMixin {
  // ─────────────────────────────────────────────────────────────────────────
  // STATE VARIABLES
  // ─────────────────────────────────────────────────────────────────────────
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Timer _verificationTimer;
  bool isResend = false;

  // Animation controller
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  // ═════════════════════════════════════════════════════════════════════════
  // LIFECYCLE METHODS
  // ═════════════════════════════════════════════════════════════════════════

  @override
  void initState() {
    super.initState();

    /// Setup animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    /// Pulse animation for email icon
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.repeat(reverse: true);

    /// ─────────────────────────────────────────────────────────────────────
    /// VERIFICATION TIMER (YOUR EXISTING LOGIC - UNCHANGED)
    /// ─────────────────────────────────────────────────────────────────────
    /// Checks every 3 seconds if email has been verified
    /// When verified, navigates to UserType selection screen
    _verificationTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkEmailVerificationStatus();
    });
  }

  /// ───────────────────────────────────────────────────────────────────────
  /// FUNCTION: _checkEmailVerificationStatus()
  /// PURPOSE: Polls Firebase to check if user verified their email
  /// ───────────────────────────────────────────────────────────────────────
  Future<void> _checkEmailVerificationStatus() async {
    User? user = _auth.currentUser;

    if (user != null) {
      user.reload();
      user = _auth.currentUser; // Refresh user data
      if (user!.emailVerified) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => UserType(
                  email: widget.email,
                  name: widget.name,
                  password: '',
                )));
        _verificationTimer.cancel();
      }
    }
  }

  @override
  void dispose() {
    _verificationTimer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  // ═════════════════════════════════════════════════════════════════════════
  // BUILD METHOD: Creates the UI
  // ═════════════════════════════════════════════════════════════════════════
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
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: TopLogo(fontColor: Colors.white),
              ),
            ),

            // ═══════════════════════════════════════════════════════════════
            // MAIN CONTENT CARD
            // ═══════════════════════════════════════════════════════════════
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
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
                  child: Column(
                    children: [
                      // ─────────────────────────────────────────────────────
                      // EMAIL ICON WITH PULSE ANIMATION
                      // ─────────────────────────────────────────────────────
                      Padding(
                        padding: EdgeInsets.only(top: screenHeight * 0.06),
                        child: Center(
                          child: ScaleTransition(
                            scale: _pulseAnimation,
                            child: Container(
                              width: screenWidth * 0.6,
                              height: screenWidth * 0.6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF1565C0).withAlpha(25),
                              ),
                              child: Center(
                                child: Container(
                                  width: screenWidth * 0.45,
                                  height: screenWidth * 0.45,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF1565C0)
                                        .withAlpha(51),
                                  ),
                                  child: Icon(
                                    Icons.email_rounded,
                                    size: 80,
                                    color: const Color(0xFF1565C0),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // ─────────────────────────────────────────────────────
                      // TEXT CONTENT
                      // ─────────────────────────────────────────────────────
                      Padding(
                        padding: EdgeInsets.only(
                          top: screenHeight * 0.04,
                          left: screenWidth * 0.08,
                          right: screenWidth * 0.08,
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Verify Your Email',
                              style: TextStyle(
                                fontFamily: "patua",
                                fontWeight: FontWeight.w600,
                                fontSize: 28,
                                color: Color(0xFF1A1A1A),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Text(
                              "We sent a confirmation email to:",
                              style: TextStyle(
                                fontFamily: "roboto",
                                fontSize: 15,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: screenHeight * 0.015),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1565C0).withAlpha(25),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                widget.email,
                                style: const TextStyle(
                                  fontFamily: "roboto",
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1565C0),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.03),
                            Text(
                              "Check your email and click the confirmation link to continue.",
                              style: TextStyle(
                                fontFamily: "roboto",
                                fontSize: 15,
                                color: Colors.grey[600],
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      const Expanded(child: SizedBox()),

                      // ─────────────────────────────────────────────────────
                      // RESEND EMAIL BUTTON
                      // ─────────────────────────────────────────────────────
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: screenHeight * 0.03,
                          left: screenWidth * 0.08,
                          right: screenWidth * 0.08,
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton(
                            onPressed: () async {
                              try {
                                await _auth.currentUser?.sendEmailVerification();
                                Utilities().successMsg(
                                    "Confirmation email resent to ${widget.email}");
                              } catch (e) {
                                Utilities().errorMsg(
                                    "Service not available, please try again in 1 minute");
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF1565C0),
                              side: const BorderSide(
                                color: Color(0xFF1565C0),
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Resend Email',
                              style: TextStyle(
                                fontFamily: 'roboto',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),
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
// 1. Timer.periodic():
//    - Runs a function repeatedly at specified intervals
//    - Used to poll Firebase for verification status
//    - Must be cancelled in dispose() to prevent memory leaks
//
// 2. User Reload:
//    - user.reload(): Refreshes user data from Firebase
//    - Necessary to get updated emailVerified status
//    - Firebase doesn't push updates, you must poll
//
// 3. Pulse Animation:
//    - Uses ScaleTransition for growing/shrinking effect
//    - Creates attention-drawing effect on email icon
//    - repeat(reverse: true): Ping-pong animation
//
// 4. OutlinedButton:
//    - Button with border and no fill
//    - Good for secondary actions
//    - Provides visual hierarchy (primary vs secondary buttons)
//
// ══════════════════════════════════════════════════════════════════════════════