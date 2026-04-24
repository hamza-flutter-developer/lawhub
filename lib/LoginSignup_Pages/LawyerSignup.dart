// ══════════════════════════════════════════════════════════════════════════════
// FILE: LawyerSignup.dart
// PURPOSE: Lawyer profile completion screen with professional details
// ══════════════════════════════════════════════════════════════════════════════

// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lawhub/Lawyer_Pages/LawyerAppBar&NavBar.dart';
import 'package:lawhub/model/Province_City.dart';
import 'package:lawhub/services/Province_City.dart';
import 'package:lawhub/widgets/Fonts.dart';
import 'package:lawhub/widgets/Themes.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import '../Utils/Utilities.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// LawyerSignup Widget (StatefulWidget)
/// ═══════════════════════════════════════════════════════════════════════════
/// Collects professional details for lawyer accounts:
/// - Date of birth
/// - License type (Lower/High/Supreme Court)
/// - Years practicing law
/// - Areas of expertise (multi-select)
/// - Province and City location
/// - Saves all data to Firestore
class LawyerSignup extends StatefulWidget {
  final String email;
  final String name;
  final String password;
  const LawyerSignup({
    super.key,
    required this.email,
    required this.name,
    required this.password,
  });

  @override
  State<LawyerSignup> createState() => _LawyerSignupState();
}

