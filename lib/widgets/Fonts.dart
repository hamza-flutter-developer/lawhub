import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LogoFont extends StatelessWidget {
  final String text;
  final Color textColor;

  const LogoFont({super.key,
    required this.text,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: "patua",
        color: textColor,
        fontSize: 34,
      ),
    );
  }
}

class BoldFont extends StatelessWidget {
  final String text;

  const BoldFont({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: "patua",
        fontWeight: FontWeight.w500,
        fontSize: 26,
      ),
    );
  }
}

class NormalFont extends StatelessWidget {
  final String text;

  const NormalFont({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'roboto',
        fontSize: 16,
      ),
    );
  }
}

class NormalBoldFont extends StatelessWidget {
  final String text;

  const NormalBoldFont({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'roboto',
        fontWeight: FontWeight.bold,
        fontSize: 15,
      ),
    );
  }
}
