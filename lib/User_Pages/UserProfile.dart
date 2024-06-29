// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lawhub/Payment_Pages/ManagePayments.dart';
import 'package:lawhub/InformationUpdate_Pages/CredentialPassword.dart';
import 'package:lawhub/InformationUpdate_Pages/PersonalInformation.dart';

import '../InformationUpdate_Pages/ProfilePictureUpdate.dart';
import '../CaseDisplay_Pages/UserCaseView.dart';

class UserProfile extends StatefulWidget{
  final Map<String, dynamic> userData;
  const UserProfile({super.key, required this.userData});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {

  bool isCaseAvailable = false;

  Future<void> checkCases() async {
    var doc = await FirebaseFirestore.instance.collection('CasesUser').doc(widget.userData['id']).get();
    if(doc.exists) {
      setState(() {
        isCaseAvailable = true;
      });
    }
    else {
      setState(() {
        isCaseAvailable = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    checkCases();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blue,
        body: Stack(
          children: [
            const SizedBox(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 21.5),
                    child: Text(
                      "LAWHUB",
                      style: TextStyle(
                          fontFamily: "patua",
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.w100),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 20,
            ),
            Stack(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 150),
                    width: double.infinity,
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(45),
                            topRight: Radius.circular(45)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5,
                              spreadRadius: 0,
                              offset : Offset(0, -3)
                          )
                        ]
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 0.07 * MediaQuery.of(context).size.width),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 80,
                          ),
                          Text(widget.userData['name'],style: const TextStyle(
                            fontFamily: 'roboto',
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),),
                          const SizedBox(
                            height: 30,
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => UserPersonalInformation(isUser: true,userData: widget.userData,)));
                            },
                            child: Container(
                              width: 340,
                              height: 60,
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
                              child: const Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 30,
                                  ),
                                  Icon(FontAwesomeIcons.userLarge,size: 25,),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text('Personal Information', style: TextStyle(
                                    fontFamily: 'roboto',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),)
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const CredentialsPassword(isUser: true,)));
                            },
                            child: Container(
                              width: 340,
                              height: 60,
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
                              child: const Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 30,
                                  ),
                                  Icon(FontAwesomeIcons.shieldHalved,size: 25,),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text('Credentials and Password', style: TextStyle(
                                    fontFamily: 'roboto',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),)
                                ],
                              ),
                            ),
                          ),
                          isCaseAvailable
                              ? Padding(padding: const EdgeInsets.only(top: 15), child: InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const CaseView(isUser: true)));
                            },
                            child: Container(
                              width: 340,
                              height: 60,
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
                              child: const Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 30,
                                  ),
                                  Icon(FontAwesomeIcons.handHoldingHand,size: 25,),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text('In Progress Case', style: TextStyle(
                                    fontFamily: 'roboto',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),)
                                ],
                              ),
                            ),
                          ),)
                              : const SizedBox(),
                          const SizedBox(
                            height: 15,
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const ManagePayment(isUser: true,)));
                            },
                            child: Container(
                              width: 340,
                              height: 60,
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
                              child: const Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 30,
                                  ),
                                  Icon(FontAwesomeIcons.solidCreditCard,size: 25,),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text('Payments', style: TextStyle(
                                    fontFamily: 'roboto',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),)
                                ],
                              ),
                            ),
                          ),
                          

                        ],
                      ),
                    ),),
                ),
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 80),
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
                        child: InkWell(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePictureUpdate(isUser: true, userData: widget.userData,)));
                          },
                          child: widget.userData['profilePic'] != 'null'
                              ? ClipRRect(
                            borderRadius: const BorderRadius.all(Radius.circular(70)),
                            child: Image.network(widget.userData['profilePic'],
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
                      ),
                    ],
                  ),
                ),
              ],
            ),

          ],
        ));
  }
}