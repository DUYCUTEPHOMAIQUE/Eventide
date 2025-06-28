import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'user_device_service.dart';

class NotificationService {
  static final UserDeviceService _userDeviceService = UserDeviceService();

  // FCM HTTP v1 API URL
  static const String _fcmUrl =
      'https://fcm.googleapis.com/v1/projects/{project_id}/messages:send';

  // Service Account credentials
  static String? get _serviceAccountJson =>
      dotenv.env['FIREBASE_SERVICE_ACCOUNT_JSON'];
  static String? get _projectId => dotenv.env['FIREBASE_PROJECT_ID'];

  // TODO: Để đa ngôn ngữ, nên truyền title/body từ UI/service gọi hàm này
  static const String kInviteTitle = 'Lời mời mới';
  static String kInviteBody(String senderName, String cardTitle) =>
      '$senderName đã mời bạn tham gia "$cardTitle"';

  // Gửi notification cho một user
  Future<bool> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      print('Sending notification to user: $userId');
      print('Title: $title');
      print('Body: $body');
      print('Data: $data');

      // Lấy FCM tokens của user
      final userDevices = await _userDeviceService.getUserDevices(userId);

      if (userDevices.isEmpty) {
        print('No devices found for user: $userId');
        return false;
      }

      print('Found ${userDevices.length} devices for user: $userId');

      // Gửi notification đến tất cả devices của user
      bool allSuccess = true;
      for (final device in userDevices) {
        final success = await _sendToDevice(
          fcmToken: device.fcmToken,
          title: title,
          body: body,
          data: data,
        );

        if (!success) {
          allSuccess = false;
          print('Failed to send notification to device: ${device.id}');
        }
      }

      print('Notification sending completed. All success: $allSuccess');
      return allSuccess;
    } catch (e) {
      print('Error sending notification to user: $e');
      return false;
    }
  }

  // Gửi notification cho nhiều users
  Future<bool> sendNotificationToUsers({
    required List<String> userIds,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      print('Sending notification to users: $userIds');
      print('Title: $title');
      print('Body: $body');
      print('Data: $data');

      // Lấy FCM tokens của tất cả users
      final userTokens = await _userDeviceService.getUsersFCMTokens(userIds);

      if (userTokens.isEmpty) {
        print('No devices found for any users');
        return false;
      }

      print('Found devices for ${userTokens.length} users');

      // Gửi notification đến tất cả devices
      bool allSuccess = true;
      for (final entry in userTokens.entries) {
        final userId = entry.key;
        final tokens = entry.value;

        print('Sending to user $userId with ${tokens.length} devices');

        for (final token in tokens) {
          final success = await _sendToDevice(
            fcmToken: token,
            title: title,
            body: body,
            data: data,
          );

          if (!success) {
            allSuccess = false;
            print(
                'Failed to send notification to token: ${token.substring(0, 20)}...');
          }
        }
      }

      print('Batch notification sending completed. All success: $allSuccess');
      return allSuccess;
    } catch (e) {
      print('Error sending notification to users: $e');
      return false;
    }
  }

  // Gửi notification đến một device cụ thể
  Future<bool> _sendToDevice({
    required String fcmToken,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      print('Sending notification to device: ${fcmToken.substring(0, 20)}...');

      if (_serviceAccountJson == null || _projectId == null) {
        print(
            'Firebase Service Account JSON or Project ID not found in environment variables');
        return false;
      }

      // Parse service account JSON
      final serviceAccount = jsonDecode(_serviceAccountJson!);

      // Tạo credentials
      final credentials = ServiceAccountCredentials.fromJson(serviceAccount);

      // Lấy access token
      final client = http.Client();
      final accessCredentials = await obtainAccessCredentialsViaServiceAccount(
        credentials,
        ['https://www.googleapis.com/auth/firebase.messaging'],
        client,
      );

      // Tạo FCM v1 payload
      final fcmPayload = {
        'message': {
          'token': fcmToken,
          'notification': {
            'title': title,
            'body': body,
          },
          'data': data ?? {},
          'android': {
            'priority': 'high',
            'notification': {
              'sound': 'default',
              'channel_id': 'invites',
            },
          },
          'apns': {
            'payload': {
              'aps': {
                'sound': 'default',
                'badge': 1,
              },
            },
          },
        },
      };

      print('FCM v1 Payload: ${jsonEncode(fcmPayload)}');

      // Gửi request đến FCM v1 API
      final url = _fcmUrl.replaceAll('{project_id}', _projectId!);
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${accessCredentials.accessToken.data}',
        },
        body: jsonEncode(fcmPayload),
      );

      print('FCM v1 Response Status: ${response.statusCode}');
      print('FCM v1 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print('Notification sent successfully to device');
        return true;
      } else {
        print('FCM v1 request failed with status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error sending notification to device: $e');
      return false;
    }
  }

  // Gửi notification cho invite
  Future<bool> sendInviteNotification({
    required String receiverId,
    required String senderName,
    required String cardTitle,
    required String cardId,
  }) async {
    try {
      print('Sending invite notification');
      print('Receiver ID: $receiverId');
      print('Sender Name: $senderName');
      print('Card Title: $cardTitle');
      print('Card ID: $cardId');

      return await sendNotificationToUser(
        userId: receiverId,
        title: kInviteTitle,
        body: kInviteBody(senderName, cardTitle),
        data: {
          'type': 'invite',
          'card_id': cardId,
          'sender_name': senderName,
          'card_title': cardTitle,
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        },
      );
    } catch (e) {
      print('Error sending invite notification: $e');
      return false;
    }
  }

  // Gửi notification cho nhiều invites
  Future<bool> sendInviteNotifications({
    required List<String> receiverIds,
    required String senderName,
    required String cardTitle,
    required String cardId,
  }) async {
    try {
      print('Sending invite notifications to multiple users');
      print('Receiver IDs: $receiverIds');
      print('Sender Name: $senderName');
      print('Card Title: $cardTitle');
      print('Card ID: $cardId');

      return await sendNotificationToUsers(
        userIds: receiverIds,
        title: kInviteTitle,
        body: kInviteBody(senderName, cardTitle),
        data: {
          'type': 'invite',
          'card_id': cardId,
          'sender_name': senderName,
          'card_title': cardTitle,
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        },
      );
    } catch (e) {
      print('Error sending invite notifications: $e');
      return false;
    }
  }

  // Test method để kiểm tra FCM connection
  Future<bool> testFCMConnection() async {
    try {
      print('Testing FCM v1 connection');

      if (_serviceAccountJson == null || _projectId == null) {
        print('Firebase Service Account JSON or Project ID not found');
        return false;
      }

      print('Firebase Project ID: $_projectId');
      print(
          'Service Account JSON found: ${_serviceAccountJson!.substring(0, 50)}...');

      // Test với một token dummy (sẽ fail nhưng kiểm tra được connection)
      final serviceAccount = jsonDecode(_serviceAccountJson!);
      final credentials = ServiceAccountCredentials.fromJson(serviceAccount);

      final client = http.Client();
      final accessCredentials = await obtainAccessCredentialsViaServiceAccount(
        credentials,
        ['https://www.googleapis.com/auth/firebase.messaging'],
        client,
      );

      print('Access token obtained successfully');
      print('Token expires at: ${accessCredentials.accessToken.expiry}');

      return true;
    } catch (e) {
      print('Error testing FCM v1 connection: $e');
      return false;
    }
  }
}
