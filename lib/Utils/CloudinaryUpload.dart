// ignore_for_file: file_names

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CloudinaryUpload {
  static const String _baseUrl = 'https://api.cloudinary.com/v1_1';
  
  /// Upload license image
  static Future<String> uploadLicenseImage(File imageFile) async {
    return await uploadImage(
      imageFile: imageFile,
      folder: 'lawyers_license',
    );
  }
  
  /// Upload chat image
  static Future<String> uploadChatImage(File imageFile) async {
    return await uploadImage(
      imageFile: imageFile,
      folder: 'chat_images',
    );
  }
  
  /// Upload profile picture
  static Future<String> uploadProfilePicture(File imageFile) async {
    return await uploadImage(
      imageFile: imageFile,
      folder: 'profile_pictures',
    );
  }
  
  /// Upload case payment screenshot
  static Future<String> uploadCasePaymentImage(File imageFile) async {
    return await uploadImage(
      imageFile: imageFile,
      folder: 'case_payments',
    );
  }
  
  /// Generic upload method
  static Future<String> uploadImage({
    required File imageFile,
    required String folder,
  }) async {
    try {
      debugPrint("=== CLOUDINARY UPLOAD DEBUG ===");
      debugPrint("Checking .env file...");
      
      final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'];
      final uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'];
      
      debugPrint("Cloud Name: ${cloudName ?? 'NULL'}");
      debugPrint("Upload Preset: ${uploadPreset ?? 'NULL'}");
      
      if (cloudName == null || uploadPreset == null) {
        throw Exception('Cloudinary credentials not found in .env file. CloudName: $cloudName, Preset: $uploadPreset');
      }
      
      debugPrint("Image file path: ${imageFile.path}");
      debugPrint("Image file exists: ${await imageFile.exists()}");
      debugPrint("Image file size: ${await imageFile.length()} bytes");
      
      final url = Uri.parse('$_baseUrl/$cloudName/image/upload');
      
      final request = http.MultipartRequest('POST', url);
      request.fields['upload_preset'] = uploadPreset;
      request.fields['folder'] = folder;
      
      final fileStream = http.ByteStream(imageFile.openRead());
      final fileLength = await imageFile.length();
      
      final multipartFile = http.MultipartFile(
        'file',
        fileStream,
        fileLength,
        filename: imageFile.path.split('/').last,
      );
      
      request.files.add(multipartFile);
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['secure_url'] as String;
      } else {
        throw Exception('Failed to upload image: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error uploading to Cloudinary: $e');
    }
  }
}
