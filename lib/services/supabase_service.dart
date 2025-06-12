import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/cloudinary_service.dart';
import '../models/card_model.dart';

class SupabaseService {
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get all cards for current user
  Future<List<CardModel>> getAllCardForUser({
    required Function(String) onProgress,
  }) async {
    try {
      onProgress('Đang tải danh sách thẻ...');

      final user = _supabase.auth.currentUser;
      if (user == null) {
        onProgress('Người dùng chưa đăng nhập');
        return [];
      }

      final response = await _supabase
          .from('cards')
          .select()
          .eq('owner_id', user.id)
          .order('created_at', ascending: false);

      print("Supabase response: $response");

      final List<CardModel> cards = (response as List)
          .map((cardData) => CardModel.fromJson(cardData))
          .toList();

      if (cards.isNotEmpty) {
        print("First card: ${cards[0].title}");
      }

      onProgress('Đã tải thành công ${cards.length} thẻ');
      return cards;
    } catch (e) {
      onProgress('Lỗi tải danh sách thẻ: $e');
      print('Error in getAllCardForUser: $e');
      return [];
    }
  }

  /// Create card with progress feedback
  Future<bool> createCard({
    required String title,
    required String description,
    File? backgroundImageFile,
    File? cardImageFile,
    String? location,
    double? latitude,
    double? longitude,
    DateTime? eventDateTime,
    required Function(String) onProgress,
  }) async {
    try {
      String? backgroundImageUrl;
      String? cardImageUrl;

      // Step 1: Upload background image if provided
      if (backgroundImageFile != null) {
        onProgress('Đang upload ảnh nền...');
        backgroundImageUrl = await _cloudinaryService.uploadImageToCloudinary(
          backgroundImageFile,
          folder: 'card_backgrounds',
        );

        if (backgroundImageUrl != null) {
          onProgress('Đã upload ảnh nền thành công');
        } else {
          onProgress('Lỗi upload ảnh nền');
          return false;
        }
      }

      // Step 2: Upload card image if provided
      if (cardImageFile != null) {
        onProgress('Đang upload ảnh kỷ niệm...');
        cardImageUrl = await _cloudinaryService.uploadImageToCloudinary(
          cardImageFile,
          folder: 'card_images',
        );

        if (cardImageUrl != null) {
          onProgress('Đã upload ảnh kỷ niệm thành công');
        } else {
          onProgress('Lỗi upload ảnh kỷ niệm');
          return false;
        }
      }

      // Step 3: Create card in database
      onProgress('Đang tạo thẻ...');

      final user = _supabase.auth.currentUser;
      if (user == null) {
        onProgress('Người dùng chưa đăng nhập');
        return false;
      }

      final response = await _supabase
          .from('cards')
          .insert({
            'title': title,
            'description': description,
            'owner_id': user.id,
            'background_image_url': backgroundImageUrl ?? 'default',
            'location': location ?? '',
            'latitude': latitude,
            'longitude': longitude,
            'image_url': cardImageUrl ?? '',
            'event_date_time': eventDateTime?.toIso8601String(),
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      if (response != null) {
        // Create CardModel with the ID from response
        final newCard = CardModel(
          id: response['id'],
          title: title,
          description: description,
          imageUserUrl: user.userMetadata?['avatar_url'] ?? '',
          ownerId: user.id,
          imageUrl: cardImageUrl ?? '',
          backgroundImageUrl: backgroundImageUrl ?? 'default',
          location: location ?? '',
          latitude: latitude,
          longitude: longitude,
          eventDateTime: eventDateTime,
        );

        onProgress('Đã tạo thẻ thành công!');
        return true;
      } else {
        onProgress('Lỗi tạo thẻ trong database');
        return false;
      }
    } catch (e) {
      onProgress('Lỗi: $e');
      print('Error in createCard: $e');
      return false;
    }
  }
}
