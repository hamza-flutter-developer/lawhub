// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'UserRequestSubmitted.dart';

/// ============================================================
/// UserRattingFeedback — StatefulWidget
///
/// This screen lets a user rate (1–5 stars) and optionally write
/// a text review for the lawyer who handled their case.
///
/// Parameters received from the previous screen:
///   userId          → logged-in user's Firestore doc ID
///   lawyerId        → lawyer's Firestore doc ID
///   caseStartDate   → when the case started
///   caseDescription → text description of the case
///   paymentProof    → URL/path to payment screenshot
///   status          → current case status string
///   index           → position in the case list (0-based)
/// ============================================================
class UserRattingFeedback extends StatefulWidget {
  final String userId;
  final String lawyerId;
  final String caseStartDate;
  final String caseDescription;
  final String paymentProof;
  final String status;
  final int index;

  const UserRattingFeedback({
    super.key,
    required this.userId,
    required this.lawyerId,
    required this.caseStartDate,
    required this.caseDescription,
    required this.paymentProof,
    required this.status,
    required this.index,
  });

  @override
  State<UserRattingFeedback> createState() => _UserRattingFeedbackState();
}

class _UserRattingFeedbackState extends State<UserRattingFeedback>
    with TickerProviderStateMixin {

  // ─── ORIGINAL STATE VARIABLES (completely untouched) ───────────────────

  /// How many stars the user has selected (0 = nothing selected yet)
  int newRating = 0;

  /// Fetched from Firestore — used in the rolling-average formula
  late int numberOfRatings;
  late int sumOfRatings;

  /// Controls the written review text field
  final TextEditingController _feedbackController = TextEditingController();
  FocusNode feedbackFocusNode = FocusNode();

  /// True while async Firestore writes are running → shows spinner on button
  bool isLoading = false;

  /// Shortcut reference so we don't repeat the long collection path
  final fireStoreNotification =
  FirebaseFirestore.instance.collection('LawyersNotifications');

  // ─── ANIMATION CONTROLLERS (UI only — zero impact on logic) ───────────

  /// Drives the fade + slide-up entrance when the screen first opens
  late AnimationController _entranceController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  /// Drives the elastic bounce when the user taps a star
  late AnimationController _starBounceController;
  late Animation<double> _starBounceAnim;

  // ============================================================
  // initState — called once when this widget is inserted into the tree.
  //
  // 1. Configures page-entrance animations (fade + upward slide).
  // 2. Configures star-tap bounce animation.
  // 3. Starts the entrance animation right away.
  // 4. Calls the original Firestore fetch methods.
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

    // Star bounce: scale up to 1.4× then snap back — 350ms
    _starBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _starBounceAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0), weight: 60),
    ]).animate(
      CurvedAnimation(parent: _starBounceController, curve: Curves.easeOut),
    );

    // Play the entrance animation as soon as the screen opens
    _entranceController.forward();

    // ORIGINAL: fetch lawyer's existing rating data from Firestore
    fetchLawyerNumberOfRatting();
    fetchLawyerSumOfRatting();
  }

  // ============================================================
  // dispose — clean up all controllers to avoid memory leaks.
  // ============================================================
  @override
  void dispose() {
    _entranceController.dispose();
    _starBounceController.dispose();
    _feedbackController.dispose();
    feedbackFocusNode.dispose();
    super.dispose();
  }

  // ╔══════════════════════════════════════════════════════════╗
  //  ALL METHODS BELOW THIS LINE ARE 100% ORIGINAL LOGIC
  //  Only comments have been added — no code was changed.
  // ╚══════════════════════════════════════════════════════════╝

  // ============================================================
  // addNotification  ← ORIGINAL LOGIC
  //
  // Writes a notification into the LawyersNotifications collection
  // so the lawyer sees an in-app alert.
  //
  //   If doc exists  → increment counter, add a new "NotificationN" field
  //   If doc missing → create the doc with Notification1 and counter=1
  // ============================================================
  void addNotification(String userID, String type) async {
    var doc = await FirebaseFirestore.instance
        .collection('LawyersNotifications')
        .doc(userID)
        .get();
    if (doc.exists) {
      int counter = doc['counter'];
      counter++;
      DocumentReference documentReference = fireStoreNotification.doc(userID);
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
  // _buildStar  ← ORIGINAL LOGIC
  //
  // Returns a filled star if index < newRating (user selected it),
  // otherwise returns an outlined star.
  //
  // UI addition: AnimatedSwitcher gives a smooth icon swap
  // when the user changes their selection.
  // ============================================================
  Widget _buildStar(int index) {
    final bool filled = index < newRating;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, anim) =>
          ScaleTransition(scale: anim, child: child),
      child: Icon(
        filled ? Icons.star_rounded : Icons.star_outline_rounded,
        key: ValueKey(filled),
        color: filled ? const Color(0xFFFFC107) : Colors.white24,
        size: 44,
      ),
    );
  }

  // ============================================================
  // _submitRattingFeedback  ← ORIGINAL LOGIC
  //
  // Calculates the new rolling average rating then calls
  // updateLawyerRatting() to write it to Firestore.
  // ============================================================
  void _submitRattingFeedback() {
    double newAverageRating =
    calculateNewRating(sumOfRatings, numberOfRatings, newRating);
    updateLawyerRatting(newAverageRating, sumOfRatings + newRating);
  }

  // ============================================================
  // calculateNewRating  ← ORIGINAL LOGIC
  //
  // Rolling average formula:
  //   newAvg = ((prevAvg × prevCount) + newStars) / (prevCount + 1)
  //
  // Edge case: numberOfRatings == 0 → return newRating directly
  //            to avoid dividing by zero.
  // ============================================================
  double calculateNewRating(
      int sumOfRatings, int numberOfRatings, int newRating) {
    double preAvg = sumOfRatings / numberOfRatings;
    if (numberOfRatings == 0) {
      return newRating + 0.0;
    } else {
      double newAverageRating =
          ((preAvg * numberOfRatings) + newRating) / ++numberOfRatings;
      debugPrint(newAverageRating.toString());
      return newAverageRating;
    }
  }

  // ============================================================
  // fetchLawyerNumberOfRatting  ← ORIGINAL LOGIC
  //
  // Reads 'numberOfRatings' from the lawyer's Firestore document
  // and saves it locally so the average formula above can use it.
  // ============================================================
  Future<void> fetchLawyerNumberOfRatting() async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('Lawyers')
        .doc(widget.lawyerId)
        .get();
    numberOfRatings = userSnapshot['numberOfRatings'];
    debugPrint(numberOfRatings.toString());
  }

  // ============================================================
  // fetchLawyerSumOfRatting  ← ORIGINAL LOGIC
  //
  // Reads 'sumOfRatings' (running total of all star values ever
  // submitted) from the lawyer's Firestore document.
  // ============================================================
  Future<void> fetchLawyerSumOfRatting() async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('Lawyers')
        .doc(widget.lawyerId)
        .get();
    sumOfRatings = userSnapshot['sumOfRatings'];
    debugPrint(sumOfRatings.toString());
  }

  // ============================================================
  // updateLawyerRatting  ← ORIGINAL LOGIC
  //
  // Writes the updated average and new sumOfRatings to the lawyer's
  // Firestore document. After the write completes:
  //   • feedback text empty → skip setLawyerFeedback()
  //   • feedback text present → call setLawyerFeedback()
  // ============================================================
  Future<void> updateLawyerRatting(
      double newRatting, int sumOfRatings) async {
    await FirebaseFirestore.instance
        .collection('Lawyers')
        .doc(widget.lawyerId)
        .update({
      'numberOfRatings': ++numberOfRatings,
      'ratting': newRatting,
      'sumOfRatings': sumOfRatings,
    }).then((value) {
      if (_feedbackController.text.isEmpty) {
        // No written review — nothing extra to store
      } else {
        setLawyerFeedback();
      }
    });
  }

  // ============================================================
  // setLawyerFeedback  ← ORIGINAL LOGIC
  //
  // Stores the written review text in the LawyersFeedbacks collection.
  //   Doc exists  → increment counter, add "FeedbackN" map entry
  //   Doc missing → create doc with Feedback1 and counter=1
  //
  // Sets isLoading=false after writing so the button returns to normal.
  // ============================================================
  Future<void> setLawyerFeedback() async {
    var docCheck = await FirebaseFirestore.instance
        .collection('LawyersFeedbacks')
        .doc(widget.lawyerId)
        .get();
    if (docCheck.exists) {
      int counter = docCheck['counter'];
      counter++;
      FirebaseFirestore.instance
          .collection('LawyersFeedbacks')
          .doc(widget.lawyerId)
          .update({
        'Feedback$counter': {
          'userId': FirebaseAuth.instance.currentUser!.email.toString(),
          'feedback': _feedbackController.text.toString(),
        },
        'counter': counter,
      }).then((value) {
        setState(() {
          isLoading = false;
        });
      });
    } else {
      FirebaseFirestore.instance
          .collection('LawyersFeedbacks')
          .doc(widget.lawyerId)
          .set({
        'Feedback1': {
          'userId': FirebaseAuth.instance.currentUser!.email.toString(),
          'feedback': _feedbackController.text.toString(),
        },
        'counter': 1,
      }).then((value) {
        setState(() {
          isLoading = false;
        });
      });
    }
  }

  // ============================================================
  // updateCaseStatusOfFeedbackRating  ← ORIGINAL LOGIC
  //
  // Marks the case as "rating & feedback given" in BOTH collections:
  //   1. CasesUser   → the user's copy of the case
  //   2. CasesLawyer → the lawyer's copy of the case
  //
  // widget.index+1 converts 0-based index to the Firestore field
  // name e.g. index=2 → "case3".
  //
  // After both writes succeed:
  //   → isLoading = false (restores Submit button)
  //   → addNotification() alerts the lawyer
  //   → Navigator.push() goes to UserRequestSubmitted screen
  // ============================================================
  Future<void> updateCaseStatusOfFeedbackRating() async {
    await FirebaseFirestore.instance
        .collection('CasesUser')
        .doc(widget.userId)
        .update({
      'case${widget.index + 1}': {
        'status': widget.status,
        'userId': widget.userId,
        'lawyerId': widget.lawyerId,
        'caseDescription': widget.caseDescription,
        'paymentSS': widget.paymentProof,
        'startDate': widget.caseStartDate,
        'givenRatingFeedback': true,
      }
    });

    await FirebaseFirestore.instance
        .collection('CasesLawyer')
        .doc(widget.lawyerId)
        .update({
      'case${widget.index + 1}': {
        'status': widget.status,
        'userId': widget.userId,
        'lawyerId': widget.lawyerId,
        'caseDescription': widget.caseDescription,
        'paymentSS': widget.paymentProof,
        'startDate': widget.caseStartDate,
        'givenRatingFeedback': true,
      }
    });

    setState(() {
      isLoading = false;
    });

    addNotification(widget.lawyerId, 'gives you Rating and Feedback');

    // ignore: use_build_context_synchronously
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UserRequestSubmitted(text: 'Response'),
      ),
    );
  }

  // ╔══════════════════════════════════════════════════════════╗
  //  BUILD — constructs the entire visual UI tree
  //
  //  Animation wrapper order (outside → inside):
  //    FadeTransition  → whole page fades in on open
  //    SlideTransition → whole page slides up 6% on open
  //
  //  Layout sections:
  //    _buildAppBar()       → glassmorphic top bar
  //    _buildStarSection()  → rating card with 5 stars
  //    _buildFeedbackField()→ multiline text input card
  //    _buildSubmitButton() → animated gradient submit button
  // ╚══════════════════════════════════════════════════════════╝
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        // ── Deep navy gradient background ────────────────────────────────
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
                  _buildAppBar(context),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 32),
                          _buildStarSection(),
                          const SizedBox(height: 28),
                          _buildFeedbackField(),
                          const SizedBox(height: 32),
                          _buildSubmitButton(),
                          const SizedBox(height: 40),
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
    );
  }

  // ============================================================
  // _buildAppBar — custom top bar (UI replacement for AppBar)
  //
  // Glassmorphic frosted-glass panel.
  // Back button: Navigator.of(context).pop() — same as original.
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
                  'Rating & Feedback',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 48), // balances the icon button width
          ],
        ),
      ),
    );
  }

  // ============================================================
  // _buildStarSection — rating card with label + 5 stars
  //
  // Star tap logic is IDENTICAL to original:
  //   setState(() { newRating = index + 1; })
  //
  // Added (UI only):
  //   • _starBounceController.forward(from:0) plays elastic bounce on tap
  //   • AnimatedSwitcher smoothly swaps filled/outlined icon
  //   • Dynamic text label below the stars ("Poor" → "Excellent!")
  // ============================================================
  Widget _buildStarSection() {
    // Maps the current star count to a descriptive label
    const List<String> labels = [
      'Tap to rate',
      'Poor',
      'Fair',
      'Good',
      'Great',
      'Excellent!',
    ];
    final String label = labels[newRating];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Rate your experience',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 20),

          // ── 5 stars — GestureDetector logic identical to original ──────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    newRating = index + 1; // ← original logic, untouched
                  });
                  // Play bounce animation (UI only — no data change)
                  _starBounceController.forward(from: 0);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ScaleTransition(
                    scale: _starBounceAnim,
                    child: _buildStar(index), // ← original logic, untouched
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 14),

          // ── Animated label that changes as the user taps stars ─────────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              label,
              key: ValueKey(label),
              style: TextStyle(
                color: newRating > 0
                    ? const Color(0xFFFFC107)
                    : Colors.white38,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // _buildFeedbackField — label + multiline text input card
  //
  // Controller (_feedbackController), focusNode, maxLines, and
  // InputDecoration logic are ALL identical to original.
  // Only the outer card decoration is modernized.
  // ============================================================
  Widget _buildFeedbackField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            'Feedback',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ),
        Container(
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
              // ── ORIGINAL: all these fields are unchanged ──────────────
              controller: _feedbackController,
              textAlignVertical: TextAlignVertical.center,
              focusNode: feedbackFocusNode,
              maxLines: 4,
              style: const TextStyle(fontSize: 15, color: Colors.white),
              decoration: const InputDecoration(
                focusedBorder: InputBorder.none,
                border: InputBorder.none,
                hintText: 'Enter your Feedback',
                hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
                focusColor: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // _buildSubmitButton — animated gradient submit button
  //
  // onPressed logic is IDENTICAL to original:
  //   setState → isLoading = true
  //   _submitRattingFeedback()
  //   updateCaseStatusOfFeedbackRating()
  //
  // Added (UI only):
  //   • AnimatedContainer shrinks the button width while loading
  //   • Gradient replaces the flat blue background
  //   • Soft blue glow shadow under the button
  // ============================================================
  Widget _buildSubmitButton() {
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: isLoading ? 160 : 220,
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
            onTap: () {
              // ── ORIGINAL onPressed logic (untouched) ─────────────────
              setState(() {
                isLoading = true;
              });
              _submitRattingFeedback();
              updateCaseStatusOfFeedbackRating();
            },
            child: Center(
              child: isLoading
              // ── ORIGINAL: spinner row ─────────────────────────────
                  ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SpinKitCircle(color: Colors.white, size: 22),
                  SizedBox(width: 10),
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
              // ── ORIGINAL: submit label ────────────────────────────
                  : const Text(
                'Submit',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'roboto',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}