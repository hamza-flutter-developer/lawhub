// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'UserRequestSubmitted.dart';

class UserRattingFeedback extends StatefulWidget{
  final String userId;
  final String lawyerId;
  final String caseStartDate;
  final String caseDescription;
  final String paymentProof;
  final String status;
  final int index;

  const UserRattingFeedback({super.key,
    required this.userId,
    required this.lawyerId,
    required this.caseStartDate,
    required this.caseDescription,
    required this.paymentProof,
    required this.status,
    required this.index
  });


  @override
  State<UserRattingFeedback> createState() => _UserRattingFeedbackState();
}

class _UserRattingFeedbackState extends State<UserRattingFeedback> {

  int newRating = 0;

  late int numberOfRatings;

  late int sumOfRatings;

  final TextEditingController _feedbackController = TextEditingController();

  FocusNode feedbackFocusNode = FocusNode();

  bool isLoading = false;

  final fireStoreNotification  = FirebaseFirestore.instance.collection('LawyersNotifications');

  void addNotification(String userID, String type) async {
    var doc = await FirebaseFirestore.instance.collection('LawyersNotifications').doc(userID).get();
    if(doc.exists) {
      int counter = doc['counter'];
      counter++;
      DocumentReference documentReference =
      fireStoreNotification.doc(userID);
      await documentReference.update({
        'Notification$counter': [
          {'userID': FirebaseAuth.instance.currentUser!.email.toString()},
          {'type': type},
          {'isSeen': false},
        ],
        'counter': counter,
      });
    }
    else {
      fireStoreNotification.doc(userID).set({'Notification1': [
        {'userID': FirebaseAuth.instance.currentUser!.email.toString()},
        {'type': type},
        {'isSeen': false},
      ],'counter': 1});
    }
  }

  Widget _buildStar(int index) {
    if (index < newRating) {
      return const Icon(Icons.star, color: Colors.yellow, size: 40,);
    } else {
      return const Icon(Icons.star_border, color: Colors.yellow, size: 40,);
    }
  }

  void _submitRattingFeedback() {
    double newAverageRating = calculateNewRating(sumOfRatings, numberOfRatings, newRating);
    updateLawyerRatting(newAverageRating, sumOfRatings+newRating);
  }

  double calculateNewRating(int sumOfRatings, int numberOfRatings, int newRating) {
    double preAvg = sumOfRatings/numberOfRatings;
    if(numberOfRatings == 0) {
      return newRating+0.0;
    }
    else {
      double newAverageRating = ((preAvg * numberOfRatings) + newRating) / ++numberOfRatings;
      debugPrint(newAverageRating.toString());
      return newAverageRating;
    }
  }

