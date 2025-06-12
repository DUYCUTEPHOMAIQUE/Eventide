import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/card_model.dart';
import '../models/user_model.dart';
import 'invite_service.dart';

class CardService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final InviteService _inviteService = InviteService();

  // Get all cards with participant information
  Future<List<CardModel>> getAllCards() async {
    try {
      print('Getting all cards with participants');
      final response = await _supabase
          .from('cards')
          .select('*')
          .order('created_at', ascending: false);

      print('Raw cards response: $response');

      if (response == null) {
        print('No cards found');
        return [];
      }

      List<CardModel> cards = [];
      for (var cardData in response) {
        print('Processing card: ${cardData['id']}');

        // Get accepted participants for this card
        final participants =
            await _inviteService.getAcceptedParticipants(cardData['id']);

        // Create card model with participants
        final card = CardModel.fromJson(cardData);
        card.participants = participants;

        cards.add(card);
        print('Added card with ${participants.length} participants');
      }

      print('Total cards processed: ${cards.length}');
      return cards;
    } catch (e) {
      print('Error getting all cards: $e');
      return [];
    }
  }

  // Get cards by owner
  Future<List<CardModel>> getCardsByOwner(String ownerId) async {
    try {
      print('Getting cards by owner: $ownerId');
      final response = await _supabase
          .from('cards')
          .select('*')
          .eq('owner_id', ownerId)
          .order('created_at', ascending: false);

      print('Raw owner cards response: $response');

      if (response == null) {
        print('No cards found for owner: $ownerId');
        return [];
      }

      List<CardModel> cards = [];
      for (var cardData in response) {
        print('Processing owner card: ${cardData['id']}');

        // Get accepted participants for this card
        final participants =
            await _inviteService.getAcceptedParticipants(cardData['id']);

        // Create card model with participants
        final card = CardModel.fromJson(cardData);
        card.participants = participants;

        cards.add(card);
        print('Added owner card with ${participants.length} participants');
      }

      print('Total owner cards processed: ${cards.length}');
      return cards;
    } catch (e) {
      print('Error getting cards by owner: $e');
      return [];
    }
  }

  // Get a single card with participant information
  Future<CardModel?> getCardById(String cardId) async {
    try {
      print('Getting card by id: $cardId');
      final response =
          await _supabase.from('cards').select('*').eq('id', cardId).single();

      print('Raw card response: $response');

      if (response == null) {
        print('Card not found: $cardId');
        return null;
      }

      // Get accepted participants for this card
      final participants = await _inviteService.getAcceptedParticipants(cardId);

      // Create card model with participants
      final card = CardModel.fromJson(response);
      card.participants = participants;

      print('Card loaded with ${participants.length} participants');
      return card;
    } catch (e) {
      print('Error getting card by id: $e');
      return null;
    }
  }

  // Create a new card
  Future<CardModel?> createCard({
    required String title,
    required String description,
    required String ownerId,
    String? imageUrl,
    String? backgroundImageUrl,
    String? location,
    double? latitude,
    double? longitude,
    DateTime? eventDateTime,
  }) async {
    try {
      print('Creating new card - Title: $title, Owner: $ownerId');

      final response = await _supabase
          .from('cards')
          .insert({
            'title': title,
            'description': description,
            'owner_id': ownerId,
            'image_url': imageUrl ?? '',
            'background_image_url': backgroundImageUrl ?? 'default',
            'location': location ?? '',
            'latitude': latitude,
            'longitude': longitude,
            'event_date_time': eventDateTime?.toIso8601String(),
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      print('Create card response: $response');

      if (response == null) {
        print('Failed to create card');
        return null;
      }

      final card = CardModel.fromJson(response);
      print('Card created successfully: ${card.id}');
      return card;
    } catch (e) {
      print('Error creating card: $e');
      return null;
    }
  }

  // Update a card
  Future<bool> updateCard({
    required String cardId,
    String? title,
    String? description,
    String? imageUrl,
    String? backgroundImageUrl,
    String? location,
    double? latitude,
    double? longitude,
    DateTime? eventDateTime,
  }) async {
    try {
      print('Updating card: $cardId');

      final updateData = <String, dynamic>{};
      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (imageUrl != null) updateData['image_url'] = imageUrl;
      if (backgroundImageUrl != null)
        updateData['background_image_url'] = backgroundImageUrl;
      if (location != null) updateData['location'] = location;
      if (latitude != null) updateData['latitude'] = latitude;
      if (longitude != null) updateData['longitude'] = longitude;
      if (eventDateTime != null)
        updateData['event_date_time'] = eventDateTime.toIso8601String();

      print('Update data: $updateData');

      final response = await _supabase
          .from('cards')
          .update(updateData)
          .eq('id', cardId)
          .select();

      print('Update card response: $response');

      final success = response != null && response.isNotEmpty;
      print(success ? 'Card updated successfully' : 'Failed to update card');
      return success;
    } catch (e) {
      print('Error updating card: $e');
      return false;
    }
  }

  // Delete a card
  Future<bool> deleteCard(String cardId) async {
    try {
      print('Deleting card: $cardId');

      // First delete all invites for this card
      await _supabase.from('invites').delete().eq('card_id', cardId);

      print('Deleted invites for card: $cardId');

      // Then delete the card
      final response =
          await _supabase.from('cards').delete().eq('id', cardId).select();

      print('Delete card response: $response');

      final success = response != null && response.isNotEmpty;
      print(success ? 'Card deleted successfully' : 'Failed to delete card');
      return success;
    } catch (e) {
      print('Error deleting card: $e');
      return false;
    }
  }

  // Get cards where user is a participant
  Future<List<CardModel>> getCardsUserParticipates(String userId) async {
    try {
      print('Getting cards user participates: $userId');

      final response = await _supabase.from('invites').select('''
            card_id,
            cards!inner(*)
          ''').eq('receiver_id', userId).eq('status', 'accepted');

      print('Raw participation response: $response');

      if (response == null) {
        print('No participation found for user: $userId');
        return [];
      }

      List<CardModel> cards = [];
      for (var inviteData in response) {
        if (inviteData['cards'] != null) {
          final cardData = inviteData['cards'];
          print('Processing participation card: ${cardData['id']}');

          final participants =
              await _inviteService.getAcceptedParticipants(cardData['id']);

          final card = CardModel.fromJson(cardData);
          card.participants = participants;

          cards.add(card);
          print(
              'Added participation card with ${participants.length} participants');
        }
      }

      print('Total participation cards: ${cards.length}');
      return cards;
    } catch (e) {
      print('Error getting cards user participates: $e');
      return [];
    }
  }
}
