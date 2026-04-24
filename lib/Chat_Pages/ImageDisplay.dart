// ignore_for_file: library_private_types_in_public_api

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lawhub/Utils/CloudinaryUpload.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

/// ============================================================
/// ImageDisplay — StatefulWidget
///
/// A preview screen shown before the user sends an image in chat.
/// Displays the selected image full-screen with Cancel / Send buttons.
///
/// Parameters:
///   img      → the local File selected from the gallery
///   lawyerId → used to build the ChatRoom doc ID + update LawyersChats
///   userId   → used to build the ChatRoom doc ID + update UsersChats
///
/// Flow:
///   User taps Send
///   → uploadImageToFirebase() uploads image to Cloudinary
///   → sendImageMessage() writes message to ChatRooms collection
///   → updateUserLastMessage() + updateLawyerLastMessage() update
///     the last-message preview in UsersChats / LawyersChats
///   → Navigator.pop() returns to the chat screen
/// ============================================================
class ImageDisplay extends StatefulWidget {
  final String lawyerId;
  final String userId;
  final File? img;

  const ImageDisplay({
    super.key,
    required this.img,
    required this.lawyerId,
    required this.userId,
  });

  @override
  _ImageDisplayState createState() => _ImageDisplayState();
}

class _ImageDisplayState extends State<ImageDisplay>
    with TickerProviderStateMixin {

  // ─── ORIGINAL STATE VARIABLES (completely untouched) ───────────────────

  /// Firestore instance for writing chat messages
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// True while the Cloudinary upload + Firestore write are running
  bool isLoadingUpload = false;

  /// Shortcut references to chat metadata collections
  final fireStoreUserChat =
  FirebaseFirestore.instance.collection('UsersChats');
  final fireStoreLawyerChat =
  FirebaseFirestore.instance.collection('LawyersChats');

  // ─── ANIMATION CONTROLLERS (UI only — zero impact on logic) ───────────

  /// Fades the image in when the screen opens
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  /// Slides the bottom action bar up from below on open
  late AnimationController _barController;
  late Animation<Offset> _barSlideAnim;
  late Animation<double> _barFadeAnim;

  // ============================================================
  // initState — runs once when this widget is inserted into tree.
  //
  // Sets up:
  //   1. Image fade-in animation (500ms)
  //   2. Bottom bar slide-up + fade animation (400ms, delayed 200ms)
  // ============================================================
  @override
  void initState() {
    super.initState();

    // Image fade-in
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();

    // Bottom bar slides up + fades in with a slight delay
    _barController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _barSlideAnim = Tween<Offset>(
      begin: const Offset(0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _barController,
      curve: Curves.easeOutCubic,
    ));
    _barFadeAnim = CurvedAnimation(
      parent: _barController,
      curve: Curves.easeOut,
    );

    // Delay bar animation so image loads first
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _barController.forward();
    });
  }

  // ============================================================
  // dispose — clean up animation controllers
  // ============================================================
  @override
  void dispose() {
    _fadeController.dispose();
    _barController.dispose();
    super.dispose();
  }

  // ╔══════════════════════════════════════════════════════════╗
  //  ALL METHODS BELOW ARE 100% ORIGINAL LOGIC
  //  Only comments have been added — no code was changed.
  // ╚══════════════════════════════════════════════════════════╝

  // ============================================================
  // sendImageMessage  ← ORIGINAL LOGIC
  //
  // Builds a formatted date-time string, constructs a message map
  // with type='image', then:
  //   1. Updates last-message preview for both user and lawyer
  //   2. Adds the message document to ChatRooms/{id}/Chats
  //   3. Sets isLoadingUpload=false and pops back to chat screen
  // ============================================================
  void sendImageMessage(String img) async {
    int minuteInt = DateTime.now().minute;
    int hourInt   = DateTime.now().hour;
    int dayInt    = DateTime.now().day;
    int monthInt  = DateTime.now().month;

    String dateTime;
    String minute = minuteInt < 10 ? '0$minuteInt' : '$minuteInt';
    String hour   = hourInt >= 12  ? '${hourInt - 12}' : '$hourInt';
    String amPm   = hourInt >= 12  ? 'PM' : 'AM';
    String date   = dayInt < 10    ? '0$dayInt' : '$dayInt';
    String month  = checkMonth(monthInt);
    dateTime = '$date $month $hour:$minute $amPm';

    Map<String, dynamic> message = {
      'senderId'     : FirebaseAuth.instance.currentUser!.email.toString(),
      'message'      : img,
      'type'         : 'image',
      'time'         : FieldValue.serverTimestamp(),
      'timeToDisplay': dateTime,
    };

    // Update last-message metadata for both sides of the chat
    updateUserLastMessage('Image');
    updateLawyerLastMessage('Image');

    // Write the image message to the chat room's Chats sub-collection
    await _firestore
        .collection('ChatRooms')
        .doc('${widget.lawyerId}${widget.userId}')
        .collection('Chats')
        .add(message)
        .then((value) {
      setState(() {
        isLoadingUpload = false;
      });
      Navigator.pop(context); // return to chat screen
    });
  }

  // ============================================================
  // checkMonth  ← ORIGINAL LOGIC
  //
  // Converts a numeric month (1–12) to a 3-letter abbreviation
  // used in the human-readable timestamp shown in chat.
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
  // uploadImageToFirebase  ← ORIGINAL LOGIC
  //
  // Uploads the selected image File to Cloudinary via the
  // CloudinaryUpload helper. On success → calls sendImageMessage()
  // with the returned URL. On error → prints debug message.
  // ============================================================
  Future uploadImageToFirebase(File? imageFile) async {
    try {
      String imageUrl = await CloudinaryUpload.uploadChatImage(imageFile!);
      sendImageMessage(imageUrl);
    } catch (e) {
      debugPrint('Error sending image');
    }
  }

  // ============================================================
  // updateUserLastMessage  ← ORIGINAL LOGIC
  //
  // Reads the user's chat list from UsersChats, finds the entry
  // matching this lawyer, and updates it with the latest message
  // preview + timestamp (milliseconds for sorting).
  // ============================================================
  Future updateUserLastMessage(String message) async {
    int minute       = DateTime.now().minute;
    int hour         = DateTime.now().hour;
    int day          = DateTime.now().day;
    int month        = DateTime.now().month;
    int milliSeconds = DateTime.now().millisecondsSinceEpoch;

    var doc = await FirebaseFirestore.instance
        .collection('UsersChats')
        .doc(widget.userId)
        .get();
    int counter = doc['counter'];
    for (int i = 1; i <= counter; i++) {
      if (doc['lawyerID$i'][0] == widget.lawyerId) {
        DocumentReference documentReference =
        fireStoreUserChat.doc(widget.userId);
        await documentReference.update({
          'lawyerID$i': [
            widget.lawyerId, minute, hour, day, month,
            milliSeconds, message,
            FirebaseAuth.instance.currentUser!.email.toString()
          ],
          'counter': counter,
        });
      }
    }
  }

  // ============================================================
  // updateLawyerLastMessage  ← ORIGINAL LOGIC
  //
  // Reads the lawyer's chat list from LawyersChats, finds the
  // entry matching this user, and updates it with the latest
  // message preview + timestamp.
  // ============================================================
  Future updateLawyerLastMessage(String message) async {
    int minute       = DateTime.now().minute;
    int hour         = DateTime.now().hour;
    int day          = DateTime.now().day;
    int month        = DateTime.now().month;
    int milliSeconds = DateTime.now().millisecondsSinceEpoch;

    var doc = await FirebaseFirestore.instance
        .collection('LawyersChats')
        .doc(widget.lawyerId)
        .get();
    int counter = doc['counter'];
    for (int i = 1; i <= counter; i++) {
      if (doc['userID$i'][0] == widget.userId) {
        DocumentReference documentReference =
        fireStoreLawyerChat.doc(widget.lawyerId);
        await documentReference.update({
          'userID$i': [
            widget.userId, minute, hour, day, month,
            milliSeconds, message,
            FirebaseAuth.instance.currentUser!.email.toString()
          ],
          'counter': counter,
        });
      }
    }
  }

  // ============================================================
  // build — constructs the full UI tree
  //
  // Structure:
  //   Scaffold (black background)
  //   ├── body: FadeTransition → full-screen image preview
  //   └── bottomNavigationBar: SlideTransition + FadeTransition
  //       └── glassmorphic bar with Cancel + Send buttons
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      // ── Full-screen image preview (fades in on open) ─────────────────
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── ORIGINAL: Image.file with cover fit ─────────────────────
            Image.file(
              widget.img!,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),

            // Subtle dark vignette at the bottom so the bar is readable
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 140,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black87, Colors.transparent],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // ── Bottom action bar (slides up + fades in) ──────────────────────
      bottomNavigationBar: SlideTransition(
        position: _barSlideAnim,
        child: FadeTransition(
          opacity: _barFadeAnim,
          child: _buildBottomBar(),
        ),
      ),
    );
  }

  // ============================================================
  // _buildBottomBar — Cancel + Send button row
  //
  // ORIGINAL onPressed logic for both buttons is fully preserved:
  //   Cancel → Navigator.pop(context)
  //   Send   → setState isLoadingUpload=true + uploadImageToFirebase()
  //
  // UI: glassmorphic dark bar replacing the plain ElevatedButtons
  // ============================================================
  Widget _buildBottomBar() {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [

          // ── Cancel button ─────────────────────────────────────────────
          _buildBarButton(
            label: 'Cancel',
            icon: Icons.close_rounded,
            color: const Color(0xFFEF5350),
            isLoading: false,
            onTap: () {
              Navigator.pop(context); // ← original logic
            },
          ),

          // Thin vertical divider
          Container(
            width: 1,
            height: 36,
            color: Colors.white12,
          ),

          // ── Send button ───────────────────────────────────────────────
          _buildBarButton(
            label: 'Send',
            icon: Icons.send_rounded,
            color: const Color(0xFF66BB6A),
            isLoading: isLoadingUpload,
            onTap: () {
              // ── ORIGINAL: set loading + upload ─────────────────────
              setState(() {
                isLoadingUpload = true;
              });
              uploadImageToFirebase(widget.img);
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // _buildBarButton — single icon + label action button
  //
  // Reusable helper used for both Cancel and Send.
  // Shows a SpinKitCircle spinner while isLoading is true.
  // onTap is passed directly from _buildBottomBar — logic untouched.
  // ============================================================
  Widget _buildBarButton({
    required String label,
    required IconData icon,
    required Color color,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.18),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.45)),
        ),
        child: isLoading
            ? SizedBox(
          width: 22,
          height: 22,
          child: SpinKitCircle(color: color, size: 22),
        )
            : Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontFamily: 'roboto',
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}