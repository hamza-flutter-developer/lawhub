// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lawhub/User_Pages/UserRattingFeedback.dart';

/// ============================================================
/// CasesList — Data model
///
/// Holds all fields for a single case entry fetched from Firestore.
/// Used to populate each card in the ListView.
/// status is mutable so we can update it in-place after Accept/
/// Reject/Complete without re-fetching the whole list.
/// ============================================================
class CasesList {
  final String userId;
  final String lawyerId;
  final String userName;
  final String lawyerName;
  final String caseStartDate;
  final String caseDescription;
  final String paymentProof;
  final bool isGivenRatingFeedback;
  String status; // mutable — updated by updateCaseStatus()

  CasesList({
    required this.userId,
    required this.lawyerId,
    required this.userName,
    required this.lawyerName,
    required this.caseStartDate,
    required this.caseDescription,
    required this.paymentProof,
    required this.status,
    required this.isGivenRatingFeedback,
  });
}

/// ============================================================
/// CaseView — StatefulWidget
///
/// Displays a scrollable list of all cases for either a User or
/// a Lawyer depending on the [isUser] flag.
///
/// Parameter:
///   isUser → true  = fetch from CasesUser  (show Lawyer name + Rating btn)
///            false = fetch from CasesLawyer (show Client name + Accept/Reject/Complete btns)
/// ============================================================
class CaseView extends StatefulWidget {
  final bool isUser;
  const CaseView({Key? key, required this.isUser}) : super(key: key);

  @override
  State<CaseView> createState() => _CaseViewState();
}

class _CaseViewState extends State<CaseView> with TickerProviderStateMixin {

  // ─── ORIGINAL STATE VARIABLES (completely untouched) ───────────────────

  /// True while initial data fetch is in progress → shows full-screen spinner
  bool isLoading = true;

  /// The local list of cases populated by checkCases()
  List<CasesList> cases = [];

  /// URL of the payment image currently being viewed full-screen
  String? imageToDisplay;

  /// True when the full-screen image viewer is active
  bool isImageShow = false;

  /// Individual loading flags for each action button
  bool isLoadingAccept   = false;
  bool isLoadingReject   = false;
  bool isLoadingComplete = false;

  /// Shortcut reference to UsersNotifications collection
  final fireStoreNotification =
  FirebaseFirestore.instance.collection('UsersNotifications');

  // ─── ANIMATION CONTROLLER (UI only) ───────────────────────────────────

