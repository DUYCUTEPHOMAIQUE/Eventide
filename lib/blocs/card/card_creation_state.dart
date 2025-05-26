import 'dart:io';

import 'package:equatable/equatable.dart';

enum CardCreationStatus { initial, loading, success, failure }

class CardCreationState extends Equatable {
  final File? backgroundImage;
  final String title;
  final DateTime? dateTime;
  final String location;
  final String description;
  final List<File> memoryImages;
  final bool isPreviewMode;
  final CardCreationStatus status;
  final String? errorMessage;

  const CardCreationState({
    this.backgroundImage,
    this.title = '',
    this.dateTime,
    this.location = '',
    this.description = '',
    this.memoryImages = const [],
    this.isPreviewMode = false,
    this.status = CardCreationStatus.initial,
    this.errorMessage,
  });

  CardCreationState copyWith({
    File? backgroundImage,
    String? title,
    DateTime? dateTime,
    String? location,
    String? description,
    List<File>? memoryImages,
    bool? isPreviewMode,
    CardCreationStatus? status,
    String? errorMessage,
  }) {
    return CardCreationState(
      backgroundImage: backgroundImage ?? this.backgroundImage,
      title: title ?? this.title,
      dateTime: dateTime ?? this.dateTime,
      location: location ?? this.location,
      description: description ?? this.description,
      memoryImages: memoryImages ?? this.memoryImages,
      isPreviewMode: isPreviewMode ?? this.isPreviewMode,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  String get formattedDateTime {
    if (dateTime == null) {
      return 'Select Date & Time';
    }

    return '${dateTime!.day}/${dateTime!.month}/${dateTime!.year} at ${dateTime!.hour.toString().padLeft(2, '0')}:${dateTime!.minute.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [
        backgroundImage,
        title,
        dateTime,
        location,
        description,
        memoryImages,
        isPreviewMode,
        status,
        errorMessage
      ];
}
