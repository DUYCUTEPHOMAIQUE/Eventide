import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static const String _themePreferenceKey = 'THEME_PREFERENCE';

  ThemeCubit() : super(ThemeMode.system);

  Future<void> loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themePreferenceKey);
    if (savedTheme != null) {
      emit(_getThemeModeFromString(savedTheme));
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (state == mode) return;

    emit(mode);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themePreferenceKey, _getStringFromThemeMode(mode));
  }

  ThemeMode _getThemeModeFromString(String themeString) {
    switch (themeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _getStringFromThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }
}
