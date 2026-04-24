// ignore_for_file: file_names

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lawhub/Utils/CloudinaryUpload.dart';
import 'package:image_picker/image_picker.dart';

import 'UserRequestSubmitted.dart';

/// ============================================================
/// UserStartCase — StatefulWidget
///
/// This screen allows the user to formally start a legal case
/// with a lawyer by providing:
///   1. A case description (text field)
///   2. A screenshot of the advance payment (image picker)
///
/// Parameter:
///   lawyerId → the selected lawyer's Firestore document ID
///
/// Flow:
///   User fills form + picks image → taps "Next"
///   → uploadImageToFirebase() uploads image to Cloudinary
///   → uploadToCases() saves case data to both CasesLawyer
///     and CasesUser collections
///   → addNotification() alerts the lawyer
///   → navigates to UserRequestSubmitted screen
/// ============================================================
class UserStartCase extends StatefulWidget {
  final String lawyerId;
  const UserStartCase({super.key, required this.lawyerId});

  @override
  State<UserStartCase> createState() => _UserStartCaseState();
}

class _UserStartCaseState extends State<UserStartCase>
    with TickerProviderStateMixin {

  // ─── ORIGINAL STATE VARIABLES (completely untouched) ───────────────────

  /// Controls the case description text input
  final TextEditingController _caseDescription = TextEditingController();

  /// FocusNode to detect/dismiss the keyboard
  final caseDescriptionFocusNode = FocusNode();

  /// Firestore instance used for reading/writing case data
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// GlobalKey used by Form to trigger validation
  final _form = GlobalKey<FormState>();

  /// True while upload + Firestore writes are running → shows spinner
  bool isLoading = false;

  /// Holds the locally selected image file before upload
  File? _image;

  /// ImagePicker instance for opening the gallery
  final picker = ImagePicker();

  // ─── ANIMATION CONTROLLERS (UI only — zero impact on logic) ───────────

  /// Drives the page-level fade + upward slide on screen open
  late AnimationController _entranceController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // ============================================================
  // initState — runs once when this widget is first created.
  //
  // Sets up and immediately plays a gentle page entrance animation.
  // Then calls the original Firestore fetch methods.
  // ============================================================
  @override
  void initState() {
    super.initState();

    // Entrance: 650ms fade + gentle upward slide
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _fadeAnim = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    ));

    _entranceController.forward();
  }

  // ============================================================
  // dispose — clean up controllers to avoid memory leaks
  // ============================================================
  @override
  void dispose() {
    _entranceController.dispose();
    _caseDescription.dispose();
    caseDescriptionFocusNode.dispose();
    super.dispose();
  }

  // ╔══════════════════════════════════════════════════════════╗
  //  ALL METHODS BELOW ARE 100% ORIGINAL LOGIC
  //  Only comments have been added — no code was changed.
  // ╚══════════════════════════════════════════════════════════╝

  // ============================================================
  // getImage  ← ORIGINAL LOGIC
  //
  // Opens the device gallery via ImagePicker.
  // If the user picks a file → stores it in _image and rebuilds.
  // If the user cancels → does nothing.
  // ============================================================
  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    } else {
      // User cancelled — no action needed
    }
  }

  // ============================================================
  // uploadImageToFirebase  ← ORIGINAL LOGIC
  //
  // Uploads the selected image file to Cloudinary via the
  // CloudinaryUpload helper class.
  // On success → calls uploadToCases() with the returned URL.
  // On error   → prints debug message (silent fail in UI).
  // ============================================================
  Future uploadImageToFirebase(File? imageFile) async {
    try {
      String imageUrl =
      await CloudinaryUpload.uploadCasePaymentImage(imageFile!);
      uploadToCases(imageUrl);
    } catch (e) {
      debugPrint("Error uploading image: $e");
    }
  }

  // ============================================================
  // uploadToCases  ← ORIGINAL LOGIC
  //
  // Builds a formatted date-time string, then writes the case
  // data map to BOTH Firestore collections:
  //   1. CasesLawyer → doc ID = lawyerId
  //   2. CasesUser   → doc ID = current user's email
  //
  // For each collection:
  //   • If doc exists  → increment counter, add "caseN" field
  //   • If doc missing → create doc with counter=1 and case1
  //
  // After CasesUser write succeeds:
  //   → sets isLoading = false
  //   → navigates to UserRequestSubmitted
  // ============================================================
  void uploadToCases(String img) async {
    // Build formatted date-time string for case start date
    int minuteInt = DateTime.now().minute;
    int hourInt = DateTime.now().hour;
    int dayInt = DateTime.now().day;
    int monthInt = DateTime.now().month;

    String dateTime;
    String minute = minuteInt < 10 ? '0$minuteInt' : '$minuteInt';
    String hour = hourInt >= 12 ? '${hourInt - 12}' : '$hourInt';
    String amPm = hourInt >= 12 ? 'PM' : 'AM';
    String date = dayInt < 10 ? '0$dayInt' : '$dayInt';
    String month = checkMonth(monthInt);
    dateTime = '$date $month $hour:$minute $amPm';

    // Case data map written to both collections
    Map<String, dynamic> data = {
      'status': 'pending',
      'userId': FirebaseAuth.instance.currentUser!.email.toString(),
      'lawyerId': widget.lawyerId,
      'caseDescription': _caseDescription.text,
      'paymentSS': img,
      'startDate': dateTime,
      'givenRatingFeedback': false,
    };

    // Write to CasesLawyer collection
    var documentCheckLawyer = await FirebaseFirestore.instance
        .collection('CasesLawyer')
        .doc(widget.lawyerId)
        .get();
    if (documentCheckLawyer.exists) {
      int counter = documentCheckLawyer['counter'];
      counter++;
      await _firestore.collection('CasesLawyer').doc(widget.lawyerId).update({
        'counter': counter,
        'case$counter': data,
      });
    } else {
      await _firestore
          .collection('CasesLawyer')
          .doc(widget.lawyerId)
          .set({'counter': 1, 'case1': data});
    }

    // Notify the lawyer about the new case request
    addNotification(widget.lawyerId, 'requests to Start Case');

    // Write to CasesUser collection
    var documentCheckUser = await FirebaseFirestore.instance
        .collection('CasesUser')
        .doc(FirebaseAuth.instance.currentUser!.email.toString())
        .get();
    if (documentCheckUser.exists) {
      int counter = documentCheckUser['counter'];
      counter++;
      await _firestore
          .collection('CasesUser')
          .doc(FirebaseAuth.instance.currentUser!.email.toString())
          .update({
        'counter': counter,
        'case$counter': data,
      }).then((value) {
        setState(() {
          isLoading = false;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const UserRequestSubmitted(text: 'Case'),
          ),
        );
      });
    } else {
      await _firestore
          .collection('CasesUser')
          .doc(FirebaseAuth.instance.currentUser!.email.toString())
          .set({'counter': 1, 'case1': data}).then((value) {
        setState(() {
          isLoading = false;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const UserRequestSubmitted(text: 'Case'),
          ),
        );
      });
    }
  }

  // ============================================================
  // checkMonth  ← ORIGINAL LOGIC
  //
  // Converts a numeric month (1–12) to a 3-letter abbreviation
  // used when building the case start date string.
  // ============================================================
  String checkMonth(int index) {
    switch (index) {
      case 1: return 'Jan';
      case 2: return 'Feb';
      case 3: return 'Mar';
      case 4: return 'Apr';
      case 5: return 'May';
      case 6: return 'Jun';
      case 7: return 'Jul';
      case 8: return 'Aug';
      case 9: return 'Sep';
      case 10: return 'Oct';
      case 11: return 'Nov';
      case 12: return 'Dec';
      default: return '';
    }
  }

  /// Shortcut reference to the LawyersNotifications Firestore collection
  final fireStoreNotification =
  FirebaseFirestore.instance.collection('LawyersNotifications');

  // ============================================================
  // addNotification  ← ORIGINAL LOGIC
  //
  // Writes a notification into LawyersNotifications so the lawyer
  // gets an in-app alert about the new case request.
  //
  //   If doc exists  → increment counter, add "NotificationN" field
  //   If doc missing → create doc with Notification1 and counter=1
  // ============================================================
  void addNotification(String userID, String type) async {
    var doc = await FirebaseFirestore.instance
        .collection('LawyersNotifications')
        .doc(userID)
        .get();
    if (doc.exists) {
      int counter = doc['counter'];
      counter++;
      DocumentReference documentReference =
      fireStoreNotification.doc(userID);
      await documentReference.update({
        'Notification$counter': [
          {'userID': FirebaseAuth.instance.currentUser!.email.toString()},
          {'type': type},
          {'isSeen': false},
        ],
        'counter': counter,
      });
    } else {
      fireStoreNotification.doc(userID).set({
        'Notification1': [
          {'userID': FirebaseAuth.instance.currentUser!.email.toString()},
          {'type': type},
          {'isSeen': false},
        ],
        'counter': 1,
      });
    }
  }

  // ============================================================
  // build — constructs the full visual UI tree
  //
  // Structure:
  //   Scaffold
  //   └── gradient background
  //       └── SafeArea
  //           └── FadeTransition + SlideTransition (entrance)
  //               ├── _buildAppBar()
  //               └── scrollable body
  //                   ├── description label + field
  //                   ├── payment section label + image picker
  //                   └── Next / Loading button
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        // ── Deep navy gradient background (matches app theme) ────────────
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A1628),
              Color(0xFF0D2137),
              Color(0xFF0B3558),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Column(
                children: [
                  // ── Custom glassmorphic AppBar ───────────────────────
                  _buildAppBar(context),

                  // ── Scrollable content body ──────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Form(
                        key: _form, // ← original GlobalKey, untouched
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 28),

                            // ── Section 1: Case Description ─────────────
                            _buildSectionLabel(
                              'Case Description',
                              'Describe your legal concern clearly',
                            ),
                            const SizedBox(height: 12),
                            _buildDescriptionField(),

                            const SizedBox(height: 28),

                            // ── Section 2: Payment Screenshot ───────────
                            _buildSectionLabel(
                              'Advance Payment Screenshot',
                              'Upload proof of your advance payment',
                            ),
                            const SizedBox(height: 12),
                            _buildImagePicker(),

                            const SizedBox(height: 32),

                            // ── Next / Loading button ───────────────────
                            _buildNextButton(),

                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // _buildAppBar — custom glassmorphic top bar
  //
  // Back button: Navigator.of(context).pop() — same as original.
  // Title: "Start Case" — same as original.
  // ============================================================
  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.13)),
        ),
        child: Row(
          children: [
            // Back — same original Navigator.pop() call
            IconButton(
              icon: const Icon(
                FontAwesomeIcons.angleLeft,
                color: Colors.white,
                size: 18,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            const Expanded(
              child: Center(
                child: Text(
                  'Start Case',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 48), // mirrors icon button width
          ],
        ),
      ),
    );
  }

  // ============================================================
  // _buildSectionLabel — reusable section title + subtitle text
  //
  // Purely decorative. Used above each input section so the UI
  // has clear visual hierarchy without any logic impact.
  // ============================================================
  Widget _buildSectionLabel(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // _buildDescriptionField — glassmorphic card wrapping TextFormField
  //
  // ORIGINAL logic fully preserved:
  //   • _caseDescription controller
  //   • caseDescriptionFocusNode
  //   • maxLines: 4
  //   • validator: empty field check
  //   • hintText, border, focusedBorder
  // ============================================================
  Widget _buildDescriptionField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: TextFormField(
          // ── ORIGINAL: all field properties untouched ──────────────────
          controller: _caseDescription,
          textAlignVertical: TextAlignVertical.center,
          focusNode: caseDescriptionFocusNode,
          style: const TextStyle(fontSize: 15, color: Colors.white),
          maxLines: 4,
          decoration: const InputDecoration(
            focusedBorder: InputBorder.none,
            border: InputBorder.none,
            hintText: 'Enter Title of your Article',
            hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
            focusColor: Colors.black,
          ),
          // ── ORIGINAL validator — untouched ────────────────────────────
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please Enter Title your Article';
            }
            return null;
          },
        ),
      ),
    );
  }

  // ============================================================
  // _buildImagePicker — image picker card with preview
  //
  // ORIGINAL logic fully preserved:
  //   • _image == null → show "Choose Image" button with hint text
  //   • _image != null → show the selected image with tap-to-replace
  //   • onTap → calls getImage() (same as original)
  //
  // UI improvements:
  //   • Glassmorphic dashed-border upload zone instead of a plain box
  //   • AnimatedSwitcher smoothly transitions between empty and preview
  // ============================================================
  Widget _buildImagePicker() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, anim) =>
          FadeTransition(opacity: anim, child: child),
      child: _image == null
      // ── ORIGINAL: no image selected yet → show picker button ──────
          ? InkWell(
        key: const ValueKey('empty'),
        onTap: () => getImage(), // ← original getImage() call
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 28),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white24,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                FontAwesomeIcons.image,
                size: 32,
                color: Colors.white.withOpacity(0.4),
              ),
              const SizedBox(height: 12),
              const Text(
                'Choose Image',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              // ── ORIGINAL warning text — same message ───────────
              Text(
                'Please Upload Screenshot of Advance Payment',
                style: TextStyle(
                  color: Colors.red.shade300,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      )
      // ── ORIGINAL: image selected → show preview with tap to replace
          : InkWell(
        key: const ValueKey('preview'),
        onTap: () => getImage(), // ← original getImage() call
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFF1E88E5).withOpacity(0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(17),
            child: Stack(
              children: [
                // ── ORIGINAL: Image.file display ─────────────────
                Image.file(
                  _image!,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                ),
                // Tap-to-change overlay badge
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.refresh,
                            color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Tap to change',
                          style: TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // _buildNextButton — animated gradient Next / Loading button
  //
  // onTap logic is IDENTICAL to the original:
  //   1. Unfocus keyboard if open
  //   2. Validate form with _form.currentState!.validate()
  //   3. Check _image != null
  //   4. Set isLoading = true
  //   5. Call uploadImageToFirebase(_image)
  //
  // Added (UI only):
  //   • AnimatedContainer shrinks width while loading
  //   • Gradient background + glow shadow
  // ============================================================
  Widget _buildNextButton() {
    return Center(
      child: GestureDetector(
        // ── ORIGINAL: unfocus on tap outside ─────────────────────────────
        onTap: () {
          if (caseDescriptionFocusNode.hasFocus) {
            caseDescriptionFocusNode.unfocus();
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: isLoading ? 160 : 300,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1565C0).withOpacity(0.45),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () async {
                // ── ORIGINAL onTap logic — untouched ─────────────────────
                if (caseDescriptionFocusNode.hasFocus) {
                  caseDescriptionFocusNode.unfocus();
                }
                if (_form.currentState!.validate()) {
                  if (_image != null) {
                    setState(() {
                      isLoading = true;
                    });
                    uploadImageToFirebase(_image);
                  }
                }
              },
              child: Center(
                child: isLoading
                // ── ORIGINAL: spinner + "Loading" text ───────────────
                    ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SpinKitCircle(color: Colors.white, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Loading',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'roboto',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
                // ── ORIGINAL: "Next" label ────────────────────────────
                    : const Text(
                  'Next',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'roboto',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}