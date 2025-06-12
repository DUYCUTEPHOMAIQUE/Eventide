import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../services/card_service.dart';
import '../services/image_picker_service.dart';
import '../services/cloudinary_service.dart';
import '../services/supabase_services.dart';

class CardCreationViewModel extends ChangeNotifier {
  final CardService _cardService = CardService();
  final CloudinaryService _cloudinaryService = CloudinaryService();

  // Form fields
  String _title = '';
  String _description = '';
  String _location = '';
  LatLng? _selectedLocation;
  DateTime? _eventDateTime;

  // Image files (selected but not uploaded yet)
  File? _backgroundImageFile;
  File? _cardImageFile;

  // Creation state
  bool _isCreatingCard = false;
  String _progressMessage = '';

  // Error handling
  String? _errorMessage;

  // Getters
  String get title => _title;
  String get description => _description;
  String get location => _location;
  LatLng? get selectedLocation => _selectedLocation;
  DateTime? get eventDateTime => _eventDateTime;
  File? get backgroundImageFile => _backgroundImageFile;
  File? get cardImageFile => _cardImageFile;
  bool get isCreatingCard => _isCreatingCard;
  String get progressMessage => _progressMessage;
  String? get errorMessage => _errorMessage;

  // Computed properties
  bool get hasBackgroundImage => _backgroundImageFile != null;
  bool get hasCardImage => _cardImageFile != null;
  bool get hasLocation => _selectedLocation != null || _location.isNotEmpty;
  bool get hasEventDateTime => _eventDateTime != null;
  bool get isFormValid => _title.isNotEmpty && _description.isNotEmpty;

  // Helper method for formatted event date time
  String get formattedEventDateTime {
    if (_eventDateTime == null) return '';
    return '${_getWeekday(_eventDateTime!.weekday)}, ${_getMonth(_eventDateTime!.month)} ${_eventDateTime!.day}, ${_formatTime(_eventDateTime!)}';
  }

  // Form setters
  void setTitle(String value) {
    _title = value;
    _clearError();
    notifyListeners();
  }

  void setDescription(String value) {
    _description = value;
    _clearError();
    notifyListeners();
  }

  void setLocation(String value) {
    _location = value;
    _clearError();
    notifyListeners();
  }

  void setSelectedLocation(LatLng location) {
    _selectedLocation = location;
    _convertLocationToAddress(location);
    _clearError();
    notifyListeners();
  }

  void setEventDateTime(DateTime dateTime) {
    _eventDateTime = dateTime;
    _clearError();
    notifyListeners();
  }

  void clearEventDateTime() {
    _eventDateTime = null;
    _clearError();
    notifyListeners();
  }

  // Helper methods for date formatting
  String _getWeekday(int weekday) {
    const weekdays = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[weekday];
  }

  String _getMonth(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month];
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

  Future<void> _convertLocationToAddress(LatLng location) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        _location = '${place.street}, ${place.locality}, ${place.country}';
        notifyListeners();
      }
    } catch (e) {
      print('Error converting location to address: $e');
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _setError('Vui lòng cấp quyền truy cập vị trí');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _setError('Quyền truy cập vị trí bị từ chối vĩnh viễn');
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition();
      LatLng currentLocation = LatLng(position.latitude, position.longitude);
      setSelectedLocation(currentLocation);
    } catch (e) {
      _setError('Không thể lấy vị trí hiện tại: $e');
    }
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _setProgress(String message) {
    _progressMessage = message;
    notifyListeners();
  }

  // Image picking methods - only store files, don't upload
  void pickBackgroundImage(BuildContext context) {
    ImagePickerService.showImageSourceDialog(
      context,
      onImageSelected: (File? imageFile) {
        if (imageFile != null) {
          _backgroundImageFile = imageFile;
          _clearError();
          notifyListeners();
        }
      },
    );
  }

  void pickCardImage(BuildContext context) {
    ImagePickerService.showImageSourceDialog(
      context,
      onImageSelected: (File? imageFile) {
        if (imageFile != null) {
          _cardImageFile = imageFile;
          _clearError();
          notifyListeners();
        }
      },
    );
  }

  // Remove image methods
  void removeBackgroundImage() {
    _backgroundImageFile = null;
    _clearError();
    notifyListeners();
  }

  void removeCardImage() {
    _cardImageFile = null;
    _clearError();
    notifyListeners();
  }

  // Create card method - calls CardService
  Future<bool> createCard() async {
    if (!isFormValid) {
      _setError('Vui lòng điền đầy đủ thông tin');
      return false;
    }

    _isCreatingCard = true;
    _clearError();
    _setProgress('Bắt đầu tạo thẻ...');
    notifyListeners();

    try {
      // Get current user
      final currentUser = SupabaseServices.client.auth.currentUser;
      if (currentUser == null) {
        _setError('Bạn chưa đăng nhập');
        return false;
      }

      String? backgroundImageUrl;
      String? cardImageUrl;

      // Step 1: Upload background image if provided
      if (_backgroundImageFile != null) {
        _setProgress('Đang upload ảnh nền...');
        backgroundImageUrl = await _cloudinaryService.uploadImageToCloudinary(
          _backgroundImageFile!,
          folder: 'card_backgrounds',
        );

        if (backgroundImageUrl != null) {
          _setProgress('Đã upload ảnh nền thành công');
        } else {
          _setError('Lỗi upload ảnh nền');
          return false;
        }
      }

      // Step 2: Upload card image if provided
      if (_cardImageFile != null) {
        _setProgress('Đang upload ảnh kỷ niệm...');
        cardImageUrl = await _cloudinaryService.uploadImageToCloudinary(
          _cardImageFile!,
          folder: 'card_images',
        );

        if (cardImageUrl != null) {
          _setProgress('Đã upload ảnh kỷ niệm thành công');
        } else {
          _setError('Lỗi upload ảnh kỷ niệm');
          return false;
        }
      }

      // Step 3: Create card using CardService
      _setProgress('Đang tạo thẻ...');
      final card = await _cardService.createCard(
        title: _title,
        description: _description,
        ownerId: currentUser.id,
        imageUrl: cardImageUrl,
        backgroundImageUrl: backgroundImageUrl,
        location: _location,
        latitude: _selectedLocation?.latitude,
        longitude: _selectedLocation?.longitude,
        eventDateTime: _eventDateTime,
      );

      if (card != null) {
        _setProgress('Đã tạo thẻ thành công!');
        // Reset form after successful creation
        _resetForm();
        return true;
      } else {
        _setError('Không thể tạo thẻ');
        return false;
      }
    } catch (e) {
      _setError('Lỗi tạo thẻ: $e');
      return false;
    } finally {
      _isCreatingCard = false;
      _progressMessage = '';
      notifyListeners();
    }
  }

  // Reset form
  void _resetForm() {
    _title = '';
    _description = '';
    _location = '';
    _selectedLocation = null;
    _eventDateTime = null;
    _backgroundImageFile = null;
    _cardImageFile = null;
    _errorMessage = null;
    _progressMessage = '';
    notifyListeners();
  }

  void clearForm() {
    _resetForm();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
