// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lawhub/InformationUpdate_Pages/LawyerAboutPracticeUpdate.dart';
import 'LawyerAvailabilityUpdate.dart';
import 'PersonalInfoUpdate.dart';

class UserPersonalInformation extends StatelessWidget{
  final Map<String, dynamic> userData;
  final bool isUser;
  const UserPersonalInformation({Key? key, required this.isUser, required this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              "Personal Information",
              style: TextStyle(
                  fontFamily: 'roboto',
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white),
            ),
          ),
          centerTitle: true,
          actions: [
            isUser
            ? Padding(
        padding: const EdgeInsets.only(top: 13,right: 18),
        child: InkWell(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => UserPersonalInfoUpdate(isUser: isUser, userData: userData)));
            },
            child: const Icon(FontAwesomeIcons.penToSquare,size: 21,color: Colors.white,)),
      )
            : const SizedBox(),
          ],
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25)),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: isUser
        ? SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 30,
                    top: 30,
                    bottom: 10,
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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 0.05 * MediaQuery.of(context).size.width),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 7,
                        offset: const Offset(1, 1), // changes position of shadow
                      ),
                    ]
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 20,bottom: 20,left: 20,right: 20),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 0.70 * MediaQuery.of(context).size.width,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Name:',style: TextStyle(
                                  fontFamily: 'roboto',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),),
                                const SizedBox(
                                  height: 8,
                                ),
                                Text(userData['name'],style: const TextStyle(
                                  fontFamily: 'roboto',
                                  fontSize: 16,
                                ),),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          SizedBox(
                            width: 0.70 * MediaQuery.of(context).size.width,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Date of Birth:',style: TextStyle(
                                  fontFamily: 'roboto',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),),
                                const SizedBox(
                                  height: 8,
                                ),
                                Text('${userData['dob'][0]}-${userData['dob'][1]}-${userData['dob'][2]}',style: const TextStyle(
                                  fontFamily: 'roboto',
                                  fontSize: 16,
                                ),),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          SizedBox(
                            width: 0.65 * MediaQuery.of(context).size.width,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Province - City:',style: TextStyle(
                                  fontFamily: 'roboto',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),),
                                const SizedBox(
                                  height: 8,
                                ),
                                Text('${userData['province']} - ${userData['city']}',style: const TextStyle(
                                  fontFamily: 'roboto',
                                  fontSize: 16,
                                ),),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10,),

                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      )
        : SingleChildScrollView(
          child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: double.infinity,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(
                        left: 30,
                        top: 30,
                        bottom: 10,
                      ),
                      child: Text(
                        "About Me:",
                        style: TextStyle(
                          fontFamily: 'roboto',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        right: 30,
                        top: 30,
                        bottom: 10,
                      ),
                      child: InkWell(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => UserPersonalInfoUpdate(isUser: isUser, userData: userData)));
                          },
                          child: const Icon(FontAwesomeIcons.penToSquare,size: 21,color: Colors.blue,)),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 0.05 * MediaQuery.of(context).size.width),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 7,
                          offset: const Offset(1, 1), // changes position of shadow
                        ),
                      ]
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20,bottom: 20,left: 20,right: 20),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 0.70 * MediaQuery.of(context).size.width,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Name:',style: TextStyle(
                                    fontFamily: 'roboto',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Text(userData['name'],style: const TextStyle(
                                    fontFamily: 'roboto',
                                    fontSize: 16,
                                  ),),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              width: 0.70 * MediaQuery.of(context).size.width,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Date of Birth:',style: TextStyle(
                                    fontFamily: 'roboto',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Text('${userData['dob'][0]}-${userData['dob'][1]}-${userData['dob'][2]}',style: const TextStyle(
                                    fontFamily: 'roboto',
                                    fontSize: 16,
                                  ),),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              width: 0.65 * MediaQuery.of(context).size.width,
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
                                  Text(userData['license'],style: const TextStyle(
                                    fontFamily: 'roboto',
                                    fontSize: 16,
                                  ),),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              width: 0.65 * MediaQuery.of(context).size.width,
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
                                  for (int i = 0; i < userData['expertise'].length; i++)
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        const SizedBox(width: 10,),
                                        const Icon(FontAwesomeIcons.solidCircle,size: 5,),
                                        const SizedBox(width: 8,),
                                        Text(userData['expertise'][i],style: const TextStyle(
                                          fontFamily: 'roboto',
                                          fontSize: 16,
                                        ),),
                                      ],
                                    )
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              width: 0.65 * MediaQuery.of(context).size.width,
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
                                  Text('${DateTime.now().year - int.parse(userData['practicingYear'])}+ Years Experience ',style: const TextStyle(
                                    fontFamily: 'roboto',
                                    fontSize: 16,
                                  ),),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              width: 0.65 * MediaQuery.of(context).size.width,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Province - City:',style: TextStyle(
                                    fontFamily: 'roboto',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Text('${userData['province']} - ${userData['city']}',style: const TextStyle(
                                    fontFamily: 'roboto',
                                    fontSize: 16,
                                  ),),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 10,),
          
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(
                        left: 30,
                        top: 30,
                        bottom: 10,
                      ),
                      child: Text(
                        "About My Practice:",
                        style: TextStyle(
                          fontFamily: 'roboto',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        right: 30,
                        top: 30,
                        bottom: 10,
                      ),
                      child: InkWell(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => LawyerAboutPracticeUpdate(isUser: isUser, userData: userData,)));
                          },
                          child: const Icon(FontAwesomeIcons.penToSquare,size: 21,color: Colors.blue,)),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 0.05 * MediaQuery.of(context).size.width),
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
                      padding: const EdgeInsets.only(top: 15,bottom: 15,left: 20,right: 20),
                      child: SingleChildScrollView(
                        child: Text(
                          userData['aboutPractice'],
                          style: const TextStyle(
                            fontFamily: 'roboto',
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(
                        left: 30,
                        top: 30,
                        bottom: 10,
                      ),
                      child: Text(
                        "Availability:",
                        style: TextStyle(
                          fontFamily: 'roboto',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        right: 30,
                        top: 30,
                        bottom: 10,
                      ),
                      child: InkWell(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => LawyerAvailabilityUpdate(isUser: isUser, userData: userData)));
                          },
                          child: const Icon(FontAwesomeIcons.penToSquare,size: 21,color: Colors.blue,)),
                    ),
                  ],
                ),
              ),
              userData['availability'].toString() == '[]'
              ? Padding(
                padding: EdgeInsets.symmetric(horizontal: 0.05 * MediaQuery.of(context).size.width),
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
                ),
              )
              : Padding(
                padding: EdgeInsets.symmetric(horizontal: 0.05 * MediaQuery.of(context).size.width),
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
                    child:
                    Column(
                      children: [
                        for (int i = 0; i < userData['availability'].length; i++)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 15,bottom: 15,left: 20),
                                child: Text(
                                  userData['availability'][i]['day'],
                                  style: const TextStyle(
                                    fontFamily: 'roboto',
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 15,bottom: 15,right: 20),
                                child: Text(
                                  userData['availability'][i]['timeSlot'],
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
                ),
              ),
              const SizedBox(height: 20,),
            ],
          ),
                ),
        ),
    );
  }

}