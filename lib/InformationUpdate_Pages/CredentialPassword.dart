// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'CredentialChangeAuth.dart';

class CredentialsPassword extends StatelessWidget{
  final bool isUser;
  const CredentialsPassword({Key? key, required this.isUser}) : super(key: key);
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
              icon: const Icon(FontAwesomeIcons.angleLeft,color: Colors.white,),
              onPressed: () {
                // Navigate back to the previous page or screen
                Navigator.of(context).pop();
              },
            ),
          ),
          title: const Padding(
            padding: EdgeInsets.only(top: 13),
            child: Text(
              "Password & Security",
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
      backgroundColor: Colors.white,
      body: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 30,
                    top: 40,
                    bottom: 10,
                  ),
                  child: Text(
                    "Login Credentials:",
                    style: TextStyle(
                      fontFamily: 'roboto',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )),
            const SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 30,
                    bottom: 30
                  ),
                  child: Text(
                    "Manage your Email/Phone and password",
                    style: TextStyle(
                        fontFamily: 'roboto',
                        fontSize: 16
                    ),
                  ),
                )),
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UserCredentialChangeAuth(isUser: isUser, isEmailPhoneChange: true,)));
              },
              child: Container(
                width: 300,
                height: 49,
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
                child: const Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Icon(Icons.email,size: 25,),
                    ),
                    SizedBox(width: 20,),
                    Text('Change Email/Phone', style: TextStyle(
                        fontFamily: 'roboto',
                        fontSize: 16
                    ),),
                    SizedBox(width: 50,),
                    Icon(FontAwesomeIcons.caretRight,size: 15,)
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UserCredentialChangeAuth(isUser: isUser, isEmailPhoneChange: false,)));
              },
              child: Container(
                width: 300,
                height: 49,
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
                child: const Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Icon(Icons.lock,size: 25,),
                    ),
                    SizedBox(width: 20,),
                    Text('Change Password', style: TextStyle(
                        fontFamily: 'roboto',
                        fontSize: 16
                    ),),
                    SizedBox(width: 71,),
                    Icon(FontAwesomeIcons.caretRight,size: 15,)
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