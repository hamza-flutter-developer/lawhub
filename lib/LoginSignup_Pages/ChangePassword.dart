// ══════════════════════════════════════════════════════════════════════════════
// FILE: ChangePassword.dart
// PURPOSE: Allows users to set new password after phone verification
// ══════════════════════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lawhub/LoginSignup_Pages/LoginPage.dart';
import 'package:lawhub/Utils/Utilities.dart';
import 'package:lawhub/widgets/Fonts.dart';
import '../widgets/Themes.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// ChangePassword Widget (StatefulWidget)
/// ═══════════════════════════════════════════════════════════════════════════
/// This screen appears after successful phone verification
/// Allows user to set a new password and saves it to Firestore
class ChangePassword extends StatefulWidget {
  final String phone;
  const ChangePassword({super.key, required this.phone});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword>
    with SingleTickerProviderStateMixin {
  // ─────────────────────────────────────────────────────────────────────────
  // STATE VARIABLES
  // ─────────────────────────────────────────────────────────────────────────
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();
  final _form = GlobalKey<FormState>();
  bool isLoading = false;

  // Password visibility toggles
  final textFieldFocusNode = FocusNode();
  bool _obscured = true;

  final textFieldFocusNode2 = FocusNode();
  bool _obscured2 = true;

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    /// Setup entrance animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    textFieldFocusNode.dispose();
    textFieldFocusNode2.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // ═════════════════════════════════════════════════════════════════════════
  // PASSWORD VISIBILITY TOGGLES
  // ═════════════════════════════════════════════════════════════════════════
  void _toggleObscured() {
    setState(() {
      _obscured = !_obscured;
      if (textFieldFocusNode.hasPrimaryFocus) {
        return;
      }
      textFieldFocusNode.canRequestFocus = false;
    });
  }

  void _toggleObscured2() {
    setState(() {
      _obscured2 = !_obscured2;
      if (textFieldFocusNode2.hasPrimaryFocus) {
        return;
      }
      textFieldFocusNode2.canRequestFocus = false;
    });
  }

  // ═════════════════════════════════════════════════════════════════════════
  // FIRESTORE UPDATE FUNCTIONS - YOUR EXISTING LOGIC (UNCHANGED)
  // ═════════════════════════════════════════════════════════════════════════

  /// ─────────────────────────────────────────────────────────────────────────
  /// FUNCTION: _updateUserPassword()
  /// PURPOSE: Updates password in Users collection
  /// ─────────────────────────────────────────────────────────────────────────
  void _updateUserPassword(String password) async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc('${widget.phone}@gmail.com')
        .update({'password': password});
    Utilities().successMsg('Your Password has been successfully changed');
    setState(() {
      isLoading = false;
    });
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  /// ─────────────────────────────────────────────────────────────────────────
  /// FUNCTION: _updateLawyerPassword()
  /// PURPOSE: Updates password in Lawyers collection
  /// ─────────────────────────────────────────────────────────────────────────
  void _updateLawyerPassword(String password) async {
    await FirebaseFirestore.instance
        .collection('Lawyers')
        .doc('${widget.phone}@gmail.com')
        .update({'password': password});
    Utilities().successMsg('Your Password has been successfully changed');
    setState(() {
      isLoading = false;
    });
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const LoginPage()));
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
        child: Stack(
          children: [
            // ── Animated Logo ──
            Positioned(
              top: screenHeight * 0.05,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: TopLogo(fontColor: Colors.white),
              ),
            ),

            // ═══════════════════════════════════════════════════════════════
            // MAIN CONTENT CARD
            // ═══════════════════════════════════════════════════════════════
            SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          margin: EdgeInsets.only(
                            top: screenHeight * 0.15,
                          ),
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
                              // ─────────────────────────────────────────────
                              // TITLE SECTION
                              // ─────────────────────────────────────────────
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
                                      "Set New Password",
                                      style: TextStyle(
                                        fontFamily: 'patua',
                                        fontSize: 32,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1A1A1A),
                                        height: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      "Your identity has been verified! Create a strong new password",
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

                              // ─────────────────────────────────────────────
                              // FORM
                              // ─────────────────────────────────────────────
                              Padding(
                                padding: EdgeInsets.only(
                                  top: screenHeight * 0.04,
                                ),
                                child: Form(
                                  key: _form,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.08,
                                    ),
                                    child: Column(
                                      children: [
                                        // ══════════════════════════════════
                                        // NEW PASSWORD FIELD
                                        // ══════════════════════════════════
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey[50],
                                            borderRadius:
                                            BorderRadius.circular(16),
                                            border: Border.all(
                                              color: Colors.grey[200]!,
                                              width: 1,
                                            ),
                                          ),
                                          child: TextFormField(
                                            controller: _passwordController,
                                            focusNode: textFieldFocusNode,
                                            obscureText: _obscured,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontFamily: 'roboto',
                                            ),
                                            decoration: InputDecoration(
                                              hintText: "New Password",
                                              hintStyle: TextStyle(
                                                color: Colors.grey[400],
                                                fontFamily: 'roboto',
                                              ),
                                              prefixIcon: Icon(
                                                Icons.lock_outline_rounded,
                                                color: Colors.grey[600],
                                                size: 24,
                                              ),
                                              suffixIcon: IconButton(
                                                onPressed: _toggleObscured,
                                                icon: Icon(
                                                  _obscured
                                                      ? Icons
                                                      .visibility_off_rounded
                                                      : Icons.visibility_rounded,
                                                  color: Colors.grey[600],
                                                  size: 22,
                                                ),
                                              ),
                                              border: InputBorder.none,
                                              contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 20,
                                                vertical: 18,
                                              ),
                                            ),
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return "Please enter a password";
                                              }
                                              return null;
                                            },
                                          ),
                                        ),

                                        const SizedBox(height: 20),

                                        // ══════════════════════════════════
                                        // CONFIRM PASSWORD FIELD
                                        // ══════════════════════════════════
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey[50],
                                            borderRadius:
                                            BorderRadius.circular(16),
                                            border: Border.all(
                                              color: Colors.grey[200]!,
                                              width: 1,
                                            ),
                                          ),
                                          child: TextFormField(
                                            controller:
                                            _confirmPasswordController,
                                            focusNode: textFieldFocusNode2,
                                            obscureText: _obscured2,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontFamily: 'roboto',
                                            ),
                                            decoration: InputDecoration(
                                              hintText: "Confirm Password",
                                              hintStyle: TextStyle(
                                                color: Colors.grey[400],
                                                fontFamily: 'roboto',
                                              ),
                                              prefixIcon: Icon(
                                                Icons.lock_outline_rounded,
                                                color: Colors.grey[600],
                                                size: 24,
                                              ),
                                              suffixIcon: IconButton(
                                                onPressed: _toggleObscured2,
                                                icon: Icon(
                                                  _obscured2
                                                      ? Icons
                                                      .visibility_off_rounded
                                                      : Icons.visibility_rounded,
                                                  color: Colors.grey[600],
                                                  size: 22,
                                                ),
                                              ),
                                              border: InputBorder.none,
                                              contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 20,
                                                vertical: 18,
                                              ),
                                            ),
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return "Please confirm your password";
                                              } else if (_passwordController
                                                  .text
                                                  .toString() !=
                                                  _confirmPasswordController.text
                                                      .toString()) {
                                                return "Passwords do not match";
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // ─────────────────────────────────────────────
                              // SUBMIT BUTTON
                              // ─────────────────────────────────────────────
                              Padding(
                                padding: EdgeInsets.only(
                                  top: screenHeight * 0.04,
                                  left: screenWidth * 0.08,
                                  right: screenWidth * 0.08,
                                ),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: isLoading
                                        ? null
                                        : () async {
                                      if (textFieldFocusNode.hasFocus) {
                                        textFieldFocusNode.unfocus();
                                      }
                                      if (textFieldFocusNode2.hasFocus) {
                                        textFieldFocusNode2.unfocus();
                                      }
                                      if (_form.currentState!.validate()) {
                                        setState(() {
                                          isLoading = true;
                                        });

                                        var documentUser =
                                        await FirebaseFirestore.instance
                                            .collection('Users')
                                            .doc(
                                            '${widget.phone}@gmail.com')
                                            .get();
                                        if (documentUser.exists) {
                                          _updateUserPassword(
                                              _confirmPasswordController.text
                                                  .toString());
                                        }

                                        var documentLawyer =
                                        await FirebaseFirestore.instance
                                            .collection('Lawyers')
                                            .doc(
                                            '${widget.phone}@gmail.com')
                                            .get();
                                        if (documentLawyer.exists) {
                                          _updateLawyerPassword(
                                              _confirmPasswordController.text
                                                  .toString());
                                        }
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1565C0),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      disabledBackgroundColor: Colors.grey[300],
                                    ),
                                    child: isLoading
                                        ? Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: SpinKitCircle(
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Updating...',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'roboto',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    )
                                        : const Text(
                                      'Update Password',
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

                              const Spacer(),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
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
// 1. Firestore Update:
//    - .update(): Updates specific fields in existing document
//    - Different from .set() which replaces entire document
//    - More efficient for partial updates
//
// 2. Checking Multiple Collections:
//    - App checks both Users and Lawyers collections
//    - Updates whichever collection contains the user
//    - Common pattern when you have multiple user types
//
// 3. Widget Parameters:
//    - widget.phone: Access parameter passed from previous screen
//    - required keyword ensures parameter must be provided
//    - Allows passing data between screens
//
// ══════════════════════════════════════════════════════════════════════════════