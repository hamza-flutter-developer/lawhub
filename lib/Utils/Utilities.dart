import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Utilities {


  void errorMsg (String msg){
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0

    );
  }

  void successMsg (String msg){
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green.shade300,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

  void getMessageFromErrorCode(var e) {
    switch (e) {
      case "ERROR_EMAIL_ALREADY_IN_USE":
      case "account-exists-with-different-credential":
      case "email-already-in-use":
        return errorMsg("Email already used. Go to login page.");
      case "ERROR_WRONG_PASSWORD":
      case "wrong-password":
        return errorMsg("Wrong email/password combination.");
      case "ERROR_USER_NOT_FOUND":
      case "user-not-found":
        return errorMsg("No user found with this email.");
      case "ERROR_USER_DISABLED":
      case "user-disabled":
        return errorMsg("User disabled.");
      case "ERROR_TOO_MANY_REQUESTS":
      case "operation-not-allowed":
        return errorMsg("Too many requests to log into this account.");
      case "ERROR_OPERATION_NOT_ALLOWED":
      case "ERROR_INVALID_EMAIL":
      case "invalid-email":
        return errorMsg("Email address is invalid.");
      case "INVALID_VERIFICATION_CODE":
      case "invalid-verification-code":
        return errorMsg("The verification code from SMS/TOTP is invalid. Please check and enter the correct");
      default:
        return errorMsg("Something went wrong, please try again later.");
    }
  }
}