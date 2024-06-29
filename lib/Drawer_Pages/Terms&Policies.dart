// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TermsPolicies extends StatelessWidget{
  const TermsPolicies({super.key});

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
                "Terms & Policies",
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
          child: Padding(
            padding: const EdgeInsets.only(top: 30,left: 20,right: 20,bottom: 15),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('1. Acceptance of Terms:',
                    style: TextStyle(
                      fontFamily: 'roboto',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      wordSpacing: 2,
                    ),),
                  const SizedBox(
                    height: 10,
                  ),
                  RichText(
                    textAlign: TextAlign.justify,
                    text: const TextSpan(
                      style: TextStyle(
                        fontFamily: 'roboto',
                        fontSize: 15.5,
                        color: Colors.black,
                        height: 1.7,
                        wordSpacing: 1.5,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Welcome to ',
                        ),
                        TextSpan(
                          text: '"LAWHUB"',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: '. By using our lawyer hiring app you agree to comply with these Terms of Service Terms.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const Text('2. Use of the App:',
                    style: TextStyle(
                      fontFamily: 'roboto',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      wordSpacing: 2,
                    ),),
                  const SizedBox(
                    height: 15,
                  ),
                  RichText(
                    textAlign: TextAlign.justify,
                    text: const TextSpan(
                        style: TextStyle(
                          fontFamily: 'roboto',
                          fontSize: 15.5,
                          color: Colors.black,
                          height: 1.7,
                          wordSpacing: 1.5,
                        ),
                        children: <TextSpan>[
                          TextSpan(text: '1 -  ',style: TextStyle(
                            fontFamily: 'roboto',
                            fontWeight: FontWeight.bold,
                            fontSize: 15.5,
                            wordSpacing: 2,
                          ),),
                          TextSpan(text: 'You must be of legal age in your jurisdiction to use the App. If you are using the App on behalf of an organization or entity, you represent and warrant that you have the authority to bind that organization or entity to these Terms.')
                        ]
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  RichText(
                    textAlign: TextAlign.justify,
                    text: const TextSpan(
                        style: TextStyle(
                          fontFamily: 'roboto',
                          fontSize: 15.5,
                          color: Colors.black,
                          height: 1.7,
                          wordSpacing: 1.5,
                        ),
                        children: <TextSpan>[
                          TextSpan(text: '2 -  ',style: TextStyle(
                            fontFamily: 'roboto',
                            fontWeight: FontWeight.bold,
                            fontSize: 15.5,
                            wordSpacing: 2,
                          ),),
                          TextSpan(text: 'You are responsible for maintaining the confidentiality of your account credentials, including your username and password. You agree to provide accurate and complete information when using the App.'),
                              ]
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  RichText(
                    textAlign: TextAlign.justify,
                    text: const TextSpan(
                        style: TextStyle(
                          fontFamily: 'roboto',
                          fontSize: 15.5,
                          color: Colors.black,
                          height: 1.7,
                          wordSpacing: 1.5,
                        ),
                        children: <TextSpan>[
                          TextSpan(text: '3 -  ',style: TextStyle(
                            fontFamily: 'roboto',
                            fontWeight: FontWeight.bold,
                            fontSize: 15.5,
                            wordSpacing: 2,
                          ),),
                          TextSpan(text: 'You agree not to engage in any activity that violates applicable laws or regulations when using the App. Prohibited activities include but are not limited to:'),
                          ]
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 23),
                    child: RichText(
                      textAlign: TextAlign.justify,
                      text: const TextSpan(
                          style: TextStyle(
                            fontFamily: 'roboto',
                            fontSize: 15.5,
                            color: Colors.black,
                            height: 1.7,
                            wordSpacing: 1.5,
                          ),
                          children: <TextSpan>[
                            TextSpan(text: '1. ',style: TextStyle(
                              fontFamily: 'roboto',
                              fontWeight: FontWeight.bold,
                              fontSize: 15.5,
                              wordSpacing: 2,
                            ),),
                            TextSpan(text: 'Impersonating another person or entity.')
                          ]
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 23),
                    child: RichText(
                      textAlign: TextAlign.justify,
                      text: const TextSpan(
                          style: TextStyle(
                            fontFamily: 'roboto',
                            fontSize: 15.5,
                            color: Colors.black,
                            height: 1.7,
                            wordSpacing: 1.5,
                          ),
                          children: <TextSpan>[
                            TextSpan(text: '2. ',style: TextStyle(
                              fontFamily: 'roboto',
                              fontWeight: FontWeight.bold,
                              fontSize: 15.5,
                              wordSpacing: 2,
                            ),),
                            TextSpan(text: 'Uploading, transmitting, or distributing harmful, malicious, or illegal content.'),
                                ]
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 23),
                    child: RichText(
                      textAlign: TextAlign.justify,
                      text: const TextSpan(
                          style: TextStyle(
                            fontFamily: 'roboto',
                            fontSize: 15.5,
                            color: Colors.black,
                            height: 1.7,
                            wordSpacing: 1.5,
                          ),
                          children: <TextSpan>[
                            TextSpan(text: '3. ',style: TextStyle(
                              fontFamily: 'roboto',
                              fontWeight: FontWeight.bold,
                              fontSize: 15.5,
                              wordSpacing: 2,
                            ),),
                            TextSpan(text: 'Attempting to gain unauthorized access to the App\'s systems or data.'),
                                ]
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 23),
                    child: RichText(
                      textAlign: TextAlign.justify,
                      text: const TextSpan(
                          style: TextStyle(
                            fontFamily: 'roboto',
                            fontSize: 15.5,
                            color: Colors.black,
                            height: 1.7,
                            wordSpacing: 1.5,
                          ),
                          children: <TextSpan>[
                            TextSpan(text: '4. ',style: TextStyle(
                              fontFamily: 'roboto',
                              fontWeight: FontWeight.bold,
                              fontSize: 15.5,
                              wordSpacing: 2,
                            ),),
                            TextSpan(text: 'Harassing, threatening, or harming other users or third parties.'),
                                ]
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const Text('3. Service Description:',
                    style: TextStyle(
                      fontFamily: 'roboto',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      wordSpacing: 2,
                    ),),
                  const SizedBox(
                    height: 15,
                  ),
                  RichText(
                    textAlign: TextAlign.justify,
                    text: const TextSpan(
                        style: TextStyle(
                          fontFamily: 'roboto',
                          fontSize: 15.5,
                          color: Colors.black,
                          height: 1.7,
                          wordSpacing: 1.5,
                        ),
                        children: <TextSpan>[
                          TextSpan(text: '1 -  ',style: TextStyle(
                            fontFamily: 'roboto',
                            fontWeight: FontWeight.bold,
                            fontSize: 15.5,
                            wordSpacing: 2,
                          ),),
                          TextSpan(text: 'The App is designed to connect clients seeking legal services with lawyers. We do not provide legal services ourselves and do not endorse any specific lawyers or legal services.'),
                              ]
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  RichText(
                    textAlign: TextAlign.justify,
                    text: const TextSpan(
                        style: TextStyle(
                          fontFamily: 'roboto',
                          fontSize: 15.5,
                          color: Colors.black,
                          height: 1.7,
                          wordSpacing: 1.5,
                        ),
                        children: <TextSpan>[
                          TextSpan(text: '2 -  ',style: TextStyle(
                            fontFamily: 'roboto',
                            fontWeight: FontWeight.bold,
                            fontSize: 15.5,
                            wordSpacing: 2,
                          ),),
                          TextSpan(text: 'We strive to maintain the availability and performance of the App but do not guarantee uninterrupted access. We reserve the right to modify, suspend, or discontinue the App at any time.'),
                              ]
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const Text('4. Intellectual Property:',
                    style: TextStyle(
                      fontFamily: 'roboto',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      wordSpacing: 2,
                    ),),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text('The App, including its content and intellectual property, is owned by us and protected by copyright and other laws. You may not use, reproduce, or distribute our content without our express permission.',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontFamily: 'roboto',
                      fontSize: 15.5,
                      color: Colors.black,
                      height: 1.7,
                      wordSpacing: 1.5,
                    ),),
                  const SizedBox(
                    height: 30,
                  ),
                  const Text('5. Privacy Policy:',
                    style: TextStyle(
                      fontFamily: 'roboto',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      wordSpacing: 2,
                    ),),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text('By using the App, you agree to the terms outlined in our Privacy Policy, which describes how we collect, use, and protect your data. Please review our Privacy Policy for more information.',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontFamily: 'roboto',
                      fontSize: 15.5,
                      color: Colors.black,
                      height: 1.7,
                      wordSpacing: 1.5,
                    ),),
                  const SizedBox(
                    height: 30,
                  ),
                  const Text('6. Limitation of Liability:',
                    style: TextStyle(
                      fontFamily: 'roboto',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      wordSpacing: 2,
                    ),),
                  const SizedBox(
                    height: 15,
                  ),
                  RichText(
                    textAlign: TextAlign.justify,
                    text: const TextSpan(
                        style: TextStyle(
                          fontFamily: 'roboto',
                          fontSize: 15.5,
                          color: Colors.black,
                          height: 1.7,
                          wordSpacing: 1.5,
                        ),
                        children: <TextSpan>[
                          TextSpan(text: '1 -  ',style: TextStyle(
                            fontFamily: 'roboto',
                            fontWeight: FontWeight.bold,
                            fontSize: 15.5,
                            wordSpacing: 2,
                          ),),
                          TextSpan(text: 'The App is provided "as is" and "as available." We make no warranties or representations regarding the accuracy, completeness, or reliability of the App.'),
                              ]
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  RichText(
                    textAlign: TextAlign.justify,
                    text: const TextSpan(
                        style: TextStyle(
                          fontFamily: 'roboto',
                          fontSize: 15.5,
                          color: Colors.black,
                          height: 1.7,
                          wordSpacing: 1.5,
                        ),
                        children: <TextSpan>[
                          TextSpan(text: '2 -  ',style: TextStyle(
                            fontFamily: 'roboto',
                            fontWeight: FontWeight.bold,
                            fontSize: 15.5,
                            wordSpacing: 2,
                          ),),
                          TextSpan(text: 'We are not liable for any indirect, incidental, special, consequential, or punitive damages, or any loss of profits or revenues, whether incurred directly or indirectly.'),
                              ]
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const Text('7. Changes to Terms:',
                    style: TextStyle(
                      fontFamily: 'roboto',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      wordSpacing: 2,
                    ),),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text('We may update these Terms as needed. We will notify you of significant changes. Your continued use of the App after such changes constitutes your acceptance of the updated Terms.',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontFamily: 'roboto',
                      fontSize: 15.5,
                      color: Colors.black,
                      height: 1.7,
                      wordSpacing: 1.5,
                    ),),
                  const SizedBox(
                    height: 30,
                  ),
                  const Text('8. Contact Information:',
                    style: TextStyle(
                      fontFamily: 'roboto',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      wordSpacing: 2,
                    ),),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text('If you have questions or concerns about these Terms, please contact us at xyz@gmail.com',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontFamily: 'roboto',
                      fontSize: 15.5,
                      color: Colors.black,
                      height: 1.7,
                      wordSpacing: 1.5,
                    ),),
                ],
              ),
            ),
          ),
        )
    );
  }

}