import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  static final ImagePicker _picker = ImagePicker();

  /// Pick single image from gallery
  static Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85, // Compress to reduce file size
        maxWidth: 1920,
        maxHeight: 1080,
      );

      return image;
    } catch (e) {
      print('Error picking image from gallery: $e');
      return null;
    }
  }

  /// Pick single image from camera
  static Future<XFile?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      return image;
    } catch (e) {
      print('Error picking image from camera: $e');
      return null;
    }
  }

  /// Show selection dialog for camera or gallery
  static void showImageSourceDialog(
    context, {
    required Function(XFile?) onImageSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.white),
                title: const Text(
                  'Choose from Gallery',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final image = await pickImageFromGallery();
                  onImageSelected(image);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.white),
                title: const Text(
                  'Take Photo',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final image = await pickImageFromCamera();
                  onImageSelected(image);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.white70),
                title: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white70),
                ),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Pick multiple images from gallery
  static Future<List<XFile>> pickMultipleImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      return images;
    } catch (e) {
      print('Error picking multiple images: $e');
      return [];
    }
  }

  /// Check if file is valid image and within size limit
  static bool isValidImage(XFile file, {int maxSizeInMB = 10}) {
    try {
      if (kIsWeb) {
        // For web, we can't check file size easily, so we'll just check extension
        final extension = file.name.toLowerCase().split('.').last;
        final validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
        return validExtensions.contains(extension);
      } else {
        // For mobile, check file size and extension
        final fileSizeInBytes = File(file.path).lengthSync();
        final fileSizeInMB = fileSizeInBytes / (1024 * 1024);

        // Check file size
        if (fileSizeInMB > maxSizeInMB) {
          print('File size too large: ${fileSizeInMB.toStringAsFixed(2)}MB');
          return false;
        }

        // Check file extension
        final extension = file.path.toLowerCase().split('.').last;
        final validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];

        if (!validExtensions.contains(extension)) {
          print('Invalid file extension: $extension');
          return false;
        }

        return true;
      }
    } catch (e) {
      print('Error validating image: $e');
      return false;
    }
  }
}