  Future<void> fetchLawyerNumberOfRatting() async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('Lawyers')
        .doc(widget.lawyerId)
        .get();
    numberOfRatings =  userSnapshot['numberOfRatings'];
    debugPrint(numberOfRatings.toString());
  }

  Future<void> fetchLawyerSumOfRatting() async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('Lawyers')
        .doc(widget.lawyerId)
        .get();
    sumOfRatings = userSnapshot['sumOfRatings'];
    debugPrint(sumOfRatings.toString());
  }

  Future<void> updateLawyerRatting(double newRatting, int sumOfRatings) async {
    await FirebaseFirestore.instance.collection('Lawyers').doc(widget.lawyerId).update({
      'numberOfRatings': ++numberOfRatings,
      'ratting': newRatting,
      'sumOfRatings': sumOfRatings
    }).then((value) {
      if(_feedbackController.text.isEmpty){

      }
      else {
        setLawyerFeedback();
      }
    });
  }

  Future<void> setLawyerFeedback() async {
    var docCheck = await FirebaseFirestore.instance.collection('LawyersFeedbacks').doc(widget.lawyerId).get();
    if(docCheck.exists) {
      int counter = docCheck['counter'];
      counter++;
      FirebaseFirestore.instance.collection('LawyersFeedbacks').doc(widget.lawyerId).update({
        'Feedback$counter': {
          'userId': FirebaseAuth.instance.currentUser!.email.toString(),
          'feedback': _feedbackController.text.toString(),
        },
        'counter': counter
      }).then((value) {
        setState(() {
          isLoading = false;
        });
      });
    }
    else {
      FirebaseFirestore.instance.collection('LawyersFeedbacks').doc(widget.lawyerId).set({
        'Feedback1': {
          'userId': FirebaseAuth.instance.currentUser!.email.toString(),
          'feedback': _feedbackController.text.toString(),
        },
        'counter': 1
      }).then((value) {
        setState(() {
          isLoading = false;
        });
      });
    }
  }

  Future<void> updateCaseStatusOfFeedbackRating() async {
    await FirebaseFirestore.instance
        .collection('CasesUser')
        .doc(widget.userId)
        .update({
      'case${widget.index+1}': {
        'status': widget.status,
        'userId': widget.userId,
        'lawyerId': widget.lawyerId,
        'caseDescription': widget.caseDescription,
        'paymentSS': widget.paymentProof,
        'startDate': widget.caseStartDate,
        'givenRatingFeedback': true
      }
    });

    await FirebaseFirestore.instance
        .collection('CasesLawyer')
        .doc(widget.lawyerId)
        .update({
      'case${widget.index+1}': {
        'status': widget.status,
        'userId': widget.userId,
        'lawyerId': widget.lawyerId,
        'caseDescription': widget.caseDescription,
        'paymentSS': widget.paymentProof,
        'startDate': widget.caseStartDate,
        'givenRatingFeedback': true
      }
    });

    setState(() {
      isLoading = false;
    });
    addNotification(widget.lawyerId, 'gives you Rating and Feedback');
    // ignore: use_build_context_synchronously
    Navigator.push(context, MaterialPageRoute(builder: (context) => const UserRequestSubmitted(text: 'Response',)));
  }

  @override
  void initState() {
    fetchLawyerNumberOfRatting();
    fetchLawyerSumOfRatting();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: AppBar(
            toolbarHeight: 70,
            leadingWidth: 40,
            backgroundColor: Colors.blue,
            leading: Padding(
              padding: const EdgeInsets.only(top: 8,left: 10),
              child: IconButton(
                icon: const Icon(FontAwesomeIcons.angleLeft, color: Colors.white,),
                onPressed: () {
                  // Navigate back to the previous page or screen
                  Navigator.of(context).pop();
                },
              ),
            ),
            title: const Padding(
              padding: EdgeInsets.only(top: 13),
              child: Text(
                "Ratting & Feedback",
                style: TextStyle(
                    fontFamily: 'roboto',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white),
              ),
            ),
            centerTitle: true,

            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25)),
            ),
          ),
        ),
        body: SizedBox(
          child: Column(
            children: [
              const SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 30,
                      top: 40,
                      bottom: 20,
                    ),
                    child: Text(
                      "Rate your experience:",
                      style: TextStyle(
                        fontFamily: 'roboto',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        newRating = index + 1;
                      });
                    },
                    child: _buildStar(index),
                  );
                }),
              ),
              const SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 30,
                      top: 20,
                    ),
                    child: Text(
                      "Feedback:",
                      style: TextStyle(
                        fontFamily: 'roboto',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 7,
                        offset: const Offset(1, 1), // changes position of shadow
                      )
                    ],),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: TextFormField(
                      controller: _feedbackController,
                      textAlignVertical: TextAlignVertical.center,
                      focusNode: feedbackFocusNode,
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                      maxLines: 4,
                      decoration: const InputDecoration(
                        focusedBorder: InputBorder.none,
                        border: InputBorder.none,
                        hintText: "Enter your Feedback",
                        focusColor: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 320,
                height: 41,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isLoading = true;
                        });
                        _submitRattingFeedback();
                        updateCaseStatusOfFeedbackRating();
                      },
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(150, 20),
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15))),
                      child: isLoading
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
                          : const Text('Submit',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'roboto',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                  ],
                ),
              )
            ],
          ),
        )
    );

  }
}