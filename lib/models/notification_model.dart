import 'dart:convert';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type; // 'invite', 'system', 'reminder', etc.
  final Map<String, dynamic>? data;
  final DateTime createdAt;
  final bool isRead;
  final String? senderName;
  final String? eventTitle;
  final String? eventId;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.data,
    required this.createdAt,
    this.isRead = false,
    this.senderName,
    this.eventTitle,
    this.eventId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      type: json['type'],
      data:
          json['data'] != null ? Map<String, dynamic>.from(json['data']) : null,
      createdAt: DateTime.parse(json['created_at']),
      isRead: json['is_read'] ?? false,
      senderName: json['sender_name'],
      eventTitle: json['event_title'],
      eventId: json['event_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      'data': data,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
      'sender_name': senderName,
      'event_title': eventTitle,
      'event_id': eventId,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    String? type,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    bool? isRead,
    String? senderName,
    String? eventTitle,
    String? eventId,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      senderName: senderName ?? this.senderName,
      eventTitle: eventTitle ?? this.eventTitle,
      eventId: eventId ?? this.eventId,
    );
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, title: $title, type: $type, isRead: $isRead, createdAt: $createdAt)';
  }

  // Helper getter with localization
  String getTimeAgo(BuildContext context) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    final appLocalizations = AppLocalizations.of(context);
    if (appLocalizations == null) {
      // Fallback to Vietnamese
      if (difference.inDays > 0) {
        return '${difference.inDays} ngày trước';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} giờ trước';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} phút trước';
      } else {
        return 'Vừa xong';
      }
    }

    if (difference.inDays > 0) {
      return appLocalizations.timeAgoDaysAgo(difference.inDays);
    } else if (difference.inHours > 0) {
      return appLocalizations.timeAgoHoursAgo(difference.inHours);
    } else if (difference.inMinutes > 0) {
      return appLocalizations.timeAgoMinutesAgo(difference.inMinutes);
    } else {
      return appLocalizations.timeAgoJustNow;
    }
  }

  // Keep the old timeAgo getter for backwards compatibility
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  String get iconData {
    switch (type) {
      case 'invite':
        return '💌';
      case 'reminder':
        return '⏰';
      case 'update':
        return '📝';
      case 'system':
        return '⚙️';
      default:
        return '🔔';
    }
  }
}
