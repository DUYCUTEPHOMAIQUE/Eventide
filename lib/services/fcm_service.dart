import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'user_device_service.dart';
import 'local_notification_service.dart';
import 'package:firebase_core/firebase_core.dart';

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final UserDeviceService _userDeviceService = UserDeviceService();
  bool _isInitialized = false;

  // Initialize FCM
  Future<void> initialize() async {
    if (_isInitialized) {
      print('FCM Service already initialized');
      return;
    }

    try {
      print('Initializing FCM Service');

      // Initialize local notifications first
      await LocalNotificationService.initialize();

      // Check if Firebase is properly initialized
      if (!await _checkFirebaseInitialized()) {
        print('Firebase not properly initialized, skipping FCM setup');
        return;
      }

      // Request permission
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      print('FCM Permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('FCM Permission granted');

        // Get FCM token
        await _getAndSaveFCMToken();

        // Listen to token refresh
        _firebaseMessaging.onTokenRefresh.listen((newToken) {
          print('FCM Token refreshed: ${newToken.substring(0, 20)}...');
          _saveFCMToken(newToken);
        });

        // Handle foreground messages
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          print('Received foreground message: ${message.notification?.title}');
          _handleForegroundMessage(message);
        });

        // Handle background messages
        FirebaseMessaging.onBackgroundMessage(
            LocalNotificationService.firebaseMessagingBackgroundHandler);

        // Handle notification tap when app is in background
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          print('App opened from notification: ${message.notification?.title}');
          _handleNotificationTap(message);
        });

        _isInitialized = true;
        print('FCM Service initialized successfully');
      } else {
        print('FCM Permission denied');
      }
    } catch (e) {
      print('Error initializing FCM: $e');
      // Don't rethrow - we don't want FCM issues to crash the app
    }
  }

  // Check if Firebase is properly initialized
  Future<bool> _checkFirebaseInitialized() async {
    try {
      // Try to get the default Firebase app
      final app = Firebase.app();
      print('Firebase app found: ${app.name}');
      return true;
    } catch (e) {
      print('Firebase not initialized: $e');
      return false;
    }
  }

  // Initialize FCM token manually (for after login)
  Future<void> initializeFCMToken() async {
    try {
      print('Manually initializing FCM token');

      // Check if FCM is initialized
      if (!_isInitialized) {
        print('FCM not initialized, trying to initialize...');
        await initialize();
      }

      if (_isInitialized) {
        await _getAndSaveFCMToken();
      } else {
        print('FCM initialization failed, cannot save token');
      }
    } catch (e) {
      print('Error manually initializing FCM token: $e');
    }
  }

  // Get and save FCM token
  Future<void> _getAndSaveFCMToken() async {
    try {
      print('Getting FCM token');

      String? token = await _firebaseMessaging.getToken();

      if (token != null) {
        print('FCM Token obtained: ${token.substring(0, 20)}...');
        await _saveFCMToken(token);
      } else {
        print('Failed to get FCM token');
      }
    } catch (e) {
      print('Error getting FCM token: $e');
    }
  }

  // Save FCM token to database
  Future<void> _saveFCMToken(String token) async {
    try {
      print('Saving FCM token to database');

      final deviceName = await _getDeviceName();
      final platform = _getPlatform();

      final success = await _userDeviceService.saveFCMToken(
        fcmToken: token,
        deviceName: deviceName,
        platform: platform,
      );

      if (success) {
        print('FCM token saved successfully');
      } else {
        print('Failed to save FCM token');
      }
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }

  // Get device name
  Future<String?> _getDeviceName() async {
    try {
      if (Platform.isAndroid) {
        return 'Android Device';
      } else if (Platform.isIOS) {
        return 'iOS Device';
      } else if (kIsWeb) {
        return 'Web Browser';
      }
      return 'Unknown Device';
    } catch (e) {
      print('Error getting device name: $e');
      return null;
    }
  }

  // Get platform
  String _getPlatform() {
    if (Platform.isAndroid) {
      return 'android';
    } else if (Platform.isIOS) {
      return 'ios';
    } else if (kIsWeb) {
      return 'web';
    }
    return 'unknown';
  }

  // Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    print('Handling foreground message');
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    print('Data: ${message.data}');

    // Show local notification using LocalNotificationService
    LocalNotificationService.handleForegroundMessage(message);
  }

  // Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    print('Handling notification tap');
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    print('Data: ${message.data}');

    // Here you can navigate to specific screen based on notification data
    // For example, navigate to event detail if it's an invite notification
    if (message.data['type'] == 'invite') {
      final cardId = message.data['card_id'];
      print('Navigate to event detail: $cardId');
      // TODO: Navigate to event detail screen
    }
  }

  // Delete FCM token (when user logs out)
  Future<void> deleteFCMToken() async {
    try {
      print('Deleting FCM token');

      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        final success = await _userDeviceService.deleteFCMToken(token);
        if (success) {
          print('FCM token deleted successfully');
        } else {
          print('Failed to delete FCM token');
        }
      }
    } catch (e) {
      print('Error deleting FCM token: $e');
    }
  }

  // Delete all FCM tokens (when user logs out from all devices)
  Future<void> deleteAllFCMTokens() async {
    try {
      print('Deleting all FCM tokens');

      final success = await _userDeviceService.deleteAllUserDevices();
      if (success) {
        print('All FCM tokens deleted successfully');
      } else {
        print('Failed to delete all FCM tokens');
      }
    } catch (e) {
      print('Error deleting all FCM tokens: $e');
    }
  }

  // Get current FCM token
  Future<String?> getCurrentToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      print('Error getting current FCM token: $e');
      return null;
    }
  }

  // Test FCM token
  Future<void> testFCMToken() async {
    try {
      print('Testing FCM token');

      final token = await getCurrentToken();
      if (token != null) {
        print('Current FCM token: ${token.substring(0, 20)}...');

        final devices = await _userDeviceService.getCurrentUserDevices();
        print('Current user devices: ${devices.length}');

        for (final device in devices) {
          print('Device: ${device.deviceName} (${device.platform})');
        }
      } else {
        print('No FCM token available');
      }
    } catch (e) {
      print('Error testing FCM token: $e');
    }
  }

  // Check if FCM is initialized
  bool get isInitialized => _isInitialized;
}
