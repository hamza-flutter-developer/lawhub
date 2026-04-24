import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>?> createPaymentIntent({
  required String name,
  required String address,
  required String pin,
  required String city,
  required String state,
  required String country,
  required String currency,
  required String amount,
}) async {
  final backendUrl = dotenv.env['PAYMENT_BACKEND_URL'];
  if (backendUrl == null || backendUrl.isEmpty) {
    debugPrint('[Payment] PAYMENT_BACKEND_URL not set in .env');
    return null;
  }

  final email = FirebaseAuth.instance.currentUser?.email ?? '';

  final response = await http.post(
    Uri.parse(backendUrl),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'amount': amount,
      'currency': currency.toLowerCase(),
      'name': name,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'pin': pin,
      'email': email,
    }),
  );

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    debugPrint('[Payment] Intent created: ${json['paymentIntent']}');
    return json;
  } else {
    debugPrint('[Payment] Backend error ${response.statusCode}: ${response.body}');
    return null;
  }
}
