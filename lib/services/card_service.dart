import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/card_model.dart';
import '../models/user_model.dart';
import 'invite_service.dart';

class CardService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final InviteService _inviteService = InviteService();

  // Get all cards with participant information (owned + accepted invitations)
  Future<List<CardModel>> getAllCards() async {
    try {
      print('Getting all cards (owned + accepted invitations)');

      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        print('No current user found');
        return [];
      }

      // Get cards owned by current user
      final ownedResponse = await _supabase
          .from('cards')
          .select('*')
          .eq('owner_id', currentUser.id)
          .order('created_at', ascending: false);

      print('Raw owned cards response: $ownedResponse');

      // Get cards where user is accepted participant
      final acceptedResponse = await _supabase.from('invites').select('''
            card_id,
            cards!inner(*)
          ''').eq('receiver_id', currentUser.id);

      print('Raw accepted invitations response: $acceptedResponse');

      List<CardModel> allCards = [];

      // Process owned cards
      if (ownedResponse != null) {
        for (var cardData in ownedResponse) {
          print('Processing owned card: ${cardData['id']}');

          // Get accepted participants for this card
          final participants =
              await _inviteService.getAcceptedParticipants(cardData['id']);

          // Create card model with participants
          final card = CardModel.fromJson(cardData);
          card.participants = participants;

          allCards.add(card);
          print('Added owned card with ${participants.length} participants');
        }
      }

      // Process accepted invitation cards
      if (acceptedResponse != null) {
        for (var inviteData in acceptedResponse) {
          if (inviteData['cards'] != null) {
            final cardData = inviteData['cards'];
            final cardId = cardData['id'];

            // Skip if already added (owned by user)
            if (allCards.any((card) => card.id == cardId)) {
              print('Skipping already added card: $cardId');
              continue;
            }

            print('Processing accepted invitation card: $cardId');

            final participants =
                await _inviteService.getAcceptedParticipants(cardId);

            final card = CardModel.fromJson(cardData);
            card.participants = participants;

            allCards.add(card);
            print(
                'Added accepted invitation card with ${participants.length} participants');
          }
        }
      }

      // Sort by created_at descending
      allCards.sort((a, b) => b.created_at.compareTo(a.created_at));

      print('Total all cards: ${allCards.length}');
      return allCards;
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

  // Get cards user participates
  Future<List<CardModel>> getCardsUserParticipates(String userId) async {
    try {
      print('Getting cards user participates: $userId');

      final response = await _supabase.from('invites').select('''
            card_id,
            cards!inner(*)
          ''').eq('receiver_id', userId).eq('status', 'going');

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

  // Get pending invitation cards for current user
  Future<List<CardModel>> getPendingInvitationCards() async {
    try {
      print('Getting pending invitation cards');

      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        print('No current user found');
        return [];
      }

      final response = await _supabase.from('invites').select('''
            card_id,
            cards!inner(*)
          ''').eq('receiver_id', currentUser.id).eq('status', 'pending');

      print('Raw pending invitations response: $response');

      if (response == null) {
        print('No pending invitations found for user: ${currentUser.id}');
        return [];
      }

      List<CardModel> cards = [];
      for (var inviteData in response) {
        if (inviteData['cards'] != null) {
          final cardData = inviteData['cards'];
          print('Processing pending invitation card: ${cardData['id']}');

          final participants =
              await _inviteService.getAcceptedParticipants(cardData['id']);

          final card = CardModel.fromJson(cardData);
          card.participants = participants;

          cards.add(card);
          print(
              'Added pending invitation card with ${participants.length} participants');
        }
      }

      print('Total pending invitation cards: ${cards.length}');
      return cards;
    } catch (e) {
      print('Error getting pending invitation cards: $e');
      return [];
    }
  }

  // Get accepted invitation cards for current user
  Future<List<CardModel>> getAcceptedInvitationCards() async {
    try {
      print('Getting going invitation cards');

      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        print('No current user found');
        return [];
      }

      final response = await _supabase.from('invites').select('''
            card_id,
            cards!inner(*)
          ''').eq('receiver_id', currentUser.id).eq('status', 'going');

      print('Raw going invitations response: $response');

      if (response == null) {
        print('No going invitations found for user: ${currentUser.id}');
        return [];
      }

      List<CardModel> cards = [];
      for (var inviteData in response) {
        if (inviteData['cards'] != null) {
          final cardData = inviteData['cards'];
          print('Processing going invitation card: ${cardData['id']}');

          final participants =
              await _inviteService.getAcceptedParticipants(cardData['id']);

          final card = CardModel.fromJson(cardData);
          card.participants = participants;

          cards.add(card);
          print(
              'Added going invitation card with ${participants.length} participants');
        }
      }

      print('Total going invitation cards: ${cards.length}');
      return cards;
    } catch (e) {
      print('Error getting going invitation cards: $e');
      return [];
    }
  }

  // Get declined invitation cards for current user
  Future<List<CardModel>> getDeclinedInvitationCards() async {
    try {
      print('Getting not going invitation cards');

      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        print('No current user found');
        return [];
      }

      final response = await _supabase.from('invites').select('''
            card_id,
            cards!inner(*)
          ''').eq('receiver_id', currentUser.id).eq('status', 'notgoing');

      print('Raw not going invitations response: $response');

      if (response == null) {
        print('No not going invitations found for user: ${currentUser.id}');
        return [];
      }

      List<CardModel> cards = [];
      for (var inviteData in response) {
        if (inviteData['cards'] != null) {
          final cardData = inviteData['cards'];
          print('Processing not going invitation card: ${cardData['id']}');

          final participants =
              await _inviteService.getAcceptedParticipants(cardData['id']);

          final card = CardModel.fromJson(cardData);
          card.participants = participants;

          cards.add(card);
          print(
              'Added not going invitation card with ${participants.length} participants');
        }
      }

      print('Total not going invitation cards: ${cards.length}');
      return cards;
    } catch (e) {
      print('Error getting not going invitation cards: $e');
      return [];
    }
  }
}
