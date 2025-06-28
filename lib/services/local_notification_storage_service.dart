import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';

class LocalNotificationStorageService {
  static const String _notificationsKey = 'local_notifications';
  static const int _maxNotifications = 100; // Giới hạn số thông báo

  // Lưu thông báo mới
  static Future<void> saveNotification(NotificationModel notification) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notifications = await getNotifications();

      // Thêm thông báo mới vào đầu danh sách
      notifications.insert(0, notification);

      // Giới hạn số lượng thông báo
      if (notifications.length > _maxNotifications) {
        notifications.removeRange(_maxNotifications, notifications.length);
      }

      // Lưu lại
      final jsonList = notifications.map((n) => n.toJson()).toList();
      await prefs.setString(_notificationsKey, jsonEncode(jsonList));

      print('Notification saved: ${notification.title}');
    } catch (e) {
      print('Error saving notification: $e');
    }
  }

  // Lấy tất cả thông báo
  static Future<List<NotificationModel>> getNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_notificationsKey);

      if (jsonString == null) return [];

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => NotificationModel.fromJson(json)).toList();
    } catch (e) {
      print('Error getting notifications: $e');
      return [];
    }
  }

  // Lấy thông báo chưa đọc
  static Future<List<NotificationModel>> getUnreadNotifications() async {
    final notifications = await getNotifications();
    return notifications.where((n) => !n.isRead).toList();
  }

  // Đánh dấu thông báo đã đọc
  static Future<void> markAsRead(String notificationId) async {
    try {
      final notifications = await getNotifications();
      final index = notifications.indexWhere((n) => n.id == notificationId);

      if (index != -1) {
        notifications[index] = notifications[index].copyWith(isRead: true);

        final prefs = await SharedPreferences.getInstance();
        final jsonList = notifications.map((n) => n.toJson()).toList();
        await prefs.setString(_notificationsKey, jsonEncode(jsonList));

        print('Notification marked as read: $notificationId');
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  // Đánh dấu tất cả thông báo đã đọc
  static Future<void> markAllAsRead() async {
    try {
      final notifications = await getNotifications();
      final updatedNotifications =
          notifications.map((n) => n.copyWith(isRead: true)).toList();

      final prefs = await SharedPreferences.getInstance();
      final jsonList = updatedNotifications.map((n) => n.toJson()).toList();
      await prefs.setString(_notificationsKey, jsonEncode(jsonList));

      print('All notifications marked as read');
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  // Xóa thông báo
  static Future<void> deleteNotification(String notificationId) async {
    try {
      final notifications = await getNotifications();
      notifications.removeWhere((n) => n.id == notificationId);

      final prefs = await SharedPreferences.getInstance();
      final jsonList = notifications.map((n) => n.toJson()).toList();
      await prefs.setString(_notificationsKey, jsonEncode(jsonList));

      print('Notification deleted: $notificationId');
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  // Xóa tất cả thông báo
  static Future<void> clearAllNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_notificationsKey);
      print('All notifications cleared');
    } catch (e) {
      print('Error clearing all notifications: $e');
    }
  }

  // Xóa thông báo cũ (> 30 ngày)
  static Future<void> cleanOldNotifications() async {
    try {
      final notifications = await getNotifications();
      final thirtyDaysAgo = DateTime.now().subtract(Duration(days: 30));

      final filteredNotifications = notifications
          .where((n) => n.createdAt.isAfter(thirtyDaysAgo))
          .toList();

      if (filteredNotifications.length != notifications.length) {
        final prefs = await SharedPreferences.getInstance();
        final jsonList = filteredNotifications.map((n) => n.toJson()).toList();
        await prefs.setString(_notificationsKey, jsonEncode(jsonList));

        final deletedCount =
            notifications.length - filteredNotifications.length;
        print('Cleaned $deletedCount old notifications');
      }
    } catch (e) {
      print('Error cleaning old notifications: $e');
    }
  }

  // Lấy số lượng thông báo chưa đọc
  static Future<int> getUnreadCount() async {
    final unreadNotifications = await getUnreadNotifications();
    return unreadNotifications.length;
  }

  // Tạo thông báo từ FCM data
  static NotificationModel createFromFCM({
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) {
    // Handle empty/null title and body
    final cleanTitle = (title.isEmpty || title == 'null')
        ? (data['card_title'] ?? data['title'] ?? 'Thông báo mới')
        : title;

    final cleanBody = (body.isEmpty || body == 'null')
        ? (data['body'] ?? data['message'] ?? 'Bạn có thông báo mới')
        : body;

    // Determine notification type from data
    String notificationType = data['type'] ?? 'system';
    if (data.containsKey('card_id') && data.containsKey('sender_name')) {
      notificationType = 'invite';
    }

    // Create appropriate icon based on type
    String iconData = '🔔'; // Default bell
    switch (notificationType) {
      case 'invite':
        iconData = '📧';
        break;
      case 'reminder':
        iconData = '⏰';
        break;
      case 'update':
        iconData = '📝';
        break;
      case 'system':
        iconData = '⚙️';
        break;
      default:
        iconData = '🔔';
    }

    return NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: cleanTitle,
      body: cleanBody,
      type: notificationType,
      data: data,
      createdAt: DateTime.now(),
      senderName: data['sender_name'],
      eventTitle: data['card_title'] ?? data['event_title'],
      eventId: data['card_id'] ?? data['event_id'],
    );
  }
}
