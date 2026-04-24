// ══════════════════════════════════════════════════════════════════════════════
// FILE: LoginPage.dart
// PURPOSE: Authentication screen where users/lawyers log in with email or phone
// ══════════════════════════════════════════════════════════════════════════════

// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lawhub/User_Pages/UserAppBar&NavBar.dart';
import 'package:lawhub/LoginSignup_Pages/ForgetPassword.dart';
import 'package:lawhub/Utils/Utilities.dart';
import 'package:lawhub/widgets/Fonts.dart';
import 'package:lawhub/widgets/Themes.dart';
import '../Lawyer_Pages/LawyerAppBar&NavBar.dart';
import 'SignupPage.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// LoginPage Widget (StatefulWidget)
/// ═══════════════════════════════════════════════════════════════════════════
/// This screen handles user/lawyer authentication via:
/// - Email login (checks Users & Lawyers collections)
/// - Phone number login (checks Users & Lawyers collections)
/// - Firebase Authentication for security
/// - Firestore for user data lookup
///
/// StatefulWidget because we need to:
/// - Track loading state
/// - Validate form inputs
/// - Show/hide password
/// - Handle user interactions
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

/// ═══════════════════════════════════════════════════════════════════════════
/// LoginPage State Class
/// ═══════════════════════════════════════════════════════════════════════════
class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  // ─────────────────────────────────────────────────────────────────────────
  // STATE VARIABLES: Store data that can change during the widget's lifetime
  // ─────────────────────────────────────────────────────────────────────────

  /// TextEditingController: Manages text input and retrieves user-entered text
  /// Think of it as a "listener" that knows what the user typed
  final TextEditingController _emailPhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  /// Firebase Auth instance - handles all authentication operations
  /// This is your connection to Firebase's authentication system
  final _auth = FirebaseAuth.instance;

  /// Loading state - shows spinner while authenticating
  /// true = show loading, false = show normal button
  bool isLoading = false;

  /// Form key - used to validate all form fields at once
  /// GlobalKey gives us access to the form's state from anywhere
  final _form = GlobalKey<FormState>();

  /// FocusNode: Tracks which text field is currently active (has cursor)
  /// Useful for keyboard management and UI responses
  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();

  /// Password visibility toggle
  /// true = password hidden (••••), false = password visible
  bool _obscured = true;

  /// Validation flags - track what type of input user provided
  bool isEmailValid = false;
  bool isPhoneValid = false;
  int checkEmailPhone = 0;

  /// Animation controller for smooth UI transitions
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // ─────────────────────────────────────────────────────────────────────────
  // LIFECYCLE: initState() - Runs once when widget is created
  // ─────────────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();

    // Setup animations for smooth entrance
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this, // SingleTickerProviderStateMixin provides this
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

    // Start the animation
    _animationController.forward();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // LIFECYCLE: dispose() - Cleanup when widget is removed
  // ─────────────────────────────────────────────────────────────────────────
  @override
  void dispose() {
    // Always dispose controllers to prevent memory leaks
    _emailPhoneController.dispose();
    _passwordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // ═════════════════════════════════════════════════════════════════════════
  // UI HELPER FUNCTIONS
  // ═════════════════════════════════════════════════════════════════════════

  /// ─────────────────────────────────────────────────────────────────────────
  /// FUNCTION: _toggleObscured()
  /// PURPOSE: Show/hide password when user taps the eye icon
  /// ─────────────────────────────────────────────────────────────────────────
  void _toggleObscured() {
    setState(() {
      _obscured = !_obscured; // Flips between true/false
      // Prevent focus issues when toggling
      if (emailFocusNode.hasPrimaryFocus) return;
      emailFocusNode.canRequestFocus = false;
    });
  }

  // ═════════════════════════════════════════════════════════════════════════
  // VALIDATION FUNCTIONS: Check if user input is valid
  // ═════════════════════════════════════════════════════════════════════════

  /// ─────────────────────────────────────────────────────────────────────────
  /// FUNCTION: _isValidEmail()
  /// PURPOSE: Check if string is a valid email format
  /// LOGIC: Uses Regular Expression (RegEx) to match email pattern
  /// ─────────────────────────────────────────────────────────────────────────
  /// RegEx Pattern Breakdown:
  /// ^          = Start of string
  /// [\w-]+     = One or more word characters or hyphens
  /// (\.[\w-]+)*= Zero or more groups of dot + word characters
  /// @          = Required @ symbol
  /// [\w-]+     = Domain name
  /// (\.[\w-]+)+= One or more domain extensions (.com, .org, etc.)
  /// $          = End of string
  bool _isValidEmail(String email) {
    RegExp emailRegExp = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
    return emailRegExp.hasMatch(email);
  }

  /// ─────────────────────────────────────────────────────────────────────────
  /// FUNCTION: _isValidPhoneNumber()
  /// PURPOSE: Check if string is a valid phone format (+92XXXXXXXXXX)
  /// LOGIC: Ensures format is exactly: + followed by 12 digits
  /// ─────────────────────────────────────────────────────────────────────────
  /// RegEx Pattern Breakdown:
  /// ^      = Start of string
  /// \+     = Plus sign (escaped because + is special in RegEx)
  /// \d{12} = Exactly 12 digits
  /// $      = End of string
  bool _isValidPhoneNumber(String phoneNumber) {
    RegExp phoneRegExp = RegExp(r'^\+\d{12}$');
    return phoneRegExp.hasMatch(phoneNumber);
  }

  // ═════════════════════════════════════════════════════════════════════════
  // AUTHENTICATION FUNCTIONS: Your existing logic - COMPLETELY UNCHANGED
  // ═════════════════════════════════════════════════════════════════════════

  /// ─────────────────────────────────────────────────────────────────────────
  /// FUNCTION: loginUserEmail()
  /// PURPOSE: Authenticate regular user with email & password
  /// FIREBASE: signInWithEmailAndPassword() verifies credentials
  /// NAVIGATION: Goes to UserAppBarNavBar on success
  /// ─────────────────────────────────────────────────────────────────────────
  void loginUserEmail() {
    _auth
        .signInWithEmailAndPassword(
        email: _emailPhoneController.text,
        password: _passwordController.text)
        .then((value) => {
      Utilities().successMsg("Authentication Successful"),
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const UserAppBarNavBar())),
      setState(() {
        checkEmailPhone = 0;
        isLoading = false;
      })
    })
        .onError((error, stackTrace) => {
      setState(() {
        checkEmailPhone = 0;
        isLoading = false;
      }),
      Utilities().errorMsg('Wrong Credentials')
    });
  }

  /// ─────────────────────────────────────────────────────────────────────────
  /// FUNCTION: loginLawyerEmail()
  /// PURPOSE: Authenticate lawyer user with email & password
  /// FIREBASE: signInWithEmailAndPassword() verifies credentials
  /// NAVIGATION: Goes to LawyerAppbarNavBar on success
  /// ─────────────────────────────────────────────────────────────────────────
  void loginLawyerEmail() {
    _auth
        .signInWithEmailAndPassword(
        email: _emailPhoneController.text,
        password: _passwordController.text)
        .then((value) => {
      Utilities().successMsg("Authentication Successful"),
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const LawyerAppbarNavBar())),
      setState(() {
        checkEmailPhone = 0;
        isLoading = false;
      })
    })
        .onError((error, stackTrace) => {
      setState(() {
        checkEmailPhone = 0;
        isLoading = false;
      }),
      Utilities().errorMsg('Wrong Credentials')
    });
  }

  /// ─────────────────────────────────────────────────────────────────────────
  /// FUNCTION: loginUserPhone()
  /// PURPOSE: Authenticate user with phone number & password
  /// LOGIC: Phone numbers are stored as email format: +92XXX@gmail.com
  /// WHY: Firebase Auth requires email format, so phone is converted
  /// ─────────────────────────────────────────────────────────────────────────
  /// PARAMETERS:
  /// phone     = Original phone number from Firestore
  /// password  = Hashed password from Firestore
  /// firstPass = Original password for Firebase Auth
  void loginUserPhone(String phone, String password, String firstPass) {
    if (_emailPhoneController.text.toString() == phone &&
        _passwordController.text.toString() == password) {
      _auth
          .signInWithEmailAndPassword(
          email: '$phone@gmail.com', password: firstPass)
          .then((value) => {
        Utilities().successMsg("Authentication Successful"),
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const UserAppBarNavBar())),
        setState(() {
          checkEmailPhone = 0;
          isLoading = false;
        })
      })
          .onError((error, stackTrace) => {
        setState(() {
          checkEmailPhone = 0;
          isLoading = false;
        }),
        debugPrint(error.toString()),
        Utilities().errorMsg('Something went wrong, please try again later.'),
      });
    } else {
      setState(() {
        checkEmailPhone = 0;
        isLoading = false;
      });
      Utilities().errorMsg('Wrong Credentials');
    }
  }

  /// ─────────────────────────────────────────────────────────────────────────
  /// FUNCTION: loginLawyerPhone()
  /// PURPOSE: Authenticate lawyer with phone number & password
  /// LOGIC: Same as loginUserPhone but navigates to lawyer dashboard
  /// ─────────────────────────────────────────────────────────────────────────
  void loginLawyerPhone(String phone, String password, String firstPass) {
    if (_emailPhoneController.text.toString() == phone &&
        _passwordController.text.toString() == password) {
      _auth
          .signInWithEmailAndPassword(
          email: '$phone@gmail.com', password: firstPass)
          .then((value) => {
        Utilities().successMsg("Authentication Successful"),
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const LawyerAppbarNavBar())),
        setState(() {
          checkEmailPhone = 0;
          isLoading = false;
        })
      })
          .onError((error, stackTrace) => {
        setState(() {
          checkEmailPhone = 0;
          isLoading = false;
        }),
        Utilities().errorMsg('Something went wrong, please try again later.'),
      });
    } else {
      setState(() {
        checkEmailPhone = 0;
        isLoading = false;
      });
      Utilities().errorMsg('Wrong Credentials');
    }
  }

  // ═════════════════════════════════════════════════════════════════════════
  // MAIN LOGIN HANDLER: Orchestrates the entire login flow
  // ═════════════════════════════════════════════════════════════════════════

  /// ─────────────────────────────────────────────────────────────────────────
  /// FUNCTION: handleLogin()
  /// PURPOSE: Main entry point for login - determines user type & method
  /// ─────────────────────────────────────────────────────────────────────────
  /// FLOW:
  /// 1. Unfocus text fields (hide keyboard)
  /// 2. Validate form inputs
  /// 3. Set loading state
  /// 4. Check if email or phone was entered
  /// 5. Query Firestore for user in Users collection
  /// 6. If not found, check Lawyers collection
  /// 7. Call appropriate login function based on findings
  /// 8. Handle errors and update UI accordingly
  /// ─────────────────────────────────────────────────────────────────────────
  Future<void> handleLogin() async {
    // Step 1: Hide keyboard when user taps login
    if (emailFocusNode.hasFocus) emailFocusNode.unfocus();
    if (passwordFocusNode.hasFocus) passwordFocusNode.unfocus();

    // Step 2: Validate all form fields (runs validator functions)
    if (!_form.currentState!.validate()) return;

    // Step 3: Show loading indicator
    setState(() => isLoading = true);

    try {
      // ══════════════════════════════════════════════════════════════════════
      // EMAIL LOGIN FLOW
      // ══════════════════════════════════════════════════════════════════════
      if (isEmailValid) {
        // Check Users collection first
        var documentUserEmail = await FirebaseFirestore.instance
            .collection('Users')
            .doc(_emailPhoneController.text)
            .get();

        if (documentUserEmail.exists) {
          loginUserEmail();
          return;
        }

        // Check Lawyers collection if not found in Users
        var documentLawyerEmail = await FirebaseFirestore.instance
            .collection('Lawyers')
            .doc(_emailPhoneController.text)
            .get();

        if (documentLawyerEmail.exists) {
          loginLawyerEmail();
          return;
        }

        // Account not found in either collection
        setState(() => isLoading = false);
        Utilities().errorMsg("No account found with the provided Email Address");
        return;
      }

      // ══════════════════════════════════════════════════════════════════════
      // PHONE LOGIN FLOW
      // ══════════════════════════════════════════════════════════════════════
      if (isPhoneValid) {
        // Check Users collection (phone stored as email format)
        var documentUserPhone = await FirebaseFirestore.instance
            .collection('Users')
            .doc("${_emailPhoneController.text}@gmail.com")
            .get();

        if (documentUserPhone.exists) {
          loginUserPhone(
            documentUserPhone.get('emailPhone').toString(),
            documentUserPhone.get('password').toString(),
            documentUserPhone.get('firstPass').toString(),
          );
          return;
        }

        // Check Lawyers collection
        var documentLawyerPhone = await FirebaseFirestore.instance
            .collection('Lawyers')
            .doc("${_emailPhoneController.text}@gmail.com")
            .get();

        if (documentLawyerPhone.exists) {
          loginLawyerPhone(
            documentLawyerPhone.get('emailPhone').toString(),
            documentLawyerPhone.get('password').toString(),
            documentLawyerPhone.get('firstPass').toString(),
          );
          return;
        }

        // Account not found
        setState(() => isLoading = false);
        Utilities().errorMsg("No account found with the provided Phone Number");
        return;
      }

      // Neither email nor phone format detected
      setState(() => isLoading = false);
      Utilities().errorMsg('Account not found. Please check your credentials.');

    } catch (e) {
      // Catch any unexpected errors
      debugPrint("Login error: $e");
      setState(() => isLoading = false);
      Utilities().errorMsg('Login failed. Please try again.');
    }
  }

  // ═════════════════════════════════════════════════════════════════════════
  // BUILD METHOD: Creates the UI
  // ═════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // ═══════════════════════════════════════════════════════════════════════
      // MODERN GRADIENT BACKGROUND
      // ═══════════════════════════════════════════════════════════════════════
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
            // ── Animated Logo at Top ──
            Positioned(
              top: screenHeight * 0.05,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: TopLogo(fontColor: Colors.white),
              ),
            ),

            // ═══════════════════════════════════════════════════════════════════
            // MAIN CONTENT CARD
            // ═══════════════════════════════════════════════════════════════════
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
                                color: Colors.black.withAlpha((255 * 0.3).round()),
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
                                      "Welcome Back",
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
                                      "Sign in to continue your journey",
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
                              // LOGIN FORM
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
                                        // ══════════════════════════════════════
                                        // EMAIL/PHONE INPUT FIELD
                                        // ══════════════════════════════════════
                                        Container(
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
                                            focusNode: emailFocusNode,
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
                                                Icons.person_outline_rounded,
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
                                                return "Please enter your email or phone";
                                              }
                                              if (!_isValidEmail(value) &&
                                                  !_isValidPhoneNumber(value)) {
                                                return "Format: xyz@example.com OR +92XXXXXXXXXX";
                                              }
                                              if (_isValidEmail(value)) {
                                                setState(() {
                                                  isEmailValid = true;
                                                  isPhoneValid = false;
                                                });
                                              } else if (_isValidPhoneNumber(value)) {
                                                setState(() {
                                                  isPhoneValid = true;
                                                  isEmailValid = false;
                                                });
                                              }
                                              return null;
                                            },
                                          ),
                                        ),

                                        const SizedBox(height: 20),

                                        // ══════════════════════════════════════
                                        // PASSWORD INPUT FIELD
                                        // ══════════════════════════════════════
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey[50],
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                              color: Colors.grey[200]!,
                                              width: 1,
                                            ),
                                          ),
                                          child: TextFormField(
                                            controller: _passwordController,
                                            focusNode: passwordFocusNode,
                                            obscureText: _obscured,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontFamily: 'roboto',
                                            ),
                                            decoration: InputDecoration(
                                              hintText: "Password",
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
                                                      ? Icons.visibility_off_rounded
                                                      : Icons.visibility_rounded,
                                                  color: Colors.grey[600],
                                                  size: 22,
                                                ),
                                              ),
                                              border: InputBorder.none,
                                              contentPadding: const EdgeInsets.symmetric(
                                                horizontal: 20,
                                                vertical: 18,
                                              ),
                                            ),
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return "Please enter your password";
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
                              // FORGOT PASSWORD LINK
                              // ─────────────────────────────────────────────
                              Padding(
                                padding: EdgeInsets.only(
                                  right: screenWidth * 0.08,
                                  top: 12,
                                ),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const ForgetPassword(),
                                        ),
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                    ),
                                    child: const Text(
                                      "Forgot Password?",
                                      style: TextStyle(
                                        fontFamily: 'roboto',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: Color(0xFF1565C0),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // ─────────────────────────────────────────────
                              // LOGIN BUTTON
                              // ─────────────────────────────────────────────
                              Padding(
                                padding: EdgeInsets.only(
                                  top: screenHeight * 0.03,
                                  left: screenWidth * 0.08,
                                  right: screenWidth * 0.08,
                                ),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: isLoading ? null : handleLogin,
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
                                      mainAxisAlignment: MainAxisAlignment.center,
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
                                          'Signing in...',
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
                                      'Sign In',
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
                              // SIGN UP LINK
                              // ─────────────────────────────────────────────
                              Padding(
                                padding: EdgeInsets.only(bottom: screenHeight * 0.03),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Don't have an account?",
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
                                            builder: (context) => const SignUpPage(),
                                          ),
                                        );
                                      },
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                      ),
                                      child: const Text(
                                        "Sign Up",
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
}

