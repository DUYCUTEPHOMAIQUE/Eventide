import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class ProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Create or update profile after successful signup
  Future<UserModel?> createOrUpdateProfile(User user) async {
    try {
      print('Creating/updating profile for user: ${user.id}');
      print('User email: ${user.email}');
      print('User metadata: ${user.userMetadata}');

      // Extract display name from user metadata
      String? displayName = _extractDisplayName(user);
      String? avatarUrl = _extractAvatarUrl(user);

      print('Extracted display name: $displayName');
      print('Extracted avatar URL: $avatarUrl');

      // Check if profile already exists
      final existingProfile = await _getProfileById(user.id);

      if (existingProfile != null) {
        print('Profile already exists, updating...');
        return await _updateProfile(user.id, displayName, avatarUrl);
      } else {
        print('Profile does not exist, creating new profile...');
        return await _createProfile(
            user.id, user.email ?? '', displayName, avatarUrl);
      }
    } catch (e) {
      print('Error creating/updating profile: $e');
      return null;
    }
  }

  // Extract display name from user metadata
  String? _extractDisplayName(User user) {
    final metadata = user.userMetadata;
    if (metadata == null) return null;

    // Try different possible keys for display name
    String? displayName = metadata['display_name'] ??
        metadata['name'] ??
        metadata['full_name'] ??
        metadata['given_name'];

    // For Google sign-in, combine given_name and family_name if available
    if (displayName == null && metadata['given_name'] != null) {
      final givenName = metadata['given_name'];
      final familyName = metadata['family_name'];
      if (familyName != null) {
        displayName = '$givenName $familyName';
      } else {
        displayName = givenName;
      }
    }

    print('Extracted display name from metadata: $displayName');
    return displayName;
  }

  // Extract avatar URL from user metadata
  String? _extractAvatarUrl(User user) {
    final metadata = user.userMetadata;
    if (metadata == null) return null;

    // Try different possible keys for avatar URL
    String? avatarUrl = metadata['avatar_url'] ??
        metadata['picture'] ??
        metadata['photoURL'] ??
        metadata['image'];

    print('Extracted avatar URL from metadata: $avatarUrl');
    return avatarUrl;
  }

  // Create new profile
  Future<UserModel?> _createProfile(String userId, String email,
      String? displayName, String? avatarUrl) async {
    try {
      print('Creating new profile in database');
      print('User ID: $userId');
      print('Email: $email');
      print('Display Name: $displayName');
      print('Avatar URL: $avatarUrl');

      final response = await _supabase
          .from('profiles')
          .insert({
            'id': userId,
            'email': email,
            'display_name': displayName,
            'avatar_url': avatarUrl,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      print('Profile creation response: $response');

      if (response != null) {
        final userModel = UserModel.fromJson(response);
        print(
            'Profile created successfully: ${userModel.displayName ?? userModel.email}');
        return userModel;
      }

      print('Failed to create profile - no response');
      return null;
    } catch (e) {
      print('Error creating profile: $e');
      return null;
    }
  }

  // Update existing profile
  Future<UserModel?> _updateProfile(
      String userId, String? displayName, String? avatarUrl) async {
    try {
      print('Updating existing profile');
      print('User ID: $userId');
      print('New Display Name: $displayName');
      print('New Avatar URL: $avatarUrl');

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (displayName != null) {
        updateData['display_name'] = displayName;
      }

      if (avatarUrl != null) {
        updateData['avatar_url'] = avatarUrl;
      }

      print('Update data: $updateData');

      final response = await _supabase
          .from('profiles')
          .update(updateData)
          .eq('id', userId)
          .select()
          .single();

      print('Profile update response: $response');

      if (response != null) {
        final userModel = UserModel.fromJson(response);
        print(
            'Profile updated successfully: ${userModel.displayName ?? userModel.email}');
        return userModel;
      }

      print('Failed to update profile - no response');
      return null;
    } catch (e) {
      print('Error updating profile: $e');
      return null;
    }
  }

  // Get profile by user ID
  Future<UserModel?> _getProfileById(String userId) async {
    try {
      print('Getting profile by ID: $userId');

      final response = await _supabase
          .from('profiles')
          .select('*')
          .eq('id', userId)
          .single();

      print('Get profile response: $response');

      if (response != null) {
        final userModel = UserModel.fromJson(response);
        print('Profile found: ${userModel.displayName ?? userModel.email}');
        return userModel;
      }

      print('Profile not found for user: $userId');
      return null;
    } catch (e) {
      print('Error getting profile: $e');
      return null;
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

      print('Current user ID: ${currentUser.id}');

      final response = await _supabase
          .from('profiles')
          .select('*')
          .eq('id', currentUser.id)
          .single();

      print('Current user profile response: $response');

      if (response != null) {
        final userModel = UserModel.fromJson(response);
        print(
            'Current user profile: ${userModel.displayName ?? userModel.email}');
        return userModel;
      }

      print('No profile found for current user');
      return null;
    } catch (e) {
      print('Error getting current user profile: $e');
      return null;
    }
  }

  // Update profile manually
  Future<UserModel?> updateProfile({
    required String userId,
    String? displayName,
    String? avatarUrl,
  }) async {
    try {
      print('Manually updating profile');
      print('User ID: $userId');
      print('Display Name: $displayName');
      print('Avatar URL: $avatarUrl');

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (displayName != null) {
        updateData['display_name'] = displayName;
      }

      if (avatarUrl != null) {
        updateData['avatar_url'] = avatarUrl;
      }

      print('Manual update data: $updateData');

      final response = await _supabase
          .from('profiles')
          .update(updateData)
          .eq('id', userId)
          .select()
          .single();

      print('Manual profile update response: $response');

      if (response != null) {
        final userModel = UserModel.fromJson(response);
        print(
            'Profile manually updated: ${userModel.displayName ?? userModel.email}');
        return userModel;
      }

      print('Failed to manually update profile');
      return null;
    } catch (e) {
      print('Error manually updating profile: $e');
      return null;
    }
  }

  // Delete profile (for cleanup purposes)
  Future<bool> deleteProfile(String userId) async {
    try {
      print('Deleting profile for user: $userId');

      final response =
          await _supabase.from('profiles').delete().eq('id', userId).select();

      print('Delete profile response: $response');

      final success = response != null && response.isNotEmpty;
      print(success
          ? 'Profile deleted successfully'
          : 'Failed to delete profile');
      return success;
    } catch (e) {
      print('Error deleting profile: $e');
      return false;
    }
  }
}
