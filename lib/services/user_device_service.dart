import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_device_model.dart';

class UserDeviceService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Lưu FCM token cho user hiện tại
  Future<bool> saveFCMToken({
    required String fcmToken,
    String? deviceName,
    String? platform,
  }) async {
    try {
      print('Saving FCM token for current user');

      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        print('No current user found');
        return false;
      }

      print('Current user ID: ${currentUser.id}');
      print('FCM Token: ${fcmToken.substring(0, 20)}...');
      print('Device Name: $deviceName');
      print('Platform: $platform');

      // Kiểm tra xem token đã tồn tại chưa
      final existingDevice = await _supabase
          .from('user_devices')
          .select('*')
          .eq('user_id', currentUser.id)
          .eq('fcm_token', fcmToken)
          .maybeSingle();

      if (existingDevice != null) {
        print('FCM token already exists, updating...');

        final response = await _supabase
            .from('user_devices')
            .update({
              'device_name': deviceName,
              'platform': platform,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', existingDevice['id'])
            .select()
            .single();

        print('FCM token updated successfully');
        return response != null;
      } else {
        print('FCM token does not exist, creating new...');

        final response = await _supabase
            .from('user_devices')
            .insert({
              'user_id': currentUser.id,
              'fcm_token': fcmToken,
              'device_name': deviceName,
              'platform': platform,
              'created_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            })
            .select()
            .single();

        print('FCM token saved successfully');
        return response != null;
      }
    } catch (e) {
      print('Error saving FCM token: $e');
      return false;
    }
  }

  // Lấy tất cả FCM tokens của một user
  Future<List<UserDeviceModel>> getUserDevices(String userId) async {
    try {
      print('Getting user devices for user: $userId');

      final response = await _supabase
          .from('user_devices')
          .select('*')
          .eq('user_id', userId);

      print('User devices response: $response');

      if (response != null) {
        final devices = (response as List)
            .map((device) => UserDeviceModel.fromJson(device))
            .toList();

        print('Found ${devices.length} devices for user $userId');
        return devices;
      }

      print('No devices found for user $userId');
      return [];
    } catch (e) {
      print('Error getting user devices: $e');
      return [];
    }
  }

  // Lấy FCM tokens của nhiều users
  Future<Map<String, List<String>>> getUsersFCMTokens(
      List<String> userIds) async {
    try {
      print('Getting FCM tokens for users: $userIds');

      final response = await _supabase
          .from('user_devices')
          .select('user_id, fcm_token')
          .inFilter('user_id', userIds);

      print('Users FCM tokens response: $response');

      final Map<String, List<String>> userTokens = {};

      if (response != null) {
        for (final device in response) {
          final userId = device['user_id'];
          final fcmToken = device['fcm_token'];

          if (!userTokens.containsKey(userId)) {
            userTokens[userId] = [];
          }
          userTokens[userId]!.add(fcmToken);
        }
      }

      print('Found FCM tokens for ${userTokens.length} users');
      for (final entry in userTokens.entries) {
        print('User ${entry.key}: ${entry.value.length} tokens');
      }

      return userTokens;
    } catch (e) {
      print('Error getting users FCM tokens: $e');
      return {};
    }
  }

  // Xóa FCM token
  Future<bool> deleteFCMToken(String fcmToken) async {
    try {
      print('Deleting FCM token: ${fcmToken.substring(0, 20)}...');

      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        print('No current user found');
        return false;
      }

      final response = await _supabase
          .from('user_devices')
          .delete()
          .eq('user_id', currentUser.id)
          .eq('fcm_token', fcmToken)
          .select();

      print('Delete FCM token response: $response');

      final success = response != null && response.isNotEmpty;
      print(success
          ? 'FCM token deleted successfully'
          : 'Failed to delete FCM token');
      return success;
    } catch (e) {
      print('Error deleting FCM token: $e');
      return false;
    }
  }

  // Xóa tất cả FCM tokens của user hiện tại
  Future<bool> deleteAllUserDevices() async {
    try {
      print('Deleting all devices for current user');

      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        print('No current user found');
        return false;
      }

      final response = await _supabase
          .from('user_devices')
          .delete()
          .eq('user_id', currentUser.id)
          .select();

      print('Delete all devices response: $response');

      final success = response != null;
      print(success
          ? 'All devices deleted successfully'
          : 'Failed to delete devices');
      return success;
    } catch (e) {
      print('Error deleting all devices: $e');
      return false;
    }
  }

  // Lấy thông tin devices của user hiện tại
  Future<List<UserDeviceModel>> getCurrentUserDevices() async {
    try {
      print('Getting current user devices');

      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        print('No current user found');
        return [];
      }

      return await getUserDevices(currentUser.id);
    } catch (e) {
      print('Error getting current user devices: $e');
      return [];
    }
  }
}