// ══════════════════════════════════════════════════════════════════════════════
// ADVANCED FLUTTER CONCEPTS IN THIS FILE:
// ══════════════════════════════════════════════════════════════════════════════
//
// 1. Firebase Authentication:
//    - signInWithEmailAndPassword() = secure login
//    - Returns Future<UserCredential> (asynchronous operation)
//    - .then() runs on success, .onError() runs on failure
//
// 2. Cloud Firestore:
//    - NoSQL database (stores data as documents in collections)
//    - .collection('Users') = get a collection
//    - .doc(email) = get specific document by ID
//    - .get() = fetch the document (asynchronous)
//    - .exists = check if document found
//    - .get('fieldName') = retrieve specific field value
//
// 3. Async/Await:
//    - async = function performs asynchronous operations
//    - await = pause and wait for operation to complete
//    - Better than .then() for multiple sequential operations
//
// 4. Form Validation:
//    - GlobalKey<FormState> gives access to form state
//    - validator: (value) {} = validation function for each field
//    - Returns null = valid, Returns String = error message
//    - _form.currentState!.validate() checks all fields at once
//
// 5. FocusNode:
//    - Tracks which input field has focus (active)
//    - .hasFocus = check if field is active
//    - .unfocus() = remove focus (hide keyboard)
//    - Important for UX (keyboard management)
//
// 6. Regular Expressions (RegEx):
//    - Pattern matching for text validation
//    - hasMatch() = check if text matches pattern
//    - Used for email/phone validation
//
// 7. Animations:
//    - AnimationController = controls animation playback
//    - Tween = defines start and end values
//    - CurvedAnimation = adds easing (speed variation)
//    - FadeTransition/SlideTransition = built-in animated widgets
//    - SingleTickerProviderStateMixin = provides timing for animations
//
// 8. Stack & Positioned:
//    - Stack = overlays widgets on top of each other
//    - Positioned = controls exact position in Stack
//    - Used for logo overlay on gradient background
//
// 9. CustomScrollView & SliverFillRemaining:
//    - Advanced scrolling with custom behavior
//    - Sliver = scrollable area in CustomScrollView
//    - hasScrollBody: false = content doesn't scroll by default
//    - Better for complex layouts than SingleChildScrollView
//
// 10. Error Handling:
//     - try-catch = handle unexpected errors
//     - debugPrint() = console logging for debugging
//     - Always provide user-friendly error messages
//
// ══════════════════════════════════════════════════════════════════════════════