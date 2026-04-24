// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'UserAppBar&NavBar.dart';

/// ============================================================
/// UserRequestSubmitted — StatelessWidget
///
/// A confirmation screen shown after the user successfully
/// submits a request, response, or rating.
///
/// Parameter:
///   text → determines what was submitted. Possible values:
///     'Request'  → "Your Request has been Submitted!"
///     'Response' → "Your Response has been Submitted!"
///     anything else → "Please wait for Lawyer to accept The Case!"
///
/// The Home button navigates to UserAppBarNavBar (main shell).
/// ============================================================
class UserRequestSubmitted extends StatefulWidget {
  final String text;
  const UserRequestSubmitted({Key? key, required this.text}) : super(key: key);

  @override
  State<UserRequestSubmitted> createState() => _UserRequestSubmittedState();
}

class _UserRequestSubmittedState extends State<UserRequestSubmitted>
    with TickerProviderStateMixin {

  // ─── ANIMATION CONTROLLERS (UI only — no logic impact) ─────────────────

  /// Drives the fade + scale entrance of the check icon
  late AnimationController _checkController;
  late Animation<double> _checkScaleAnim;
  late Animation<double> _checkFadeAnim;

  /// Drives the staggered fade+slide of the text elements
  late AnimationController _textController;
  late Animation<double> _textFadeAnim;
  late Animation<Offset> _textSlideAnim;

  /// Drives the fade+slide-up of the Home button
  late AnimationController _buttonController;
  late Animation<double> _buttonFadeAnim;
  late Animation<Offset> _buttonSlideAnim;

  // ============================================================
  // initState — runs once when the screen is first created.
  //
  // Sets up three staggered animation stages:
  //   1. Check icon pops in with a scale bounce (400ms)
  //   2. Text fades + slides up shortly after (500ms, delayed 300ms)
  //   3. Home button fades + slides up last (500ms, delayed 550ms)
  //
  // The stagger makes the UI feel polished and celebratory.
  // ============================================================
  @override
  void initState() {
    super.initState();

    // Stage 1 — check icon scale bounce
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _checkScaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.25), weight: 55),
      TweenSequenceItem(tween: Tween(begin: 1.25, end: 1.0), weight: 45),
    ]).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.easeOut),
    );
    _checkFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkController, curve: const Interval(0.0, 0.5)),
    );

    // Stage 2 — text fade + upward slide
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _textFadeAnim = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    );
    _textSlideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic));

    // Stage 3 — button fade + upward slide
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _buttonFadeAnim = CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeOut,
    );
    _buttonSlideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _buttonController, curve: Curves.easeOutCubic));

    // Fire all three animations in staggered sequence
    _runStaggeredEntrance();
  }

  // ============================================================
  // _runStaggeredEntrance — fires each animation with a delay
  //
  // Sequence:
  //   0ms   → check icon bounces in
  //   300ms → text fades + slides up
  //   550ms → home button fades + slides up
  // ============================================================
  Future<void> _runStaggeredEntrance() async {
    _checkController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _textController.forward();
    await Future.delayed(const Duration(milliseconds: 250));
    _buttonController.forward();
  }

  // ============================================================
  // dispose — clean up all controllers to avoid memory leaks
  // ============================================================
  @override
  void dispose() {
    _checkController.dispose();
    _textController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  // ============================================================
  // build — constructs the visual UI tree
  //
  // Structure:
  //   Scaffold
  //   └── gradient background
  //       └── SafeArea
  //           ├── _buildAppBar()          ← glassmorphic top bar
  //           └── centered column
  //               ├── animated check icon
  //               ├── animated title text
  //               ├── animated subtitle text
  //               └── animated Home button
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
          child: Column(
            children: [
              // ── Custom glassmorphic AppBar ───────────────────────────
              _buildAppBar(),

              // ── Main centered content ────────────────────────────────
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ── Animated check icon ──────────────────────────
                    _buildCheckIcon(),

                    const SizedBox(height: 28),

                    // ── Animated title + subtitle ────────────────────
                    _buildTitleText(),

                    const SizedBox(height: 80),

                    // ── Animated Home button ─────────────────────────
                    _buildHomeButton(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // _buildAppBar — custom glassmorphic top bar
  //
  // Displays "${text} Submitted" as the title — same text as the
  // original AppBar title. No back button (same as original —
  // leading was a SizedBox()).
  // ============================================================
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.13)),
        ),
        child: Center(
          child: Text(
            '${widget.text} Submitted', // ← original title text, untouched
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'roboto',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // _buildCheckIcon — animated success check icon
  //
  // Uses ScaleTransition + FadeTransition driven by _checkController.
  // The icon is FontAwesomeIcons.solidCircleCheck — same as original.
  // Surrounded by a soft glowing circle for visual emphasis.
  // ============================================================
  Widget _buildCheckIcon() {
    return FadeTransition(
      opacity: _checkFadeAnim,
      child: ScaleTransition(
        scale: _checkScaleAnim,
        child: Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.07),
            border: Border.all(
              color: const Color(0xFF1E88E5).withOpacity(0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E88E5).withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Center(
            // ── ORIGINAL: same icon, size, color ──────────────────────
            child: Icon(
              FontAwesomeIcons.solidCircleCheck,
              size: 54,
              color: Color(0xFF1E88E5),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // _buildTitleText — animated title + subtitle text block
  //
  // ORIGINAL logic for choosing subtitle text is fully preserved:
  //   text == 'Request'  → "Your Request has been Submitted!"
  //   text == 'Response' → "Your Response has been Submitted!"
  //   otherwise          → "Please wait for Lawyer to accept The Case!"
  // ============================================================
  Widget _buildTitleText() {
    // ── ORIGINAL conditional subtitle text — untouched ────────────────
    final String subtitle = widget.text == 'Request'
        ? 'Your Request has been Submitted!'
        : widget.text == 'Response'
        ? 'Your Response has been Submitted!'
        : 'Please wait for Lawyer to accept The Case!';

    return FadeTransition(
      opacity: _textFadeAnim,
      child: SlideTransition(
        position: _textSlideAnim,
        child: Column(
          children: [
            // ── ORIGINAL: "${text} Submitted" title ───────────────────
            Text(
              '${widget.text} Submitted',
              style: const TextStyle(
                fontFamily: 'roboto',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Successfully',
              style: TextStyle(
                fontFamily: 'roboto',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E88E5),
              ),
            ),
            const SizedBox(height: 16),
            // ── ORIGINAL: conditional subtitle line ───────────────────
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'roboto',
                fontSize: 15,
                color: Colors.white60,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // _buildHomeButton — animated gradient Home button
  //
  // onTap logic is IDENTICAL to original:
  //   Navigator.push → UserAppBarNavBar()
  //
  // Added (UI only):
  //   • FadeTransition + SlideTransition entrance
  //   • Gradient background + glow shadow
  // ============================================================
  Widget _buildHomeButton(BuildContext context) {
    return FadeTransition(
      opacity: _buttonFadeAnim,
      child: SlideTransition(
        position: _buttonSlideAnim,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Container(
            height: 52,
            width: double.infinity,
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
                  // ── ORIGINAL navigation logic — untouched ─────────
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserAppBarNavBar(),
                    ),
                  );
                },
                child: const Center(
                  child: Text(
                    'Home', // ── ORIGINAL label ────────────────────────
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
      ),
    );
  }
}