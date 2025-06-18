import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  static const String _defaultLanguage = 'en';

  Locale _currentLocale = const Locale('en');

  Locale get currentLocale => _currentLocale;

  // Supported languages - easy to expand
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('vi'), // Vietnamese
    // Add more languages here as needed:
    // Locale('fr'), // French
    // Locale('es'), // Spanish
    // Locale('de'), // German
    // Locale('ja'), // Japanese
    // Locale('ko'), // Korean
    // Locale('zh'), // Chinese
  ];

  // Language names for UI display
  static const Map<String, String> languageNames = {
    'en': 'English',
    'vi': 'Tiếng Việt',
    // Add more language names here:
    // 'fr': 'Français',
    // 'es': 'Español',
    // 'de': 'Deutsch',
    // 'ja': '日本語',
    // 'ko': '한국어',
    // 'zh': '中文',
  };

  LanguageService() {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString(_languageKey) ?? _defaultLanguage;
      _currentLocale = Locale(savedLanguage);
      notifyListeners();
    } catch (e) {
      // Fallback to default language if there's an error
      _currentLocale = const Locale(_defaultLanguage);
      notifyListeners();
    }
  }

  Future<void> setLanguage(String languageCode) async {
    if (!supportedLocales
        .any((locale) => locale.languageCode == languageCode)) {
      throw ArgumentError('Unsupported language code: $languageCode');
    }

    _currentLocale = Locale(languageCode);

    // Save to preferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
    } catch (e) {
      // Log error but don't crash the app
      debugPrint('Failed to save language preference: $e');
    }

    notifyListeners();
  }

  String getLanguageName(String languageCode) {
    return languageNames[languageCode] ?? languageCode;
  }

  String getCurrentLanguageName() {
    return getLanguageName(_currentLocale.languageCode);
  }

  // Get system language if supported, otherwise return default
  static String getSystemLanguage() {
    final systemLocale = WidgetsBinding.instance.window.locale;
    final systemLanguageCode = systemLocale.languageCode;

    if (supportedLocales
        .any((locale) => locale.languageCode == systemLanguageCode)) {
      return systemLanguageCode;
    }

    return _defaultLanguage;
  }

  // Reset to system language
  Future<void> resetToSystemLanguage() async {
    final systemLanguage = getSystemLanguage();
    await setLanguage(systemLanguage);
  }
}
