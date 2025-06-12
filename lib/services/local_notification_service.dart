import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    print('Initializing LocalNotificationService');

    // Android settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    print('LocalNotificationService initialized successfully');
  }

  static void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
    // TODO: Navigate to specific screen based on payload
  }

  // Background message handler
  static Future<void> firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print('Handling background message: ${message.messageId}');
    await _showNotification(
      message.notification?.title,
      message.notification?.body,
      message.data,
    );
  }

  // Foreground message handler
  static void handleForegroundMessage(RemoteMessage message) {
    print('Handling foreground message: ${message.messageId}');
    _showNotification(
      message.notification?.title,
      message.notification?.body,
      message.data,
    );
  }

  // Show local notification
  static Future<void> _showNotification(
    String? title,
    String? body,
    Map<String, dynamic>? data,
  ) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'event_invites',
      'Event Invitations',
      channelDescription: 'Notifications for event invitations',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    try {
      await _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title ?? 'Event Invitation',
        body ?? 'You have a new event invitation',
        platformChannelSpecifics,
        payload: data != null ? data.toString() : null,
      );
      print('Local notification shown successfully');
    } catch (e) {
      print('Error showing local notification: $e');
    }
  }

  // Show custom notification
  static Future<void> showCustomNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    await _showNotification(title, body, data);
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  // Cancel specific notification
  static Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }
}
