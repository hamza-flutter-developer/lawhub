// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lawhub/Article_Pages/ArticlesView.dart';
import 'package:lawhub/User_Pages/UserSendRequest.dart';

import '../Utils/Utilities.dart';

// ============================================================================
// COMMENTS DATA MODEL
// ============================================================================
// This class represents a single feedback/comment from a user about a lawyer.
// It stores the user's profile image, name, and their comment text.
class Comments {
  final String imageUrl;     // User's profile picture URL
  final String userName;      // User's display name
  final String userComment;   // The actual feedback text

  Comments({required this.imageUrl, required this.userName, required this.userComment});
}

// ============================================================================
// USER LAWYER PROFILE - MAIN WIDGET
// ============================================================================
// This page displays detailed information about a specific lawyer including:
// - Profile picture and basic info
// - License, expertise, experience, location
// - Practice description and articles
// - Availability schedule
// - Feedback/reviews from other users
// - Options to add to favorites or send consultation request
class UserLawyerProfile extends StatefulWidget{
  final Map<String, dynamic> userData;    // Logged-in user's information
  final Map<String, dynamic> lawyerData;  // Selected lawyer's complete data

  const UserLawyerProfile({Key? key, required this.lawyerData, required this.userData}) : super(key: key);

  @override
  State<UserLawyerProfile> createState() => _UserLawyerProfileState();
}

class _UserLawyerProfileState extends State<UserLawyerProfile> with SingleTickerProviderStateMixin {

  // Firebase reference for favorites collection
  final fireStore = FirebaseFirestore.instance.collection('Favourite');

  // ============================================================================
  // STATE VARIABLES
  // ============================================================================

  // Request state tracking
  bool isRequestSent = false;      // TRUE if user already sent consultation request
  bool isLoadingRequest = false;   // TRUE while checking request status

  // Favorite state tracking
  bool isLoadingFavourite = false; // TRUE while adding/removing from favorites
  bool isFavouriteAdded = false;   // TRUE if lawyer is in user's favorites

  // Feedback state tracking
  bool isFeedbacksAvailable = false;  // TRUE if lawyer has any reviews
  List<Comments> feedbacks = [];       // List of all feedback comments

  // Data storage
  late Map<String, dynamic> favDataList;  // User's complete favorites list

  // Animation controller for smooth page transitions
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // ============================================================================
  // CHECK FAVOURITE LAWYERS
  // ============================================================================
  // This function checks if the current lawyer is already in the user's
  // favorites list. It fetches the user's favorites from Firebase and
  // searches for a match with the current lawyer's ID.
  Future<void> checkFavouriteLawyers() async {
    // Check if user has a favorites document in Firebase
    var documentCheck = await FirebaseFirestore.instance
        .collection('Favourite')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get();

    if(!documentCheck.exists) {
      // User has no favorites yet
      setState(() {
        isFavouriteAdded = false;
        isLoadingFavourite = false;
      });
    }
    else {
      // User has favorites - fetch and check if this lawyer is included
      fetchAllFavouriteLawyerData().then((data) {
        setState(() {
          favDataList = data;
          // Loop through all favorite lawyer IDs
          for (int i = 1; i <= favDataList['counter']; i++) {
            String lawyerId = favDataList['LawyerID$i'];
            if(lawyerId == widget.lawyerData['id']) {
              // Found a match - this lawyer is favorited
              setState(() {
                isFavouriteAdded = true;
                isLoadingFavourite = false;
              });
              break;
            }
            // If we've checked all and no match found
            if(i > favDataList['counter']) {
              setState(() {
                isFavouriteAdded = false;
                isLoadingFavourite = false;
              });
            }
          }
          setState(() {
            isLoadingFavourite = false;
          });
        });
      });
    }
  }

  // ============================================================================
  // FETCH ALL FAVOURITE LAWYER DATA
  // ============================================================================
  // Retrieves the complete favorites document for the current user from Firebase.
  // Returns a Map containing all favorite lawyer IDs and a counter.
  Future<Map<String, dynamic>> fetchAllFavouriteLawyerData() async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('Favourite')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get();

