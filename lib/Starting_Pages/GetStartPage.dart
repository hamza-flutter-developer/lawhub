import 'package:flutter/material.dart';
import 'package:lawhub/LoginSignup_Pages/LoginPage.dart';
import 'package:lawhub/widgets/Themes.dart';

class GetStart extends StatelessWidget {
  const GetStart({super.key});
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(
                  top: 0.03 * screenHeight,
                  bottom: 0.03 * screenHeight,
              ),
              child: TopLogo(fontColor: Colors.blue),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 0.8 * screenWidth,
                    height: 0.8 * screenWidth,
                    child: Image.asset("assets/images/GetStart.jpg"),
                  ),
                  Column(
                    children: [
                      SizedBox(
                        width: 0.8 * screenWidth,
                        child: const Text(
                          "Legal Solutions at Your Fingertips",
                          style: TextStyle(
                            fontFamily: "patua",
                            fontWeight: FontWeight.w500,
                            fontSize: 26,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 0.01 * screenHeight),
                        child: SizedBox(
                          width: 0.7 * screenWidth,
                          child: const Text(
                            "Unlock Justice: Connect with Top Lawyers in Your Area – Your Legal Solution Just a Click Away!",
                            style: TextStyle(
                              fontFamily: 'roboto',
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 0.015 * screenHeight),
              child: SizedBox(
                width: 0.8 * screenWidth,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      'Get Started',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'roboto',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
