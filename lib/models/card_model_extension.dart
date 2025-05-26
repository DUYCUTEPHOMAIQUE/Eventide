import 'package:enva/models/card_model.dart';

extension CardModelExtension on CardModel {
  static CardModel create({
    required String title,
    required String description,
    required String imageUserUrl,
    required String ownerId,
    String? customBackgroundUrl,
    String? customLocation,
    String? customCreatedAt,
  }) {
    final card = CardModel(
      title: title,
      description: description,
      imageUserUrl: imageUserUrl,
      ownerId: ownerId,
    );

    // Use reflection to access and modify the private fields
    // Note: This is a workaround since the fields are final in CardModel
    if (customBackgroundUrl != null) {
      final cardObject = card as dynamic;
      cardObject.backgroundImageUrl = customBackgroundUrl;
    }

    if (customLocation != null) {
      final cardObject = card as dynamic;
      cardObject.location = customLocation;
    }

    if (customCreatedAt != null) {
      final cardObject = card as dynamic;
      cardObject.created_at = customCreatedAt;
    }

    return card;
  }
}
