// ignore_for_file: camel_case_types, file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lawhub/Drawer_Pages/Help&Support.dart';

import 'AboutUs.dart';
import 'Terms&Policies.dart';

class drawer extends StatefulWidget {
  final String imageURL;
  final String userName;
  final String userEmail;
  const drawer({super.key, required this.userName,required this.userEmail, required this.imageURL});

  @override
  State<drawer> createState() => _drawerState();
}

class _drawerState extends State<drawer> {


  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.blue.shade600,
      width: 0.6 * MediaQuery.of(context).size.width,
      child: ListView(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 0.07 * MediaQuery.of(context).size.width),
            child: widget.imageURL != 'null'
            ? CircleAvatar(
              radius: 53,
              child: ClipOval(
                child: SizedBox(
                  height: 110,
                  width: 110,
                  child: Image.network(
                    widget.imageURL,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                    ),
                )
              ),
            )
            : CircleAvatar(
                radius: 52,
                backgroundColor: Colors.grey[300],
                child: const SizedBox(
                  height: 100,
                  width: 100,
                  child: Icon(
                    Icons.person,
                    size: 45,
                    color: Colors.grey,
                  ),
                )
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 0.03 * MediaQuery.of(context).size.width),
            child: Container(
              alignment: Alignment.center,
              child: Text(widget.userName,style: const TextStyle(
                  fontFamily: 'roboto',
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white
              ),),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 0.05 * MediaQuery.of(context).size.width),
            child: Container(
              alignment: Alignment.center,
              child: Text(widget.userEmail,style: const TextStyle(
                  fontFamily: 'roboto',
                  fontSize: 14,
                  color: Colors.white
              ),),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 0.03 * MediaQuery.of(context).size.width),
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white,
                    width: 0.7,
                  )
                )
              ),
            ),
          ),
          ListTile(
            contentPadding: const EdgeInsets.only(left: 20),
            minLeadingWidth: 25,
            leading: const Icon(FontAwesomeIcons.question,color: Colors.white,size: 20,),
            title: const Text('Help',style: TextStyle(
                fontFamily: 'roboto',
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white
            ),),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const HelpSupport()));
            },
          ),
          ListTile(
            contentPadding: const EdgeInsets.only(left: 20),
            minLeadingWidth: 25,
            leading: const Icon(FontAwesomeIcons.exclamation,color: Colors.white,size: 20,),
            title: const Text('About Us',style: TextStyle(
                fontFamily: 'roboto',
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white
            ),),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AboutUs()));
            },
          ),
          ListTile(
            contentPadding: const EdgeInsets.only(left: 20),
            minLeadingWidth: 25,
            leading: const Icon(FontAwesomeIcons.book,color: Colors.white,size: 20,),
            title: const Text('Terms and Policies',style: TextStyle(
                fontFamily: 'roboto',
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white
            ),),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const TermsPolicies()));
            },
          ),
          ListTile(
            contentPadding: const EdgeInsets.only(left: 20),
            minLeadingWidth: 25,
            leading: const Icon(FontAwesomeIcons.arrowRightFromBracket,color: Colors.white,size: 20,),
            title: const Text('Logout',style: TextStyle(
                fontFamily: 'roboto',
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white
            ),),
            onTap: () {
              FirebaseAuth.instance.signOut().then((value) {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              });

            },
          ),
        ],
      ),

    );
  }
}