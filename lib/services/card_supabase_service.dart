import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:enva/models/models.dart';

class CardSupabaseService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // Create new card
  static Future<Map<String, dynamic>?> createCard({
    required String title,
    required String description,
    required String location,
    required DateTime? eventDateTime,
    File? backgroundImage,
    List<File>? memoryImages,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw 'User not authenticated';

      String? backgroundImageUrl;
      List<String> memoryImageUrls = [];

      // Upload background image if provided
      if (backgroundImage != null) {
        backgroundImageUrl = await _uploadImage(backgroundImage,
            'backgrounds/${user.id}/${DateTime.now().millisecondsSinceEpoch}_bg.jpg');
      }

      // Upload memory images if provided
      if (memoryImages != null && memoryImages.isNotEmpty) {
        for (int i = 0; i < memoryImages.length; i++) {
          final imageUrl = await _uploadImage(memoryImages[i],
              'memories/${user.id}/${DateTime.now().millisecondsSinceEpoch}_memory_$i.jpg');
          if (imageUrl != null) {
            memoryImageUrls.add(imageUrl);
          }
        }
      }

      // Insert card into database
      final response = await _supabase
          .from('cards')
          .insert({
            'title': title,
            'description': description,
            'location': location,
            'event_date_time': eventDateTime?.toIso8601String(),
            'background_image_url': backgroundImageUrl ?? 'default',
            'memory_images': memoryImageUrls,
            'owner_id': user.id,
            'image_user_url': user.userMetadata?['avatar_url'] ?? '',
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return response;
    } catch (e) {
      print('Error creating card: $e');
      return null;
    }
  }

  // Get user's cards
  static Future<List<CardModel>> getUserCards() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      final response = await _supabase
          .from('cards')
          .select()
          .eq('owner_id', user.id)
          .order('created_at', ascending: false);

      print(response);
      if (response.isNotEmpty) {
        List<CardModel> cards =
            response.map((e) => CardModel.fromJson(e)).toList();
        print("getCardthanh cong");
        print(cards[0]);
        return cards;
      }
      return [];
    } catch (e) {
      print('Error fetching cards: $e');
      return [];
    }
  }

  // Update card
  static Future<Map<String, dynamic>?> updateCard({
    required String cardId,
    String? title,
    String? description,
    String? location,
    DateTime? eventDateTime,
    File? backgroundImage,
    List<File>? memoryImages,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw 'User not authenticated';

      Map<String, dynamic> updateData = {};

      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (location != null) updateData['location'] = location;
      if (eventDateTime != null)
        updateData['event_date_time'] = eventDateTime.toIso8601String();

      // Upload new background image if provided
      if (backgroundImage != null) {
        final imageUrl = await _uploadImage(backgroundImage,
            'backgrounds/${user.id}/${DateTime.now().millisecondsSinceEpoch}_bg.jpg');
        if (imageUrl != null) {
          updateData['background_image_url'] = imageUrl;
        }
      }

      // Upload new memory images if provided
      if (memoryImages != null && memoryImages.isNotEmpty) {
        List<String> memoryImageUrls = [];
        for (int i = 0; i < memoryImages.length; i++) {
          final imageUrl = await _uploadImage(memoryImages[i],
              'memories/${user.id}/${DateTime.now().millisecondsSinceEpoch}_memory_$i.jpg');
          if (imageUrl != null) {
            memoryImageUrls.add(imageUrl);
          }
        }
        updateData['memory_images'] = memoryImageUrls;
      }

      final response = await _supabase
          .from('cards')
          .update(updateData)
          .eq('id', cardId)
          .eq('owner_id', user.id)
          .select()
          .single();

      return response;
    } catch (e) {
      print('Error updating card: $e');
      return null;
    }
  }

  // Delete card
  static Future<bool> deleteCard(String cardId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      await _supabase
          .from('cards')
          .delete()
          .eq('id', cardId)
          .eq('owner_id', user.id);

      return true;
    } catch (e) {
      print('Error deleting card: $e');
      return false;
    }
  }

  // Upload image to Supabase Storage
  static Future<String?> _uploadImage(File image, String path) async {
    try {
      final response =
          await _supabase.storage.from('card-images').upload(path, image);

      if (response.isNotEmpty) {
        return _supabase.storage.from('card-images').getPublicUrl(path);
      }
      return null;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Get public URL for image
  static String getImageUrl(String path) {
    return _supabase.storage.from('card-images').getPublicUrl(path);
  }

  // Search cards by title
  static Future<List<Map<String, dynamic>>> searchCards(String query) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      final response = await _supabase
          .from('cards')
          .select()
          .eq('owner_id', user.id)
          .ilike('title', '%$query%')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error searching cards: $e');
      return [];
    }
  }

  // Get cards by category/filter
  static Future<List<Map<String, dynamic>>> getCardsByFilter({
    String? filter, // 'upcoming', 'past', 'today'
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      var query = _supabase.from('cards').select().eq('owner_id', user.id);

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));

      switch (filter) {
        case 'upcoming':
          query = query.gte('event_date_time', now.toIso8601String());
          break;
        case 'past':
          query = query.lt('event_date_time', now.toIso8601String());
          break;
        case 'today':
          query = query
              .gte('event_date_time', today.toIso8601String())
              .lt('event_date_time', tomorrow.toIso8601String());
          break;
      }

      final response = await query.order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error filtering cards: $e');
      return [];
    }
  }
}
