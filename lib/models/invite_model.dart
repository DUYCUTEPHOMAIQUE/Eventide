class InviteModel {
  final String id;
  final String cardId;
  final String senderId;
  final String receiverId;
  final String status; // pending, accepted, declined, cancelled, undecided
  final DateTime sentAt;

  InviteModel({
    required this.id,
    required this.cardId,
    required this.senderId,
    required this.receiverId,
    required this.status,
    required this.sentAt,
  });

  factory InviteModel.fromJson(Map<String, dynamic> json) {
    return InviteModel(
      id: json['id'] ?? '',
      cardId: json['card_id'] ?? '',
      senderId: json['sender_id'] ?? '',
      receiverId: json['receiver_id'] ?? '',
      status: json['status'] ?? 'pending',
      sentAt:
          DateTime.parse(json['sent_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'card_id': cardId,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'status': status,
      'sent_at': sentAt.toIso8601String(),
    };
  }

  InviteModel copyWith({
    String? id,
    String? cardId,
    String? senderId,
    String? receiverId,
    String? status,
    DateTime? sentAt,
  }) {
    return InviteModel(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      status: status ?? this.status,
      sentAt: sentAt ?? this.sentAt,
    );
  }

  @override
  String toString() {
    return 'InviteModel(id: $id, cardId: $cardId, senderId: $senderId, receiverId: $receiverId, status: $status, sentAt: $sentAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InviteModel &&
        other.id == id &&
        other.cardId == cardId &&
        other.senderId == senderId &&
        other.receiverId == receiverId &&
        other.status == status &&
        other.sentAt == sentAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        cardId.hashCode ^
        senderId.hashCode ^
        receiverId.hashCode ^
        status.hashCode ^
        sentAt.hashCode;
  }
}
