class UserDeviceModel {
  final String id;
  final String userId;
  final String fcmToken;
  final String? deviceName;
  final String? platform;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserDeviceModel({
    required this.id,
    required this.userId,
    required this.fcmToken,
    this.deviceName,
    this.platform,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserDeviceModel.fromJson(Map<String, dynamic> json) {
    return UserDeviceModel(
      id: json['id'],
      userId: json['user_id'],
      fcmToken: json['fcm_token'],
      deviceName: json['device_name'],
      platform: json['platform'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'fcm_token': fcmToken,
      'device_name': deviceName,
      'platform': platform,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserDeviceModel copyWith({
    String? id,
    String? userId,
    String? fcmToken,
    String? deviceName,
    String? platform,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserDeviceModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fcmToken: fcmToken ?? this.fcmToken,
      deviceName: deviceName ?? this.deviceName,
      platform: platform ?? this.platform,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserDeviceModel(id: $id, userId: $userId, fcmToken: ${fcmToken.substring(0, 20)}..., deviceName: $deviceName, platform: $platform)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserDeviceModel &&
        other.id == id &&
        other.userId == userId &&
        other.fcmToken == fcmToken;
  }

  @override
  int get hashCode {
    return id.hashCode ^ userId.hashCode ^ fcmToken.hashCode;
  }
}