class _LawyerSignupState extends State<LawyerSignup>
    with SingleTickerProviderStateMixin {
  // ─────────────────────────────────────────────────────────────────────────
  // FIRESTORE REFERENCE
  // ─────────────────────────────────────────────────────────────────────────
  /// Direct reference to Lawyers collection in Firestore
  /// Used for saving lawyer profile data
  final fireStore = FirebaseFirestore.instance.collection('Lawyers');

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
  /// Stores date as [day, month, year] for Firestore
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
  // LICENSE SELECTION STATE
  // ─────────────────────────────────────────────────────────────────────────
  final licenseList = [
    {'id': 1, 'name': 'Lower Court'},
    {'id': 2, 'name': 'High Court'},
    {'id': 3, 'name': 'Supreme Court'},
  ];
  String? license;
  String? licenseText;

  // ─────────────────────────────────────────────────────────────────────────
  // PRACTICING YEAR STATE
  // ─────────────────────────────────────────────────────────────────────────
  List<dynamic> yearList = [];
  String? year;
  String? practicingYear;

  // ─────────────────────────────────────────────────────────────────────────
  // EXPERTISE (MULTI-SELECT) STATE
  // ─────────────────────────────────────────────────────────────────────────
  /// List of all available practice areas
  List<String> expertiseList = [
    'Consumer Protection',
    'Harassment Law',
    'Cyber Crime',
    'Family Law',
    'Civil Law',
    'Criminal Law',
    'Real Estate',
    'Rent Law',
    'Intellectual Property',
    'Banking Law',
    'Medical Law',
    'Business Law',
    'Tax Law',
    'Immigration',
    'Constitutional Law',
    'Employment & Labour',
    'International Law',
    'Environment Law',
    'Human Rights',
    'Defamation Law',
    'Arbitration',
    'Construction Law',
  ];

  /// User's selected expertise areas
  List<String> selectedExpertise = [];

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

    /// Generate year list (2022 to 1980)
    var y = 1;
    for (var i = 2022; i >= 1980; i--) {
      yearList.add({'id': y, 'year': i});
      y++;
    }

    /// Load province/city data
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
  /// PURPOSE: Saves lawyer profile to Firestore (email signup)
  /// ───────────────────────────────────────────────────────────────────────
  void insertDataEmail() {
    fireStore.doc(widget.email).set({
      'id': widget.email,
      'emailPhone': widget.email,
      'name': widget.name,
      'dob': dob,
      'license': licenseText,
      'practicingYear': practicingYear,
      'expertise': selectedExpertise,
      'province': provinceText,
      'city': cityText,
      'profilePic': 'null',
      'aboutPractice': 'Not Set',
      'availability': [],
      'isVerified': 'Not Verified',
      'numberOfRatings': 0,
      'ratting': 0,
      'sumOfRatings': 0
    }).then((value) => {
      setState(() {
        isDataLoading = false;
      }),
      Utilities().successMsg('Successfully Registered'),
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const LawyerAppbarNavBar())),
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
  /// PURPOSE: Saves lawyer profile to Firestore (phone signup)
  /// ───────────────────────────────────────────────────────────────────────
  void insertDataPhone() {
    fireStore.doc('${widget.email}@gmail.com').set({
      'id': '${widget.email}@gmail.com',
      'emailPhone': widget.email,
      'name': widget.name,
      'dob': dob,
      'license': licenseText,
      'practicingYear': practicingYear,
      'expertise': selectedExpertise,
      'province': provinceText,
      'city': cityText,
      'firstPass': widget.password,
      'password': widget.password,
      'profilePic': 'null',
      'aboutPractice': 'Not Set',
      'availability': [],
      'isVerified': 'Not Verified',
      'numberOfRatings': 0,
      'ratting': 0,
      'sumOfRatings': 0
    }).then((value) => {
      setState(() {
        isDataLoading = false;
      }),
      Utilities().successMsg('Successfully Registered'),
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const LawyerAppbarNavBar())),
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
                                      "Provide your professional details to complete registration",
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
                                      SizedBox(height: screenHeight * 0.03),

                                      // ═══════════════════════════════
                                      // DATE OF BIRTH PICKER
                                      // ═══════════════════════════════
                                      _buildSectionLabel("Date of Birth"),
                                      const SizedBox(height: 8),
                                      _buildModernDatePicker(),

                                      SizedBox(height: screenHeight * 0.025),

                                      // ═══════════════════════════════
                                      // LICENSE DROPDOWN
                                      // ═══════════════════════════════
                                      _buildSectionLabel("License Type"),
                                      const SizedBox(height: 8),
                                      _buildModernDropdown(
                                        hint: "Select License",
                                        value: license,
                                        items: licenseList,
                                        onChanged: (newValue) {
                                          setState(() {
                                            license = newValue.toString();
                                            licenseText = licenseList[
                                            int.parse(license
                                                .toString()) -
                                                1]['name']
                                                .toString();
                                          });
                                        },
                                      ),

                                      SizedBox(height: screenHeight * 0.025),

                                      // ═══════════════════════════════
                                      // PRACTICING YEAR DROPDOWN
                                      // ═══════════════════════════════
                                      _buildSectionLabel(
                                          "Practicing Law Since"),
                                      const SizedBox(height: 8),
                                      _buildModernDropdown(
                                        hint: "Select Year",
                                        value: year,
                                        items: yearList,
                                        onChanged: (newValue) {
                                          setState(() {
                                            year = newValue.toString();
                                            practicingYear = yearList[
                                            int.parse(year
                                                .toString()) -
                                                1]['year']
                                                .toString();
                                          });
                                        },
                                      ),

                                      SizedBox(height: screenHeight * 0.025),

                                      // ═══════════════════════════════
                                      // EXPERTISE MULTI-SELECT
                                      // ═══════════════════════════════
                                      _buildSectionLabel(
                                          "Areas of Practice"),
                                      const SizedBox(height: 8),
                                      _buildModernMultiSelect(),

                                      SizedBox(height: screenHeight * 0.025),

                                      // ═══════════════════════════════
                                      // PROVINCE DROPDOWN
                                      // ═══════════════════════════════
                                      _buildSectionLabel(
                                          "Province & City"),
                                      const SizedBox(height: 8),
                                      _buildProvinceDropdown(),

                                      // ═══════════════════════════════
                                      // CITY DROPDOWN (conditional)
                                      // ═══════════════════════════════
                                      if (!isProvinceSelected) ...[
                                        SizedBox(
                                            height: screenHeight * 0.015),
                                        _buildCityDropdown(),
                                      ],

                                      // ═══════════════════════════════
                                      // SUBMIT BUTTON (conditional)
                                      // ═══════════════════════════════
                                      if (!isCitySelected) ...[
                                        SizedBox(
                                            height: screenHeight * 0.04),
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
  /// HELPER: _buildModernDropdown()
  /// PURPOSE: Creates modern dropdown with consistent styling
  /// ───────────────────────────────────────────────────────────────────────
  Widget _buildModernDropdown({
    required String hint,
    required String? value,
    required List<dynamic> items,
    required Function(String?) onChanged,
  }) {
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
          hint,
          style: TextStyle(
            fontFamily: 'roboto',
            fontSize: 16,
            color: Colors.grey[400],
          ),
        ),
        isExpanded: true,
        underline: const SizedBox(),
        value: value,
        icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
        items: items.map((e) {
          return DropdownMenuItem(
            value: e['id'].toString(),
            child: Text(
              e['name']?.toString() ?? e['year']?.toString() ?? '',
              style: const TextStyle(
                fontFamily: 'roboto',
                fontSize: 16,
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  /// ───────────────────────────────────────────────────────────────────────
  /// HELPER: _buildModernMultiSelect()
  /// PURPOSE: Creates modern multi-select field for expertise
  /// ───────────────────────────────────────────────────────────────────────
  Widget _buildModernMultiSelect() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: MultiSelectDialogField(
          items: expertiseList.map((e) => MultiSelectItem(e, e)).toList(),
          title: const Text("Select Areas of Practice"),
          buttonText: Text(
            selectedExpertise.isEmpty
                ? "Select at least 1 area"
                : "${selectedExpertise.length} area(s) selected",
            style: TextStyle(
              fontFamily: 'roboto',
              fontSize: 16,
              color: selectedExpertise.isEmpty
                  ? Colors.grey[400]
                  : Colors.black87,
            ),
          ),
          decoration: const BoxDecoration(
            border: Border(),
          ),
          buttonIcon: Icon(
            Icons.keyboard_arrow_down,
            color: Colors.grey[600],
          ),
          selectedColor: const Color(0xFF1565C0),
          searchable: true,
          onConfirm: (values) {
            setState(() {
              selectedExpertise = values.cast<String>();
            });
          },
          initialValue: selectedExpertise,
          chipDisplay: MultiSelectChipDisplay.none(),
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
            provinceText = provinceList[int.parse(province.toString()) - 1].name;
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
// 1. Complex Form Handling:
//    - Multiple dropdown menus
//    - Multi-select widget for expertise
//    - Date picker integration
//    - Conditional rendering (show city after province selected)
//
// 2. Firestore Data Structure:
//    - .set(): Creates/overwrites entire document
//    - Document ID: Uses email or phone@gmail.com
//    - Nested data: Arrays (expertise, dob) and objects stored directly
//
// 3. Multi-Select Widget:
//    - MultiSelectDialogField: Shows searchable dialog
//    - MultiSelectItem: Converts list to selectable items
//    - onConfirm: Callback when user confirms selection
//    - chipDisplay.none(): Hides selected chips (custom display instead)
//
// 4. Dependent Dropdowns:
//    - Province selection triggers city list filtering
//    - tempList stores filtered cities for current province
//    - Conditional rendering shows/hides based on selection state
//
// 5. Date Picker:
//    - showDatePicker(): Material Design date picker
//    - Theme: Customizes colors to match app design
//    - firstDate/lastDate: Restricts selectable date range
//    - .then(): Callback when date selected
//
// 6. Helper Methods Pattern:
//    - _buildModernDropdown(): Reusable dropdown builder
//    - Reduces code duplication
//    - Makes UI consistent
//    - Easier to maintain and update
//
// 7. Conditional UI:
//    - isLoading: Shows spinner while loading data
//    - isProvinceSelected: Controls city dropdown visibility
//    - isCitySelected: Controls submit button visibility
//    - Progressive disclosure: Shows next step only when ready
//
// 8. Data Validation:
//    - _isValidPhoneNumber(): Determines if signup was via phone
//    - Routes to correct insert function (phone vs email)
//    - Different data saved for phone (includes firstPass field)
//
// ══════════════════════════════════════════════════════════════════════════════