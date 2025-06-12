import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

class CloudinaryService {
  static String cloudName = dotenv.env['CLOUD_NAME'] ?? '';
  static String uploadPreset = dotenv.env['UPLOAD_PRESET'] ?? '';
  static String apiKey = dotenv.env['API_KEY'] ?? '';
  static String apiSecret = dotenv.env['API_SECRET'] ?? '';

  String get url => "https://api.cloudinary.com/v1_1/$cloudName/image/upload";

  /// Upload image to Cloudinary and return the secure URL
  Future<String?> uploadImageToCloudinary(File imageFile,
      {String? folder}) async {
    final uri = Uri.parse(url);

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    // Add folder if specified
    if (folder != null) {
      request.fields['folder'] = folder;
    }

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseBody);
        final imageUrl = jsonResponse['secure_url'];
        print("Upload thành công: $imageUrl");
        return imageUrl;
      } else {
        print("Lỗi upload: ${response.statusCode}");
        print(responseBody);
        return null;
      }
    } catch (e) {
      print("Lỗi khi gửi request: $e");
      return null;
    }
  }

  /// Upload image with progress tracking
  Future<String?> uploadImageWithProgress(
    File imageFile, {
    String? folder,
    Function(double progress)? onProgress,
  }) async {
    final uri = Uri.parse(url);

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    // Add folder if specified
    if (folder != null) {
      request.fields['folder'] = folder;
    }

    try {
      final streamedResponse = await request.send();
      final total = streamedResponse.contentLength ?? 0;
      int sent = 0;

      final List<int> responseBytes = [];
      await for (final chunk in streamedResponse.stream) {
        responseBytes.addAll(chunk);
        sent += chunk.length;

        if (onProgress != null && total > 0) {
          onProgress(sent / total);
        }
      }

      if (streamedResponse.statusCode == 200) {
        final responseData = String.fromCharCodes(responseBytes);
        final Map<String, dynamic> jsonResponse = json.decode(responseData);
        final imageUrl = jsonResponse['secure_url'];
        print("Upload thành công: $imageUrl");
        return imageUrl;
      } else {
        print("Lỗi upload: ${streamedResponse.statusCode}");
        return null;
      }
    } catch (e) {
      print("Lỗi khi gửi request: $e");
      return null;
    }
  }

  // Upload image từ file
  Future<String?> uploadImage(File imageFile) async {
    try {
      final url = 'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.fields['upload_preset'] = uploadPreset;
      request.fields['folder'] = 'avatars'; // Lưu trong folder avatars

      final file = await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
      );
      request.files.add(file);

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonData = json.decode(responseData);

      if (response.statusCode == 200) {
        return jsonData['secure_url'] as String?;
      } else {
        print('Upload failed: ${jsonData['error']}');
        return null;
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Upload image từ XFile (từ image_picker)
  Future<String?> uploadImageFromXFile(XFile imageFile) async {
    try {
      final file = File(imageFile.path);
      return await uploadImage(file);
    } catch (e) {
      print('Error uploading image from XFile: $e');
      return null;
    }
  }

  // Upload image từ bytes
  Future<String?> uploadImageFromBytes(
      List<int> imageBytes, String fileName) async {
    try {
      final url = 'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.fields['upload_preset'] = uploadPreset;
      request.fields['folder'] = 'avatars';

      final file = http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: fileName,
      );
      request.files.add(file);

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonData = json.decode(responseData);

      if (response.statusCode == 200) {
        return jsonData['secure_url'] as String?;
      } else {
        print('Upload failed: ${jsonData['error']}');
        return null;
      }
    } catch (e) {
      print('Error uploading image from bytes: $e');
      return null;
    }
  }

  // Delete image từ public ID
  Future<bool> deleteImage(String publicId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final signature = _generateSignature(publicId, timestamp);

      final url = 'https://api.cloudinary.com/v1_1/$cloudName/image/destroy';
      final response = await http.post(
        Uri.parse(url),
        body: {
          'public_id': publicId,
          'api_key': apiKey,
          'timestamp': timestamp.toString(),
          'signature': signature,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  // Generate signature cho delete request
  String _generateSignature(String publicId, int timestamp) {
    // Implement signature generation logic here
    // This is a simplified version - you should implement proper signature generation
    return 'signature_placeholder';
  }
}