    Map<String, dynamic> favLawyerData = userSnapshot.data() as Map<String, dynamic>;
    return favLawyerData;
  }

  // ============================================================================
  // ADD FIRST FAVOURITE
  // ============================================================================
  // Creates a new favorites document for users who haven't favorited anyone yet.
  // Initializes the counter to 0.
  void addFirstFavourite() {
    fireStore.doc(widget.userData['id']).set({'counter': 0});
  }

  // ============================================================================
  // ADD TO FAVOURITE
  // ============================================================================
  // Adds the current lawyer to the user's favorites list in Firebase.
  // First checks if lawyer is already favorited to prevent duplicates.
  void addToFavourite() async {
    var documentCheck = await FirebaseFirestore.instance
        .collection('Favourite')
        .doc(widget.userData['id'])
        .get();

    int counter = documentCheck['counter'];
    bool furterPorcess = true;

    // Check if lawyer is already in favorites
    for(int i = 1; i <= counter; i++) {
      if(documentCheck['LawyerID$i'] == widget.lawyerData['id']) {
        setState(() {
          isLoadingFavourite = false;
        });
        Utilities().errorMsg('Already added to Favourite');
        furterPorcess = false;
        break;
      }
    }

    // If not duplicate, proceed to add
    if(furterPorcess) {
      counter++;  // Increment the counter
      DocumentReference documentReference = fireStore.doc(widget.userData['id']);

      // Update Firebase with new favorite
      await documentReference.update({
        'LawyerID$counter': widget.lawyerData['id'],
        'counter': counter,
      }).then((value) => {
        setState(() {
          isLoadingFavourite = false;
          isFavouriteAdded = true;
        }),
        Utilities().successMsg('Added to Favourite'),
      }).onError((error, stackTrace) => {
        setState(() {
          isLoadingFavourite = false;
        }),
        Utilities().errorMsg('Something Went Wrong'),
      });
    }
  }

  // ============================================================================
  // DELETE FROM FAVOURITE
  // ============================================================================
  // Removes the current lawyer from user's favorites list.
  // If this is the only favorite, deletes the entire document.
  // Otherwise, reorganizes the remaining favorites and updates Firebase.
  void deleteFromFavourite() async {
    var documentSnapshot = await FirebaseFirestore.instance
        .collection('Favourite')
        .doc(widget.userData['id'])
        .get();

    int counter = documentSnapshot['counter'];

    // If this is the only favorite, delete the entire document
    if (counter == 1) {
      String lawyerId = favDataList['LawyerID1'];
      if (lawyerId == widget.lawyerData['id']) {
        await FirebaseFirestore.instance
            .collection('Favourite')
            .doc(widget.userData['id'])
            .delete();
      }
    }
    else {
      // Multiple favorites - need to reorganize the list
      Map<String, dynamic> favDataList = await fetchAllFavouriteLawyerData();

      // Delete old document
      FirebaseFirestore.instance
          .collection('Favourite')
          .doc(widget.userData['id'])
          .delete();

      // Create new document
      addFirstFavourite();

      // Re-add all favorites except the deleted one
      int controller = 1;
      for (int i = 1; i <= counter; i++) {
        String lawyerId = favDataList['LawyerID$i'];
        if (lawyerId == widget.lawyerData['id']) {
          continue;  // Skip the lawyer we're removing
        } else {
          DocumentReference documentReference = FirebaseFirestore.instance
              .collection('Favourite')
              .doc(widget.userData['id']);
          await documentReference.update({
            'LawyerID$controller': lawyerId,
            'counter': controller,
          });
          controller++;
        }
      }
    }

    setState(() {
      isLoadingFavourite = false;
      isFavouriteAdded = false;
    });

    Utilities().successMsg('Removed from Favourite');
  }

  // ============================================================================
  // CHECK REQUEST
  // ============================================================================
  // Checks if user has already sent a consultation request to this lawyer.
  // Looks through all requests sent to the lawyer to find a match with user ID.
  Future<void> checkRequest() async {
    var documentCheck = await FirebaseFirestore.instance
        .collection('Requests')
        .doc(widget.lawyerData['id'])
        .get();

    if (!documentCheck.exists) {
      // Lawyer has no requests yet
      setState(() {
        isLoadingRequest = false;
        isRequestSent = false;
      });
    } else {
      // Lawyer has requests - check if one is from current user
      fetchAllRequests().then((data) {
        setState(() {
          int counter = data['counter'];
          for (int i = 1; i <= counter; i++) {
            if(data['Request$i'][0]['userID'] == widget.userData['id']) {
              isRequestSent = true;  // Found user's request
              break;
            }
          }
          isLoadingRequest = false;
        });
      }).catchError((error) {
        setState(() {
          isLoadingRequest = false;
          isRequestSent = false;
        });
      });
    }
  }

  // ============================================================================
  // FETCH ALL REQUESTS
  // ============================================================================
  // Retrieves all consultation requests sent to this lawyer from Firebase.
  Future<DocumentSnapshot> fetchAllRequests() async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('Requests')
        .doc(widget.lawyerData['id'])
        .get();
    return userSnapshot;
  }

  // ============================================================================
  // FETCH FEEDBACK USER IMAGE
  // ============================================================================
  // Gets the profile picture URL for a user who left feedback.
  // Used to display user avatars next to their comments.
  Future<String> fetchFeedbackUserImage(String id) async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(id)
        .get();
    return userSnapshot['profilePic'];
  }

  // ============================================================================
  // FETCH FEEDBACK USER NAME
  // ============================================================================
  // Gets the display name for a user who left feedback.
  Future<String> fetchFeedbackUserName(String id) async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(id)
        .get();
    return userSnapshot['name'];
  }

  // ============================================================================
  // FETCH FEEDBACKS
  // ============================================================================
  // Retrieves all feedback/reviews for this lawyer from Firebase.
  // For each feedback, fetches the reviewer's name and profile picture.
  // Builds a list of Comments objects to display in the UI.
  Future<void> fetchFeedbacks() async {
    var docCheck = await FirebaseFirestore.instance
        .collection('LawyersFeedbacks')
        .doc(widget.lawyerData['id'])
        .get();

    if(docCheck.exists) {
      int counter = docCheck['counter'];
      // Loop through all feedbacks
      for(int i = 1; i <= counter; i++) {
        String feedback = docCheck['Feedback$i']['feedback'];

        // Fetch user details for this feedback
        fetchFeedbackUserImage(docCheck['Feedback$i']['userId']).then((imgUrl) {
          fetchFeedbackUserName(docCheck['Feedback$i']['userId']).then((name) {
            // Create Comments object and add to list
            feedbacks.add(Comments(
                imageUrl: imgUrl,
                userName: name,
                userComment: feedback
            ));

            // When all feedbacks loaded, update UI
            if(feedbacks.length == counter) {
              setState(() {
                isFeedbacksAvailable = true;
              });
            }
          });
        });
      }
    }
    else {
      // No feedbacks exist for this lawyer
      setState(() {
        isFeedbacksAvailable = false;
      });
    }
  }

  // ============================================================================
  // INITIALIZATION
  // ============================================================================
  // Called once when page loads. Fetches all necessary data and starts animations.
  @override
  void initState() {
    super.initState();

    // Set loading states
    isLoadingFavourite = true;
    isLoadingRequest = true;

    // Fetch data from Firebase
    checkFavouriteLawyers();
    checkRequest();
    fetchFeedbacks();

    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    _animationController.forward();
  }

  // ============================================================================
  // CLEANUP
  // ============================================================================
  // Dispose of animation controller when page is closed.
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ============================================================================
  // BUILD INFO CARD
  // ============================================================================
  // Creates a reusable information card with label and value.
  // Used for displaying lawyer details like license, experience, etc.
  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.blue.shade50.withOpacity(0.3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade300, Colors.blue.shade500],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'roboto',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'roboto',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // BUILD SECTION HEADER
  // ============================================================================
  // Creates a modern section header with icon and title.
  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 25, top: 20, bottom: 15),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade300, Colors.blue.shade600],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'roboto',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // BUILD METHOD - MAIN UI
  // ============================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Modern gradient background instead of solid blue
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade600,
              Colors.blue.shade400,
            ],
          ),
        ),
        child: Stack(
          children: [
            // ====================================================================
            // MAIN SCROLLABLE CONTENT
            // ====================================================================
            SingleChildScrollView(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Stack(
                    children: [
                      // ============================================================
                      // WHITE CONTENT CONTAINER
                      // ============================================================
                      Container(
                        margin: const EdgeInsets.only(top: 180),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(35),
                            topRight: Radius.circular(35),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 5,
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 80),

                            // ========================================================
                            // LAWYER NAME
                            // ========================================================
                            Text(
                              widget.lawyerData['name'],
                              style: const TextStyle(
                                fontFamily: 'roboto',
                                fontWeight: FontWeight.bold,
                                fontSize: 26,
                                color: Colors.black87,
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Rating badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.amber.shade300, Colors.amber.shade500],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.amber.withOpacity(0.3),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  )
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star_rounded, color: Colors.white, size: 20),
                                  const SizedBox(width: 5),
                                  Text(
                                    (widget.lawyerData['ratting'] + 0.0).toString().substring(0, 3),
                                    style: const TextStyle(
                                      fontFamily: 'roboto',
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  const Text(
                                    'Rating',
                                    style: TextStyle(
                                      fontFamily: 'roboto',
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 30),

                            // ========================================================
                            // ABOUT ME SECTION
                            // ========================================================
                            _buildSectionHeader('About Me', Icons.person_outline_rounded),

                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                children: [
                                  // License info
                                  _buildInfoCard(
                                    'License Number',
                                    widget.lawyerData['license'],
                                    Icons.badge_outlined,
                                  ),

                                  // Expertise info with chips
                                  Container(
                                    padding: const EdgeInsets.all(15),
                                    margin: const EdgeInsets.only(bottom: 15),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Colors.white, Colors.blue.shade50.withOpacity(0.3)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blue.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                          spreadRadius: 1,
                                        )
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [Colors.blue.shade300, Colors.blue.shade500],
                                                ),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: const Icon(Icons.gavel_rounded, color: Colors.white, size: 24),
                                            ),
                                            const SizedBox(width: 15),
                                            Text(
                                              'Expertise',
                                              style: TextStyle(
                                                fontFamily: 'roboto',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: widget.lawyerData['expertise'].map<Widget>((expertise) {
                                            return Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.shade100,
                                                borderRadius: BorderRadius.circular(15),
                                                border: Border.all(color: Colors.blue.shade300, width: 1),
                                              ),
                                              child: Text(
                                                expertise,
                                                style: TextStyle(
                                                  fontFamily: 'roboto',
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.blue.shade700,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Experience info
                                  _buildInfoCard(
                                    'Experience',
                                    '${DateTime.now().year - int.parse(widget.lawyerData['practicingYear'])}+ Years',
                                    Icons.work_outline_rounded,
                                  ),

                                  // Location info
                                  _buildInfoCard(
                                    'Location',
                                    '${widget.lawyerData['province']} - ${widget.lawyerData['city']}',
                                    Icons.location_on_outlined,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // ========================================================
                            // ABOUT MY PRACTICE SECTION
                            // ========================================================
                            _buildSectionHeader('About My Practice', Icons.description_outlined),

                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.white, Colors.blue.shade50.withOpacity(0.3)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                      spreadRadius: 1,
                                    )
                                  ],
                                ),
                                child: Text(
                                  widget.lawyerData['aboutPractice'],
                                  style: const TextStyle(
                                    fontFamily: 'roboto',
                                    fontSize: 15,
                                    height: 1.5,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),

                            // Articles button
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ArticleView(
                                          isUser: true,
                                          userData: widget.lawyerData,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.article_outlined, size: 20),
                                  label: const Text('View Articles'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade600,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    elevation: 3,
                                  ),
                                ),
                              ),
                            ),

                            // ========================================================
                            // AVAILABILITY SECTION
                            // ========================================================
                            _buildSectionHeader('Availability', Icons.calendar_today_outlined),

                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: widget.lawyerData['availability'].toString() == '[]'
                                  ? Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: Colors.grey.shade300, width: 1),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.info_outline, color: Colors.grey.shade500),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Availability not set',
                                      style: TextStyle(
                                        fontFamily: 'roboto',
                                        fontSize: 15,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                                  : Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.white, Colors.blue.shade50.withOpacity(0.3)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                      spreadRadius: 1,
                                    )
                                  ],
                                ),
                                child: Column(
                                  children: widget.lawyerData['availability'].map<Widget>((slot) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Colors.grey.shade200,
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.calendar_month_rounded,
                                                size: 20,
                                                color: Colors.blue.shade600,
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                slot['day'],
                                                style: const TextStyle(
                                                  fontFamily: 'roboto',
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade100,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              slot['timeSlot'],
                                              style: TextStyle(
                                                fontFamily: 'roboto',
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.blue.shade700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),

                            const SizedBox(height: 30),

                            // ========================================================
                            // FAVORITE BUTTON
                            // ========================================================
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    setState(() {
                                      isLoadingFavourite = true;
                                    });

                                    if (isFavouriteAdded) {
                                      deleteFromFavourite();
                                    } else {
                                      var documentCheck = await FirebaseFirestore.instance
                                          .collection('Favourite')
                                          .doc(widget.userData['id'])
                                          .get();

                                      if (documentCheck.exists) {
                                        addToFavourite();
                                      } else {
                                        addFirstFavourite();
                                        addToFavourite();
                                      }
                                    }
                                  },
                                  icon: isLoadingFavourite
                                      ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                      : Icon(
                                    isFavouriteAdded ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                    size: 22,
                                  ),
                                  label: Text(
                                    isLoadingFavourite
                                        ? 'Loading...'
                                        : isFavouriteAdded
                                        ? 'Remove from Favorites'
                                        : 'Add to Favorites',
                                    style: const TextStyle(
                                      fontFamily: 'roboto',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isFavouriteAdded ? Colors.red.shade400 : Colors.blue.shade600,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    elevation: 5,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 30),

                            // ========================================================
                            // FEEDBACKS SECTION
                            // ========================================================
                            if (isFeedbacksAvailable) ...[
                              _buildSectionHeader('Client Feedbacks', Icons.rate_review_outlined),

                              ListView.builder(
                                itemBuilder: (context, index) {
                                  var itemData = feedbacks[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 15, right: 20, left: 20),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [Colors.white, Colors.blue.shade50.withOpacity(0.2)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.blue.withOpacity(0.1),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          )
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(15),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // User avatar
                                            Container(
                                              width: 50,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [Colors.blue.shade300, Colors.blue.shade500],
                                                ),
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.blue.withOpacity(0.3),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 3),
                                                  )
                                                ],
                                              ),
                                              child: itemData.imageUrl == 'null' || itemData.imageUrl == null
                                                  ? const Icon(Icons.person, color: Colors.white, size: 30)
                                                  : ClipOval(
                                                child: Image.network(
                                                  itemData.imageUrl,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 15),

                                            // Feedback content
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    itemData.userName,
                                                    style: const TextStyle(
                                                      fontFamily: 'roboto',
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    itemData.userComment,
                                                    style: TextStyle(
                                                      fontFamily: 'roboto',
                                                      fontSize: 14,
                                                      height: 1.4,
                                                      color: Colors.grey.shade700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                itemCount: feedbacks.length,
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                              ),
                            ],

                            // Bottom padding to prevent content cutting off
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),

                      // ============================================================
                      // PROFILE PICTURE (FLOATING)
                      // ============================================================
                      SizedBox(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 110),
                              height: 140,
                              width: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [Colors.blue.shade300, Colors.blue.shade600],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                    spreadRadius: 2,
                                  )
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: widget.lawyerData['profilePic'] != 'null' && widget.lawyerData['profilePic'] != null
                                    ? ClipOval(
                                  child: Image.network(
                                    widget.lawyerData['profilePic'],
                                    fit: BoxFit.cover,
                                    filterQuality: FilterQuality.high,
                                  ),
                                )
                                    : Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    size: 70,
                                    color: Colors.grey,
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
              ),
            ),

            // ====================================================================
            // TOP APP BAR
            // ====================================================================
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 10,
                  bottom: 10,
                  left: 10,
                  right: 10,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade600, Colors.blue.shade400],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),

                    // App title
                    const Text(
                      "LAWHUB",
                      style: TextStyle(
                        fontFamily: "patua",
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),

                    // Request button
                    isLoadingRequest
                        ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SpinKitCircle(color: Colors.white, size: 24),
                    )
                        : IconButton(
                      onPressed: () {
                        if (isRequestSent) {
                          Utilities().errorMsg('Your request has already been submitted');
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserSendRequest(
                                userData: widget.userData,
                                lawyerData: widget.lawyerData,
                              ),
                            ),
                          );
                        }
                      },
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isRequestSent
                              ? Colors.green.withOpacity(0.3)
                              : Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isRequestSent
                              ? Icons.check_circle_outline_rounded
                              : Icons.send_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}