import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/invite_model.dart';
import '../models/user_model.dart';
import 'notification_service.dart';

class InviteService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final NotificationService _notificationService = NotificationService();

  // Get all invites for a card with participant information
  Future<List<InviteModel>> getInvitesForCard(String cardId) async {
    try {
      print('Getting invites for card: $cardId');
      final response =
          await _supabase.from('invites').select('*').eq('card_id', cardId);

      print('Raw invites response: $response');

      if (response == null) {
        print('No invites found for card: $cardId');
        return [];
      }

      final invites = (response as List)
          .map((invite) => InviteModel.fromJson(invite))
          .toList();

      print('Found ${invites.length} invites for card: $cardId');
      return invites;
    } catch (e) {
      print('Error getting invites for card: $e');
      return [];
    }
  }

  // Get all invited users for a card (including pending, accepted, etc.)
  Future<List<UserModel>> getAllInvitedUsers(String cardId) async {
    try {
      print('Getting all invited users for card: $cardId');

      // First, get all invites for this card
      final invites = await getInvitesForCard(cardId);

      if (invites.isEmpty) {
        print('No invites found for card: $cardId');
        return [];
      }

      // Extract all receiver IDs
      final receiverIds = invites.map((invite) => invite.receiverId).toList();
      print('Receiver IDs found: $receiverIds');

      // Query profiles table to get user information
      List<UserModel> users = [];

      for (String receiverId in receiverIds) {
        try {
          print('Querying user info for ID: $receiverId');

          // Query profiles table
          final userResponse = await _supabase
              .from('profiles')
              .select('*')
              .eq('id', receiverId)
              .single();

          print('User response for $receiverId: $userResponse');

          if (userResponse != null) {
            final user = UserModel.fromJson(userResponse);
            users.add(user);
            print('Added user: ${user.displayName ?? user.email}');
          }
        } catch (e) {
          print('Error getting user info for $receiverId: $e');
          // Continue with other users even if one fails
        }
      }

      print('Total users found: ${users.length}');
      return users;
    } catch (e) {
      print('Error getting all invited users: $e');
      return [];
    }
  }

  // Get accepted participants for a card
  Future<List<UserModel>> getAcceptedParticipants(String cardId) async {
    try {
      print('Getting accepted participants for card: $cardId');

      // Get invites with status 'accepted'
      final response = await _supabase
          .from('invites')
          .select('receiver_id')
          .eq('card_id', cardId)
          .eq('status', 'accepted');

      print('Accepted invites response: $response');

      if (response == null || response.isEmpty) {
        print('No accepted participants found for card: $cardId');
        return [];
      }

      // Extract receiver IDs
      final receiverIds = (response as List)
          .map((invite) => invite['receiver_id'] as String)
          .toList();

      print('Accepted receiver IDs: $receiverIds');

      // Query user information for each accepted participant
      List<UserModel> participants = [];

      for (String receiverId in receiverIds) {
        try {
          print('Querying accepted user info for ID: $receiverId');

          final userResponse = await _supabase
              .from('profiles')
              .select('*')
              .eq('id', receiverId)
              .single();

          print('Accepted user response for $receiverId: $userResponse');

          if (userResponse != null) {
            final user = UserModel.fromJson(userResponse);
            participants.add(user);
            print(
                'Added accepted participant: ${user.displayName ?? user.email}');
          }
        } catch (e) {
          print('Error getting accepted user info for $receiverId: $e');
        }
      }

      print('Total accepted participants: ${participants.length}');
      return participants;
    } catch (e) {
      print('Error getting accepted participants: $e');
      return [];
    }
  }

  // Send invite to a user
  Future<bool> sendInvite({
    required String cardId,
    required String senderId,
    required String receiverId,
  }) async {
    try {
      print(
          'Sending invite - Card: $cardId, Sender: $senderId, Receiver: $receiverId');

      // Check if user is already invited
      final isAlreadyInvited = await isUserInvited(
        cardId: cardId,
        userId: receiverId,
      );

      if (isAlreadyInvited) {
        print(
            'User $receiverId is already invited to card $cardId, only sending notification');

        // Get sender profile for notification
        UserModel? senderProfile;
        try {
          final senderResponse = await _supabase
              .from('profiles')
              .select('*')
              .eq('id', senderId)
              .single();

          if (senderResponse != null) {
            senderProfile = UserModel.fromJson(senderResponse);
            print(
                'Sender profile: ${senderProfile.displayName ?? senderProfile.email}');
          }
        } catch (e) {
          print('Error getting sender profile: $e');
        }

        // Get card title for notification
        String cardTitle = 'Sự kiện';
        try {
          final cardResponse = await _supabase
              .from('cards')
              .select('title')
              .eq('id', cardId)
              .single();

          if (cardResponse != null) {
            cardTitle = cardResponse['title'] ?? 'Sự kiện';
            print('Card title: $cardTitle');
          }
        } catch (e) {
          print('Error getting card title: $e');
        }

        // Send push notification only
        final senderName =
            senderProfile?.displayName ?? senderProfile?.email ?? 'Người dùng';
        final notificationSuccess =
            await _notificationService.sendInviteNotification(
          receiverId: receiverId,
          senderName: senderName,
          cardTitle: cardTitle,
          cardId: cardId,
        );

        print(
            'Notification sent for already invited user: $notificationSuccess');
        return true; // Return true since notification was sent
      }

      // Get sender profile for notification
      UserModel? senderProfile;
      try {
        final senderResponse = await _supabase
            .from('profiles')
            .select('*')
            .eq('id', senderId)
            .single();

        if (senderResponse != null) {
          senderProfile = UserModel.fromJson(senderResponse);
          print(
              'Sender profile: ${senderProfile.displayName ?? senderProfile.email}');
        }
      } catch (e) {
        print('Error getting sender profile: $e');
      }

      // Get card title for notification
      String cardTitle = 'Sự kiện';
      try {
        final cardResponse = await _supabase
            .from('cards')
            .select('title')
            .eq('id', cardId)
            .single();

        if (cardResponse != null) {
          cardTitle = cardResponse['title'] ?? 'Sự kiện';
          print('Card title: $cardTitle');
        }
      } catch (e) {
        print('Error getting card title: $e');
      }

      // Insert invite into database
      final response = await _supabase.from('invites').insert({
        'card_id': cardId,
        'sender_id': senderId,
        'receiver_id': receiverId,
        'status': 'pending',
        'sent_at': DateTime.now().toIso8601String(),
      }).select();

      print('Send invite response: $response');

      final success = response != null && response.isNotEmpty;

      if (success) {
        print('Invite sent successfully, sending notification...');

        // Send push notification
        final senderName =
            senderProfile?.displayName ?? senderProfile?.email ?? 'Người dùng';
        final notificationSuccess =
            await _notificationService.sendInviteNotification(
          receiverId: receiverId,
          senderName: senderName,
          cardTitle: cardTitle,
          cardId: cardId,
        );

        print('Notification sent: $notificationSuccess');
      } else {
        print('Failed to send invite');
      }

      return success;
    } catch (e) {
      print('Error sending invite: $e');
      return false;
    }
  }

  // Send multiple invites
  Future<bool> sendMultipleInvites({
    required String cardId,
    required String senderId,
    required List<String> receiverIds,
  }) async {
    try {
      print(
          'Sending multiple invites - Card: $cardId, Sender: $senderId, Receivers: $receiverIds');

      // Get sender profile for notification
      UserModel? senderProfile;
      try {
        final senderResponse = await _supabase
            .from('profiles')
            .select('*')
            .eq('id', senderId)
            .single();

        if (senderResponse != null) {
          senderProfile = UserModel.fromJson(senderResponse);
          print(
              'Sender profile: ${senderProfile.displayName ?? senderProfile.email}');
        }
      } catch (e) {
        print('Error getting sender profile: $e');
      }

      // Get card title for notification
      String cardTitle = 'Sự kiện';
      try {
        final cardResponse = await _supabase
            .from('cards')
            .select('title')
            .eq('id', cardId)
            .single();

        if (cardResponse != null) {
          cardTitle = cardResponse['title'] ?? 'Sự kiện';
          print('Card title: $cardTitle');
        }
      } catch (e) {
        print('Error getting card title: $e');
      }

      // Separate already invited users from new users
      List<String> alreadyInvitedUsers = [];
      List<String> newUsers = [];

      for (String receiverId in receiverIds) {
        final isAlreadyInvited = await isUserInvited(
          cardId: cardId,
          userId: receiverId,
        );

        if (isAlreadyInvited) {
          alreadyInvitedUsers.add(receiverId);
          print('User $receiverId is already invited to card $cardId');
        } else {
          newUsers.add(receiverId);
          print('User $receiverId is new, will be invited');
        }
      }

      // Send notifications to already invited users
      if (alreadyInvitedUsers.isNotEmpty) {
        print(
            'Sending notifications to ${alreadyInvitedUsers.length} already invited users');
        final senderName =
            senderProfile?.displayName ?? senderProfile?.email ?? 'Người dùng';
        final notificationSuccess =
            await _notificationService.sendInviteNotifications(
          receiverIds: alreadyInvitedUsers,
          senderName: senderName,
          cardTitle: cardTitle,
          cardId: cardId,
        );
        print(
            'Notifications sent to already invited users: $notificationSuccess');
      }

      // Insert new invites into database
      if (newUsers.isNotEmpty) {
        final invites = newUsers
            .map((receiverId) => {
                  'card_id': cardId,
                  'sender_id': senderId,
                  'receiver_id': receiverId,
                  'status': 'pending',
                  'sent_at': DateTime.now().toIso8601String(),
                })
            .toList();

        print('Invites to send for new users: $invites');

        final response =
            await _supabase.from('invites').insert(invites).select();

        print('Send multiple invites response: $response');

        final success = response != null && response.isNotEmpty;

        if (success) {
          print('New invites sent successfully, sending notifications...');

          // Send push notifications to new users
          final senderName = senderProfile?.displayName ??
              senderProfile?.email ??
              'Người dùng';
          final notificationSuccess =
              await _notificationService.sendInviteNotifications(
            receiverIds: newUsers,
            senderName: senderName,
            cardTitle: cardTitle,
            cardId: cardId,
          );

          print('Notifications sent to new users: $notificationSuccess');
        } else {
          print('Failed to send new invites');
          return false;
        }
      } else {
        print(
            'No new users to invite, only sent notifications to already invited users');
      }

      return true; // Return true if we processed all users (either sent invites or notifications)
    } catch (e) {
      print('Error sending multiple invites: $e');
      return false;
    }
  }

  // Update invite status
  Future<bool> updateInviteStatus({
    required String inviteId,
    required String status,
  }) async {
    try {
      print('Updating invite status - ID: $inviteId, Status: $status');

      final response = await _supabase
          .from('invites')
          .update({'status': status})
          .eq('id', inviteId)
          .select();

      print('Update status response: $response');

      final success = response != null && response.isNotEmpty;
      print(
          success ? 'Status updated successfully' : 'Failed to update status');
      return success;
    } catch (e) {
      print('Error updating invite status: $e');
      return false;
    }
  }

  // Get invites sent by a user
  Future<List<InviteModel>> getInvitesSentByUser(String userId) async {
    try {
      print('Getting invites sent by user: $userId');

      final response =
          await _supabase.from('invites').select('*').eq('sender_id', userId);

      print('Sent invites response: $response');

      if (response == null) {
        print('No sent invites found for user: $userId');
        return [];
      }

      final invites = (response as List)
          .map((invite) => InviteModel.fromJson(invite))
          .toList();

      print('Found ${invites.length} sent invites for user: $userId');
      return invites;
    } catch (e) {
      print('Error getting invites sent by user: $e');
      return [];
    }
  }

  // Get invites received by a user
  Future<List<InviteModel>> getInvitesReceivedByUser(String userId) async {
    try {
      print('Getting invites received by user: $userId');

      final response =
          await _supabase.from('invites').select('*').eq('receiver_id', userId);

      print('Received invites response: $response');

      if (response == null) {
        print('No received invites found for user: $userId');
        return [];
      }

      final invites = (response as List)
          .map((invite) => InviteModel.fromJson(invite))
          .toList();

      print('Found ${invites.length} received invites for user: $userId');
      return invites;
    } catch (e) {
      print('Error getting invites received by user: $e');
      return [];
    }
  }

  // Search users by email or display name
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      print('Searching users with query: $query');

      if (query.isEmpty) {
        print('Empty search query');
        return [];
      }

      final response = await _supabase
          .from('profiles')
          .select('*')
          .or('email.ilike.%$query%,display_name.ilike.%$query%')
          .limit(10);

      print('Search users response: $response');

      if (response == null) {
        print('No users found for query: $query');
        return [];
      }

      final users =
          (response as List).map((user) => UserModel.fromJson(user)).toList();

      print('Found ${users.length} users for query: $query');
      return users;
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  // Check if user is already invited to a card
  Future<bool> isUserInvited({
    required String cardId,
    required String userId,
  }) async {
    try {
      print('Checking if user $userId is invited to card $cardId');

      final response = await _supabase
          .from('invites')
          .select('id')
          .eq('card_id', cardId)
          .eq('receiver_id', userId)
          .single();

      print('Is user invited response: $response');

      final isInvited = response != null;
      print(isInvited ? 'User is already invited' : 'User is not invited');
      return isInvited;
    } catch (e) {
      print('Error checking if user is invited: $e');
      return false;
    }
  }

  // Get current user profile
  Future<UserModel?> getCurrentUserProfile() async {
    try {
      print('Getting current user profile');

      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        print('No current user found');
        return null;
      }

      final response = await _supabase
          .from('profiles')
          .select('*')
          .eq('id', currentUser.id)
          .single();

      print('Current user profile response: $response');

      if (response != null) {
        final user = UserModel.fromJson(response);
        print('Current user: ${user.displayName ?? user.email}');
        return user;
      }

      print('No profile found for current user');
      return null;
    } catch (e) {
      print('Error getting current user profile: $e');
      return null;
    }
  }
}