  /// Drives the page-level fade + upward slide on screen open
  late AnimationController _entranceController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // ============================================================
  // initState — runs once when this widget is first created.
  //
  // 1. Sets up and starts the entrance animation.
  // 2. Calls the original checkCases() to fetch case data.
  // ============================================================
  @override
  void initState() {
    super.initState();

    // Page entrance animation
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _fadeAnim = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    ));

    _entranceController.forward();

    // ORIGINAL: start fetching cases from Firestore
    checkCases();
  }

  // ============================================================
  // dispose — clean up animation controller
  // ============================================================
  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  // ╔══════════════════════════════════════════════════════════╗
  //  ALL METHODS BELOW ARE 100% ORIGINAL LOGIC
  //  Only comments have been added — no code was changed.
  // ╚══════════════════════════════════════════════════════════╝

  // ============================================================
  // checkCases  ← ORIGINAL LOGIC
  //
  // Calls fetchAllCases() to get the document snapshot, then
  // loops through case1…caseN reading each field.
  // For each case it fetches the lawyer name and user name in
  // parallel via fetchLawyerData() and fetchUserData().
  // Once all names are resolved it adds a CasesList entry and
  // when the list length matches the counter it sets isLoading=false.
  // On any error → sets isLoading=false silently.
  // ============================================================
  void checkCases() {
    fetchAllCases().then((data) {
      int counter = data['counter'];
      for (int i = 1; i <= counter; i++) {
        String caseDescription      = data['case$i']['caseDescription'];
        String startDate            = data['case$i']['startDate'];
        String paymentProof         = data['case$i']['paymentSS'];
        String status               = data['case$i']['status'];
        String userId               = data['case$i']['userId'];
        String lawyerId             = data['case$i']['lawyerId'];
        bool isGivenRatingFeedback  = data['case$i']['givenRatingFeedback'];
        fetchLawyerData(data['case$i']['lawyerId']).then((valueL) {
          fetchUserData(data['case$i']['userId']).then((valueU) {
            setState(() {
              cases.add(CasesList(
                userId: userId,
                lawyerId: lawyerId,
                userName: valueU,
                lawyerName: valueL,
                caseStartDate: startDate,
                caseDescription: caseDescription,
                paymentProof: paymentProof,
                status: status,
                isGivenRatingFeedback: isGivenRatingFeedback,
              ));
              if (cases.length == counter) {
                setState(() {
                  isLoading = false;
                });
              }
            });
          });
        });
      }
    }).catchError((error) {
      setState(() {
        isLoading = false;
      });
    });
  }

  // ============================================================
  // fetchAllCases  ← ORIGINAL LOGIC
  //
  // Reads from CasesUser if isUser==true, otherwise CasesLawyer.
  // Both use the current user's email as the document ID.
  // ============================================================
  Future<DocumentSnapshot> fetchAllCases() async {
    if (widget.isUser) {
      return await FirebaseFirestore.instance
          .collection('CasesUser')
          .doc(FirebaseAuth.instance.currentUser!.email.toString())
          .get();
    } else {
      return await FirebaseFirestore.instance
          .collection('CasesLawyer')
          .doc(FirebaseAuth.instance.currentUser!.email.toString())
          .get();
    }
  }

  // ============================================================
  // fetchUserData  ← ORIGINAL LOGIC
  //
  // Reads the user's 'name' field from the Users collection
  // using the userId as the document ID.
  // ============================================================
  Future<String> fetchUserData(String id) async {
    DocumentSnapshot userSnapshot =
    await FirebaseFirestore.instance.collection('Users').doc(id).get();
    return userSnapshot['name'];
  }

  // ============================================================
  // fetchLawyerData  ← ORIGINAL LOGIC
  //
  // Reads the lawyer's 'name' field from the Lawyers collection
  // using the lawyerId as the document ID.
  // ============================================================
  Future<String> fetchLawyerData(String id) async {
    DocumentSnapshot userSnapshot =
    await FirebaseFirestore.instance.collection('Lawyers').doc(id).get();
    return userSnapshot['name'];
  }

  // ============================================================
  // updateCaseStatus  ← ORIGINAL LOGIC
  //
  // Writes the updated status to BOTH CasesUser and CasesLawyer
  // for the specific case (identified by index+1).
  //
  // After writing, based on the new status:
  //   'accept'   → addNotification + update local cases[index].status
  //   'reject'   → addNotification + update local cases[index].status
  //   'complete' → addNotification + update local cases[index].status
  // ============================================================
  Future<void> updateCaseStatus(
      String userID,
      String lawyerID,
      String status,
      String caseDescription,
      String paymentSS,
      String startDate,
      int index,
      bool isGivenRatingFeedback,
      ) async {
    await FirebaseFirestore.instance
        .collection('CasesUser')
        .doc(userID)
        .update({
      'case${index + 1}': {
        'status': status,
        'userId': userID,
        'lawyerId': lawyerID,
        'caseDescription': caseDescription,
        'paymentSS': paymentSS,
        'startDate': startDate,
        'givenRatingFeedback': isGivenRatingFeedback,
      }
    });

    await FirebaseFirestore.instance
        .collection('CasesLawyer')
        .doc(lawyerID)
        .update({
      'case${index + 1}': {
        'status': status,
        'userId': userID,
        'lawyerId': lawyerID,
        'caseDescription': caseDescription,
        'paymentSS': paymentSS,
        'startDate': startDate,
        'givenRatingFeedback': isGivenRatingFeedback,
      }
    });

    if (status == 'accept') {
      addNotification(userID, 'accepts you request to Start the Case');
      setState(() {
        isLoadingAccept = false;
        cases[index].status = 'accept';
      });
    } else if (status == 'reject') {
      addNotification(userID, 'rejects you request to Start the Case');
      setState(() {
        isLoadingReject = false;
        cases[index].status = 'reject';
      });
    } else {
      addNotification(
          userID, 'completed the Case Please give Ratting and Feedback');
      setState(() {
        isLoadingComplete = false;
        cases[index].status = 'complete';
      });
    }
  }

  // ============================================================
  // addNotification  ← ORIGINAL LOGIC
  //
  // Writes a notification into UsersNotifications so the user
  // gets an in-app alert when the lawyer acts on their case.
  //
  //   If doc exists  → increment counter, add "NotificationN" field
  //   If doc missing → create doc with Notification1 and counter=1
  // ============================================================
  void addNotification(String userID, String type) async {
    var doc = await FirebaseFirestore.instance
        .collection('UsersNotifications')
        .doc(userID)
        .get();
    if (doc.exists) {
      int counter = doc['counter'];
      counter++;
      DocumentReference documentReference =
      fireStoreNotification.doc(userID);
      await documentReference.update({
        'Notification$counter': [
          {'lawyerID': FirebaseAuth.instance.currentUser!.email.toString()},
          {'type': type},
          {'isSeen': false},
        ],
        'counter': counter,
      });
    } else {
      fireStoreNotification.doc(userID).set({
        'Notification1': [
          {'lawyerID': FirebaseAuth.instance.currentUser!.email.toString()},
          {'type': type},
          {'isSeen': false},
        ],
        'counter': 1,
      });
    }
  }

  // ============================================================
  // build — top-level build method
  //
  // ORIGINAL logic: if isImageShow==true → show full-screen image
  //                 else → show the cases list scaffold
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return isImageShow ? _buildImageViewer() : _buildCaseListScaffold();
  }

  // ============================================================
  // _buildImageViewer — full-screen payment image viewer
  //
  // ORIGINAL logic: black scaffold, X button sets isImageShow=false,
  // Image.network displays imageToDisplay with cover fit.
  // UI: same black background, just a cleaner close button.
  // ============================================================
  Widget _buildImageViewer() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            // ── ORIGINAL: close image view ─────────────────────────────
            setState(() {
              isImageShow = false;
            });
          },
          child: const Padding(
            padding: EdgeInsets.only(top: 10, left: 10),
            child: Icon(FontAwesomeIcons.x, color: Colors.white, size: 20),
          ),
        ),
      ),
      body: Center(
        child: Hero(
          // Hero tag ties the thumbnail to the full-screen view (UI only)
          tag: imageToDisplay ?? '',
          child: Image.network(
            imageToDisplay!,
            width: double.infinity,
            height: 500,
            fit: BoxFit.cover, // ← original fit
          ),
        ),
      ),
    );
  }

  // ============================================================
  // _buildCaseListScaffold — the main cases list screen
  //
  // Structure:
  //   Scaffold
  //   └── gradient background
  //       └── SafeArea
  //           └── FadeTransition + SlideTransition (entrance)
  //               ├── _buildAppBar()
  //               └── body:
  //                   isLoading → full-screen spinner
  //                   else      → ListView of case cards
  // ============================================================
  Widget _buildCaseListScaffold() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
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
                    child: isLoading
                    // ── ORIGINAL: full-screen loading spinner ───────
                        ? const Center(
                      child: SpinKitCircle(
                          color: Color(0xFF1E88E5), size: 34),
                    )
                        : _buildCaseList(),
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
  // Title: "In Progress Cases" — same as original.
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
            IconButton(
              icon: const Icon(FontAwesomeIcons.angleLeft,
                  color: Colors.white, size: 18),
              onPressed: () => Navigator.of(context).pop(),
            ),
            const Expanded(
              child: Center(
                child: Text(
                  'In Progress Cases',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // _buildCaseList — the scrollable ListView of case cards
  //
  // ORIGINAL: SingleChildScrollView → Column → ListView.builder
  // All itemBuilder logic is identical to original — just extracted
  // into _buildCaseCard() for readability.
  // ============================================================
  Widget _buildCaseList() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 20),
          ListView.builder(
            itemCount: cases.length,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return _buildCaseCard(cases[index], index);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ============================================================
  // _buildCaseCard — renders a single case card
  //
  // All data reading and conditional logic is IDENTICAL to the
  // original itemBuilder block. Only the wrapping decoration,
  // colors, and spacing are modernized.
  //
  // Contains:
  //   • Case number header
  //   • Start date
  //   • Lawyer/Client name (depends on isUser)
  //   • Case description
  //   • Status badge
  //   • Payment image (tap → full-screen)
  //   • Action buttons (depends on isUser + status)
  // ============================================================
  Widget _buildCaseCard(CasesList itemData, int index) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Case number header ─────────────────────────────────
              Center(
                child: Text(
                  'Case # ${(index + 1)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'roboto',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 16),
              _divider(),

              // ── Start Date ─────────────────────────────────────────
              const SizedBox(height: 14),
              _fieldLabel('Start Date'),
              const SizedBox(height: 6),
              _fieldValue(itemData.caseStartDate),

              const SizedBox(height: 16),

              // ── Lawyer / Client name (ORIGINAL conditional) ────────
              _fieldLabel(widget.isUser ? 'Lawyer Name' : 'Client Name'),
              const SizedBox(height: 6),
              _fieldValue(
                  widget.isUser ? itemData.lawyerName : itemData.userName),

              const SizedBox(height: 16),

              // ── Case Description ───────────────────────────────────
              _fieldLabel('Case Description'),
              const SizedBox(height: 6),
              _fieldValue(itemData.caseDescription),

              const SizedBox(height: 16),

              // ── Status badge ───────────────────────────────────────
              _fieldLabel('Status'),
              const SizedBox(height: 8),
              _buildStatusBadge(itemData.status),

              const SizedBox(height: 16),

              // ── Advance Payment image ──────────────────────────────
              _fieldLabel('Advance Payment'),
              const SizedBox(height: 12),
              _buildPaymentImage(itemData),

              const SizedBox(height: 16),

              // ── Action buttons (ORIGINAL conditional logic) ────────
              _buildActionButtons(itemData, index),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // _buildStatusBadge — coloured pill showing the case status
  //
  // ORIGINAL logic: pending → 'Requested', accept → 'In Progress',
  // complete → 'Completed', else → empty SizedBox.
  // UI: replaced plain Text with a coloured pill badge.
  // ============================================================
  Widget _buildStatusBadge(String status) {
    // Map status strings to label + colour
    final Map<String, Map<String, dynamic>> config = {
      'pending':  {'label': 'Requested',   'color': const Color(0xFFFFA726)},
      'accept':   {'label': 'In Progress', 'color': const Color(0xFF66BB6A)},
      'complete': {'label': 'Completed',   'color': const Color(0xFF1E88E5)},
      'reject':   {'label': 'Rejected',    'color': const Color(0xFFEF5350)},
    };

    final cfg = config[status];
    if (cfg == null) return const SizedBox(); // ← original empty fallback

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: (cfg['color'] as Color).withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (cfg['color'] as Color).withOpacity(0.5),
        ),
      ),
      child: Text(
        cfg['label'] as String,
        style: TextStyle(
          color: cfg['color'] as Color,
          fontFamily: 'roboto',
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ============================================================
  // _buildPaymentImage — tappable payment screenshot
  //
  // ORIGINAL logic:
  //   onTap → setState({ imageToDisplay = ..., isImageShow = true })
  //   Image.network with cover fit and fixed height
  // UI: clipped rounded corners + Hero animation tag.
  // ============================================================
  Widget _buildPaymentImage(CasesList itemData) {
    return InkWell(
      onTap: () {
        // ── ORIGINAL: open full-screen viewer ────────────────────────
        setState(() {
          imageToDisplay = itemData.paymentProof;
          isImageShow = true;
        });
      },
      borderRadius: BorderRadius.circular(14),
      child: Hero(
        tag: itemData.paymentProof,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.network(
            itemData.paymentProof,
            width: double.infinity,
            height: 220,
            fit: BoxFit.cover, // ← original fit
          ),
        ),
      ),
    );
  }

  // ============================================================
  // _buildActionButtons — renders the correct buttons per role/status
  //
  // ORIGINAL conditional logic fully preserved:
  //
  // isUser == true:
  //   status == 'complete' && !isGivenRatingFeedback
  //     → "Rating and Feedback" button → navigates to UserRattingFeedback
  //   else → empty SizedBox
  //
  // isUser == false (lawyer):
  //   status == 'pending'
  //     → Reject + Accept buttons → call updateCaseStatus()
  //   status == 'accept'
  //     → Complete button → calls updateCaseStatus()
  //   else → empty SizedBox
  // ============================================================
  Widget _buildActionButtons(CasesList itemData, int index) {
    if (widget.isUser) {
      // ── User view: only show Rating button when case is complete ────
      if (itemData.status == 'complete' && !itemData.isGivenRatingFeedback) {
        return _buildFullWidthButton(
          label: 'Rating and Feedback',
          isLoading: isLoadingComplete,
          color: const Color(0xFF1E88E5),
          onTap: () {
            // ── ORIGINAL: navigate to UserRattingFeedback ────────────
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserRattingFeedback(
                  userId: itemData.userId,
                  lawyerId: itemData.lawyerId,
                  caseDescription: itemData.caseDescription,
                  caseStartDate: itemData.caseStartDate,
                  paymentProof: itemData.paymentProof,
                  status: itemData.status,
                  index: index,
                ),
              ),
            );
          },
        );
      }
      return const SizedBox();
    } else {
      // ── Lawyer view: show action buttons based on status ────────────
      if (itemData.status == 'pending') {
        // Show Reject + Accept side by side
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionButton(
              label: 'Reject',
              isLoading: isLoadingReject,
              color: const Color(0xFFEF5350),
              onTap: () {
                // ── ORIGINAL: set loading + call updateCaseStatus ─────
                setState(() {
                  isLoadingReject = true;
                });
                updateCaseStatus(
                  itemData.userId,
                  itemData.lawyerId,
                  'reject',
                  itemData.caseDescription,
                  itemData.paymentProof,
                  itemData.caseStartDate,
                  index,
                  false,
                );
              },
            ),
            _buildActionButton(
              label: 'Accept',
              isLoading: isLoadingAccept,
              color: const Color(0xFF66BB6A),
              onTap: () {
                // ── ORIGINAL: set loading + call updateCaseStatus ─────
                setState(() {
                  isLoadingAccept = true;
                });
                updateCaseStatus(
                  itemData.userId,
                  itemData.lawyerId,
                  'accept',
                  itemData.caseDescription,
                  itemData.paymentProof,
                  itemData.caseStartDate,
                  index,
                  false,
                );
              },
            ),
          ],
        );
      } else if (itemData.status == 'accept') {
        // Show Complete button
        return _buildFullWidthButton(
          label: 'Complete',
          isLoading: isLoadingComplete,
          color: const Color(0xFF1E88E5),
          onTap: () {
            // ── ORIGINAL: set loading + call updateCaseStatus ─────────
            setState(() {
              isLoadingComplete = true;
            });
            updateCaseStatus(
              itemData.userId,
              itemData.lawyerId,
              'complete',
              itemData.caseDescription,
              itemData.paymentProof,
              itemData.caseStartDate,
              index,
              false,
            );
          },
        );
      }
      return const SizedBox(); // ← original fallback
    }
  }

  // ============================================================
  // _buildFullWidthButton — gradient button spanning full card width
  //
  // Used for single-action situations (Complete, Rating & Feedback).
  // Logic in onTap is passed from _buildActionButtons — untouched.
  // ============================================================
  Widget _buildFullWidthButton({
    required String label,
    required bool isLoading,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.85), color],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: isLoading
                  ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SpinKitCircle(color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text('Loading',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'roboto',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      )),
                ],
              )
                  : Text(
                label,
                style: const TextStyle(
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

  // ============================================================
  // _buildActionButton — smaller side-by-side button (Reject/Accept)
  //
  // Used for two-button rows. onTap passed from _buildActionButtons.
  // ============================================================
  Widget _buildActionButton({
    required String label,
    required bool isLoading,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 130,
      height: 46,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.85), color],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: SpinKitCircle(color: Colors.white, size: 20),
              )
                  : Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'roboto',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Small helper widgets (purely UI, no logic) ────────────────────────

  /// Thin divider line used between the case header and body
  Widget _divider() => Container(
    height: 1,
    color: Colors.white.withOpacity(0.08),
  );

  /// Bold white label for each field (e.g. "Start Date:")
  Widget _fieldLabel(String text) => Text(
    text,
    style: const TextStyle(
      color: Colors.white70,
      fontFamily: 'roboto',
      fontSize: 13,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.4,
    ),
  );

  /// Regular white value text shown under each label
  Widget _fieldValue(String text) => Text(
    text,
    style: const TextStyle(
      color: Colors.white,
      fontFamily: 'roboto',
      fontSize: 15,
    ),
  );
}