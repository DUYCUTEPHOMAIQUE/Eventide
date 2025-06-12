import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'profile_service.dart';
import '../models/user_model.dart';
import 'fcm_service.dart';

class SupabaseServices {
  static SupabaseClient client = Supabase.instance.client;
  static final ProfileService _profileService = ProfileService();
  static final FCMService _fcmService = FCMService();

  static Future<User?> getCurrentUser() async {
    final user = client.auth.currentUser;
    return user;
  }

  static Future<void> signOut() async {
    try {
      print('Signing out user');

      // Delete FCM token before signing out
      print('Deleting FCM token before sign out');
      await _fcmService.deleteFCMToken();

      await client.auth.signOut();
      print('User signed out successfully');
    } catch (e) {
      print('Error during sign out: $e');
      rethrow;
    }
  }

  static Future<AuthResponse> signInWithGoogle() async {
    try {
      print('Starting Google Sign-In process');
      final googleSignIn = GoogleSignIn(
        serverClientId: dotenv.env['GOOGLE_CLIENT_ID']!,
      );
      print('GoogleSignIn initialized');

      final googleUser = await googleSignIn.signIn();
      print('Google user sign-in result: ${googleUser?.email}');

      if (googleUser == null) {
        print('Google Sign-In was cancelled by user');
        throw 'Google Sign-In was cancelled by user';
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;
      print(
          'Google access token obtained: ${accessToken != null ? 'Yes' : 'No'}');
      print('Google ID token obtained: ${idToken != null ? 'Yes' : 'No'}');

      if (accessToken == null || idToken == null) {
        print('Google Sign-In Error: accessToken or idToken is null');
        throw 'Google Sign-In Error: accessToken or idToken is null';
      }

      print('Signing in to Supabase with Google tokens');
      final AuthResponse response = await client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      print('Supabase Google sign-in successful');
      print('User ID: ${response.user?.id}');
      print('User email: ${response.user?.email}');

      // Create or update profile after successful sign-in
      if (response.user != null) {
        print('Creating/updating profile for Google user');
        final profile =
            await _profileService.createOrUpdateProfile(response.user!);
        if (profile != null) {
          print(
              'Profile created/updated successfully for Google user: ${profile.displayName ?? profile.email}');
        } else {
          print('Failed to create/update profile for Google user');
        }

        // Initialize FCM token for push notifications
        print('Initializing FCM token for Google user');
        await _fcmService.initializeFCMToken();
      }

      return response;
    } catch (e) {
      print('Error during Google Sign-In: $e');
      Fluttertoast.showToast(
        msg: 'Đăng nhập thất bại: ${e.toString()}',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
      rethrow;
    }
  }

  static Future<AuthResponse> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      print('Signing in with email: $email');

      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      print('Email sign-in successful');
      print('User ID: ${response.user?.id}');

      // Create or update profile after successful sign-in
      if (response.user != null) {
        print('Creating/updating profile for email user');
        final profile =
            await _profileService.createOrUpdateProfile(response.user!);
        if (profile != null) {
          print(
              'Profile created/updated successfully for email user: ${profile.displayName ?? profile.email}');
        } else {
          print('Failed to create/update profile for email user');
        }

        // Initialize FCM token for push notifications
        print('Initializing FCM token for email user');
        await _fcmService.initializeFCMToken();
      }

      return response;
    } catch (e) {
      print('Error during email sign-in: $e');
      rethrow;
    }
  }

  static Future<AuthResponse> signUpWithEmail(
      String email, String password) async {
    try {
      print('Signing up with email: $email');

      final response = await client.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: null, // Không redirect, chỉ gửi OTP
      );

      print('Email sign-up successful');
      print('User ID: ${response.user?.id}');

      // Create profile after successful sign-up
      if (response.user != null) {
        print('Creating profile for new email user');
        final profile =
            await _profileService.createOrUpdateProfile(response.user!);
        if (profile != null) {
          print(
              'Profile created successfully for new email user: ${profile.displayName ?? profile.email}');
        } else {
          print('Failed to create profile for new email user');
        }

        // Initialize FCM token for push notifications
        print('Initializing FCM token for new email user');
        await _fcmService.initializeFCMToken();
      }

      return response;
    } catch (e) {
      print('Error during Email Sign-Up: $e');
      Fluttertoast.showToast(
        msg: 'Đăng ký thất bại: ${e.toString()}',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
      rethrow;
    }
  }

  static Future<AuthResponse> verifyOTP(String email, String token) async {
    try {
      print('Verifying OTP for email: $email');

      final response = await client.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.signup,
      );

      print('OTP verification successful');
      print('User ID: ${response.user?.id}');

      // Create profile after successful OTP verification
      if (response.user != null) {
        print('Creating profile for verified OTP user');
        final profile =
            await _profileService.createOrUpdateProfile(response.user!);
        if (profile != null) {
          print(
              'Profile created successfully for verified OTP user: ${profile.displayName ?? profile.email}');
        } else {
          print('Failed to create profile for verified OTP user');
        }

        // Initialize FCM token for push notifications
        print('Initializing FCM token for verified OTP user');
        await _fcmService.initializeFCMToken();
      }

      return response;
    } catch (e) {
      print('Error during OTP verification: $e');
      Fluttertoast.showToast(
        msg: 'Xác thực OTP thất bại: ${e.toString()}',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
      rethrow;
    }
  }

  static Future<void> resendOTP(String email) async {
    try {
      print('Resending OTP to email: $email');

      await client.auth.resend(
        type: OtpType.signup,
        email: email,
      );

      print('OTP resent successfully');
      Fluttertoast.showToast(
        msg: 'Mã OTP mới đã được gửi đến email của bạn',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      print('Error resending OTP: $e');
      Fluttertoast.showToast(
        msg: 'Gửi lại mã OTP thất bại: ${e.toString()}',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
      rethrow;
    }
  }

  // Get current user profile
  static Future<UserModel?> getCurrentUserProfile() async {
    try {
      print('Getting current user profile from SupabaseServices');
      return await _profileService.getCurrentUserProfile();
    } catch (e) {
      print('Error getting current user profile from SupabaseServices: $e');
      return null;
    }
  }

  // Update current user profile
  static Future<UserModel?> updateCurrentUserProfile({
    String? displayName,
    String? avatarUrl,
  }) async {
    try {
      print('Updating current user profile from SupabaseServices');

      final currentUser = client.auth.currentUser;
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
      print('Error updating current user profile from SupabaseServices: $e');
      return null;
    }
  }
}
