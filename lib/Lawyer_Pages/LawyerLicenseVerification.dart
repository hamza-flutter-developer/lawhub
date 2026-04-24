// ignore_for_file: file_names

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lawhub/Utils/Utilities.dart';
import 'package:lawhub/Utils/CloudinaryUpload.dart';

import 'LawyerLicenseDetailsSubmitted.dart';

/// ============================================================
/// LawyerLicenseVerification — StatefulWidget
///
/// Allows a lawyer to submit their license details for admin
/// verification. Shows different UI based on current status:
///   'Verified'  → success message, no form
///   'Submitted' → pending message, no form
///   else        → full form (Bar Council, License Number,
///                 Court Enrollment, License Image)
///
/// Flow when submitting:
///   validate fields → uploadImageToFirebase()
///   → Cloudinary upload → uploadLicense() → updateLawyerStatus()
///   → navigate to LawyerLicenseDetailsSubmitted
/// ============================================================
class LawyerLicenseVerification extends StatefulWidget {
  const LawyerLicenseVerification({super.key});

  @override
  State<LawyerLicenseVerification> createState() =>
      _LawyerLicenseVerificationState();
}

class _LawyerLicenseVerificationState extends State<LawyerLicenseVerification>
    with TickerProviderStateMixin {

  // ─── ORIGINAL STATE VARIABLES (completely untouched) ───────────────────

  /// True while fetchLawyerVerificationStatus() runs
  bool isLoading = true;

  /// True while the upload + Firestore write are running
  bool isLoadingSubmit = false;

  /// Controls the license number text input
  final TextEditingController _licenseNumberController =
  TextEditingController();
  FocusNode licenseNumberFocusNode = FocusNode();

  /// 'Verified', 'Submitted', or 'Not Verified' — read from Firestore
  late String isVerified;

  /// Bar Council dropdown data and selected value
  final barCouncilList = [
    {'id': 1, 'name': 'Islamabad Bar Council'},
    {'id': 2, 'name': 'Punjab Bar Council'},
    {'id': 3, 'name': 'KPK Bar Council'},
    {'id': 4, 'name': 'Balochistan Bar Council'},
    {'id': 5, 'name': 'Sindh Bar Council'},
    {'id': 6, 'name': 'Gilgit Baltistan Bar Council'},
    {'id': 7, 'name': 'Supreme Court'},
  ];
  String? barCouncil;
  String? barCouncilText;

  /// Court Enrollment dropdown data and selected value
  final licenseList = [
    {'id': 1, 'name': 'Lower Court'},
    {'id': 2, 'name': 'High Court'},
    {'id': 3, 'name': 'Supreme Court'},
  ];
  String? license;
  String? licenseText;

  /// The locally selected license image file
  File? _image;
  final picker = ImagePicker();

  // ─── ANIMATION CONTROLLERS (UI only) ──────────────────────────────────

  /// Drives the page-level fade + upward slide entrance
  late AnimationController _entranceController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // ============================================================
  // initState
  // ============================================================
  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
        parent: _entranceController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _entranceController, curve: Curves.easeOutCubic));
    _entranceController.forward();

    // ORIGINAL: fetch current verification status
    fetchLawyerVerificationStatus();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _licenseNumberController.dispose();
    licenseNumberFocusNode.dispose();
    super.dispose();
  }

  // ╔══════════════════════════════════════════════════════════╗
  //  ALL METHODS BELOW ARE 100% ORIGINAL LOGIC
  // ╚══════════════════════════════════════════════════════════╝

  // ============================================================
  // fetchLawyerVerificationStatus  ← ORIGINAL LOGIC
  //
  // Reads 'isVerified' from the lawyer's Firestore document.
  // Sets isLoading=false when done so the spinner is replaced
  // by the appropriate UI state.
  // ============================================================
  Future<void> fetchLawyerVerificationStatus() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('Lawyers')
        .doc(FirebaseAuth.instance.currentUser!.email.toString())
        .get();
    isVerified = doc['isVerified'];
    setState(() { isLoading = false; });
  }

  // ============================================================
  // uploadLicense  ← ORIGINAL LOGIC
  //
  // Builds a formatted date string, then writes all license
  // details to the LawyersLicense collection under admin@gmail.com.
  //   Doc exists  → increment counter, add "LawyerN" map
  //   Doc missing → create with Lawyer1 and counter=1
  // On success → calls updateLawyerStatus()
  // On error   → shows error snackbar, resets isLoadingSubmit
  // ============================================================
  Future<void> uploadLicense(String imageUrl) async {
    try {
      int dayInt   = DateTime.now().day;
      int monthInt = DateTime.now().month;
      String date  = dayInt < 10 ? '0$dayInt' : '$dayInt';
      String month = checkMonth(monthInt);
      String year  = DateTime.now().year.toString();
      String dateTimeText = '$month $date, $year';

      var doc = await FirebaseFirestore.instance
          .collection('LawyersLicense')
          .doc('admin@gmail.com')
          .get();
      if (doc.exists) {
        int counter = doc['counter'];
        counter++;
        await FirebaseFirestore.instance
            .collection('LawyersLicense')
            .doc('admin@gmail.com')
            .update({
          'Lawyer$counter': {
            'lawyerId': FirebaseAuth.instance.currentUser!.email.toString(),
            'barCouncil': barCouncilText,
            'licenseNumber': _licenseNumberController.text.toString(),
            'courtEnrollment': licenseText,
            'licenseImage': imageUrl,
            'dateTime': dateTimeText,
            'status': 'Submitted',
          },
          'counter': counter,
        });
      } else {
        await FirebaseFirestore.instance
            .collection('LawyersLicense')
            .doc('admin@gmail.com')
            .set({
          'Lawyer1': {
            'lawyerId': FirebaseAuth.instance.currentUser!.email.toString(),
            'barCouncil': barCouncilText,
            'licenseNumber': _licenseNumberController.text.toString(),
            'courtEnrollment': licenseText,
            'licenseImage': imageUrl,
            'dateTime': dateTimeText,
            'status': 'Submitted',
          },
          'counter': 1,
        });
      }
      await updateLawyerStatus();
    } catch (e) {
      debugPrint('Error saving to Firestore: $e');
      setState(() { isLoadingSubmit = false; });
      Utilities().errorMsg('Failed to save license. Please try again.');
      rethrow;
    }
  }

  // ============================================================
  // checkMonth  ← ORIGINAL LOGIC
  // ============================================================
  String checkMonth(int index) {
    switch (index) {
      case 1:  return 'Jan';
      case 2:  return 'Feb';
      case 3:  return 'Mar';
      case 4:  return 'Apr';
      case 5:  return 'May';
      case 6:  return 'Jun';
      case 7:  return 'Jul';
      case 8:  return 'Aug';
      case 9:  return 'Sep';
      case 10: return 'Oct';
      case 11: return 'Nov';
      case 12: return 'Dec';
      default: return '';
    }
  }

  // ============================================================
  // updateLawyerStatus  ← ORIGINAL LOGIC
  //
  // Sets isVerified='Submitted' on the lawyer's Firestore doc,
  // resets isLoadingSubmit=false, then navigates to the
  // LawyerLicenseDetailsSubmitted confirmation screen.
  // ============================================================
  Future<void> updateLawyerStatus() async {
    await FirebaseFirestore.instance
        .collection('Lawyers')
        .doc(FirebaseAuth.instance.currentUser!.email.toString())
        .update({'isVerified': 'Submitted'});
    setState(() { isLoadingSubmit = false; });
    // ignore: use_build_context_synchronously
    Navigator.push(context, MaterialPageRoute(
        builder: (_) => const LawyerLicenseDetailsSubmitted()));
  }

  // ============================================================
  // getImage  ← ORIGINAL LOGIC
  //
  // Opens the gallery via ImagePicker. Stores the picked file
  // in _image and rebuilds. Does nothing if user cancels.
  // ============================================================
  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() { _image = File(pickedFile.path); });
    }
  }

  // ============================================================
  // uploadImageToFirebase  ← ORIGINAL LOGIC
  //
  // Uploads the license image to Cloudinary then calls
  // uploadLicense() with the returned URL.
  // On error → detailed debug prints + user-facing error msg.
  // ============================================================
  Future uploadImageToFirebase(File? imageFile) async {
    try {
      debugPrint('=== STARTING LICENSE UPLOAD ===');
      debugPrint('Image file path: ${imageFile?.path}');
      debugPrint('Image file exists: ${imageFile?.existsSync()}');
      debugPrint('Step 1: Uploading to Cloudinary...');
      String imageUrl = await CloudinaryUpload.uploadLicenseImage(imageFile!);
      debugPrint('Step 1 SUCCESS: Got Cloudinary URL: $imageUrl');
      debugPrint('Step 2: Saving to Firestore...');
      await uploadLicense(imageUrl);
      debugPrint('Step 2 SUCCESS: Saved to Firestore');
      debugPrint('=== LICENSE UPLOAD COMPLETE ===');
    } catch (e, stackTrace) {
      debugPrint('=== ERROR IN LICENSE UPLOAD ===');
      debugPrint('Error type: ${e.runtimeType}');
      debugPrint('Error message: $e');
      debugPrint('Stack trace: $stackTrace');
      setState(() { isLoadingSubmit = false; });
      String errorMsg = 'Failed to upload. ';
      if (e.toString().contains('Cloudinary credentials not found')) {
        errorMsg += 'Cloudinary not configured. Check .env file.';
      } else if (e.toString().contains('Failed to upload image')) {
        errorMsg += 'Cloudinary upload failed. Check internet connection.';
      } else if (e.toString().contains('Firestore')) {
        errorMsg += 'Database error. Check Firebase connection.';
      } else {
        errorMsg += 'Error: ${e.toString()}';
      }
      Utilities().errorMsg(errorMsg);
    }
  }

  // ============================================================
  // build — constructs the full UI tree
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: isLoading
          ? const Center(
          child: SpinKitCircle(color: Color(0xFF1E88E5), size: 34))
          : FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 28),

                // ── Page title + subtitle ──────────────────────
                const Text(
                  'License Verification',
                  style: TextStyle(
                    fontFamily: 'roboto',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Provide your legal practice license details below to get verified',
                  style: TextStyle(
                    fontFamily: 'roboto',
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 20),

                // ── Status badge ───────────────────────────────
                _buildStatusBadge(),

                const SizedBox(height: 20),

                // ── Body based on verification state ──────────
                // ORIGINAL: Verified → congrats, Submitted → pending,
                // else → full form
                if (isVerified == 'Verified')
                  _buildVerifiedMessage()
                else if (isVerified == 'Submitted')
                  _buildSubmittedMessage()
                else
                  _buildForm(),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // _buildAppBar — styled AppBar matching the rest of the app
  // ============================================================
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60.0),
      child: AppBar(
        toolbarHeight: 70,
        leadingWidth: 40,
        backgroundColor: const Color(0xFF1565C0),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(top: 8, left: 10),
          child: IconButton(
            icon: const Icon(FontAwesomeIcons.angleLeft, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: const Padding(
          padding: EdgeInsets.only(top: 13),
          child: Text(
            'License Verification',
            style: TextStyle(
              fontFamily: 'roboto',
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ),
        centerTitle: true,
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
  // _buildStatusBadge — coloured pill showing current status
  //
  // ORIGINAL: Verified → green, Submitted → orange, else → red
  // ============================================================
  Widget _buildStatusBadge() {
    final Map<String, Map<String, dynamic>> config = {
      'Verified':     {'label': 'Verified',     'color': Colors.green},
      'Submitted':    {'label': 'Submitted',    'color': Colors.orange},
      'Not Verified': {'label': 'Not Verified', 'color': Colors.redAccent},
    };
    final cfg = config[isVerified] ?? config['Not Verified']!;
    final Color color = cfg['color'] as Color;

    return Row(
      children: [
        const Text(
          'Status: ',
          style: TextStyle(
            fontFamily: 'roboto',
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A2E),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Text(
            cfg['label'] as String,
            style: TextStyle(
              fontFamily: 'roboto',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // _buildVerifiedMessage — shown when isVerified == 'Verified'
  // ORIGINAL text preserved exactly.
  // ============================================================
  Widget _buildVerifiedMessage() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(FontAwesomeIcons.circleCheck,
              color: Colors.green, size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Congratulations! Your license has been successfully verified. '
                  'You now have full access to client interactions and opportunities.',
              style: TextStyle(
                fontFamily: 'roboto',
                fontSize: 15,
                color: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // _buildSubmittedMessage — shown when isVerified == 'Submitted'
  // ORIGINAL text preserved exactly.
  // ============================================================
  Widget _buildSubmittedMessage() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.hourglass_top_rounded,
              color: Colors.orange, size: 22),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Thank you for submitting your license details. Your account is now '
                  'under verification by our admin team. Please allow some time for '
                  'the verification process. Once verified, you\'ll gain full access '
                  'to client interactions and opportunities. We appreciate your patience.',
              style: TextStyle(
                fontFamily: 'roboto',
                fontSize: 15,
                color: Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // _buildForm — the full license submission form
  //
  // ORIGINAL fields and logic fully preserved:
  //   Bar Council dropdown → barCouncil + barCouncilText
  //   License Number text field → _licenseNumberController
  //   Court Enrollment dropdown → license + licenseText
  //   License Image picker → _image via getImage()
  //   Submit button → validates + uploadImageToFirebase()
  // ============================================================
  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // ── Bar Council dropdown ─────────────────────────────
        _fieldLabel('Bar Council'),
        const SizedBox(height: 8),
        _buildDropdownCard(
          hint: 'Select Bar Council',
          value: barCouncil,
          items: barCouncilList,
          onChanged: (newValue) {
            setState(() {
              barCouncil = newValue.toString();
              barCouncilText = barCouncilList[
              int.parse(barCouncil.toString()) - 1]['name']
                  .toString();
            });
          },
        ),

        const SizedBox(height: 20),

        // ── License Number text field ────────────────────────
        _fieldLabel('License Number'),
        const SizedBox(height: 8),
        _buildInputCard(
          controller: _licenseNumberController,
          focusNode: licenseNumberFocusNode,
          hint: 'Ex: 1234',
        ),

        const SizedBox(height: 20),

        // ── Court Enrollment dropdown ────────────────────────
        _fieldLabel('Court Enrollment'),
        const SizedBox(height: 8),
        _buildDropdownCard(
          hint: 'Select Court',
          value: license,
          items: licenseList,
          onChanged: (newValue) {
            setState(() {
              license = newValue.toString();
              licenseText = licenseList[
              int.parse(license.toString()) - 1]['name']
                  .toString();
            });
          },
        ),

        const SizedBox(height: 20),

        // ── License image picker ─────────────────────────────
        _fieldLabel('License Scan or Photo'),
        const SizedBox(height: 8),
        _buildImagePicker(),

        const SizedBox(height: 30),

        // ── Submit button ────────────────────────────────────
        _buildSubmitButton(),
      ],
    );
  }

  // ============================================================
  // _buildDropdownCard — styled dropdown wrapped in a card
  //
  // ORIGINAL: DropdownButton with barCouncilList or licenseList,
  // onChanged sets barCouncil/barCouncilText or license/licenseText
  // ============================================================
  Widget _buildDropdownCard({
    required String hint,
    required String? value,
    required List<Map<String, dynamic>> items,
    required ValueChanged<dynamic> onChanged,
  }) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: DropdownButton(
          iconSize: 22,
          hint: Text(hint,
              style: TextStyle(
                  fontFamily: 'roboto',
                  fontSize: 15,
                  color: Colors.grey.shade500)),
          isExpanded: true,
          underline: const SizedBox(),
          value: value,
          items: items.map((e) {
            return DropdownMenuItem(
              value: e['id'].toString(),
              child: Text(e['name'].toString(),
                  style: const TextStyle(
                      fontFamily: 'roboto', fontSize: 15)),
            );
          }).toList(),
          onChanged: onChanged, // ← original logic passed in
        ),
      ),
    );
  }

  // ============================================================
  // _buildInputCard — styled text field wrapped in a card
  //
  // ORIGINAL: controller, focusNode, validator all unchanged.
  // ============================================================
  Widget _buildInputCard({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
  }) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TextFormField(
          controller: controller,       // ← original
          focusNode: focusNode,         // ← original
          textAlignVertical: TextAlignVertical.center,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide.none),
            focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide.none),
            hintText: hint,
            hintStyle: TextStyle(
                fontFamily: 'roboto',
                fontSize: 15,
                color: Colors.grey.shade400),
          ),
          validator: (value) {          // ← original validator
            if (value!.isEmpty) return 'Enter Name';
            return null;
          },
        ),
      ),
    );
  }

  // ============================================================
  // _buildImagePicker — image picker with preview
  //
  // ORIGINAL logic:
  //   _image == null → show "Add License" button row
  //   _image != null → show Image.file preview, tap to replace
  // ============================================================
  Widget _buildImagePicker() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _image == null
          ? InkWell(
        key: const ValueKey('empty'),
        onTap: getImage,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(FontAwesomeIcons.image,
                  size: 28, color: Colors.grey.shade400),
              const SizedBox(height: 8),
              Text(
                'Add License',
                style: TextStyle(
                    fontFamily: 'roboto',
                    fontSize: 15,
                    color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      )
          : InkWell(
        key: const ValueKey('preview'),
        onTap: getImage,
        borderRadius: BorderRadius.circular(14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            children: [
              Image.file(
                _image!,
                width: double.infinity,
                height: 280,
                fit: BoxFit.cover,
              ),
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
                      Icon(Icons.refresh, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text('Tap to change',
                          style: TextStyle(
                              color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // _buildSubmitButton — gradient Submit / Loading button
  //
  // ORIGINAL onTap logic fully preserved:
  //   unfocus keyboard → validate all fields are filled
  //   → isLoadingSubmit=true → uploadImageToFirebase(_image)
  //   On missing fields → Utilities().errorMsg()
  // ============================================================
  Widget _buildSubmitButton() {
    return Center(
      child: GestureDetector(
        onTap: () {
          if (licenseNumberFocusNode.hasFocus) {
            licenseNumberFocusNode.unfocus();
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: isLoadingSubmit ? 160 : 240,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1565C0).withOpacity(0.4),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () async {
                // ── ORIGINAL onTap logic — untouched ─────────────────
                if (licenseNumberFocusNode.hasFocus) {
                  licenseNumberFocusNode.unfocus();
                }
                if (_licenseNumberController.text.isNotEmpty &&
                    _image != null &&
                    barCouncilText!.isNotEmpty &&
                    licenseText!.isNotEmpty) {
                  setState(() { isLoadingSubmit = true; });
                  uploadImageToFirebase(_image);
                } else {
                  Utilities().errorMsg('Please fill all details');
                }
              },
              child: Center(
                child: isLoadingSubmit
                    ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SpinKitCircle(color: Colors.white, size: 22),
                    SizedBox(width: 8),
                    Text('Loading',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'roboto',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        )),
                  ],
                )
                    : const Text(
                  'Submit',
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

  // ── Small helper ────────────────────────────────────────────
  Widget _fieldLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontFamily: 'roboto',
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: Color(0xFF1A1A2E),
    ),
  );
}