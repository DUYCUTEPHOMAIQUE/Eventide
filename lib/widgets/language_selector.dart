import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:enva/services/language_service.dart';
import 'package:enva/l10n/app_localizations.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.language,
                    size: 24,
                    color: Colors.grey.shade700,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppLocalizations.of(context)?.language ?? 'Language',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Language options
              ...LanguageService.supportedLocales.map((locale) {
                final isSelected = languageService.currentLocale.languageCode ==
                    locale.languageCode;
                final languageName =
                    languageService.getLanguageName(locale.languageCode);

                return _buildLanguageOption(
                  context,
                  languageName,
                  locale.languageCode,
                  isSelected,
                  languageService,
                );
              }).toList(),

              const SizedBox(height: 20),

              // System language option
              _buildSystemLanguageOption(context, languageService),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String languageName,
    String languageCode,
    bool isSelected,
    LanguageService languageService,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isSelected ? Colors.blue.shade200 : Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(32),
          onTap: () => languageService.setLanguage(languageCode),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Language flag/icon
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.blue.shade100
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      _getLanguageFlag(languageCode),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Language name
                Expanded(
                  child: Text(
                    languageName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.blue.shade700
                          : Colors.grey.shade800,
                    ),
                  ),
                ),

                // Check icon if selected
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: Colors.blue.shade600,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSystemLanguageOption(
    BuildContext context,
    LanguageService languageService,
  ) {
    final systemLanguage = LanguageService.getSystemLanguage();
    final isSystemSelected =
        languageService.currentLocale.languageCode == systemLanguage;

    return Container(
      decoration: BoxDecoration(
        color: isSystemSelected ? Colors.green.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color:
              isSystemSelected ? Colors.green.shade200 : Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(32),
          onTap: () => languageService.resetToSystemLanguage(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // System icon
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isSystemSelected
                        ? Colors.green.shade100
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.settings,
                    size: 18,
                    color: isSystemSelected
                        ? Colors.green.shade600
                        : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 16),

                // System language text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)?.systemLanguage ??
                            'System Language',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isSystemSelected
                              ? Colors.green.shade700
                              : Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        languageService.getLanguageName(systemLanguage),
                        style: TextStyle(
                          fontSize: 14,
                          color: isSystemSelected
                              ? Colors.green.shade600
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Check icon if selected
                if (isSystemSelected)
                  Icon(
                    Icons.check_circle,
                    color: Colors.green.shade600,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getLanguageFlag(String languageCode) {
    switch (languageCode) {
      case 'en':
        return '🇺🇸';
      case 'vi':
        return '🇻🇳';
      case 'fr':
        return '🇫🇷';
      case 'es':
        return '🇪🇸';
      case 'de':
        return '🇩🇪';
      case 'ja':
        return '🇯🇵';
      case 'ko':
        return '🇰🇷';
      case 'zh':
        return '🇨🇳';
      default:
        return '🌐';
    }
  }
}

// Simple language selector dialog
class LanguageSelectorDialog extends StatelessWidget {
  const LanguageSelectorDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.language,
                    size: 24,
                    color: Colors.grey.shade700,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppLocalizations.of(context)?.language ?? 'Language',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade900,
                    ),
                  ),
                ],
              ),
            ),

            // Language options
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: const LanguageSelector(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const LanguageSelectorDialog(),
    );
  }
}
