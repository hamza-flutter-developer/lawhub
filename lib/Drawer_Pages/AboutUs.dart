import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// ignore: use_key_in_widget_constructors
class AboutUs extends StatelessWidget{
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
                icon: const Icon(FontAwesomeIcons.angleLeft, color:  Colors.white,),
                onPressed: () {
                  // Navigate back to the previous page or screen
                  Navigator.of(context).pop();
                },
              ),
            ),
            title: const Padding(
              padding: EdgeInsets.only(top: 13),
              child: Text(
                "About Us",
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
                  const Text('Find Your Legal Partner with “LAWHUB”',
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
                          text: 'In today\'s complex legal landscape, finding the right lawyer can be a daunting task. Whether you\'re facing a personal legal matter or seeking expert counsel for your business, the choice of legal representation is critical. That\'s where ',
                        ),
                        TextSpan(
                          text: '"LAWHUB"',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: ' comes in.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const Text('About LAWHUB:',
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
                          text: ', your trusted platform for connecting clients with experienced lawyers.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const Text('Our Mission:',
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
                          text: 'At ',
                        ),
                        TextSpan(
                          text: '"LAWHUB"',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: ', our mission is to simplify the process of finding and hiring the right legal professionals for your specific needs. We understand that legal matters can be complex and daunting, and that\'s why we\'ve created a user-friendly and secure platform to help you navigate the legal landscape with confidence.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const Text('How It Works:',
                    style: TextStyle(
                      fontFamily: 'roboto',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      wordSpacing: 2,
                    ),),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text('Our app provides a seamless and efficient way to connect clients seeking legal assistance with skilled lawyers in various practice areas. Whether you\'re facing a personal injury case, need assistance with family law matters, or require legal advice in any other field, we\'ve got you covered.',
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
                  const Text('Here\'s how it works:',
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
                        TextSpan(text: 'Clients can search for lawyers based on their specific needs, including practice area, location, and client reviews. Our advanced matching algorithm connects you with lawyers who are best suited to handle your case.')
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
                          TextSpan(text: 'Browse detailed lawyer profiles to learn more about their qualifications, experience, and client testimonials. This helps you make an informed decision when choosing legal representation.')
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
                          TextSpan(text: 'Our app provides a secure and confidential messaging system, allowing you to communicate directly with lawyers, share documents, and ask questions about your case.')
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
                          TextSpan(text: '4 -  ',style: TextStyle(
                            fontFamily: 'roboto',
                            fontWeight: FontWeight.bold,
                            fontSize: 15.5,
                            wordSpacing: 2,
                          ),),
                          TextSpan(text: 'Schedule consultations or appointments with lawyers directly through the app. You can choose convenient meeting times and locations.')
                        ]
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const Text('Your Privacy and Security:',
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
                          text: 'At ',
                        ),
                        TextSpan(
                          text: '"LAWHUB"',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: ', we take your privacy and security seriously. We use state-of-the-art encryption and data protection measures to ensure that your personal information and communications are safe. You can learn more about our commitment to privacy in our Privacy Policy.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const Text('Get Started Today:',
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
                          text: 'Whether you\'re facing a legal challenge, need legal advice, or simply want to explore your legal options, ',
                        ),
                        TextSpan(
                          text: '"LAWHUB"',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: ' is here to help. Our user-friendly platform makes it easy to find the right lawyer for your needs. Get started today and take the first step toward resolving your legal matters with confidence.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const Text('Contact Us:',
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
                          text: 'If you have questions or need assistance, our dedicated support team is here to help. Contact us at xyz@gmail.com for prompt assistance. Thank you for choosing ',
                        ),
                        TextSpan(
                          text: '"LAWHUB"',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: ' as your trusted legal resource.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
    );
  }

}