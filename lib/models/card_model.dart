import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'user_model.dart';
import 'package:enva/l10n/app_localizations.dart';

class CardModel extends Equatable {
  final String id;
  final String title;
  final String description;
  String imageUserUrl;
  final String ownerId;
  String backgroundImageUrl = 'default';
  String location = '';
  final String created_at = DateTime.now().toIso8601String();
  String imageUrl = '';
  double? latitude;
  double? longitude;

  DateTime? eventDateTime;
  // Not using Hive for participants as it contains UserModel objects
  List<UserModel> participants = [];
  // Not using Hive for invite status as it's only used for display
  String? inviteStatus;

  CardModel({
    required this.id,
    required this.title,
    required this.description,
    this.imageUserUrl = '',
    required this.ownerId,
    required this.imageUrl,
    required this.backgroundImageUrl,
    required this.location,
    this.latitude,
    this.longitude,
    this.eventDateTime,
    this.participants = const [],
    this.inviteStatus,
  });

  @override
  List<Object?> get props => <Object?>[
        id,
        title,
        description,
        ownerId,
        participants,
      ];

  factory CardModel.fromJson(Map<String, dynamic> json) {
    List<UserModel> participants = [];
    if (json['participants'] != null) {
      participants = (json['participants'] as List)
          .map((participant) => UserModel.fromJson(participant))
          .toList();
    }

    return CardModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageUserUrl: json['image_user_url'] ?? '',
      ownerId: json['owner_id'] ?? '',
      imageUrl: json['image_url'] ?? '',
      backgroundImageUrl: json['background_image_url'] ?? 'default',
      location: json['location'] ?? '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      eventDateTime: json['event_date_time'] != null
          ? DateTime.parse(json['event_date_time'])
          : null,
      participants: participants,
      inviteStatus: json['invite_status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_user_url': imageUserUrl ?? '',
      'owner_id': ownerId ?? '',
      'background_image_url': backgroundImageUrl ?? '',
      'location': location ?? '',
      'latitude': latitude,
      'longitude': longitude,
      'created_at': created_at ?? '',
      'image_url': imageUrl,
      'event_date_time': eventDateTime?.toIso8601String(),
      'participants': participants.map((p) => p.toJson()).toList(),
      'invite_status': inviteStatus,
    };
  }

  CardModel copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUserUrl,
    String? ownerId,
    String? backgroundImageUrl,
    String? location,
    double? latitude,
    double? longitude,
    DateTime? eventDateTime,
    List<UserModel>? participants,
    String? inviteStatus,
  }) {
    return CardModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUserUrl: imageUserUrl ?? this.imageUserUrl,
      ownerId: ownerId ?? this.ownerId,
      imageUrl: imageUrl,
      backgroundImageUrl: backgroundImageUrl ?? this.backgroundImageUrl,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      eventDateTime: eventDateTime ?? this.eventDateTime,
      participants: participants ?? this.participants,
      inviteStatus: inviteStatus ?? this.inviteStatus,
    );
  }

  // Helper methods for coordinates
  bool get hasCoordinates => latitude != null && longitude != null;

  // Helper method for location
  bool get hasLocation => location.isNotEmpty;

  String get coordinatesString => hasCoordinates
      ? '${latitude!.toStringAsFixed(6)}, ${longitude!.toStringAsFixed(6)}'
      : '';

  // Generate Google Maps URL for navigation
  String get googleMapsUrl => hasCoordinates
      ? 'https://www.google.com/maps/search/?api=1&query=${latitude},${longitude}'
      : '';

  // Generate Apple Maps URL for navigation
  String get appleMapsUrl =>
      hasCoordinates ? 'http://maps.apple.com/?q=${latitude},${longitude}' : '';

  // Helper method for event date time
  bool get hasEventDateTime => eventDateTime != null;

  String getFormattedEventDateTime(BuildContext context) {
    if (eventDateTime == null) return '';
    final l10n = AppLocalizations.of(context)!;

    // Check if current locale is Vietnamese
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'vi') {
      // Vietnamese format: "Thứ 2, ngày 28 tháng 6, 2:30 PM"
      return '${_getWeekday(context, eventDateTime!.weekday)}, ngày ${eventDateTime!.day} ${_getMonth(context, eventDateTime!.month)}, ${_formatTime(eventDateTime!)}';
    } else {
      // English format: "Mon, Jun 28, 2:30 PM"
      return '${_getWeekday(context, eventDateTime!.weekday)}, ${_getMonth(context, eventDateTime!.month)} ${eventDateTime!.day}, ${_formatTime(eventDateTime!)}';
    }
  }

  // Get accepted participants (those who have accepted the invite)
  List<UserModel> get acceptedParticipants => participants;

  // Get participant count
  int get participantCount => participants.length;

  String _getWeekday(BuildContext context, int weekday) {
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'vi') {
      const weekdays = [
        '',
        'Thứ 2',
        'Thứ 3',
        'Thứ 4',
        'Thứ 5',
        'Thứ 6',
        'Thứ 7',
        'Chủ nhật'
      ];
      return weekdays[weekday];
    } else {
      const weekdays = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return weekdays[weekday];
    }
  }

  String _getMonth(BuildContext context, int month) {
    final l10n = AppLocalizations.of(context)!;
    switch (month) {
      case 1:
        return l10n.month_jan;
      case 2:
        return l10n.month_feb;
      case 3:
        return l10n.month_mar;
      case 4:
        return l10n.month_apr;
      case 5:
        return l10n.month_may;
      case 6:
        return l10n.month_jun;
      case 7:
        return l10n.month_jul;
      case 8:
        return l10n.month_aug;
      case 9:
        return l10n.month_sep;
      case 10:
        return l10n.month_oct;
      case 11:
        return l10n.month_nov;
      case 12:
        return l10n.month_dec;
      default:
        return '';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour == 0
        ? 12
        : dateTime.hour > 12
            ? dateTime.hour - 12
            : dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
