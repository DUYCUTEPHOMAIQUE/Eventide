import 'dart:io';

import 'package:equatable/equatable.dart';

abstract class CardCreationEvent extends Equatable {
  const CardCreationEvent();

  @override
  List<Object?> get props => [];
}

class BackgroundImageChanged extends CardCreationEvent {
  final File image;

  const BackgroundImageChanged(this.image);

  @override
  List<Object?> get props => [image];
}

class TitleChanged extends CardCreationEvent {
  final String title;

  const TitleChanged(this.title);

  @override
  List<Object?> get props => [title];
}

class DateTimeChanged extends CardCreationEvent {
  final DateTime dateTime;

  const DateTimeChanged(this.dateTime);

  @override
  List<Object?> get props => [dateTime];
}

class LocationChanged extends CardCreationEvent {
  final String location;

  const LocationChanged(this.location);

  @override
  List<Object?> get props => [location];
}

class DescriptionChanged extends CardCreationEvent {
  final String description;

  const DescriptionChanged(this.description);

  @override
  List<Object?> get props => [description];
}

class MemoryImageAdded extends CardCreationEvent {
  final File image;

  const MemoryImageAdded(this.image);

  @override
  List<Object?> get props => [image];
}

class SubmitCard extends CardCreationEvent {
  const SubmitCard();
}

class PreviewModeToggled extends CardCreationEvent {
  const PreviewModeToggled();
}
