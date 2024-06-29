import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lawhub/LoginSignup_Pages/UserSignup.dart';
import 'package:lawhub/widgets/Fonts.dart';
import 'package:lawhub/widgets/Themes.dart';

import 'LawyerSignup.dart';

class UserType extends StatelessWidget{

  final String email;
  final String name;
  final String password;
  UserType({super.key, required this.email, required this.name, required this.password});

  String userType = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blue,
        body: Column(
          children: [
            Padding(
              padding:
              EdgeInsets.only(top: 0.03 * MediaQuery.of(context).size.height),
              child: TopLogo(fontColor: Colors.white),
            ),
            Expanded(
                child: Container(
                    margin: EdgeInsets.only(
                        top: 0.0425 * MediaQuery.of(context).size.height),
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
                      children: [
                        SizedBox(
                            width: double.infinity,
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: 0.08 *
                                      MediaQuery.of(context).size.width,
                                  top: 0.07 *
                                      MediaQuery.of(context).size.height
                              ),
                              child: const BoldFont(text: "Complete Profile"),
                            )),
                        SizedBox(
                            width: double.infinity,
                            child: Padding(
                              padding: EdgeInsets.only(
                                left:
                                0.08 * MediaQuery.of(context).size.width,
                              ),
                              child: const NormalFont(
                                  text:
                                  "Please Provide the Following information \nto complete account creation"),
                            )),
                        Padding(
                          padding: EdgeInsets.only(
                            top:
                            0.1 * MediaQuery.of(context).size.height,
                          ),
                          child: InkWell(
                            onTap: () {
                              userType = 'User';
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => UserSignup(email: email, name: name, password: password,)));
                            },
                            child: Container(
                              width: 300,
                              height: 80,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 7,
                                    offset: const Offset(1, 1), // changes position of shadow
                                  ),
                                ],),
                              child: const Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(left: 22),
                                        child: Icon(
                                          FontAwesomeIcons.userLarge,
                                          size: 38,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 21),
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "I’m a User",
                                              style: TextStyle(
                                                fontFamily: 'roboto',
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Text(
                                              "Looking for Legal Help",
                                              style: TextStyle(
                                                fontFamily: 'roboto',
                                                fontSize: 15,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(right: 15),
                                    child: Icon(
                                      FontAwesomeIcons.chevronRight,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        InkWell(
                          onTap: () {
                            userType = 'Lawyer';
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LawyerSignup(email: email, name: name, password: password,)));
                          },
                          child: Container(
                            width: 300,
                            height: 80,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 7,
                                  offset: const Offset(1, 1), // changes position of shadow
                                )
                              ],),
                            child: const Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(left: 20),
                                      child: Icon(
                                        FontAwesomeIcons.userTie,
                                        size: 40,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 20),
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "I’m a Lawyer",
                                            style: TextStyle(
                                              fontFamily: 'roboto',
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            "Register as an Advocate",
                                            style: TextStyle(
                                              fontFamily: 'roboto',
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsets.only(right: 15),
                                  child: Icon(
                                    FontAwesomeIcons.chevronRight,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )))
          ],
        ));
  }
  
}