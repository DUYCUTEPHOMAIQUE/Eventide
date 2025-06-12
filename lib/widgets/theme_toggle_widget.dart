import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:enva/blocs/theme/theme_cubit.dart';

class ThemeToggleWidget extends StatelessWidget {
  final bool isCompact;
  const ThemeToggleWidget({Key? key, this.isCompact = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return isCompact
            ? _buildCompactToggle(context, themeMode)
            : _buildFullToggle(context, themeMode);
      },
    );
  }

  Widget _buildCompactToggle(BuildContext context, ThemeMode themeMode) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 1.5,
        ),
      ),
      child: IconButton(
        onPressed: () => _toggleTheme(context, themeMode),
        icon: Icon(
          isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          color: Theme.of(context).colorScheme.onSurface,
          size: 20,
        ),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(
          minWidth: 44,
          minHeight: 44,
        ),
        tooltip: isDark ? 'Chế độ sáng' : 'Chế độ tối',
      ),
    );
  }

  Widget _buildFullToggle(BuildContext context, ThemeMode themeMode) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption(
              context,
              themeMode,
              ThemeMode.light,
              Icons.light_mode_outlined,
              'Sáng',
            ),
            const SizedBox(width: 4),
            _buildThemeOption(
              context,
              themeMode,
              ThemeMode.dark,
              Icons.dark_mode_outlined,
              'Tối',
            ),
            const SizedBox(width: 4),
            _buildThemeOption(
              context,
              themeMode,
              ThemeMode.system,
              Icons.brightness_auto_outlined,
              'Tự động',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    ThemeMode currentMode,
    ThemeMode targetMode,
    IconData icon,
    String label,
  ) {
    final isSelected = currentMode == targetMode;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => context.read<ThemeCubit>().setThemeMode(targetMode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleTheme(BuildContext context, ThemeMode currentMode) {
    ThemeMode newMode;
    switch (currentMode) {
      case ThemeMode.light:
        newMode = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        newMode = ThemeMode.system;
        break;
      case ThemeMode.system:
        newMode = ThemeMode.light;
        break;
    }
    context.read<ThemeCubit>().setThemeMode(newMode);
  }
}

// Theme-aware icon helper
class ThemeAwareIcon extends StatelessWidget {
  final IconData lightIcon;
  final IconData darkIcon;
  final double? size;
  final Color? color;

  const ThemeAwareIcon({
    Key? key,
    required this.lightIcon,
    required this.darkIcon,
    this.size,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Icon(
      isDark ? darkIcon : lightIcon,
      size: size,
      color: color,
    );
  }
}

// Theme toggle button for app bars
class AppBarThemeToggle extends StatelessWidget {
  const AppBarThemeToggle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () {
              final newMode = isDark ? ThemeMode.light : ThemeMode.dark;
              context.read<ThemeCubit>().setThemeMode(newMode);
            },
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              size: 20,
            ),
            tooltip: isDark ? 'Chế độ sáng' : 'Chế độ tối',
            padding: const EdgeInsets.all(8),
          ),
        );
      },
    );
  }
}
