// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lawhub/Article_Pages/ArticlesView.dart';
import 'package:lawhub/User_Pages/UserSendRequest.dart';

import '../Utils/Utilities.dart';

class Comments {
  final String imageUrl;
  final String userName;
  final String userComment;

  Comments({required this.imageUrl, required this.userName, required this.userComment});
}

class UserLawyerProfile extends StatefulWidget{
  final Map<String, dynamic> userData;
  final Map<String, dynamic> lawyerData;
  const UserLawyerProfile({Key? key, required this.lawyerData, required this.userData}) : super(key: key);

  @override
  State<UserLawyerProfile> createState() => _UserLawyerProfileState();
}

class _UserLawyerProfileState extends State<UserLawyerProfile> {

  final fireStore  = FirebaseFirestore.instance.collection('Favourite');

  bool isRequestSent = false;
  bool isLoadingRequest = false;

  bool isLoadingFavourite = false;
  bool isFavouriteAdded = false;

  late Map<String, dynamic> favDataList;

  Future<void> checkFavouriteLawyers() async {
    var documentCheck = await FirebaseFirestore.instance.collection('Favourite').doc(FirebaseAuth.instance.currentUser!.email).get();
    if(!documentCheck.exists) {
      setState(() {
        isFavouriteAdded = false;
        isLoadingFavourite = false;
      });
    }
    else {
      fetchAllFavouriteLawyerData().then((data) {
        setState(() {
          favDataList = data;
          for (int i = 1; i <= favDataList['counter']; i++) {
            String lawyerId = favDataList['LawyerID$i'];
            if(lawyerId == widget.lawyerData['id']) {
              setState(() {
                isFavouriteAdded = true;
                isLoadingFavourite = false;
              });
              break;
            }
            else {
            }
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

  Future<Map<String, dynamic>> fetchAllFavouriteLawyerData() async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('Favourite')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get();

    Map<String, dynamic> favLawyerData = userSnapshot.data() as Map<String, dynamic>;
    return favLawyerData;
  }

  void addFirstFavourite() {
    fireStore.doc(widget.userData['id']).set({'counter': 0});
  }

  void addToFavourite() async {
    var documentCheck = await FirebaseFirestore.instance.collection('Favourite').doc(widget.userData['id']).get();
    int counter = documentCheck['counter'];
    bool furterPorcess = true;
    for(int i = 1; i <= counter; i++) {
      if(documentCheck['LawyerID$i'] == widget.lawyerData['id']) {
        setState(() {
          isLoadingFavourite = false;
        });
        Utilities().errorMsg('Already added to Favourite');
        furterPorcess = false;
      }
    }
    if(furterPorcess) {
      counter++;
      DocumentReference documentReference =
      fireStore.doc(widget.userData['id']);
      await documentReference.update({
        'LawyerID$counter': widget.lawyerData['id'],
        'counter': counter,
      }).then((value) => {
        setState(() {
          isLoadingFavourite = false;
          isFavouriteAdded = true;
          setState(() {

          });
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

  void deleteFromFavourite() async {
    var documentSnapshot = await FirebaseFirestore.instance.collection('Favourite').doc(widget.userData['id']).get();
    int counter = documentSnapshot['counter'];
    if (counter == 1) {
      String lawyerId = favDataList['LawyerID1'];
      if (lawyerId == widget.lawyerData['id']) {
        await FirebaseFirestore.instance.collection('Favourite').doc(widget.userData['id']).delete();
      }

    }
    else {
      Map<String, dynamic> favDataList = await fetchAllFavouriteLawyerData();
      FirebaseFirestore.instance.collection('Favourite').doc(widget.userData['id']).delete();
      addFirstFavourite();
      int controller = 1;
      for (int i = 1; i <= counter; i++) {
        String lawyerId = favDataList['LawyerID$i'];
        if (lawyerId == widget.lawyerData['id']) {
          continue;
        } else {
          DocumentReference documentReference = FirebaseFirestore.instance.collection('Favourite').doc(widget.userData['id']);
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

    // Show success message
    Utilities().successMsg('Removed from Favourite');
  }

  Future<void> checkRequest() async {
    var documentCheck = await FirebaseFirestore.instance.collection('Requests').doc(widget.lawyerData['id']).get();
    if (!documentCheck.exists) {
      setState(() {
        isLoadingRequest = false;
        isRequestSent = false;
      });
    } else {
      fetchAllRequests().then((data) {
        setState(() {
          int counter = data['counter'];
          for (int i = 1; i <= counter; i++) {
            if(data['Request$i'][0]['userID'] == widget.userData['id']) {
              isRequestSent = true;
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

  Future<DocumentSnapshot> fetchAllRequests() async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('Requests')
        .doc(widget.lawyerData['id'])
        .get();
    return userSnapshot;
  }

  Future<String> fetchFeedbackUserImage(String id) async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(id)
        .get();
    return userSnapshot['profilePic'];
  }

  Future<String> fetchFeedbackUserName(String id) async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(id)
        .get();
    return userSnapshot['name'];
  }

  bool isFeedbacksAvailable = false;

  List<Comments> feedbacks = [];
  
  Future<void> fetchFeedbacks() async {
    var docCheck = await FirebaseFirestore.instance.collection('LawyersFeedbacks').doc(widget.lawyerData['id']).get();
    if(docCheck.exists) {
      int counter = docCheck['counter'];
      for(int i = 1; i <= counter; i++) {
        String feedback = docCheck['Feedback$i']['feedback'];
        fetchFeedbackUserImage(docCheck['Feedback$i']['userId']).then((imgUrl) {
          fetchFeedbackUserName(docCheck['Feedback$i']['userId']).then((name) {
            feedbacks.add(Comments(imageUrl: imgUrl, userName: name, userComment: feedback));
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
      setState(() {
        isFeedbacksAvailable = false;
      });
    }
  }
  
  @override
  void initState() {
    isLoadingFavourite = true;
    isLoadingRequest = true;
    checkFavouriteLawyers();
    checkRequest();
    fetchFeedbacks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blue,
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 180),
                    width: double.infinity,
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(45),
                            topRight: Radius.circular(45)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black45,
                              blurRadius: 15.0,
                              spreadRadius: 5.0)
                        ]),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 80,
                        ),
                        Text(widget.lawyerData['name'],style: const TextStyle(
                          fontFamily: 'roboto',
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),),
                        const SizedBox(
                          height: 30,
                        ),
                        const SizedBox(
                            width: double.infinity,
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: 30,
                              ),
                              child: Text(
                                "About Me:",
                                style: TextStyle(
                                  fontFamily: 'roboto',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )),
                        const SizedBox(
                          height: 15,
                        ),
                        Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: const BorderRadius.all(Radius.circular(15)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12.withOpacity(0.35),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 260,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('License:',style: TextStyle(
                                              fontFamily: 'roboto',
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),),
                                            const SizedBox(
                                              height: 8,
                                            ),
                                            Text(widget.lawyerData['license'],style: const TextStyle(
                                              fontFamily: 'roboto',
                                              fontSize: 16,
                                            ),),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 260,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Expertise:',style: TextStyle(
                                              fontFamily: 'roboto',
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),),
                                            const SizedBox(
                                              height: 8,
                                            ),
                                            for (int i = 0; i < widget.lawyerData['expertise'].length; i++)
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  const Icon(FontAwesomeIcons.solidCircle,size: 5,),
                                                  const SizedBox(width: 8,),
                                                  Text(widget.lawyerData['expertise'][i],style: const TextStyle(
                                                    fontFamily: 'roboto',
                                                    fontSize: 16,
                                                  ),),
                                                ],
                                              )

                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 260,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Experience:',style: TextStyle(
                                              fontFamily: 'roboto',
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),),
                                            const SizedBox(
                                              height: 8,
                                            ),
                                            Text('${DateTime.now().year - int.parse(widget.lawyerData['practicingYear'])}+ Years Experience ',style: const TextStyle(
                                              fontFamily: 'roboto',
                                              fontSize: 16,
                                            ),),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 260,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Location:',style: TextStyle(
                                              fontFamily: 'roboto',
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),),
                                            const SizedBox(
                                              height: 8,
                                            ),
                                            Text('${widget.lawyerData['province']} - ${widget.lawyerData['city']}',style: const TextStyle(
                                              fontFamily: 'roboto',
                                              fontSize: 16,
                                            ),),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12,),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 260,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Ratting:',style: TextStyle(
                                              fontFamily: 'roboto',
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),),
                                            const SizedBox(
                                              height: 8,
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  (widget.lawyerData['ratting']+0.0).toString().substring(0,3).toString(),
                                                  style: const TextStyle(
                                                    fontFamily: 'roboto',
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.amberAccent,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 3,
                                                ),
                                                const Icon(
                                                  Icons.star,
                                                  color: Colors.amberAccent,
                                                  size: 18,
                                                ),

                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12,),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        const SizedBox(
                            width: double.infinity,
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: 30,
                              ),
                              child: Text(
                                "About My Practice:",
                                style: TextStyle(
                                  fontFamily: 'roboto',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )),
                        const SizedBox(
                          height: 15,
                        ),
                        Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                            width: 360,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: const BorderRadius.all(Radius.circular(15)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12.withOpacity(0.35),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 15,bottom: 15,left: 20,right: 20),
                              child: SingleChildScrollView(
                                child: Text(
                                  widget.lawyerData['aboutPractice'],
                                  style: const TextStyle(
                                    fontFamily: 'roboto',
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            )
                        ),),
                        const SizedBox(
                          height: 15,
                        ),
                        Padding(padding: const EdgeInsets.symmetric(horizontal: 20),child: SizedBox(
                          width: 360,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ArticleView(isUser: true,userData: widget.lawyerData,)));
                                },
                                style: ElevatedButton.styleFrom(
                                    fixedSize: const Size(110, 20),
                                    backgroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(15))),
                                child: const Text('Articles',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'roboto',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    )),),
                            ],
                          ),
                        ),),
                        const SizedBox(
                          height: 15,
                        ),
                        const SizedBox(
                            width: double.infinity,
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: 30,
                              ),
                              child: Text(
                                "Availability:",
                                style: TextStyle(
                                  fontFamily: 'roboto',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )),
                        const SizedBox(
                          height: 15,
                        ),
                        widget.lawyerData['availability'].toString() == '[]'
                        ? Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Container(
                          width: 360,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.all(Radius.circular(15)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12.withOpacity(0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                )
                              ]
                          ),
                          child: const Padding(
                            padding: EdgeInsets.only(top: 15,bottom: 15,left: 20),
                            child: Text(
                              'Not Set',
                              style: TextStyle(
                                fontFamily: 'roboto',
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),)
                        : Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Container(
                            width: 360,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: const BorderRadius.all(Radius.circular(15)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12.withOpacity(0.35),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                            ),
                            child: Column(
                              children: [
                                for (int i = 0; i < widget.lawyerData['availability'].length; i++)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 15,bottom: 15,left: 20),
                                        child: Text(
                                          widget.lawyerData['availability'][i]['day'],
                                          style: const TextStyle(
                                            fontFamily: 'roboto',
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 15,bottom: 15,right: 20),
                                        child: Text(
                                          widget.lawyerData['availability'][i]['timeSlot'],
                                          style: const TextStyle(
                                            fontFamily: 'roboto',
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            )
                        ),),
                        const SizedBox(
                          height: 30,
                        ),
                        isFavouriteAdded
                        ? Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: SizedBox(
                          width: 360,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                isLoadingFavourite = true;
                              });
                              deleteFromFavourite();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: isLoadingFavourite
                                    ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                        color: Colors.blue,
                                        height: 20,
                                        width: 20,
                                        child: const SpinKitCircle(color: Colors.white,size: 20)),
                                    const SizedBox(width: 5,),
                                    const Text('Loading',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'roboto',
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        )),
                                  ],
                                )
                                    : const Text(
                                  'Remove From Favourite',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'roboto',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                            ),
                          ),
                        ))
                        : Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: SizedBox(
                          width: 360,
                          child: ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                isLoadingFavourite = true;
                              });
                              setState(() {
                                isLoadingFavourite = true;
                              });
                              var  documentCheck = await FirebaseFirestore.instance.collection('Favourite').doc(widget.userData['id']).get();
                              if(documentCheck.exists) {
                                addToFavourite();
                              }
                              else {
                                addFirstFavourite();
                                addToFavourite();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: isLoadingFavourite
                                    ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                        color: Colors.blue,
                                        height: 20,
                                        width: 20,
                                        child: const SpinKitCircle(color: Colors.white,size: 20)),
                                    const SizedBox(width: 5,),
                                    const Text('Loading',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'roboto',
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        )),
                                  ],
                                )
                                    : const Text(
                                  'Add to Favourite',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'roboto',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                            ),
                          ),
                        )),
                        const SizedBox(
                          height: 20,
                        ),
                        isFeedbacksAvailable
                        ? const SizedBox(
                            width: double.infinity,
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: 30,
                              ),
                              child: Text(
                                "Feedbacks:",
                                style: TextStyle(
                                  fontFamily: 'roboto',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ))
                        : const SizedBox(),
                        isFeedbacksAvailable 
                        ? ListView.builder(itemBuilder: (context, index) {
                          var itemData = feedbacks[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 15, right: 20, left: 20),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: const BorderRadius.all(Radius.circular(25)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12.withOpacity(0.35),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center, // Align items vertically center
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5, right: 15),
                                      child: SizedBox(
                                        width: 50, // Fixed width for the avatar
                                        height: 50, // Fixed height for the avatar
                                        child: itemData.imageUrl == 'null'
                                            ? CircleAvatar(
                                          backgroundColor: Colors.grey[300],
                                          child: const Icon(Icons.person, color: Colors.grey, size: 30),
                                        )
                                            : CircleAvatar(
                                          backgroundImage: NetworkImage(itemData.imageUrl),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            itemData.userName,
                                            style: const TextStyle(
                                              fontFamily: 'roboto',
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 3,),
                                          Text(
                                            itemData.userComment,
                                            style: const TextStyle(
                                              fontFamily: 'roboto',
                                              fontSize: 16,
                                            ),
                                          )
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
                        )
                        : const SizedBox(),
                      ],
                    ),),
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
                              color: Colors.white,
                              borderRadius: const BorderRadius.all(Radius.circular(70)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12.withOpacity(0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                )
                              ]
                          ),
                          child: widget.lawyerData['profilePic'] != 'null'
                              ? ClipRRect(
                            borderRadius: const BorderRadius.all(Radius.circular(70)),
                            child: Image.network(widget.lawyerData['profilePic'],
                              fit: BoxFit.fitHeight,
                              filterQuality: FilterQuality.high,

                            ),
                          )
                              : CircleAvatar(
                              radius: 80,
                              backgroundColor: Colors.grey[300],
                              child: const SizedBox(
                                height: 150,
                                width: 150,
                                child: Icon(
                                  Icons.person,
                                  size: 90,
                                  color: Colors.grey,
                                ),
                              )
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 44.5),
                    height: 30,
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(
                            FontAwesomeIcons.angleLeft,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            // Navigate back to the previous page or screen
                            Navigator.of(context).pop();
                          },
                        ),
                        const Text(
                          "LAWHUB",
                          style: TextStyle(
                              fontFamily: "patua",
                              color: Colors.white,
                              fontSize: 23,
                              fontWeight: FontWeight.w100),
                        ),
                        isLoadingRequest
                        ? const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: SpinKitCircle(color: Colors.white,size: 24),
                        )
                        : isRequestSent
                            ? IconButton(
                            onPressed: () {
                              Utilities().errorMsg('Your request has already been submitted');
                            },
                            icon: const Icon(
                              FontAwesomeIcons.userCheck,
                              size: 20,
                              color: Colors.white,
                            ))
                            : IconButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => UserSendRequest(userData: widget.userData, lawyerData: widget.lawyerData,)));
                            },
                            icon: const Icon(
                              FontAwesomeIcons.userPlus,
                              size: 20,
                              color: Colors.white,
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ));
  }
}