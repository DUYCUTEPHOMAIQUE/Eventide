import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'invite_model.g.dart';

@HiveType(typeId: 1)
class InviteModel extends HiveObject with EquatableMixin {
  @HiveField(0)
  final String id = '';
  @HiveField(1)
  final String cardId;
  @HiveField(2)
  final String senderId;
  @HiveField(3)
  final String receiverId;
  @HiveField(4)
  final String status = 'pending';
  @HiveField(5)
  final String sent_at = DateTime.now().toIso8601String();
  @HiveField(6)
  final String expired_at = '';
  @HiveField(7)
  final String accepted_at = '';

  InviteModel({
    required this.cardId,
    required this.senderId,
    required this.receiverId,
  });
  @override
  // TODO: implement props
  List<Object?> get props => <Object?>[
        id,
        cardId,
        senderId,
        receiverId,
      ];
}
