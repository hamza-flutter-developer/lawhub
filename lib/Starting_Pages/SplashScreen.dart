// ══════════════════════════════════════════════════════════════════════════════
// FILE: SplashScreen.dart
// PURPOSE: First screen shown when app launches - displays logo and loading animation
// ══════════════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:lawhub/Starting_Pages/GetStartPage.dart';
import 'package:lawhub/main.dart';
import 'package:lawhub/widgets/Fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// SplashScreen Widget (StatefulWidget)
/// ═══════════════════════════════════════════════════════════════════════════
/// This is the first screen users see when opening the app.
/// StatefulWidget is used because we need to:
/// - Track time passing (5 second timer)
/// - Navigate to next screen automatically
/// - Potentially update UI during the splash (like loading progress)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

/// ═══════════════════════════════════════════════════════════════════════════
/// SplashScreen State Class
/// ═══════════════════════════════════════════════════════════════════════════
/// This class manages the SplashScreen's behavior and lifecycle
class _SplashScreenState extends State<SplashScreen> {

  // ─────────────────────────────────────────────────────────────────────────
  // LIFECYCLE: initState()
  // ─────────────────────────────────────────────────────────────────────────
  /// initState() runs ONCE when the widget is first created
  /// Think of it like the "startup" function for this screen
  /// Perfect place to start timers, load data, or setup listeners
  @override
  void initState() {
    super.initState(); // Always call this first - it initializes the parent class

    // ═══ TIMER LOGIC (Your existing logic - UNCHANGED) ═══
    // Timer.Duration creates a countdown
    // After 5 seconds, the function inside Timer() runs
    Timer(const Duration(seconds: 5), () {
      // Navigator.pushReplacement removes current screen and shows new one
      // This prevents user from going "back" to splash screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const GetStart(), // Next screen to show
        ),
      );
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD METHOD - Creates the UI
  // ─────────────────────────────────────────────────────────────────────────
  /// build() is called every time the UI needs to update
  /// It returns a Widget tree that describes what should appear on screen
  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive design
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // Scaffold provides basic app structure (app bar, body, etc.)

      // ═══════════════════════════════════════════════════════════════════════
      // MODERN GRADIENT BACKGROUND
      // ═══════════════════════════════════════════════════════════════════════
      /// Container with gradient instead of solid color for modern look
      body: Container(
        width: double.infinity,  // Full screen width
        height: double.infinity, // Full screen height

        // ── Modern Gradient Background ──
        // Creates a smooth color transition from top to bottom
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            // begin/end control the gradient direction
            begin: Alignment.topLeft,     // Start from top-left corner
            end: Alignment.bottomRight,   // End at bottom-right corner
            colors: [
              Color(0xFF1E88E5), // Light blue at top
              Color(0xFF1565C0), // Medium blue in middle
              Color(0xFF0D47A1), // Dark blue at bottom
            ],
            // stops control where each color appears (0.0 = start, 1.0 = end)
            stops: [0.0, 0.5, 1.0],
          ),
        ),

        // ═══════════════════════════════════════════════════════════════════════
        // CENTERED CONTENT WITH MODERN ANIMATIONS
        // ═══════════════════════════════════════════════════════════════════════
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Centers vertically
            children: [
              // ── Animated Logo Container ──
              // TweenAnimationBuilder creates smooth animations
              // It animates from 0.0 to 1.0 over 1.5 seconds
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1500), // Animation length
                tween: Tween(begin: 0.0, end: 1.0), // From invisible to fully visible
                curve: Curves.easeOutBack, // Smooth bounce animation curve
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value, // Scales from 0 (invisible) to 1 (full size)
                    child: Opacity(
                      opacity: value.clamp(0.0, 1.0), // Clamp to valid range (0.0 to 1.0)
                      child: child,
                    ),
                  );
                },
                // ── Logo Content ──
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    // Semi-transparent white background behind logo
                    color: Colors.white.withAlpha((255 * 0.15).round()),
                    borderRadius: BorderRadius.circular(30),
                    // Soft shadow for depth
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((255 * 0.1).round()),
                        blurRadius: 30,
                        spreadRadius: 0,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const LogoFont(
                    text: "LAWHUB",
                    textColor: Colors.white,
                  ),
                ),
              ),

              // ── Spacing between logo and loading indicator ──
              SizedBox(height: screenHeight * 0.08),

              // ── Modern Loading Indicator ──
              // SpinKitCircle is your existing loading animation
              // Wrapped in a container with glow effect
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // Glowing effect behind the spinner
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withAlpha((255 * 0.3).round()),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const SpinKitCircle(
                  color: Colors.white,
                  size: 50, // Slightly larger for better visibility
                ),
              ),

              // ── Loading Text with Fade Animation ──
              SizedBox(height: screenHeight * 0.03),

              // Another animation for the loading text
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 2000),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: Curves.easeIn,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value.clamp(0.0, 1.0), // Clamp to valid range
                    child: child,
                  );
                },
                child: Text(
                  'Legal Solutions at Your Fingertips',
                  style: TextStyle(
                    color: Colors.white.withAlpha((255 * 0.9).round()),
                    fontSize: 16,
                    fontFamily: 'roboto',
                    fontWeight: FontWeight.w300,
                    letterSpacing: 1.2, // Spacing between letters for elegance
                  ),
                  textAlign: TextAlign.center,
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
// 1. StatefulWidget vs StatelessWidget:
//    - StatefulWidget can change over time (has mutable state)
//    - StatelessWidget is immutable (cannot change)
//    - Use Stateful when you need timers, animations, user input
//
// 2. initState():
//    - Runs ONCE when widget is created
//    - Perfect for starting timers, loading data, subscribing to streams
//
// 3. Navigator:
//    - Manages screen navigation (like pages in a book)
//    - push() = go to new screen (can go back)
//    - pushReplacement() = replace current screen (cannot go back)
//
// 4. MediaQuery:
//    - Gets device information (screen size, orientation, etc.)
//    - Use for responsive design that works on all devices
//
// 5. TweenAnimationBuilder:
//    - Creates smooth animations between two values
//    - 'Tween' = in-between (animates from start to end)
//    - Curve controls animation speed (linear, ease, bounce, etc.)
//
// 6. BoxDecoration:
//    - Decorates containers with colors, gradients, borders, shadows
//    - LinearGradient creates smooth color transitions
//
// 7. Opacity & Transform:
//    - Opacity controls transparency (0.0 = invisible, 1.0 = solid)
//    - Transform.scale changes size (0.5 = half size, 2.0 = double size)
//
// ══════════════════════════════════════════════════════════════════════════════