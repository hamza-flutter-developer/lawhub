import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lawhub/widgets/Fonts.dart';

class TopLogo extends StatelessWidget {
  final Color fontColor;

  TopLogo({required this.fontColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 90,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          LogoFont(text: "LAWHUB", textColor: fontColor),
        ],
      ),
    );
  }
}

class SignDetails extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Text('Hassan');
  }

}