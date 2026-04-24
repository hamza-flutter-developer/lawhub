// ══════════════════════════════════════════════════════════════════════════════
// FILE: UserSignup.dart
// PURPOSE: User profile completion screen - collects DOB and location
// ══════════════════════════════════════════════════════════════════════════════

// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lawhub/Utils/Utilities.dart';
import 'package:lawhub/model/Province_City.dart';
import 'package:lawhub/services/Province_City.dart';
import 'package:lawhub/widgets/Fonts.dart';
import 'package:lawhub/widgets/Themes.dart';
import '../User_Pages/UserAppBar&NavBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// UserSignup Widget (StatefulWidget)
/// ═══════════════════════════════════════════════════════════════════════════
/// Collects basic profile details for regular users:
/// - Date of birth
/// - Province and City location
/// - Saves data to Firestore Users collection
///
/// Simpler than LawyerSignup (no license, expertise, etc.)
class UserSignup extends StatefulWidget {
  final String email;
  final String name;
  final String password;
  const UserSignup({
    super.key,
    required this.email,
    required this.name,
    required this.password,
  });

  @override
  State<UserSignup> createState() => _UserSignupState();
}

class _UserSignupState extends State<UserSignup>
    with SingleTickerProviderStateMixin {
  // ─────────────────────────────────────────────────────────────────────────
  // FIRESTORE REFERENCE
  // ─────────────────────────────────────────────────────────────────────────
  /// Direct reference to Users collection in Firestore
  final fireStore = FirebaseFirestore.instance.collection('Users');

  // ─────────────────────────────────────────────────────────────────────────
  // VALIDATION HELPERS
  // ─────────────────────────────────────────────────────────────────────────
  bool isPhoneValid = false;

  bool _isValidPhoneNumber(String phoneNumber) {
    RegExp phoneRegExp = RegExp(r'^\+\d{12}$');
    return phoneRegExp.hasMatch(phoneNumber);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DATE OF BIRTH STATE
  // ─────────────────────────────────────────────────────────────────────────
  List<String> dob = [];
  DateTime _dateTime = DateTime.now();
  var isSelected = true;

  /// ───────────────────────────────────────────────────────────────────────
  /// FUNCTION: _showDatePicker()
  /// PURPOSE: Shows date picker dialog and saves selected date
  /// ───────────────────────────────────────────────────────────────────────
  void _showDatePicker() {
    showDatePicker(
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.highContrastLight(
              primary: Color(0xFF1565C0),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF1565C0),
              ),
            ),
          ),
          child: child!,
        );
      },
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1980),
      lastDate: DateTime.now(),
    ).then((value) {
      setState(() {
        _dateTime = value!;
        isSelected = false;
        dob.clear();
        dob.add(_dateTime.day.toString());
        dob.add(_dateTime.month.toString());
        dob.add(_dateTime.year.toString());
      });
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PROVINCE & CITY STATE
  // ─────────────────────────────────────────────────────────────────────────
  List<Provinces> provinceList = [];
  List<City> citiesList = [];
  List<City> tempList = []; // Filtered cities based on province

  String? province;
  String? cities;
  String? provinceText;
  String? cityText;

  var isLoading = true; // Loading province/city data
  var isProvinceSelected = true;
  var isCitySelected = true;
  bool isDataLoading = false; // Submitting form data

  // Animation controller
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // ═════════════════════════════════════════════════════════════════════════
  // INITIALIZATION
  // ═════════════════════════════════════════════════════════════════════════

  /// ───────────────────────────────────────────────────────────────────────
  /// FUNCTION: populateDropDown()
  /// PURPOSE: Loads province and city data from service
  /// ───────────────────────────────────────────────────────────────────────
  populateDropDown() async {
    Temperatures data = await getData();
    provinceList = data.province;
    citiesList = data.cities;
    isLoading = false;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    populateDropDown();

    /// Setup animations
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
    _animationController.dispose();
    super.dispose();
  }

  // ═════════════════════════════════════════════════════════════════════════
  // FIRESTORE DATA INSERTION - YOUR EXISTING LOGIC (UNCHANGED)
  // ═════════════════════════════════════════════════════════════════════════

  /// ───────────────────────────────────────────────────────────────────────
  /// FUNCTION: insertDataEmail()
  /// PURPOSE: Saves user profile to Firestore (email signup)
  /// ───────────────────────────────────────────────────────────────────────
  void insertDataEmail() {
    fireStore.doc(widget.email).set({
      'id': widget.email,
      'emailPhone': widget.email,
      'name': widget.name,
      'dob': dob,
      'province': provinceText,
      'city': cityText,
      'profilePic': 'null',
    }).then((value) => {
      setState(() {
        isDataLoading = false;
      }),
      Utilities().successMsg('Successfully Registered'),
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const UserAppBarNavBar())),
    })
        .onError((error, stackTrace) => {
      setState(() {
        isDataLoading = false;
      }),
      Utilities().errorMsg(error.toString()),
    });
  }

  /// ───────────────────────────────────────────────────────────────────────
  /// FUNCTION: insertDataPhone()
  /// PURPOSE: Saves user profile to Firestore (phone signup)
  /// ───────────────────────────────────────────────────────────────────────
  void insertDataPhone() {
    fireStore.doc('${widget.email}@gmail.com').set({
      'id': '${widget.email}@gmail.com',
      'emailPhone': widget.email,
      'name': widget.name,
      'dob': dob,
      'province': provinceText,
      'city': cityText,
      'firstPass': widget.password,
      'password': widget.password,
      'profilePic': 'null',
    }).then((value) => {
      setState(() {
        isDataLoading = false;
      }),
      Utilities().successMsg('Successfully Registered'),
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const UserAppBarNavBar())),
    })
        .onError((error, stackTrace) => {
      setState(() {
        isDataLoading = false;
      }),
      Utilities().errorMsg(error.toString()),
    });
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
        child: Stack(
          children: [
            // ── Logo ──
            Positioned(
              top: screenHeight * 0.05,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: TopLogo(fontColor: Colors.white),
              ),
            ),

            // ═══════════════════════════════════════════════════════════════
            // MAIN CONTENT
            // ═══════════════════════════════════════════════════════════════
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
                                      "Complete Profile",
                                      style: TextStyle(
                                        fontFamily: 'patua',
                                        fontSize: 28,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1A1A1A),
                                        height: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Just a few more details to get started",
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

                              // ═════════════════════════════════════════════
                              // FORM FIELDS CONTAINER
                              // ═════════════════════════════════════════════
                              Container(
                                child: isLoading
                                    ? SizedBox(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      top: screenHeight * 0.2,
                                    ),
                                    child: const SpinKitCircle(
                                      color: Color(0xFF1565C0),
                                      size: 40,
                                    ),
                                  ),
                                )
                                    : Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.08,
                                  ),
                                  child: Column(
                                    children: [
                                      SizedBox(height: screenHeight * 0.04),

                                      // ═══════════════════════════════
                                      // DATE OF BIRTH PICKER
                                      // ═══════════════════════════════
                                      _buildSectionLabel("Date of Birth"),
                                      const SizedBox(height: 8),
                                      _buildModernDatePicker(),

                                      SizedBox(height: screenHeight * 0.03),

                                      // ═══════════════════════════════
                                      // PROVINCE DROPDOWN
                                      // ═══════════════════════════════
                                      _buildSectionLabel("Location"),
                                      const SizedBox(height: 8),
                                      _buildProvinceDropdown(),

                                      // ═══════════════════════════════
                                      // CITY DROPDOWN (conditional)
                                      // ═══════════════════════════════
                                      if (!isProvinceSelected) ...[
                                        SizedBox(height: screenHeight * 0.015),
                                        _buildCityDropdown(),
                                      ],

                                      // ═══════════════════════════════
                                      // SUBMIT BUTTON (conditional)
                                      // ═══════════════════════════════
                                      if (!isCitySelected) ...[
                                        SizedBox(height: screenHeight * 0.05),
                                        _buildSubmitButton(),
                                      ],

                                      const SizedBox(height: 30),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // UI BUILDER HELPER METHODS
  // ═════════════════════════════════════════════════════════════════════════

  /// ───────────────────────────────────────────────────────────────────────
  /// HELPER: _buildSectionLabel()
  /// PURPOSE: Creates consistent section labels
  /// ───────────────────────────────────────────────────────────────────────
  Widget _buildSectionLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'roboto',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// ───────────────────────────────────────────────────────────────────────
  /// HELPER: _buildModernDatePicker()
  /// PURPOSE: Creates modern date picker button
  /// ───────────────────────────────────────────────────────────────────────
  Widget _buildModernDatePicker() {
    return InkWell(
      onTap: _showDatePicker,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            isSelected
                ? Text(
              'Select Date of Birth',
              style: TextStyle(
                fontFamily: 'roboto',
                color: Colors.grey[400],
                fontSize: 16,
              ),
            )
                : Text(
              '${_dateTime.day}-${_dateTime.month}-${_dateTime.year}',
              style: const TextStyle(
                fontFamily: 'roboto',
                color: Colors.black87,
                fontSize: 16,
              ),
            ),
            Icon(Icons.calendar_today_rounded,
                size: 20, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  /// ───────────────────────────────────────────────────────────────────────
  /// HELPER: _buildProvinceDropdown()
  /// PURPOSE: Creates province selection dropdown
  /// ───────────────────────────────────────────────────────────────────────
  Widget _buildProvinceDropdown() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: DropdownButton<String>(
        hint: Text(
          "Select Province",
          style: TextStyle(
            fontFamily: 'roboto',
            fontSize: 16,
            color: Colors.grey[400],
          ),
        ),
        isExpanded: true,
        underline: const SizedBox(),
        value: province,
        icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
        items: provinceList.map((e) {
          return DropdownMenuItem(
            value: e.id.toString(),
            child: Text(
              e.name,
              style: const TextStyle(fontFamily: 'roboto', fontSize: 16),
            ),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            cities = null;
            province = newValue.toString();
            tempList = citiesList
                .where((element) =>
            element.provinceId.toString() == province.toString())
                .toList();
            isProvinceSelected = false;
            provinceText =
                provinceList[int.parse(province.toString()) - 1].name;
          });
        },
      ),
    );
  }

  /// ───────────────────────────────────────────────────────────────────────
  /// HELPER: _buildCityDropdown()
  /// PURPOSE: Creates city selection dropdown (shown after province selected)
  /// ───────────────────────────────────────────────────────────────────────
  Widget _buildCityDropdown() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: DropdownButton<String>(
        hint: Text(
          "Select City",
          style: TextStyle(
            fontFamily: 'roboto',
            fontSize: 16,
            color: Colors.grey[400],
          ),
        ),
        isExpanded: true,
        underline: const SizedBox(),
        value: cities,
        icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
        items: tempList.map((e) {
          return DropdownMenuItem(
            value: e.id.toString(),
            child: Text(
              e.name,
              style: const TextStyle(fontFamily: 'roboto', fontSize: 16),
            ),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            cities = newValue.toString();
            isCitySelected = false;
            cityText = tempList[int.parse(cities.toString()) - 1].name;
          });
        },
      ),
    );
  }

  /// ───────────────────────────────────────────────────────────────────────
  /// HELPER: _buildSubmitButton()
  /// PURPOSE: Creates submit button (shown after all fields filled)
  /// ───────────────────────────────────────────────────────────────────────
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isDataLoading
            ? null
            : () {
          setState(() {
            isDataLoading = true;
          });
          if (_isValidPhoneNumber(widget.email)) {
            insertDataPhone();
          } else {
            insertDataEmail();
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
        child: isDataLoading
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
              'Creating Profile...',
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
          'Complete Registration',
          style: TextStyle(
            fontFamily: 'roboto',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// KEY CONCEPTS IN THIS FILE:
// ══════════════════════════════════════════════════════════════════════════════
//
// 1. Simpler Form vs LawyerSignup:
//    - Only 3 fields: DOB, Province, City
//    - No license, expertise, or practicing years
//    - Faster registration for regular users
//
// 2. Conditional Rendering:
//    - if (!isProvinceSelected) shows city dropdown
//    - if (!isCitySelected) shows submit button
//    - Progressive disclosure improves UX
//
// 3. Reusable Helper Methods:
//    - _buildSectionLabel(): Consistent labels
//    - _buildModernDatePicker(): Date picker UI
//    - _buildProvinceDropdown(): Province dropdown
//    - _buildCityDropdown(): City dropdown
//    - _buildSubmitButton(): Submit button
//    - Reduces code duplication and improves maintainability
//
// 4. Firestore Document Structure:
//    - Users have fewer fields than Lawyers
//    - Both use same pattern: email or phone@gmail.com as doc ID
//    - profilePic initialized as 'null' string (not actual null)
//
// ══════════════════════════════════════════════════════════════════════════════