// ignore_for_file: file_names

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lawhub/User_Pages/UserLawyerProfile.dart';

// ============================================================================
// LAWYER CATEGORIES LIST
// ============================================================================
// This list contains all available legal expertise categories that users can
// filter by. Used to display category chips and filter lawyers by specialization.
final List<String> lawyerCategories = [
  'Family Law', 'Civil Law', 'Criminal Law',
  'Medical Law', 'Business Law', 'Tax Law',
  'Consumer Protection', 'Rent Law', 'Harassment Law',
  'Cyber Crime', 'Real Estate', 'Banking Law',
  'Intellectual Property', 'Immigration',
  'Constitutional Law', 'Employment & Labour',
  'International Law', 'Environment Law', 'Human Rights',
  'Defamation Law', 'Arbitration', 'Construction Law',
];

// ============================================================================
// USER HOME PAGE - MAIN WIDGET
// ============================================================================
// This is the main home page where users can:
// 1. Search for lawyers by name
// 2. Filter lawyers by legal expertise/category
// 3. View top-rated lawyers in a carousel
// 4. View nearby lawyers in their city
// ignore: must_be_immutable
class UserHomePage extends StatefulWidget {
  final Map<String, dynamic> userData;  // Logged-in user's data
  List<Map<String, dynamic>> dataList;  // Complete list of all lawyers

