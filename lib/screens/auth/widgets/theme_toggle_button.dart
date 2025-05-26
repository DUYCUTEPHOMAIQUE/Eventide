import 'package:enva/blocs/blocs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeCubit themeCubit = context.read<ThemeCubit>();
    final currentTheme = context.select((ThemeCubit cubit) => cubit.state);

    // Determine which icon to show based on current theme
    IconData themeIcon =
        currentTheme == ThemeMode.light ? Icons.light_mode : Icons.dark_mode;

    return IconButton(
      icon: Icon(themeIcon),
      onPressed: () {
        // Show theme selection modal
        showThemeSelectionModal(context, themeCubit, currentTheme);
      },
    );
  }

  void showThemeSelectionModal(
      BuildContext context, ThemeCubit themeCubit, ThemeMode currentTheme) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Choose Theme',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Light Theme Option
                    _buildThemeOption(
                      context,
                      themeCubit,
                      ThemeMode.light,
                      currentTheme,
                      'Light',
                      Icons.light_mode,
                    ),
                    // Dark Theme Option
                    _buildThemeOption(
                      context,
                      themeCubit,
                      ThemeMode.dark,
                      currentTheme,
                      'Dark',
                      Icons.dark_mode,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    ThemeCubit themeCubit,
    ThemeMode themeMode,
    ThemeMode currentTheme,
    String label,
    IconData icon,
  ) {
    final isSelected = currentTheme == themeMode;
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        themeCubit.setThemeMode(themeMode);
        Navigator.pop(context);
      },
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected ? Colors.purpleAccent : Colors.grey.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 40,
              color: isSelected ? Colors.purpleAccent : null,
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.purpleAccent : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
