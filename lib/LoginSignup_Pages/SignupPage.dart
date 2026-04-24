// ══════════════════════════════════════════════════════════════════════════════
// FILE: SignupPage.dart
// PURPOSE: User registration screen - handles email/phone signup with validation
// ══════════════════════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lawhub/LoginSignup_Pages/SignupOTPVerification.dart';
import 'package:lawhub/Utils/Utilities.dart';
import 'package:lawhub/LoginSignup_Pages/VerifyEmail.dart';
import 'package:lawhub/widgets/Fonts.dart';
import 'package:lawhub/widgets/Themes.dart';
import 'LoginPage.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// SignUpPage Widget (StatefulWidget)
/// ═══════════════════════════════════════════════════════════════════════════
/// Handles user registration with:
/// - Email OR phone number
/// - Password validation & confirmation
/// - Email verification flow
/// - Phone OTP verification flow
/// - Duplicate account checking
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with SingleTickerProviderStateMixin {
  // ─────────────────────────────────────────────────────────────────────────
  // STATE VARIABLES: Form Controllers
  // ─────────────────────────────────────────────────────────────────────────
  /// TextEditingController: Manages text input for each field
  /// Think of them as "containers" that hold and track what user types
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailPhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  /// Form key for validation - gives us access to all form fields at once
  final _form = GlobalKey<FormState>();

  /// Firebase Auth instance - handles all authentication operations
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Loading state indicator
  bool isLoading = false;

  // ─────────────────────────────────────────────────────────────────────────
  // ANIMATION CONTROLLERS
  // ─────────────────────────────────────────────────────────────────────────
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    /// Setup entrance animations for smooth UI
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
    /// Always dispose controllers to prevent memory leaks
    _nameController.dispose();
    _emailPhoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // ═════════════════════════════════════════════════════════════════════════
  // EMAIL VERIFICATION FUNCTION - YOUR EXISTING LOGIC (UNCHANGED)
  // ═════════════════════════════════════════════════════════════════════════
  /// ─────────────────────────────────────────────────────────────────────────
  /// FUNCTION: _sendVerificationEmail()
  /// PURPOSE: Creates Firebase user account and sends verification email
  /// ─────────────────────────────────────────────────────────────────────────
  /// FLOW:
  /// 1. Create user with Firebase Auth
  /// 2. Send verification email
  /// 3. Navigate to VerifyEmail screen
  /// 4. Handle account-already-exists case
  void _sendVerificationEmail() async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailPhoneController.text,
        password: _passwordController.text,
      );
      User? user = userCredential.user;
      if (user != null) {
        await user.sendEmailVerification();
        setState(() {
          isLoading = false;
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => VerifyEmail(
                      email: _emailPhoneController.text.toString(),
                      name: _nameController.text.toString())));
        });
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == "ERROR_EMAIL_ALREADY_IN_USE" ||
          e.code == "account-exists-with-different-credential" ||
          e.code == "email-already-in-use") {
        _auth.signInWithEmailAndPassword(
            email: _emailPhoneController.text,
            password: _passwordController.text);
        setState(() {
          User? userCheck = _auth.currentUser;
          debugPrint(_auth.currentUser?.email);
          if (!userCheck!.emailVerified) {
            userCheck.sendEmailVerification();
            setState(() {
              isLoading = false;
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => VerifyEmail(
                          email: _emailPhoneController.text.toString(),
                          name: _nameController.text.toString())));
            });
          } else {
            Utilities().getMessageFromErrorCode(e.code);
            setState(() {
              isLoading = false;
            });
          }
        });
      } else {
        Utilities().getMessageFromErrorCode(e.code);
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ═════════════════════════════════════════════════════════════════════════
  // PHONE VERIFICATION FUNCTION - YOUR EXISTING LOGIC (UNCHANGED)
  // ═════════════════════════════════════════════════════════════════════════
  /// ─────────────────────────────────────────────────────────────────────────
  /// FUNCTION: _verifyPhoneNumber()
  /// PURPOSE: Initiates phone number verification via SMS OTP
  /// ─────────────────────────────────────────────────────────────────────────
  /// Firebase Phone Auth has 4 callbacks:
  /// - verificationCompleted: Auto-verified (instant)
  /// - verificationFailed: Error occurred
  /// - codeSent: OTP sent successfully
  /// - codeAutoRetrievalTimeout: Timeout reached
  String verificationId = '';

  Future<void> _verifyPhoneNumber() async {
    verificationCompleted(PhoneAuthCredential credential) async {}

    verificationFailed(FirebaseAuthException e) {
      setState(() {
        isLoading = false;
      });
    }

    codeSent(String verificationId, int? resendToken) async {
      setState(() {
        isLoading = false;
        this.verificationId = verificationId;
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SignupOTPVerification(
                    isForgottenPass: false,
                    emailPhone: _emailPhoneController.text.toString(),
                    name: _nameController.text.toString(),
                    verificationId: verificationId,
                    password: _passwordController.text)));
      });
    }

    codeAutoRetrievalTimeout(String verificationId) {}

    await _auth.verifyPhoneNumber(
      phoneNumber: _emailPhoneController.text,
      timeout: const Duration(seconds: 60),
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // UI HELPER FUNCTIONS
  // ═════════════════════════════════════════════════════════════════════════

  /// Password visibility toggles
  final textFieldFocusNode = FocusNode();
  bool _obscured = true;

  void _toggleObscured() {
    setState(() {
      _obscured = !_obscured;
      if (textFieldFocusNode.hasPrimaryFocus) {
        return;
      }
      textFieldFocusNode.canRequestFocus = false;
    });
  }

  final textFieldFocusNode2 = FocusNode();
  bool _obscured2 = true;

  void _toggleObscured2() {
    setState(() {
      _obscured2 = !_obscured2;
      if (textFieldFocusNode2.hasPrimaryFocus) {
        return;
      }
      textFieldFocusNode2.canRequestFocus = false;
    });
  }

  /// Validation state
  bool isEmailValid = false;
  bool isPhoneValid = false;

  /// ─────────────────────────────────────────────────────────────────────────
  /// VALIDATION FUNCTIONS: Check email/phone format
  /// ─────────────────────────────────────────────────────────────────────────
  bool _isValidEmail(String email) {
    RegExp emailRegExp = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
    return emailRegExp.hasMatch(email);
  }

  bool _isValidPhoneNumber(String phoneNumber) {
    RegExp phoneRegExp = RegExp(r'^\+\d{12}$');
    return phoneRegExp.hasMatch(phoneNumber);
  }

  final textFieldFocusNode0 = FocusNode();
  final textFieldFocusNode1 = FocusNode();

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
                                      "Create Account",
                                      style: TextStyle(
                                        fontFamily: 'patua',
                                        fontSize: 32,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1A1A1A),
                                        height: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Sign up to get started",
                                      style: TextStyle(
                                        fontFamily: 'roboto',
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // ─────────────────────────────────────────────
                              // SIGNUP FORM
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
                                        // FULL NAME FIELD
                                        // ══════════════════════════════════
                                        _buildModernTextField(
                                          controller: _nameController,
                                          focusNode: textFieldFocusNode0,
                                          hint: "Full Name",
                                          icon: FontAwesomeIcons.userLarge,
                                          iconSize: 20,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return "Please enter your name";
                                            }
                                            return null;
                                          },
                                        ),

                                        const SizedBox(height: 20),

                                        // ══════════════════════════════════
                                        // EMAIL/PHONE FIELD
                                        // ══════════════════════════════════
                                        _buildModernTextField(
                                          controller: _emailPhoneController,
                                          focusNode: textFieldFocusNode1,
                                          hint: "Email or Phone Number",
                                          icon: Icons.alternate_email_rounded,
                                          keyboardType: TextInputType.emailAddress,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return "Please enter email or phone";
                                            } else if (!_isValidEmail(
                                                _emailPhoneController.text
                                                    .toString()) &&
                                                !_isValidPhoneNumber(
                                                    _emailPhoneController.text
                                                        .toString())) {
                                              return "Format: xyz@example.com OR +92XXXXXXXXXX";
                                            }
                                            if (_isValidEmail(_emailPhoneController
                                                .text
                                                .toString())) {
                                              isEmailValid = true;
                                              isPhoneValid = false;
                                            } else if (_isValidPhoneNumber(
                                                _emailPhoneController.text
                                                    .toString())) {
                                              isPhoneValid = true;
                                              isEmailValid = false;
                                            }
                                            return null;
                                          },
                                        ),

                                        const SizedBox(height: 20),

                                        // ══════════════════════════════════
                                        // PASSWORD FIELD
                                        // ══════════════════════════════════
                                        _buildModernTextField(
                                          controller: _passwordController,
                                          focusNode: textFieldFocusNode,
                                          hint: "Password",
                                          icon: Icons.lock_outline_rounded,
                                          obscureText: _obscured,
                                          suffixIcon: IconButton(
                                            onPressed: _toggleObscured,
                                            icon: Icon(
                                              _obscured
                                                  ? Icons.visibility_off_rounded
                                                  : Icons.visibility_rounded,
                                              color: Colors.grey[600],
                                              size: 22,
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return "Please enter a password";
                                            }
                                            return null;
                                          },
                                        ),

                                        const SizedBox(height: 20),

                                        // ══════════════════════════════════
                                        // CONFIRM PASSWORD FIELD
                                        // ══════════════════════════════════
                                        _buildModernTextField(
                                          controller: _confirmPasswordController,
                                          focusNode: textFieldFocusNode2,
                                          hint: "Confirm Password",
                                          icon: Icons.lock_outline_rounded,
                                          obscureText: _obscured2,
                                          suffixIcon: IconButton(
                                            onPressed: _toggleObscured2,
                                            icon: Icon(
                                              _obscured2
                                                  ? Icons.visibility_off_rounded
                                                  : Icons.visibility_rounded,
                                              color: Colors.grey[600],
                                              size: 22,
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return "Please confirm your password";
                                            } else if (_passwordController.text
                                                .toString() !=
                                                _confirmPasswordController.text
                                                    .toString()) {
                                              return "Passwords do not match";
                                            }
                                            return null;
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // ─────────────────────────────────────────────
                              // NEXT BUTTON (YOUR EXISTING LOGIC)
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
                                      // Unfocus all fields
                                      if (textFieldFocusNode2.hasFocus) {
                                        textFieldFocusNode2.unfocus();
                                      }
                                      if (textFieldFocusNode0.hasFocus) {
                                        textFieldFocusNode0.unfocus();
                                      }
                                      if (textFieldFocusNode1.hasFocus) {
                                        textFieldFocusNode1.unfocus();
                                      }
                                      if (textFieldFocusNode.hasFocus) {
                                        textFieldFocusNode.unfocus();
                                      }

                                      if (_form.currentState!.validate()) {
                                        setState(() {
                                          isLoading = true;
                                        });

                                        // Email signup flow
                                        if (isEmailValid) {
                                          _sendVerificationEmail();
                                        }

                                        // Phone signup flow
                                        if (isPhoneValid) {
                                          var documentUser =
                                          await FirebaseFirestore
                                              .instance
                                              .collection('Users')
                                              .doc(
                                              '${_emailPhoneController.text}@gmail.com')
                                              .get();
                                          var documentLawyer =
                                          await FirebaseFirestore
                                              .instance
                                              .collection('Lawyers')
                                              .doc(
                                              '${_emailPhoneController.text}@gmail.com')
                                              .get();
                                          if (documentUser.exists ||
                                              documentLawyer.exists) {
                                            setState(() {
                                              isLoading = false;
                                            });
                                            Utilities().errorMsg(
                                                'Phone number already registered');
                                          } else {
                                            _verifyPhoneNumber();
                                          }
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
                                          'Processing...',
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
                                      'Next',
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

                              // ─────────────────────────────────────────────
                              // LOGIN LINK
                              // ─────────────────────────────────────────────
                              Padding(
                                padding: EdgeInsets.only(
                                    bottom: screenHeight * 0.03),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Already have an account?",
                                      style: TextStyle(
                                        fontFamily: 'roboto',
                                        fontSize: 15,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                            const LoginPage(),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        "Login",
                                        style: TextStyle(
                                          fontFamily: 'roboto',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Color(0xFF1565C0),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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

  // ═════════════════════════════════════════════════════════════════════════
  // REUSABLE MODERN TEXT FIELD BUILDER
  // ═════════════════════════════════════════════════════════════════════════
  /// ─────────────────────────────────────────────────────────────────────────
  /// HELPER METHOD: _buildModernTextField()
  /// PURPOSE: Creates consistent, modern text input fields
  /// PARAMETERS:
  /// - controller: Manages the text input
  /// - focusNode: Tracks field focus state
  /// - hint: Placeholder text
  /// - icon: Leading icon
  /// - validator: Validation function
  /// - obscureText: Hide text (for passwords)
  /// - suffixIcon: Trailing icon (e.g., password toggle)
  /// ─────────────────────────────────────────────────────────────────────────
  Widget _buildModernTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required IconData icon,
    double? iconSize,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontSize: 16,
          fontFamily: 'roboto',
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontFamily: 'roboto',
          ),
          prefixIcon: Icon(
            icon,
            color: Colors.grey[600],
            size: iconSize ?? 24,
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
        validator: validator,
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// FLUTTER CONCEPTS EXPLAINED IN THIS FILE:
// ══════════════════════════════════════════════════════════════════════════════
//
// 1. Firebase Authentication:
//    - createUserWithEmailAndPassword(): Creates new user account
//    - sendEmailVerification(): Sends verification link to email
//    - verifyPhoneNumber(): Initiates SMS OTP verification
//    - FirebaseAuthException: Catches authentication errors
//
// 2. Form Validation:
//    - GlobalKey<FormState>: Gives access to form state
//    - validator: Function that checks if input is valid
//    - Returns null = valid, Returns String = error message
//    - currentState!.validate(): Checks all fields at once
//
// 3. Regular Expressions (RegEx):
//    - Pattern matching for email/phone validation
//    - r'^...$ denotes raw string (special characters work directly)
//    - \w = word character, \d = digit, + = one or more
//
// 4. Async/Await:
//    - async functions can pause execution
//    - await waits for asynchronous operations to complete
//    - Better than .then() for multiple operations
//
// 5. Firestore Queries:
//    - collection('Users'): Access database collection
//    - doc('email'): Get specific document
//    - .get(): Fetch data (returns Future)
//    - .exists: Check if document found
//
// 6. Password Visibility Toggle:
//    - obscureText controls whether text is hidden
//    - Toggle between true/false to show/hide password
//    - Common UX pattern for security
//
// 7. FocusNode:
//    - Tracks which input field is active
//    - .hasFocus checks if field is selected
//    - .unfocus() removes focus (hides keyboard)
//    - Important for UX and keyboard management
//
// 8. Helper Methods:
//    - _buildModernTextField(): Reusable widget builder
//    - Reduces code duplication
//    - Makes UI consistent across all input fields
//    - Named parameters for flexibility
//
// 9. State Management:
//    - setState(): Triggers UI rebuild
//    - Only call when data changes that affects UI
//    - All UI updates must be inside setState()
//
// 10. Navigation:
//     - Navigator.push(): Go to new screen
//     - MaterialPageRoute: Standard page transition
//     - Can pass data between screens via constructor
//
// ══════════════════════════════════════════════════════════════════════════════