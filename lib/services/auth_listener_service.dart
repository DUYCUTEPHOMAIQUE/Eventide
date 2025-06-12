import 'package:supabase_flutter/supabase_flutter.dart';
import 'profile_service.dart';
import '../models/user_model.dart';

class AuthListenerService {
  static final ProfileService _profileService = ProfileService();
  static bool _isInitialized = false;

  // Initialize auth state listener
  static void initialize() {
    if (_isInitialized) {
      print('AuthListenerService already initialized');
      return;
    }

    print('Initializing AuthListenerService');

    // Listen to auth state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;
      final User? user = data.session?.user;

      print('Auth state change detected');
      print('Event: $event');
      print('User: ${user?.email}');
      print('Session: ${session != null ? 'Active' : 'None'}');

      switch (event) {
        case AuthChangeEvent.signedIn:
          if (user != null) {
            print('User signed in, creating/updating profile');
            _handleUserSignIn(user);
          }
          break;

        case AuthChangeEvent.userUpdated:
          if (user != null) {
            print('User updated, creating/updating profile');
            _handleUserSignUp(user);
          }
          break;

        case AuthChangeEvent.tokenRefreshed:
          if (user != null) {
            print('Token refreshed, checking profile');
            _handleTokenRefresh(user);
          }
          break;

        case AuthChangeEvent.signedOut:
          print('User signed out');
          break;

        default:
          print('Unhandled auth event: $event');
          break;
      }
    });

    _isInitialized = true;
    print('AuthListenerService initialized successfully');
  }

  // Handle user sign in
  static Future<void> _handleUserSignIn(User user) async {
    try {
      print('Handling user sign in for: ${user.email}');
      print('User ID: ${user.id}');
      print('User metadata: ${user.userMetadata}');

      // Check if profile exists
      final existingProfile = await _profileService.getCurrentUserProfile();

      if (existingProfile != null) {
        print(
            'Profile already exists for signed in user: ${existingProfile.displayName ?? existingProfile.email}');

        // Update profile with latest metadata if needed
        final updatedProfile =
            await _profileService.createOrUpdateProfile(user);
        if (updatedProfile != null) {
          print(
              'Profile updated for signed in user: ${updatedProfile.displayName ?? updatedProfile.email}');
        }
      } else {
        print('No profile found for signed in user, creating new profile');
        final newProfile = await _profileService.createOrUpdateProfile(user);
        if (newProfile != null) {
          print(
              'New profile created for signed in user: ${newProfile.displayName ?? newProfile.email}');
        } else {
          print('Failed to create profile for signed in user');
        }
      }
    } catch (e) {
      print('Error handling user sign in: $e');
    }
  }

  // Handle user sign up
  static Future<void> _handleUserSignUp(User user) async {
    try {
      print('Handling user sign up for: ${user.email}');
      print('User ID: ${user.id}');
      print('User metadata: ${user.userMetadata}');

      // Create new profile for signed up user
      final newProfile = await _profileService.createOrUpdateProfile(user);
      if (newProfile != null) {
        print(
            'New profile created for signed up user: ${newProfile.displayName ?? newProfile.email}');
      } else {
        print('Failed to create profile for signed up user');
      }
    } catch (e) {
      print('Error handling user sign up: $e');
    }
  }

  // Handle token refresh
  static Future<void> _handleTokenRefresh(User user) async {
    try {
      print('Handling token refresh for: ${user.email}');
      print('User ID: ${user.id}');

      // Check if profile exists and update if needed
      final profile = await _profileService.getCurrentUserProfile();
      if (profile == null) {
        print('No profile found during token refresh, creating profile');
        final newProfile = await _profileService.createOrUpdateProfile(user);
        if (newProfile != null) {
          print(
              'Profile created during token refresh: ${newProfile.displayName ?? newProfile.email}');
        }
      } else {
        print(
            'Profile exists during token refresh: ${profile.displayName ?? profile.email}');
      }
    } catch (e) {
      print('Error handling token refresh: $e');
    }
  }

  // Manual profile creation for current user
  static Future<void> ensureCurrentUserProfile() async {
    try {
      print('Ensuring current user profile exists');

      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        print('No current user found');
        return;
      }

      print('Current user: ${currentUser.email}');
      print('Current user ID: ${currentUser.id}');

      final profile = await _profileService.getCurrentUserProfile();
      if (profile == null) {
        print('No profile found for current user, creating profile');
        final newProfile =
            await _profileService.createOrUpdateProfile(currentUser);
        if (newProfile != null) {
          print(
              'Profile created for current user: ${newProfile.displayName ?? newProfile.email}');
        } else {
          print('Failed to create profile for current user');
        }
      } else {
        print(
            'Profile already exists for current user: ${profile.displayName ?? profile.email}');
      }
    } catch (e) {
      print('Error ensuring current user profile: $e');
    }
  }

  // Get current user profile
  static Future<UserModel?> getCurrentUserProfile() async {
    try {
      print('Getting current user profile from AuthListenerService');
      return await _profileService.getCurrentUserProfile();
    } catch (e) {
      print('Error getting current user profile from AuthListenerService: $e');
      return null;
    }
  }

  // Update current user profile
  static Future<UserModel?> updateCurrentUserProfile({
    String? displayName,
    String? avatarUrl,
  }) async {
    try {
      print('Updating current user profile from AuthListenerService');

      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        print('No current user found for profile update');
        return null;
      }

      return await _profileService.updateProfile(
        userId: currentUser.id,
        displayName: displayName,
        avatarUrl: avatarUrl,
      );
    } catch (e) {
      print('Error updating current user profile from AuthListenerService: $e');
      return null;
    }
  }
}
