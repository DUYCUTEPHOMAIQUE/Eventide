import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:enva/blocs/blocs.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ToggleLanguageButton extends StatelessWidget {
  final Color? backgroundColor;
  final Color? textColor;

  const ToggleLanguageButton({
    Key? key,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, state) {
        final isEnglish = state.locale.languageCode == 'en';
        final languageCode = isEnglish ? 'VI' : 'EN';
        // final l10n = AppLocalizations.of(context);

        return InkWell(
          onTap: () {
            context.read<LocaleCubit>().toggleLocale();
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.language,
                  size: 18,
                  color: textColor ?? Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  languageCode,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor ?? Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
