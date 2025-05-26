import 'package:bloc/bloc.dart';
import 'package:enva/blocs/card/card_creation_event.dart';
import 'package:enva/blocs/card/card_creation_state.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CardCreationBloc extends Bloc<CardCreationEvent, CardCreationState> {
  final ImagePicker _picker = ImagePicker();

  CardCreationBloc() : super(const CardCreationState()) {
    on<BackgroundImageChanged>(_onBackgroundImageChanged);
    on<TitleChanged>(_onTitleChanged);
    on<DateTimeChanged>(_onDateTimeChanged);
    on<LocationChanged>(_onLocationChanged);
    on<DescriptionChanged>(_onDescriptionChanged);
    on<MemoryImageAdded>(_onMemoryImageAdded);
    on<SubmitCard>(_onSubmitCard);
    on<PreviewModeToggled>(_onPreviewModeToggled);
  }

  void _onBackgroundImageChanged(
    BackgroundImageChanged event,
    Emitter<CardCreationState> emit,
  ) {
    emit(state.copyWith(backgroundImage: event.image));
  }

  void _onTitleChanged(
    TitleChanged event,
    Emitter<CardCreationState> emit,
  ) {
    emit(state.copyWith(title: event.title));
  }

  void _onDateTimeChanged(
    DateTimeChanged event,
    Emitter<CardCreationState> emit,
  ) {
    emit(state.copyWith(dateTime: event.dateTime));
  }

  void _onLocationChanged(
    LocationChanged event,
    Emitter<CardCreationState> emit,
  ) {
    emit(state.copyWith(location: event.location));
  }

  void _onDescriptionChanged(
    DescriptionChanged event,
    Emitter<CardCreationState> emit,
  ) {
    emit(state.copyWith(description: event.description));
  }

  void _onMemoryImageAdded(
    MemoryImageAdded event,
    Emitter<CardCreationState> emit,
  ) {
    final List<File> updatedImages = List.from(state.memoryImages)
      ..add(event.image);
    emit(state.copyWith(memoryImages: updatedImages));
  }

  void _onSubmitCard(
    SubmitCard event,
    Emitter<CardCreationState> emit,
  ) async {
    emit(state.copyWith(status: CardCreationStatus.loading));
    try {
      // Here you'd implement your card creation logic,
      // like saving to a database or sending to a server
      await Future.delayed(
          const Duration(seconds: 1)); // Simulating a network request
      emit(state.copyWith(status: CardCreationStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: CardCreationStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onPreviewModeToggled(
    PreviewModeToggled event,
    Emitter<CardCreationState> emit,
  ) {
    emit(state.copyWith(isPreviewMode: !state.isPreviewMode));
  }

  // Helper methods for UI use
  Future<void> pickBackgroundImage() async {
    print('pickBackgroundImage called');
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image != null) {
      add(BackgroundImageChanged(File(image.path)));
      print('Background image selected: ${image.path}');
    }
  }

  Future<void> pickMemoryImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image != null) {
      add(MemoryImageAdded(File(image.path)));
    }
  }

  Future<void> selectDateTime(
      DateTime? pickedDate, TimeOfDay? pickedTime) async {
    if (pickedDate != null && pickedTime != null) {
      final DateTime combinedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      add(DateTimeChanged(combinedDateTime));
    }
  }
}
