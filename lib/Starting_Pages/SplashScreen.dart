import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:lawhub/Starting_Pages/GetStartPage.dart';
import 'package:lawhub/main.dart';
import 'package:lawhub/widgets/Fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SplashScreen extends StatefulWidget{
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const GetStart(),
          ));
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.blue,
        child: const Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LogoFont(text: "LAWHUB", textColor: Colors.white),
            SizedBox(height: 10,),
            SpinKitCircle(
              color: Colors.white,
              size: 34,
            )
          ],
        ))
      ),
    );
  }
}