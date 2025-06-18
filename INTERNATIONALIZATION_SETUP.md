# Internationalization (i18n) Setup Guide

## Overview

This app supports multiple languages with a clean, scalable architecture. Currently supports:
- English (en)
- Vietnamese (vi)

## Architecture

### 1. Language Service (`lib/services/language_service.dart`)
- Manages language selection and persistence
- Provides easy language switching
- Supports system language detection
- Easy to extend for new languages

### 2. Localization Files (`lib/l10n/`)
- `app_en.arb` - English translations
- `app_vi.arb` - Vietnamese translations
- `l10n.dart` - Supported locales configuration

### 3. Language Selector Widget (`lib/widgets/language_selector.dart`)
- Beautiful UI for language selection
- Shows flags and language names
- Supports system language option

## Setup Instructions

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Generate Localization Files
```bash
flutter gen-l10n
```

### 3. Enable Localization in main.dart
After running `flutter pub get`, uncomment these lines in `lib/main.dart`:

```dart
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// And uncomment the localizationsDelegates:
localizationsDelegates: const [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
],
```

### 4. Enable AppLocalizations in Widgets
After generation, uncomment this line in `lib/widgets/language_selector.dart`:
```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
```

## Usage

### 1. Using Translations in Widgets

```dart
// After enabling AppLocalizations
Text(AppLocalizations.of(context)?.createEvent ?? 'Create Event')

// Or with fallback
Text(AppLocalizations.of(context)?.eventTitle ?? 'Event Title')
```

### 2. Language Service Usage

```dart
// Get current language service
final languageService = context.read<LanguageService>();

// Change language
await languageService.setLanguage('vi');

// Get current language
final currentLang = languageService.currentLocale.languageCode;

// Reset to system language
await languageService.resetToSystemLanguage();
```

### 3. Show Language Selector

```dart
// Show as dialog
await LanguageSelectorDialog.show(context);

// Or use as widget
const LanguageSelector()
```

## Adding New Languages

### 1. Add Language Code
In `lib/services/language_service.dart`:

```dart
static const List<Locale> supportedLocales = [
  Locale('en'),
  Locale('vi'),
  Locale('fr'), // Add new language
];

static const Map<String, String> languageNames = {
  'en': 'English',
  'vi': 'Tiếng Việt',
  'fr': 'Français', // Add language name
};
```

### 2. Add Flag Emoji
In `lib/widgets/language_selector.dart`:

```dart
String _getLanguageFlag(String languageCode) {
  switch (languageCode) {
    case 'en':
      return '🇺🇸';
    case 'vi':
      return '🇻🇳';
    case 'fr':
      return '🇫🇷'; // Add flag
    default:
      return '🌐';
  }
}
```

### 3. Create Translation File
Create `lib/l10n/app_fr.arb`:

```json
{
  "@@locale": "fr",
  "appTitle": "Eventide",
  "createEvent": "Créer un événement",
  // ... add all translations
}
```

### 4. Regenerate Files
```bash
flutter gen-l10n
```

## Best Practices

### 1. Always Use Fallbacks
```dart
// Good
Text(AppLocalizations.of(context)?.createEvent ?? 'Create Event')

// Bad
Text(AppLocalizations.of(context)!.createEvent)
```

### 2. Use Descriptive Keys
```dart
// Good
"eventTitle": "Event Title"
"eventTitleHint": "Enter your event title"

// Bad
"title": "Event Title"
"hint": "Enter your event title"
```

### 3. Keep Translations Consistent
- Use consistent terminology across the app
- Maintain similar tone and style
- Consider cultural differences

### 4. Test All Languages
- Test UI layout with different text lengths
- Verify all translations are present
- Check for text overflow issues

## File Structure

```
lib/
├── l10n/
│   ├── app_en.arb          # English translations
│   ├── app_vi.arb          # Vietnamese translations
│   └── l10n.dart           # Locale configuration
├── services/
│   └── language_service.dart # Language management
└── widgets/
    └── language_selector.dart # Language selection UI
```

## Troubleshooting

### 1. Localization Not Working
- Run `flutter gen-l10n` to generate files
- Check that `generate: true` is in pubspec.yaml
- Verify AppLocalizations import is uncommented

### 2. Language Not Persisting
- Check SharedPreferences permissions
- Verify LanguageService is properly initialized
- Check for error logs in console

### 3. Missing Translations
- Add missing keys to all .arb files
- Run `flutter gen-l10n` again
- Restart the app

### 4. UI Issues with Long Text
- Test with different languages
- Use flexible layouts
- Consider text wrapping and overflow

## Future Enhancements

1. **RTL Support**: Add support for right-to-left languages
2. **Pluralization**: Support for plural forms
3. **Date/Time Formatting**: Localized date and time formats
4. **Number Formatting**: Localized number formats
5. **Currency Support**: Localized currency display
6. **Dynamic Language Loading**: Load languages on demand

## Contributing

When adding new features:
1. Add translations to all .arb files
2. Test with all supported languages
3. Update this documentation
4. Consider cultural implications 