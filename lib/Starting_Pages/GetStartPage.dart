// ══════════════════════════════════════════════════════════════════════════════
// FILE: GetStartPage.dart
// PURPOSE: Welcome/Onboarding screen that introduces the app to new users
// ══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:lawhub/LoginSignup_Pages/LoginPage.dart';
import 'package:lawhub/widgets/Themes.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// GetStart Widget (StatelessWidget)
/// ═══════════════════════════════════════════════════════════════════════════
/// This is a welcome screen that:
/// - Shows the app logo
/// - Displays a hero image
/// - Explains what the app does
/// - Has a "Get Started" button to begin
///
/// StatelessWidget is used because this screen doesn't change after it's built
/// No timers, no user input to track - just displays static content
class GetStart extends StatelessWidget {
  const GetStart({super.key});

  @override
  Widget build(BuildContext context) {
    // ─────────────────────────────────────────────────────────────────────────
    // RESPONSIVE DESIGN: Get screen dimensions
    // ─────────────────────────────────────────────────────────────────────────
    /// MediaQuery gets device info - we use it for responsive sizing
    /// This makes the app look good on all screen sizes (phones, tablets)
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // ═══════════════════════════════════════════════════════════════════════
      // MODERN GRADIENT BACKGROUND
      // ═══════════════════════════════════════════════════════════════════════
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Modern subtle gradient background instead of plain white
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8F9FA), // Very light gray at top
              Color(0xFFFFFFFF), // Pure white at bottom
            ],
          ),
        ),

        // ═══════════════════════════════════════════════════════════════════════
        // SAFE AREA: Avoids notches, status bars, etc.
        // ═══════════════════════════════════════════════════════════════════════
        /// SafeArea ensures content doesn't go under system UI elements
        /// (like iPhone notch, Android navigation bar, etc.)
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ═════════════════════════════════════════════════════════════════
              // SECTION 1: ANIMATED LOGO AT TOP
              // ═════════════════════════════════════════════════════════════════
              /// TweenAnimationBuilder creates a slide-in animation for the logo
              /// It animates from offscreen (top) to its final position
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 800),
                tween: Tween(begin: -100.0, end: 0.0), // Slides from -100 to 0
                curve: Curves.easeOutCubic, // Smooth deceleration curve
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, value), // Moves vertically by 'value'
                    child: Opacity(
                      opacity: ((value + 100) / 100).clamp(0.0, 1.0), // Fades in as it slides
                      child: child,
                    ),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.only(
                    top: 0.03 * screenHeight,
                    bottom: 0.02 * screenHeight,
                  ),
                  child: TopLogo(fontColor: const Color(0xFF1565C0)),
                ),
              ),

              // ═════════════════════════════════════════════════════════════════
              // SECTION 2: MAIN CONTENT AREA (Scrollable)
              // ═════════════════════════════════════════════════════════════════
              /// Expanded takes all available space between logo and button
              /// This makes the layout flexible and responsive
              Expanded(
                child: SingleChildScrollView(
                  // SingleChildScrollView makes content scrollable if needed
                  physics: const BouncingScrollPhysics(), // iOS-style bounce effect
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // ───────────────────────────────────────────────────────
                      // HERO IMAGE with Modern Shadow and Animation
                      // ───────────────────────────────────────────────────────
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 1200),
                        tween: Tween(begin: 0.8, end: 1.0), // Scales up from 80% to 100%
                        curve: Curves.easeOutBack, // Slight overshoot for playfulness
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Opacity(
                              opacity: value.clamp(0.0, 1.0),
                              child: child,
                            ),
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: 0.1 * screenWidth,
                            vertical: 0.04 * screenHeight,
                          ),
                          // Modern card-style decoration with shadow
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            // Elegant shadow for depth
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1565C0).withAlpha(38), // 15% opacity = 255 * 0.15 = 38
                                blurRadius: 40,
                                spreadRadius: 0,
                                offset: const Offset(0, 20),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            // ClipRRect clips the image to match rounded corners
                            borderRadius: BorderRadius.circular(30),
                            child: Image.asset(
                              "assets/images/GetStart.jpg",
                              width: 0.8 * screenWidth,
                              height: 0.8 * screenWidth,
                              fit: BoxFit.cover, // Fills space while maintaining aspect ratio
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 0.04 * screenHeight),

                      // ───────────────────────────────────────────────────────
                      // TEXT CONTENT with Staggered Animation
                      // ───────────────────────────────────────────────────────
                      Column(
                        children: [
                          // ── Main Headline ──
                          TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 1000),
                            tween: Tween(begin: 0.0, end: 1.0),
                            curve: Curves.easeOut,
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, 30 * (1 - value)), // Slides up
                                child: Opacity(
                                  opacity: value.clamp(0.0, 1.0),
                                  child: child,
                                ),
                              );
                            },
                            child: Container(
                              width: 0.85 * screenWidth,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: const Text(
                                "Legal Solutions at Your Fingertips",
                                style: TextStyle(
                                  fontFamily: "patua",
                                  fontWeight: FontWeight.w600,
                                  fontSize: 28,
                                  color: Color(0xFF1A1A1A), // Almost black for readability
                                  height: 1.3, // Line height for better readability
                                  letterSpacing: -0.5, // Tighter spacing for modern look
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),

                          SizedBox(height: 0.02 * screenHeight),

                          // ── Subtitle/Description ──
                          TweenAnimationBuilder<double>(
                            // Delayed animation (starts after headline)
                            duration: const Duration(milliseconds: 1000),
                            tween: Tween(begin: 0.0, end: 1.0),
                            curve: Curves.easeOut,
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, 30 * (1 - value)),
                                child: Opacity(
                                  opacity: value.clamp(0.0, 1.0),
                                  child: child,
                                ),
                              );
                            },
                            child: Container(
                              width: 0.8 * screenWidth,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: const Text(
                                "Unlock Justice: Connect with Top Lawyers in Your Area – Your Legal Solution Just a Click Away!",
                                style: TextStyle(
                                  fontFamily: 'roboto',
                                  fontSize: 16,
                                  color: Color(0xFF666666), // Subtle gray for secondary text
                                  height: 1.6, // More line height for easy reading
                                  letterSpacing: 0.2,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 0.04 * screenHeight),
                    ],
                  ),
                ),
              ),

              // ═════════════════════════════════════════════════════════════════
              // SECTION 3: "GET STARTED" BUTTON (Fixed at bottom)
              // ═════════════════════════════════════════════════════════════════
              /// This button navigates to the Login page
              /// Your existing navigation logic is preserved
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1200),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 50 * (1 - value)), // Slides up from bottom
                    child: Opacity(
                      opacity: value.clamp(0.0, 1.0),
                      child: child,
                    ),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: 0.03 * screenHeight,
                    left: 0.1 * screenWidth,
                    right: 0.1 * screenWidth,
                  ),
                  child: SizedBox(
                    width: double.infinity, // Full width button
                    height: 56, // Standard touch target size (minimum 48px)
                    child: ElevatedButton(
                      // ═══ YOUR EXISTING NAVIGATION LOGIC - UNCHANGED ═══
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },

                      // ── Modern Button Styling ──
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0), // Primary blue
                        foregroundColor: Colors.white, // Text color
                        elevation: 0, // Flat design (no shadow)
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16), // Rounded corners
                        ),
                      ),

                      // ── Button Content ──
                      child: const Text(
                        'Get Started',
                        style: TextStyle(
                          fontFamily: 'roboto',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// FLUTTER CONCEPTS EXPLAINED IN THIS FILE:
// ══════════════════════════════════════════════════════════════════════════════
//
// 1. StatelessWidget:
//    - Cannot change after it's built (immutable)
//    - Perfect for screens that just display content
//    - More efficient than StatefulWidget when you don't need state
//
// 2. Column & Expanded:
//    - Column arranges children vertically
//    - Expanded takes all available remaining space
//    - Useful for flexible layouts that adapt to screen size
//
// 3. SingleChildScrollView:
//    - Makes content scrollable when it's too tall for screen
//    - BouncingScrollPhysics adds iOS-style bounce effect
//    - Important for small screens and landscape orientation
//
// 4. Transform & Animation:
//    - Transform.translate moves widgets (x, y coordinates)
//    - Transform.scale changes size
//    - Offset(x, y) specifies movement direction
//
// 5. BoxDecoration & ClipRRect:
//    - BoxDecoration adds visual effects (shadows, gradients, borders)
//    - ClipRRect clips child widget to rounded rectangle
//    - borderRadius creates rounded corners
//
// 6. Responsive Design:
//    - Use MediaQuery for screen dimensions
//    - Multiply by percentages (0.8 * width = 80% of screen)
//    - Makes app work on phones, tablets, different screen sizes
//
// 7. Color Codes:
//    - 0xFF prefix means fully opaque
//    - Next 6 digits are RGB hex code
//    - Example: 0xFF1565C0 = blue color
//    - .withAlpha(value) makes colors transparent (0-255 range)
//    - withAlpha is NOT deprecated - it's the modern approach!
//
// 8. TweenAnimationBuilder:
//    - Creates smooth animations between two values
//    - 'Tween' = in-between (animates from start to end)
//    - Curve controls animation speed (linear, ease, bounce, etc.)
//    - Builder function is called repeatedly during animation
//    - IMPORTANT: Use .clamp(0.0, 1.0) on opacity to prevent crashes
//    - Some curves can produce values outside 0.0-1.0 range
//
// ══════════════════════════════════════════════════════════════════════════════