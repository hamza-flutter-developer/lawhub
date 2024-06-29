// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lawhub/User_Pages/UserRattingFeedback.dart';

class CasesList {
  final String userId;
  final String lawyerId;
  final String userName;
  final String lawyerName;
  final String caseStartDate;
  final String caseDescription;
  final String paymentProof;
  final bool isGivenRatingFeedback;
  String status;

  CasesList({
    required this.userId,
    required this.lawyerId,
    required this.userName,
    required this.lawyerName,
    required this.caseStartDate,
    required this.caseDescription,
    required this.paymentProof,
    required this.status,
    required this.isGivenRatingFeedback
  });

}
class CaseView extends StatefulWidget{
  final bool isUser;
  const CaseView({Key? key, required this.isUser}) : super(key: key);

  @override
  State<CaseView> createState() => _CaseViewState();
}

class _CaseViewState extends State<CaseView> {

  bool isLoading = true;

  void checkCases() {
    fetchAllCases().then((data) {
      int counter = data['counter'];
      for (int i = 1; i <= counter; i++) {
        String caseDescription = data['case$i']['caseDescription'];
        String startDate = data['case$i']['startDate'];
        String paymentProof = data['case$i']['paymentSS'];
        String status = data['case$i']['status'];
        String userId = data['case$i']['userId'];
        String lawyerId = data['case$i']['lawyerId'];
        bool isGivenRatingFeedback = data['case$i']['givenRatingFeedback'];
        fetchLawyerData(data['case$i']['lawyerId']).then((valueL) {
          fetchUserData(data['case$i']['userId']).then((valueU) {
            setState(() {
              cases.add(CasesList(userId: userId, lawyerId: lawyerId, userName: valueU, lawyerName: valueL, caseStartDate: startDate, caseDescription: caseDescription, paymentProof: paymentProof, status: status, isGivenRatingFeedback: isGivenRatingFeedback));
              if(cases.length == counter) {
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

  Future<DocumentSnapshot> fetchAllCases() async {
    if(widget.isUser) {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('CasesUser')
          .doc(FirebaseAuth.instance.currentUser!.email.toString())
          .get();
      return userSnapshot;
    }
    else {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('CasesLawyer')
          .doc(FirebaseAuth.instance.currentUser!.email.toString())
          .get();
      return userSnapshot;
    }
  }

  Future<String> fetchUserData(String id) async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(id)
        .get();
    return userSnapshot['name'];
  }

  Future<String> fetchLawyerData(String id) async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('Lawyers')
        .doc(id)
        .get();
    return userSnapshot['name'];
  }

  Future<void> updateCaseStatus(String userID, String lawyerID, String status, String caseDescription, String paymentSS, String startDate, int index, bool isGivenRatingFeedback) async {
    await FirebaseFirestore.instance
        .collection('CasesUser')
        .doc(userID)
        .update({
        'case${index+1}': {
          'status': status,
          'userId': userID,
          'lawyerId': lawyerID,
          'caseDescription': caseDescription,
          'paymentSS': paymentSS,
          'startDate': startDate,
          'givenRatingFeedback': isGivenRatingFeedback
    }
        });

    await FirebaseFirestore.instance
        .collection('CasesLawyer')
        .doc(lawyerID)
        .update({
      'case${index+1}': {
        'status': status,
        'userId': userID,
        'lawyerId': lawyerID,
        'caseDescription': caseDescription,
        'paymentSS': paymentSS,
        'startDate': startDate,
        'givenRatingFeedback': isGivenRatingFeedback
      }
    });



    if(status == 'accept') {
      addNotification(userID, 'accepts you request to Start the Case');
      setState(() {
        isLoadingAccept = false;
        cases[index].status = 'accept';
      });
    }
    else if(status == 'reject'){
      addNotification(userID, 'rejects you request to Start the Case');
      setState(() {
        isLoadingReject = false;
        cases[index].status = 'reject';
      });
    }
    else {
      addNotification(userID, 'completed the Case Please give Ratting and Feedback');
      setState(() {
        isLoadingComplete = false;
        cases[index].status = 'complete';
      });
    }
  }

  final fireStoreNotification  = FirebaseFirestore.instance.collection('UsersNotifications');

  void addNotification(String userID, String type) async {
    var doc = await FirebaseFirestore.instance.collection('UsersNotifications').doc(userID).get();
    if(doc.exists) {
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
    }
    else {
      fireStoreNotification.doc(userID).set({'Notification1': [
        {'lawyerID': FirebaseAuth.instance.currentUser!.email.toString()},
        {'type': type},
        {'isSeen': false},
      ],'counter': 1});
    }
  }

  List<CasesList> cases = [];

  String? imageToDisplay;

  bool isImageShow = false;

  bool isLoadingAccept = false;

  bool isLoadingReject = false;

  bool isLoadingComplete = false;

  @override
  void initState() {
    checkCases();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isImageShow
        ? Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          backgroundColor: Colors.black,
          leading: InkWell(
            onTap: () {
              setState(() {
                isImageShow = false;
              });
            },
            child: const Padding(padding: EdgeInsets.only(top: 10, left: 10), child: Icon(FontAwesomeIcons.x, color: Colors.white,size: 20,),),
          )
      ),
      body: Center(child: Image.network(
        imageToDisplay!,
        width: double.infinity,
        height: 500,
        fit: BoxFit.cover,
      ),),
    )
        : Scaffold(
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
                "In Progress Cases",
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
        body: isLoading
            ? Center(
          child: Container(
              color: Colors.white,
              child: const SpinKitCircle(
                  color: Colors.blue, size: 34) ),
        )
            : SingleChildScrollView(
          physics: const ScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              ListView.builder(
                itemBuilder: (context, index) {
                  var itemData = cases[index];
                  return Padding(
                    padding: const EdgeInsets.only(left: 26.2, right: 26.2, bottom: 13),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 360),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.all(Radius.circular(15)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12.withOpacity(0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 320,
                              height: 41,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Case # ${(index + 1).toString()}',
                                    style: const TextStyle(
                                      fontFamily: 'roboto',
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Text(
                              'Start Date:',
                              style: TextStyle(
                                fontFamily: 'roboto',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              itemData.caseStartDate,
                              style: const TextStyle(
                                fontFamily: 'roboto',
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 20),
                            widget.isUser
                                ? const Text(
                              'Lawyer Name: ',
                              style: TextStyle(
                                fontFamily: 'roboto',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                                : const Text(
                              'Client Name: ',
                              style: TextStyle(
                                fontFamily: 'roboto',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            widget.isUser
                                ? Text(
                              itemData.lawyerName,
                              style: const TextStyle(
                                fontFamily: 'roboto',
                                fontSize: 16,
                              ),
                            )
                                : Text(
                              itemData.userName,
                              style: const TextStyle(
                                fontFamily: 'roboto',
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Case Description:',
                              style: TextStyle(
                                fontFamily: 'roboto',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              itemData.caseDescription,
                              style: const TextStyle(
                                fontFamily: 'roboto',
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Status:',
                              style: TextStyle(
                                fontFamily: 'roboto',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            itemData.status == 'pending'
                            ? const Text(
                              'Requested',
                              style: TextStyle(
                                fontFamily: 'roboto',
                                fontSize: 16,
                              ),
                            )
                            : itemData.status == 'accept'
                              ? const Text(
                              'In Progress',
                              style: TextStyle(
                                fontFamily: 'roboto',
                                fontSize: 16,
                              ),
                            )
                              : itemData.status == 'complete'
                                ? const Text(
                              'Completed',
                              style: TextStyle(
                                fontFamily: 'roboto',
                                fontSize: 16,
                              ),
                            )
                                : const SizedBox(),
                            const SizedBox(height: 20),
                            const Text(
                              'Advance Payment:',
                              style: TextStyle(
                                fontFamily: 'roboto',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 15),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  imageToDisplay = itemData.paymentProof;
                                  isImageShow = true;
                                });
                              },
                              child: Padding(padding: const EdgeInsets.symmetric(horizontal: 30),
                                child: Center(child: Image.network(
                                  itemData.paymentProof,
                                  width: double.infinity,
                                  height: 300,
                                  fit: BoxFit.cover,
                                ),),),
                            ),
                            const SizedBox(height: 15,),
                            widget.isUser
                            ? itemData.status == 'complete'
                              ? itemData.isGivenRatingFeedback
                                ? const SizedBox()
                                : SizedBox(
                              width: 320,
                              height: 41,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => UserRattingFeedback(userId: itemData.userId, lawyerId: itemData.lawyerId, caseDescription: itemData.caseDescription, caseStartDate: itemData.caseStartDate, paymentProof: itemData.paymentProof, status: itemData.status, index: index,)));
                                    },
                                    style: ElevatedButton.styleFrom(
                                        fixedSize: const Size(220, 20),
                                        backgroundColor: Colors.blue,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15))),
                                    child: isLoadingComplete
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
                                        : const Text('Ratting and Feedback',
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
                              : const SizedBox()
                            : itemData.status == 'pending'
                              ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    setState(() {
                                      isLoadingReject = true;
                                    });
                                    updateCaseStatus(itemData.userId, itemData.lawyerId, 'reject', itemData.caseDescription,  itemData.paymentProof, itemData.caseStartDate, index, false);
                                  },
                                  style: ElevatedButton.styleFrom(
                                      fixedSize: const Size(100, 40),
                                      backgroundColor: Colors.deepOrangeAccent,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                                  child: isLoadingReject
                                      ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: SpinKitCircle(color: Colors.white, size: 20))
                                      : const Text('Reject', style: TextStyle(color: Colors.white, fontFamily: 'roboto', fontSize: 16, fontWeight: FontWeight.bold)),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isLoadingAccept = true;
                                    });
                                    updateCaseStatus(itemData.userId, itemData.lawyerId, 'accept', itemData.caseDescription,  itemData.paymentProof, itemData.caseStartDate, index, false);
                                  },
                                  style: ElevatedButton.styleFrom(
                                      fixedSize: const Size(100, 40),
                                      backgroundColor: Colors.lightGreen,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                                  child: isLoadingAccept
                                      ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: SpinKitCircle(color: Colors.white, size: 20))
                                      : const Text('Accept', style: TextStyle(color: Colors.white, fontFamily: 'roboto', fontSize: 16, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            )
                              : itemData.status == 'accept'
                                ? SizedBox(
                              width: 320,
                              height: 41,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        isLoadingComplete = true;
                                      });
                                      updateCaseStatus(itemData.userId, itemData.lawyerId, 'complete', itemData.caseDescription,  itemData.paymentProof, itemData.caseStartDate, index, false);
                                    },
                                    style: ElevatedButton.styleFrom(
                                        fixedSize: const Size(200, 20),
                                        backgroundColor: Colors.blue,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15))),
                                    child: isLoadingComplete
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
                                        : const Text('Complete',
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
                                : const SizedBox(),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                itemCount: cases.length,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
              )

            ],
          ),
        )
    );

  }
}