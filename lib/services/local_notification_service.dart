import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'local_notification_storage_service.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';

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
    print('=== BACKGROUND MESSAGE HANDLER ===');
    print('Message ID: ${message.messageId}');
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    print('Data: ${message.data}');
    print('=================================');

    // Save notification to local storage
    await _saveNotificationToLocal(message);

    await _showNotification(
      message.notification?.title,
      message.notification?.body,
      message.data,
    );
  }

  // Foreground message handler
  static Future<void> handleForegroundMessage(RemoteMessage message) async {
    print('=== FOREGROUND MESSAGE HANDLER ===');
    print('Message ID: ${message.messageId}');
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    print('Data: ${message.data}');
    print('=================================');

    // Save notification to local storage
    await _saveNotificationToLocal(message);

    await _showNotification(
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
    // Custom Android notification with enhanced UI
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'event_invites',
      'Event Invitations',
      channelDescription: 'Notifications for event invitations and updates',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,

      // Custom UI enhancements
      icon: '@mipmap/ic_launcher', // App icon
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      colorized: true,

      // Enhanced text styling
      styleInformation: BigTextStyleInformation(
        body ?? 'You have a new notification',
        htmlFormatBigText: true,
        contentTitle: title ?? 'Eventide',
        htmlFormatContentTitle: true,
        summaryText: 'Eventide',
        htmlFormatSummaryText: true,
      ),

      // Notification behavior
      autoCancel: true,
      ongoing: false,
      silent: false,
      enableLights: true,
      ledColor: const Color(0xFF6366F1),
      ledOnMs: 1000,
      ledOffMs: 500,

      // Group notifications
      groupKey: 'eventide_notifications',
      setAsGroupSummary: false,

      // Custom vibration pattern
      vibrationPattern: Int64List.fromList([0, 250, 250, 250]),

      // Ticker text (brief text that appears in status bar)
      ticker: title ?? 'New notification from Eventide',
    );

    // Enhanced iOS notification
    final DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
      badgeNumber: null,
      subtitle: 'Eventide',
      threadIdentifier: 'eventide_notifications',
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    try {
      await _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title ?? 'Eventide',
        body ?? 'You have a new notification',
        platformChannelSpecifics,
        payload: data != null ? data.toString() : null,
      );
      print('Enhanced local notification shown successfully');
    } catch (e) {
      print('Error showing local notification: $e');
    }
  }

  // Show invitation notification with action buttons
  static Future<void> showInvitationNotification({
    required String title,
    required String body,
    required String eventId,
    String? senderName,
  }) async {
    // Save to local storage first
    await _saveCustomNotificationToLocal(
      title: title,
      body: body,
      type: 'invite',
      eventId: eventId,
      senderName: senderName,
    );

    // Action buttons for invitation
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'event_invites',
      'Event Invitations',
      channelDescription: 'Event invitation notifications with quick actions',
      importance: Importance.high,
      priority: Priority.high,

      // Custom UI
      icon: '@drawable/ic_event_invite', // Custom icon for invites
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      color: const Color(0xFF10B981), // Green for invitations
      colorized: true,

      // Big text style for invitation
      styleInformation: BigTextStyleInformation(
        body,
        htmlFormatBigText: true,
        contentTitle: title,
        htmlFormatContentTitle: true,
        summaryText:
            senderName != null ? 'From $senderName' : 'Event Invitation',
        htmlFormatSummaryText: true,
      ),

      // Action buttons
      actions: <AndroidNotificationAction>[
        const AndroidNotificationAction(
          'accept_invite',
          'Accept',
          showsUserInterface: true,
        ),
        const AndroidNotificationAction(
          'decline_invite',
          'Decline',
          showsUserInterface: false,
        ),
        const AndroidNotificationAction(
          'view_invite',
          'View Details',
          showsUserInterface: true,
        ),
      ],

      // Enhanced styling
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 300, 200, 300]),
      enableLights: true,
      ledColor: const Color(0xFF10B981),
      ticker: 'New event invitation: $title',
      autoCancel: false, // Keep until user acts
      groupKey: 'event_invitations',
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      subtitle: 'Event Invitation',
      threadIdentifier: 'event_invitations',
      categoryIdentifier: 'INVITE_CATEGORY',
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    try {
      await _flutterLocalNotificationsPlugin.show(
        eventId.hashCode, // Use eventId hash as unique ID
        title,
        body,
        platformChannelSpecifics,
        payload: 'invite:$eventId',
      );
      print('Invitation notification shown with actions');
    } catch (e) {
      print('Error showing invitation notification: $e');
    }
  }

  // Show reminder notification
  static Future<void> showReminderNotification({
    required String title,
    required String body,
    required String eventId,
    int? minutesBefore,
  }) async {
    // Save to local storage first
    await _saveCustomNotificationToLocal(
      title: title,
      body: body,
      type: 'reminder',
      eventId: eventId,
    );

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'event_reminders',
      'Event Reminders',
      channelDescription: 'Reminders for upcoming events',
      importance: Importance.high,
      priority: Priority.high,

      // Reminder specific styling
      icon: '@drawable/ic_reminder',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      color: const Color(0xFFF59E0B), // Amber for reminders
      colorized: true,

      styleInformation: BigTextStyleInformation(
        body,
        contentTitle: title,
        summaryText: minutesBefore != null
            ? 'Starting in $minutesBefore minutes'
            : 'Event Reminder',
      ),

      // Reminder actions
      actions: <AndroidNotificationAction>[
        const AndroidNotificationAction(
          'view_event',
          'View Event',
          showsUserInterface: true,
        ),
        const AndroidNotificationAction(
          'snooze_reminder',
          'Snooze 5min',
          showsUserInterface: false,
        ),
      ],

      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 100, 100, 100, 100, 100]),
      ticker: 'Event reminder: $title',
      groupKey: 'event_reminders',
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      subtitle: 'Event Reminder',
      threadIdentifier: 'event_reminders',
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      eventId.hashCode + 1000, // Different ID for reminders
      title,
      body,
      platformChannelSpecifics,
      payload: 'reminder:$eventId',
    );
  }

  // Show custom notification
  static Future<void> showCustomNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    // Save to local storage first
    await _saveCustomNotificationToLocal(
      title: title,
      body: body,
      type: 'custom',
      data: data,
    );

    // Use the main _showNotification method directly
    await _showNotification(title, body, data);
  }

  // Save custom notification to local storage
  static Future<void> _saveCustomNotificationToLocal({
    required String title,
    required String body,
    required String type,
    String? eventId,
    String? senderName,
    Map<String, dynamic>? data,
  }) async {
    try {
      final notification = LocalNotificationStorageService.createFromFCM(
        title: title,
        body: body,
        data: {
          'type': type,
          if (eventId != null) 'eventId': eventId,
          if (senderName != null) 'senderName': senderName,
          ...?data,
        },
      );

      await LocalNotificationStorageService.saveNotification(notification);
      print('Custom notification saved to local storage: $title');
    } catch (e) {
      print('Error saving custom notification to local storage: $e');
    }
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  // Cancel specific notification
  static Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  // Save notification to local storage
  static Future<void> _saveNotificationToLocal(RemoteMessage message) async {
    try {
      // Extract title and body with fallbacks
      String title = message.notification?.title ?? '';
      String body = message.notification?.body ?? '';
      Map<String, dynamic> data = message.data;

      // If notification payload is empty, try to get from data
      if (title.isEmpty && data.containsKey('title')) {
        title = data['title'] ?? '';
      }
      if (body.isEmpty && data.containsKey('body')) {
        body = data['body'] ?? '';
      }

      // Skip saving if both title and body are empty and no meaningful data
      if (title.isEmpty && body.isEmpty && data.isEmpty) {
        print('Skipping empty notification save');
        return;
      }

      final notification = LocalNotificationStorageService.createFromFCM(
        title: title,
        body: body,
        data: data,
      );

      await LocalNotificationStorageService.saveNotification(notification);
      print('Notification saved to local storage: ${notification.title}');
    } catch (e) {
      print('Error saving notification to local storage: $e');
    }
  }
}
