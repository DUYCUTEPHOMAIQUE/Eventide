// lib/cubits/locale/locale_cubit.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// State
class LocaleState extends Equatable {
  final Locale locale;

  const LocaleState(this.locale);

  @override
  List<Object> get props => [locale];
}

class LocaleCubit extends Cubit<LocaleState> {
  static const String LOCALE_KEY = 'user_locale';

  LocaleCubit() : super(const LocaleState(Locale('en'))) {
    loadSavedLocale();
  }

  Future<void> loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(LOCALE_KEY);

    if (languageCode != null) {
      changeLocale(Locale(languageCode));
    }
  }

  Future<void> changeLocale(Locale locale) async {
    if (['en', 'vi'].contains(locale.languageCode)) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(LOCALE_KEY, locale.languageCode);

      emit(LocaleState(locale));
    }
  }

  Future<void> toggleLocale() async {
    final currentLocale = state.locale;
    final newLocale = currentLocale.languageCode == 'en'
        ? const Locale('vi')
        : const Locale('en');

    await changeLocale(newLocale);
  }
}
