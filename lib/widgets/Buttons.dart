import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lawhub/widgets/fonts.dart';

class button extends StatelessWidget {
  final String text;
  final Icon? btIcon;
  final Color? btTextColor;
  final Color? btBgColor;
  final FontStyle? btFontSize;
  final VoidCallback? callBack;

  button({
    required this.text,
    this.btIcon,
    this.btTextColor = Colors.white,
    this.btBgColor,
    this.btFontSize,
    this.callBack,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: btBgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15)
        )
      ),
        onPressed: () {
          callBack!();
        },
        child: btIcon != null
            ? Row(
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      fontFamily: "patua",
                      color: btTextColor,
                      fontSize: 24,
                    ),
                  ),
                  btIcon!,
                ],
              )
            : Column(
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      fontFamily: "patua",
                      color: btTextColor,
                      fontSize: 18,
                    ),
                  )
                ],
              )
        
    );
  }
}
