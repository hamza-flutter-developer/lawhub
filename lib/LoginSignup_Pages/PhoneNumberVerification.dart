import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PhoneNumberVerification extends StatefulWidget {
  @override
  _PhoneNumberVerificationState createState() => _PhoneNumberVerificationState();
}

class _PhoneNumberVerificationState extends State<PhoneNumberVerification> {
  String text = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _phoneNumberController = TextEditingController();
  String verificationId = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Phone Number Verification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(labelText: 'Phone Number'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _verifyPhoneNumber();
              },
              child: Text('Send OTP'),
            ),
            Text(text),
          ],
        ),
      ),
    );
  }

  Future<void> _verifyPhoneNumber() async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: '+${_phoneNumberController.text.trim()}',
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Automatic verification on some devices
          await _auth.signInWithCredential(credential);
          text = 'Phone number automatically verified: ${credential.smsCode}';
        },
        verificationFailed: (FirebaseAuthException e) {
          text = 'Verification failed: $e';
        },
        codeSent: (String verificationId, int? resendToken) {
          // Save the verification ID
          setState(() {
            this.verificationId = verificationId;
          });
          text = 'Code sent to ${_phoneNumberController.text.trim()}';
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Called when the auto-retrieval timer has expired
          text = 'Auto-retrieval timeout';
        },
      );
      setState(() {

      });
    } catch (e) {
      print('Error: $e');
    }
  }
}

