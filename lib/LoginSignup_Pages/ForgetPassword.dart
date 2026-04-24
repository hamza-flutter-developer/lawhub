// ══════════════════════════════════════════════════════════════════════════════
// FILE: ForgetPassword.dart
// PURPOSE: Password recovery screen - sends reset email or OTP via phone
// ══════════════════════════════════════════════════════════════════════════════

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lawhub/LoginSignup_Pages/LoginPage.dart';
import 'package:lawhub/Utils/Utilities.dart';
import 'package:lawhub/widgets/Fonts.dart';
import '../widgets/Themes.dart';
import 'SignupOTPVerification.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// ForgetPassword Widget (StatefulWidget)
/// ═══════════════════════════════════════════════════════════════════════════
/// Handles password recovery via:
/// - Email: Sends password reset link
/// - Phone: Sends OTP for verification
class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> with SingleTickerProviderStateMixin {
  // ─────────────────────────────────────────────────────────────────────────
  // STATE VARIABLES
  // ─────────────────────────────────────────────────────────────────────────
  final TextEditingController _emailPhoneController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _form = GlobalKey<FormState>();

  bool isEmailValid = false;
  bool isPhoneValid = false;
  final textFieldFocusNode = FocusNode();
  bool isLoading = false;

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
    _emailPhoneController.dispose();
    textFieldFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // ═════════════════════════════════════════════════════════════════════════
  // VALIDATION FUNCTIONS
  // ═════════════════════════════════════════════════════════════════════════
  bool _isValidEmail(String email) {
    RegExp emailRegExp = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
    return emailRegExp.hasMatch(email);
  }

  bool _isValidPhoneNumber(String phoneNumber) {
    RegExp phoneRegExp = RegExp(r'^\+\d{12}$');
    return phoneRegExp.hasMatch(phoneNumber);
  }

  // ═════════════════════════════════════════════════════════════════════════
  // PASSWORD RESET FUNCTIONS - YOUR EXISTING LOGIC (UNCHANGED)
  // ═════════════════════════════════════════════════════════════════════════

  /// ─────────────────────────────────────────────────────────────────────────
  /// FUNCTION: _sendVerificationEmail()
  /// PURPOSE: Sends password reset email via Firebase
  /// ─────────────────────────────────────────────────────────────────────────
  void _sendVerificationEmail() async {
    _auth
        .sendPasswordResetEmail(email: _emailPhoneController.text)
        .then((value) => {
      setState(() {
        isLoading = false;
      }),
      Utilities().successMsg(
          'We have sent you email to recover password, please check email'),
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const LoginPage())),
    })
        .onError((error, stackTrace) => {
      setState(() {
        isLoading = false;
      }),
      Utilities()
          .errorMsg('Something went wrong, please try again later'),
    });
  }

  /// ─────────────────────────────────────────────────────────────────────────
  /// FUNCTION: _verifyPhoneNumber()
  /// PURPOSE: Initiates phone verification for password reset
  /// ─────────────────────────────────────────────────────────────────────────
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
                    isForgottenPass: true,
                    emailPhone: _emailPhoneController.text.toString(),
                    name: '',
                    verificationId: verificationId,
                    password: '')));
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
            // ── Animated Logo ──
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
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    margin: EdgeInsets.only(
                      top: screenHeight * 0.0425,
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
                    child: SingleChildScrollView(
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
                                  "Forgot Password?",
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
                                  "Enter your email or phone number to receive a password reset link",
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
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.grey[200]!,
                                      width: 1,
                                    ),
                                  ),
                                  child: TextFormField(
                                    controller: _emailPhoneController,
                                    focusNode: textFieldFocusNode,
                                    keyboardType: TextInputType.emailAddress,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'roboto',
                                    ),
                                    decoration: InputDecoration(
                                      hintText: "Email or Phone Number",
                                      hintStyle: TextStyle(
                                        color: Colors.grey[400],
                                        fontFamily: 'roboto',
                                      ),
                                      prefixIcon: Icon(
                                        Icons.alternate_email_rounded,
                                        color: Colors.grey[600],
                                        size: 24,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 18,
                                      ),
                                    ),
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
                                      if (_isValidEmail(
                                          _emailPhoneController.text.toString())) {
                                        isEmailValid = true;
                                        isPhoneValid = false;
                                      } else if (_isValidPhoneNumber(
                                          _emailPhoneController.text.toString())) {
                                        isPhoneValid = true;
                                        isEmailValid = false;
                                      }
                                      return null;
                                    },
                                  ),
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
                                    : () {
                                  if (textFieldFocusNode.hasFocus) {
                                    textFieldFocusNode.unfocus();
                                  }
                                  if (_form.currentState!.validate()) {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    if (isEmailValid) {
                                      _sendVerificationEmail();
                                    } else if (isPhoneValid) {
                                      _verifyPhoneNumber();
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
                                      'Sending...',
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
                                  'Reset Password',
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

                          SizedBox(height: screenHeight * 0.05),
                        ],
                      ),
                    ),
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
// 1. Password Reset Flow:
//    - Email: Firebase sends reset link automatically
//    - Phone: App sends OTP and verifies before allowing reset
//    - sendPasswordResetEmail(): Built-in Firebase method
//
// 2. Error Handling:
//    - .then(): Executes on success
//    - .onError(): Executes on failure
//    - Always show user-friendly messages
//
// 3. Input Validation:
//    - Checks format before submitting to Firebase
//    - Prevents unnecessary API calls
//    - Provides immediate feedback to user
//
// ══════════════════════════════════════════════════════════════════════════════