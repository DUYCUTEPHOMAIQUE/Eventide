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
import '../models/card_model.dart';
import '../l10n/app_localizations.dart';

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

  // Current image URLs (for editing mode)
  String _currentBackgroundImageUrl = '';
  String _currentCardImageUrl = '';

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
  String get currentBackgroundImageUrl => _currentBackgroundImageUrl;
  String get currentCardImageUrl => _currentCardImageUrl;
  bool get isCreatingCard => _isCreatingCard;
  String get progressMessage => _progressMessage;
  String? get errorMessage => _errorMessage;

  // Computed properties
  bool get hasBackgroundImage =>
      _backgroundImageFile != null || _currentBackgroundImageUrl.isNotEmpty;
  bool get hasCardImage =>
      _cardImageFile != null || _currentCardImageUrl.isNotEmpty;
  bool get hasLocation => _selectedLocation != null || _location.isNotEmpty;
  bool get hasEventDateTime => _eventDateTime != null;
  bool get isFormValid => _title.isNotEmpty && _description.isNotEmpty;

  // Helper method for formatted event date time
  String getFormattedEventDateTime(BuildContext context) {
    if (_eventDateTime == null) return '';

    // Check if current locale is Vietnamese
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'vi') {
      // Vietnamese format: "Thứ 2, ngày 28 tháng 6, 2:30 PM"
      return '${_getWeekday(context, _eventDateTime!.weekday)}, ngày ${_eventDateTime!.day} ${_getMonth(context, _eventDateTime!.month)}, ${_formatTime(_eventDateTime!)}';
    } else {
      // English format: "Mon, Jun 28, 2:30 PM"
      return '${_getWeekday(context, _eventDateTime!.weekday)}, ${_getMonth(context, _eventDateTime!.month)} ${_eventDateTime!.day}, ${_formatTime(_eventDateTime!)}';
    }
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
    _currentBackgroundImageUrl = '';
    _clearError();
    notifyListeners();
  }

  void removeCardImage() {
    _cardImageFile = null;
    _currentCardImageUrl = '';
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

      // Step 1: Upload background image if provided, otherwise use current
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
      } else if (_currentBackgroundImageUrl.isNotEmpty) {
        // Keep current background image
        backgroundImageUrl = _currentBackgroundImageUrl;
      }

      // Step 2: Upload card image if provided, otherwise use current
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
      } else if (_currentCardImageUrl.isNotEmpty) {
        // Keep current card image
        cardImageUrl = _currentCardImageUrl;
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
    _currentBackgroundImageUrl = '';
    _currentCardImageUrl = '';
    _errorMessage = null;
    _progressMessage = '';
    notifyListeners();
  }

  void clearForm() {
    _resetForm();
  }

  // Load card data for editing
  void loadCardForEditing(CardModel card) {
    _title = card.title;
    _description = card.description;
    _location = card.location;
    _selectedLocation = card.latitude != null && card.longitude != null
        ? LatLng(card.latitude!, card.longitude!)
        : null;
    _eventDateTime = card.eventDateTime;

    // Load current image URLs
    _currentBackgroundImageUrl = card.backgroundImageUrl;
    _currentCardImageUrl = card.imageUrl;

    // Reset new image files
    _backgroundImageFile = null;
    _cardImageFile = null;

    _errorMessage = null;
    _progressMessage = '';
    notifyListeners();
  }

  // Update card method
  Future<bool> updateCard(String cardId) async {
    if (!isFormValid) {
      _setError('Vui lòng điền đầy đủ thông tin');
      return false;
    }

    _isCreatingCard = true;
    _clearError();
    _setProgress('Bắt đầu cập nhật thẻ...');
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

      // Step 1: Upload background image if provided, otherwise use current
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
      } else if (_currentBackgroundImageUrl.isNotEmpty) {
        // Keep current background image
        backgroundImageUrl = _currentBackgroundImageUrl;
      }

      // Step 2: Upload card image if provided, otherwise use current
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
      } else if (_currentCardImageUrl.isNotEmpty) {
        // Keep current card image
        cardImageUrl = _currentCardImageUrl;
      }

      // Step 3: Update card using CardService
      _setProgress('Đang cập nhật thẻ...');
      final success = await _cardService.updateCard(
        cardId: cardId,
        title: _title,
        description: _description,
        imageUrl: cardImageUrl,
        backgroundImageUrl: backgroundImageUrl,
        location: _location,
        latitude: _selectedLocation?.latitude,
        longitude: _selectedLocation?.longitude,
        eventDateTime: _eventDateTime,
      );

      if (success) {
        _setProgress('Đã cập nhật thẻ thành công!');
        return true;
      } else {
        _setError('Không thể cập nhật thẻ');
        return false;
      }
    } catch (e) {
      _setError('Lỗi cập nhật thẻ: $e');
      return false;
    } finally {
      _isCreatingCard = false;
      _progressMessage = '';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