  UserHomePage({super.key, required this.dataList, required this.userData});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> with TickerProviderStateMixin {

  // ============================================================================
  // STATE VARIABLES
  // ============================================================================
  final TextEditingController _searchController = TextEditingController();
  late FocusNode _focusNode;  // Manages keyboard focus for search field
  bool isCancelPressed = false;  // Controls search mode visibility

  // Category filtering state
  bool isSpecificCategorySelected = false;  // True when user selects a category
  String? categorySelected;  // Currently selected category name
  List<Map<String, dynamic>> specificCategory = [];  // Filtered lawyers by category

  // Lists for different sections
  List<Map<String, dynamic>> topRattedLawyers = [];  // Top 6 highest-rated lawyers
  List<Map<String, dynamic>> nearbyLawyers = [];  // Lawyers in user's city

  // Animation controllers for smooth transitions
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // ============================================================================
  // FETCH LAWYERS BY EXPERTISE
  // ============================================================================
  // This function filters the complete lawyer list to show only lawyers who
  // specialize in the selected legal expertise/category.
  // Parameters: expertise - the legal category to filter by (e.g., "Family Law")
  void fetchLawyersByExpertise(String expertise) {
    setState(() {
      specificCategory = [];  // Clear previous results
    });

    // Loop through all lawyers in the database
    for(int i = 0; i < widget.dataList.length; i++) {
      Map<String, dynamic> itemData = widget.dataList[i];

      // Check if this lawyer has the selected expertise in their expertise list
      for(int j = 0; j < itemData['expertise'].length; j++) {
        if(itemData['expertise'][j] == expertise) {
          specificCategory.add(itemData);  // Add matching lawyer to filtered list
          break;  // No need to check other expertise for this lawyer
        }
      }
    }
  }

  // ============================================================================
  // FETCH TOP RATED LAWYERS
  // ============================================================================
  // This function sorts all lawyers by their rating (highest first) to display
  // the top-rated lawyers in the carousel slider on the home page.
  void fetchTopRatedLawyers() {
    topRattedLawyers = widget.dataList;
    // Sort in descending order (highest rating first)
    topRattedLawyers.sort((a, b) => b['ratting'].compareTo(a['ratting']));
  }

  // ============================================================================
  // FETCH NEARBY LAWYERS
  // ============================================================================
  // This function filters lawyers to show only those who practice in the same
  // city as the logged-in user. Helps users find local legal assistance.
  void fetchNearbyLawyers() {
    setState(() {
      nearbyLawyers = [];  // Clear previous results
    });

    // Loop through all lawyers
    for(int i = 0; i < widget.dataList.length; i++) {
      Map<String, dynamic> itemData = widget.dataList[i];

      // Check if lawyer's city matches user's city
      if(itemData['city'] == widget.userData['city']) {
        nearbyLawyers.add(itemData);  // Add to nearby list
      }
    }
  }

  // ============================================================================
  // INITIALIZATION
  // ============================================================================
  // Called once when the widget is created. Sets up initial data and animations.
  @override
  void initState() {
    super.initState();

    // Fetch data for different sections
    fetchTopRatedLawyers();
    fetchNearbyLawyers();

    // Initialize search field focus listener
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        // When search field is focused, enable search mode
        if(_focusNode.hasFocus) {
          isCancelPressed = true;
        }
      });
    });

    // Initialize fade animation for smooth transitions (0.0 to 1.0 over 500ms)
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    // Initialize slide animation for card entries (slides from bottom)
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  // ============================================================================
  // CLEANUP
  // ============================================================================
  // Called when widget is removed. Properly dispose of controllers to free memory.
  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  // ============================================================================
  // BUILD LAWYER CARD
  // ============================================================================
  // This function creates a reusable lawyer card widget that displays lawyer info.
  // Used in search results, category filtering, and other list views.
  // Parameters: itemData - Map containing lawyer information, index - for animation delay
  Widget _buildLawyerCard(Map<String, dynamic> itemData, int index) {
    // Calculate years of experience from practicing year
    final yearsExperience = DateTime.now().year - int.parse(itemData['practicingYear']);

    return TweenAnimationBuilder<double>(
      // Staggered animation - each card appears slightly after the previous one
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),  // Slide up animation
          child: Opacity(
            opacity: value,  // Fade in animation
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 15, right: 20, left: 20),
        child: InkWell(
          onTap: () {
            // Navigate to lawyer's detailed profile page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserLawyerProfile(
                  lawyerData: itemData,
                  userData: widget.userData,
                ),
              ),
            );
          },
          child: Container(
            width: 200,
            height: 130,  // Increased height for better spacing
            decoration: BoxDecoration(
              // Modern gradient background
              gradient: LinearGradient(
                colors: [Colors.white, Colors.blue.shade50.withOpacity(0.3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                  spreadRadius: 2,
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // Lawyer profile picture with modern styling
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Hero(
                        // Hero animation for smooth transition to profile page
                        tag: 'lawyer_${itemData['name']}_$index',
                        child: Container(
                          height: 95,
                          width: 95,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue.shade300, Colors.blue.shade600],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: const BorderRadius.all(Radius.circular(20)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: itemData['profilePic'] != 'null' && itemData['profilePic'] != null
                              ? ClipRRect(
                            borderRadius: const BorderRadius.all(Radius.circular(20)),
                            child: Image.network(
                              itemData['profilePic'],
                              height: 95,
                              width: 95,
                              fit: BoxFit.cover,
                            ),
                          )
                              : Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              FontAwesomeIcons.userTie,
                              size: 50,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Lawyer information section
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Lawyer name
                          Text(
                            itemData['name'],
                            style: const TextStyle(
                              fontFamily: 'roboto',
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Primary expertise with modern badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              itemData['expertise'][0],
                              style: TextStyle(
                                fontFamily: 'roboto',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Years of experience
                          Row(
                            children: [
                              Icon(
                                Icons.work_outline_rounded,
                                size: 16,
                                color: Colors.blue.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$yearsExperience+ Years Exp.',
                                style: TextStyle(
                                  fontFamily: 'roboto',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // City location
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                itemData['city'],
                                style: TextStyle(
                                  fontFamily: 'roboto',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),

                // Rating display with modern design
                Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 24,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          (itemData['ratting'] + 0.0).toString().substring(0, 3),
                          style: const TextStyle(
                            fontFamily: 'roboto',
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                            fontSize: 15,
                          ),
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

  // ============================================================================
  // BUILD CATEGORY CHIP
  // ============================================================================
  // Creates a modern category filter chip with smooth animations.
  // Parameters: category - category name, isSelected - whether this category is active
  Widget _buildCategoryChip(String category, bool isSelected) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0.95, end: 1.0),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                colors: [Colors.blue.shade400, Colors.blue.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
                  : null,
              color: isSelected ? null : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? Colors.blue.withOpacity(0.4)
                      : Colors.grey.withOpacity(0.2),
                  spreadRadius: isSelected ? 2 : 1,
                  blurRadius: isSelected ? 12 : 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      // Deselect category - show all sections again
                      categorySelected = null;
                      isSpecificCategorySelected = false;
                    } else {
                      // Select new category and filter lawyers
                      categorySelected = category;
                      isSpecificCategorySelected = true;
                      fetchLawyersByExpertise(category);
                    }
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontFamily: 'roboto',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================================
  // BUILD TOP RATED CAROUSEL CARD
  // ============================================================================
  // Creates a featured card for top-rated lawyers in the carousel slider.
  // Parameters: itemData - lawyer information
  Widget _buildTopRatedCard(Map<String, dynamic> itemData) {
    final yearsExperience = DateTime.now().year - int.parse(itemData['practicingYear']);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserLawyerProfile(
              lawyerData: itemData,
              userData: widget.userData,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 5),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Main profile image container with gradient overlay
            Container(
              height: 180,
              width: 280,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [Colors.blue.shade300, Colors.blue.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    spreadRadius: 3,
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Stack(
                children: [
                  // Profile picture or default icon
                  itemData['profilePic'] != 'null' && itemData['profilePic'] != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      itemData['profilePic'],
                      width: 280,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                  )
                      : Center(
                    child: Icon(
                      FontAwesomeIcons.userTie,
                      size: 80,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),

                  // Gradient overlay for better text readability
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),

                  // "Top Rated" badge
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.amber.shade300, Colors.amber.shade600],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: 1,
                          )
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.stars_rounded, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Top Rated',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Information card at the bottom (overlapping the image)
            Positioned(
              bottom: -15,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    // Lawyer name
                    Text(
                      itemData['name'],
                      style: const TextStyle(
                        fontFamily: 'roboto',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),

                    // Experience badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$yearsExperience+ Years Experience',
                        style: TextStyle(
                          fontFamily: 'roboto',
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Rating display
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          (itemData['ratting'] + 0.0).toString().substring(0, 3),
                          style: const TextStyle(
                            fontFamily: 'roboto',
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // BUILD NEARBY LAWYER GRID ITEM
  // ============================================================================
  // Creates a compact card for nearby lawyers in the grid view.
  // Parameters: itemData - lawyer information
  Widget _buildNearbyLawyerCard(Map<String, dynamic> itemData) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserLawyerProfile(
              lawyerData: itemData,
              userData: widget.userData,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue.shade50.withOpacity(0.3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Profile picture with gradient border
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade300, Colors.blue.shade600],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: itemData['profilePic'] != 'null' && itemData['profilePic'] != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  itemData['profilePic'],
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              )
                  : Center(
                child: Icon(
                  FontAwesomeIcons.userTie,
                  size: 45,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Lawyer name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                itemData['name'],
                style: const TextStyle(
                  fontFamily: 'roboto',
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 6),

            // Primary expertise
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                itemData['expertise'][0],
                style: TextStyle(
                  fontFamily: 'roboto',
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  color: Colors.blue.shade700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // BUILD METHOD - MAIN UI
  // ============================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,  // Light background
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          // FIXED: Added padding at bottom to prevent overflow with bottom nav bar
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ====================================================================
              // SEARCH BAR SECTION
              // ====================================================================
              // Modern search bar with cancel button that appears on focus
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 15),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: _focusNode.hasFocus
                                  ? Colors.blue.shade300
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: TextField(
                            controller: _searchController,
                            focusNode: _focusNode,
                            style: const TextStyle(
                              fontFamily: 'roboto',
                              fontSize: 15,
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                              border: InputBorder.none,
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(left: 15, right: 10),
                                child: Icon(
                                  Icons.search_rounded,
                                  size: 22,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              prefixIconConstraints: const BoxConstraints(minHeight: 10),
                              hintText: 'Search lawyers...',
                              hintStyle: TextStyle(
                                fontFamily: 'roboto',
                                fontSize: 15,
                                color: Colors.grey.shade500,
                              ),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.clear_rounded,
                                    size: 20,
                                    color: Colors.grey.shade600,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                                ),
                              )
                                  : null,
                              suffixIconConstraints: const BoxConstraints(minHeight: 10),
                            ),
                            onChanged: (String value) {
                              setState(() {});
                            },
                          ),
                        ),
                      ),

                      // Cancel button (appears when search is active)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: isCancelPressed ? 70 : 0,
                        child: isCancelPressed
                            ? Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: InkWell(
                            onTap: () {
                              _searchController.clear();
                              _focusNode.unfocus();
                              setState(() {
                                isCancelPressed = false;
                              });
                            },
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.blue.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                            : null,
                      ),
                    ],
                  ),
                ),
              ),

              // ====================================================================
              // SEARCH RESULTS SECTION
              // ====================================================================
              // Displays when user is actively searching or has focused search bar
              isCancelPressed
                  ? Column(
                children: [
                  // Section header
                  SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 25, top: 20, bottom: 15),
                      child: Text(
                        _searchController.text.isEmpty ? 'All Lawyers' : 'Search Results',
                        style: const TextStyle(
                          fontFamily: 'roboto',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),

                  // List of lawyers (filtered by search query or showing all)
                  ListView.builder(
                    itemBuilder: (context, index) {
                      Map<String, dynamic> itemData = widget.dataList[index];
                      final name = itemData['name'].toString();

                      // Show all lawyers if search is empty
                      if (_searchController.text.isEmpty) {
                        return _buildLawyerCard(itemData, index);
                      }
                      // Filter by name if search query exists
                      else if (name.toLowerCase().contains(
                          _searchController.text.toLowerCase())) {
                        return _buildLawyerCard(itemData, index);
                      }
                      // Hide lawyers that don't match search
                      else {
                        return Container();
                      }
                    },
                    itemCount: widget.dataList.length,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                  )
                ],
              )
              // ====================================================================
              // MAIN HOME CONTENT
              // ====================================================================
              // Shows when not in search mode
                  : Column(
                children: [
                  const SizedBox(height: 10),

                  // ================================================================
                  // CATEGORY FILTER CHIPS
                  // ================================================================
                  // Horizontal scrollable list of legal expertise categories
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    child: Row(
                      children: lawyerCategories.map((category) {
                        return _buildCategoryChip(
                          category,
                          categorySelected == category,
                        );
                      }).toList(),
                    ),
                  ),

                  // ================================================================
                  // FILTERED CATEGORY VIEW
                  // ================================================================
                  // Shows lawyers of selected category when a chip is tapped
                  if (isSpecificCategorySelected)
                    Column(
                      children: [
                        // Category section header
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(left: 25, top: 10, bottom: 15),
                          child: Row(
                            children: [
                              Icon(
                                Icons.filter_list_rounded,
                                color: Colors.blue.shade600,
                                size: 24,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                categorySelected!,
                                style: const TextStyle(
                                  fontFamily: 'roboto',
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // List of lawyers in selected category
                        specificCategory.isNotEmpty
                            ? ListView.builder(
                          itemBuilder: (context, index) {
                            Map<String, dynamic> itemData = specificCategory[index];
                            return _buildLawyerCard(itemData, index);
                          },
                          itemCount: specificCategory.length,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                        )
                        // Empty state when no lawyers found in category
                            : Padding(
                          padding: const EdgeInsets.all(30),
                          child: Column(
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 60,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 15),
                              Text(
                                'No lawyers available',
                                style: TextStyle(
                                  fontFamily: 'roboto',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Try selecting a different category',
                                style: TextStyle(
                                  fontFamily: 'roboto',
                                  fontSize: 14,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    )
                  // ================================================================
                  // DEFAULT HOME VIEW (NO CATEGORY SELECTED)
                  // ================================================================
                  // Shows top-rated lawyers carousel and nearby lawyers grid
                  else
                    SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          // ============================================================
                          // TOP RATED LAWYERS SECTION
                          // ============================================================
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.only(left: 25, top: 10, bottom: 5),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.stars_rounded,
                                  color: Colors.amber.shade600,
                                  size: 26,
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  "Top Rated Lawyers",
                                  style: TextStyle(
                                    fontFamily: 'roboto',
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Carousel slider showing top 6 lawyers
                          CarouselSlider.builder(
                            itemCount: topRattedLawyers.length > 6 ? 6 : topRattedLawyers.length,
                            itemBuilder: (context, index, realIndex) {
                              Map<String, dynamic> itemData = topRattedLawyers[index];
                              return _buildTopRatedCard(itemData);
                            },
                            options: CarouselOptions(
                              height: 300,
                              autoPlay: true,
                              enlargeCenterPage: true,
                              enableInfiniteScroll: topRattedLawyers.length > 1,
                              autoPlayInterval: const Duration(seconds: 4),
                              autoPlayAnimationDuration: const Duration(milliseconds: 1000),
                              autoPlayCurve: Curves.easeInOutCubic,
                              viewportFraction: 0.85,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ============================================================
                          // NEARBY LAWYERS SECTION
                          // ============================================================
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.only(left: 25, bottom: 15),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on_rounded,
                                  color: Colors.blue.shade600,
                                  size: 26,
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  "Nearby You",
                                  style: TextStyle(
                                    fontFamily: 'roboto',
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Grid view of lawyers in user's city
                          nearbyLawyers.isNotEmpty
                              ? GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.85,
                              crossAxisSpacing: 5,
                              mainAxisSpacing: 5,
                            ),
                            itemCount: nearbyLawyers.length,
                            itemBuilder: (context, index) {
                              Map<String, dynamic> itemData = nearbyLawyers[index];
                              return _buildNearbyLawyerCard(itemData);
                            },
                          )
                          // Empty state when no nearby lawyers found
                              : Padding(
                            padding: const EdgeInsets.all(30),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.location_off_rounded,
                                  size: 60,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  'No lawyers nearby',
                                  style: TextStyle(
                                    fontFamily: 'roboto',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Try searching in other areas',
                                  style: TextStyle(
                                    fontFamily: 'roboto',
                                    fontSize: 14,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // FIXED: Extra padding at the very bottom to prevent overflow
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}