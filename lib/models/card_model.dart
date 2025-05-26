import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'card_model.g.dart';

@HiveType(typeId: 0)
class CardModel extends HiveObject with EquatableMixin {
  @HiveField(0)
  final String id = '';
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String description;
  @HiveField(3)
  final String imageUserUrl;
  @HiveField(4)
  final String ownerId;
  @HiveField(5)
  final String backgroundImageUrl = 'default';
  @HiveField(6)
  final String location = '';
  @HiveField(7)
  final String created_at = DateTime.now().toIso8601String();

  CardModel({
    required this.title,
    required this.description,
    required this.imageUserUrl,
    required this.ownerId,
  });

  @override
  // TODO: implement props
  List<Object?> get props => <Object?>[
        id,
        title,
        description,
        ownerId,
      ];
}
