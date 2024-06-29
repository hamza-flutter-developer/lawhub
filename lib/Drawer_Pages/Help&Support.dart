// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lawhub/main.dart';

class HelpSupport extends StatefulWidget{
  const HelpSupport({super.key});

  @override
  State<HelpSupport> createState() => _HelpSupportState();
}

class _HelpSupportState extends State<HelpSupport> {
  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _emailPhoneController = TextEditingController();

  final TextEditingController _statementController = TextEditingController();

  final _form = GlobalKey<FormState>();

  bool isLoading = false;

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
                "Help & Support",
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
        body: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 0.04 * MediaQuery.of(context).size.height),
                  child: const Text('Tech Support',
                    style: TextStyle(
                      fontFamily: 'roboto',
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      wordSpacing: 2,
                    ),),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 0.02 * MediaQuery.of(context).size.height),
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: Image.asset(
                      'assets/images/customer-support.png',
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(0.05 * MediaQuery.of(context).size.height),
                  child: Form(
                    key: _form,
                    child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        textAlignVertical: TextAlignVertical.center,
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                        decoration: const InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                            borderSide:
                            BorderSide(color: Colors.black),
                          ),
                          prefixIcon: Icon(
                            FontAwesomeIcons.userLarge,
                            size: 18,
                          ),
                          prefixIconColor: Colors.black,
                          prefixIconConstraints: BoxConstraints(
                            minWidth: 65,
                          ),
                          hintText: "Full Name",
                          focusColor: Colors.black,
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Enter Name";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: _emailPhoneController,
                        textAlignVertical: TextAlignVertical.center,
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                            borderSide:
                            BorderSide(color: Colors.black),
                          ),
                          prefixIcon: Icon(
                            Icons.email,
                            size: 22,
                          ),
                          prefixIconColor: Colors.black,
                          prefixIconConstraints: BoxConstraints(
                            minWidth: 65,
                          ),
                          hintText: "Email/Phone No",
                          focusColor: Colors.black,
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Enter Email/Phone No";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: _statementController,
                        textAlignVertical: TextAlignVertical.center,
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                        maxLines: 4,
                        decoration: const InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                            borderSide:
                            BorderSide(color: Colors.black),
                          ),
                          hintText: "Please Explain your problem",
                          focusColor: Colors.black,
                        ),
                      ),
                    ],
                  )),
                ),
                SizedBox(
                  width: 300,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: ()  async {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const MyHomePage()));
                        },
                        style: ElevatedButton.styleFrom(
                            fixedSize: const Size(200, 20),
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(15))),
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
                            : const Text('Next',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'roboto',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            )),

                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        )
    );
  }
}