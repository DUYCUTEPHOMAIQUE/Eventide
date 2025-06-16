import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class MinimalistTheme {
  // Minimalist Color Palette
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color gray200 = Color(0xFFEEEEEE);
  static const Color gray300 = Color(0xFFE0E0E0);
  static const Color gray400 = Color(0xFFBDBDBD);
  static const Color gray500 = Color(0xFF9E9E9E);
  static const Color gray600 = Color(0xFF757575);
  static const Color gray700 = Color(0xFF616161);
  static const Color gray800 = Color(0xFF424242);
  static const Color gray900 = Color(0xFF212121);

  // Accent Colors (minimal usage)
  static const Color blue50 = Color(0xFFE3F2FD);
  static const Color blue100 = Color(0xFFBBDEFB);
  static const Color blue200 = Color(0xFF90CAF9);
  static const Color blue500 = Color(0xFF2196F3);
  static const Color blue600 = Color(0xFF1E88E5);

  static const Color green50 = Color(0xFFE8F5E8);
  static const Color green600 = Color(0xFF43A047);

  static const Color red50 = Color(0xFFFFEBEE);
  static const Color red600 = Color(0xFFE53935);

  // Typography Scale (clear hierarchy)
  static TextStyle get displayLarge => const TextStyle(
        fontFamily: 'SF Pro Rounded',
        fontSize: 32,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        height: 1.2,
      );

  static TextStyle get displayMedium => const TextStyle(
        fontFamily: 'SF Pro Rounded',
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
        height: 1.2,
      );

  static TextStyle get headlineLarge => const TextStyle(
        fontFamily: 'SF Pro Rounded',
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        height: 1.3,
      );

  static TextStyle get headlineMedium => const TextStyle(
        fontFamily: 'SF Pro Rounded',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.3,
      );

  static TextStyle get titleLarge => const TextStyle(
        fontFamily: 'SF Pro Rounded',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.4,
      );

  static TextStyle get titleMedium => const TextStyle(
        fontFamily: 'SF Pro Rounded',
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        height: 1.4,
      );

  static TextStyle get bodyLarge => const TextStyle(
        fontFamily: 'SF Pro Rounded',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.5,
      );

  static TextStyle get bodyMedium => const TextStyle(
        fontFamily: 'SF Pro Rounded',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
        height: 1.4,
      );

  static TextStyle get bodySmall => const TextStyle(
        fontFamily: 'SF Pro Rounded',
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.4,
      );

  static TextStyle get labelLarge => const TextStyle(
        fontFamily: 'SF Pro Rounded',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.4,
      );

  // Spacing Scale (8pt grid system)
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space56 = 56.0;

  // Border Radius Scale
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;

  // Subtle shadows
  static List<BoxShadow> get subtleShadow => [
        BoxShadow(
          color: gray900.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: gray900.withOpacity(0.08),
          blurRadius: 20,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ];

  // Light Theme (primary minimalist theme)
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: 'SF Pro Rounded',

        // Color Scheme
        colorScheme: const ColorScheme.light(
          brightness: Brightness.light,
          primary: black,
          onPrimary: white,
          secondary: gray700,
          onSecondary: white,
          error: red600,
          onError: white,
          background: white,
          onBackground: gray900,
          surface: white,
          onSurface: gray900,
          surfaceVariant: gray50,
          onSurfaceVariant: gray700,
          outline: gray300,
        ),

        // App Bar Theme
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: white,
          foregroundColor: gray900,
          titleTextStyle: const TextStyle(
            fontFamily: 'SF Pro Rounded',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: gray900,
          ),
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
        ),

        // Scaffold Theme
        scaffoldBackgroundColor: white,

        // Card Theme
        cardTheme: CardThemeData(
          elevation: 0,
          color: white,
          shadowColor: gray900.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLarge),
            side: BorderSide(color: gray200, width: 1),
          ),
        ),

        // Button Themes
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: black,
            foregroundColor: white,
            disabledBackgroundColor: gray300,
            disabledForegroundColor: gray600,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
            minimumSize: const Size(double.infinity, 56),
            textStyle: const TextStyle(
              fontFamily: 'SF Pro Rounded',
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            elevation: 0,
            backgroundColor: white,
            foregroundColor: gray900,
            disabledForegroundColor: gray400,
            textStyle: labelLarge,
            side: BorderSide(color: gray300, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusLarge),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: space24,
              vertical: space16,
            ),
            minimumSize: const Size(double.infinity, space56),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: gray700,
            textStyle: labelLarge,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusMedium),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: space16,
              vertical: space12,
            ),
          ),
        ),

        // Input Decoration Theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: gray50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: gray200, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: gray200, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: blue200, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: red600, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          hintStyle: const TextStyle(
            fontFamily: 'SF Pro Rounded',
            fontSize: 16,
            color: gray500,
          ),
          labelStyle: const TextStyle(
            fontFamily: 'SF Pro Rounded',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: gray700,
          ),
        ),

        // Text Theme
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontFamily: 'SF Pro Rounded',
            fontSize: 32,
            fontWeight: FontWeight.w600,
            color: gray900,
          ),
          headlineLarge: TextStyle(
            fontFamily: 'SF Pro Rounded',
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: gray900,
          ),
          headlineMedium: TextStyle(
            fontFamily: 'SF Pro Rounded',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: gray900,
          ),
          titleLarge: TextStyle(
            fontFamily: 'SF Pro Rounded',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: gray900,
          ),
          titleMedium: TextStyle(
            fontFamily: 'SF Pro Rounded',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: gray800,
          ),
          bodyLarge: TextStyle(
            fontFamily: 'SF Pro Rounded',
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: gray900,
          ),
          bodyMedium: TextStyle(
            fontFamily: 'SF Pro Rounded',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: gray700,
          ),
          bodySmall: TextStyle(
            fontFamily: 'SF Pro Rounded',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: gray600,
          ),
          labelLarge: TextStyle(
            fontFamily: 'SF Pro Rounded',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: gray800,
          ),
        ),

        // Divider Theme
        dividerTheme: const DividerThemeData(
          color: gray200,
          thickness: 1,
          space: 1,
        ),

        // Icon Theme
        iconTheme: const IconThemeData(
          color: gray700,
          size: 24,
        ),

        // Bottom Navigation Bar Theme
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: white,
          selectedItemColor: black,
          unselectedItemColor: gray500,
          elevation: 8,
          type: BottomNavigationBarType.fixed,
        ),

        // Snackbar Theme
        snackBarTheme: SnackBarThemeData(
          backgroundColor: gray900,
          contentTextStyle: bodyMedium.copyWith(color: white),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
        ),

        // Chip Theme
        chipTheme: ChipThemeData(
          backgroundColor: gray100,
          disabledColor: gray100,
          selectedColor: blue50,
          secondarySelectedColor: blue100,
          padding:
              const EdgeInsets.symmetric(horizontal: space12, vertical: space8),
          labelStyle: labelLarge.copyWith(color: gray700),
          secondaryLabelStyle: labelLarge.copyWith(color: blue600),
          brightness: Brightness.light,
        ),
      );

  // Dark Theme (complete minimalist dark mode)
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: 'SF Pro Rounded',

        // Color Scheme for Dark Mode
        colorScheme: const ColorScheme.dark(
          brightness: Brightness.dark,
          primary: white,
          onPrimary: black,
          secondary: gray300,
          onSecondary: gray900,
          error: red600,
          onError: white,
          background: gray900,
          onBackground: white,
          surface: gray800,
          onSurface: white,
          surfaceVariant: gray700,
          onSurfaceVariant: gray300,
          outline: gray600,
        ),

        // Scaffold Theme
        scaffoldBackgroundColor: gray900,

        // App Bar Theme
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: gray900,
          foregroundColor: white,
          titleTextStyle: const TextStyle(
            fontFamily: 'SF Pro Rounded',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: white,
          ),
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
        ),

        // Button Themes
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: white,
            foregroundColor: black,
            disabledBackgroundColor: gray700,
            disabledForegroundColor: gray500,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
            minimumSize: const Size(double.infinity, 56),
            textStyle: const TextStyle(
              fontFamily: 'SF Pro Rounded',
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            elevation: 0,
            backgroundColor: gray900,
            foregroundColor: white,
            disabledForegroundColor: gray600,
            side: BorderSide(color: gray600, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
            minimumSize: const Size(double.infinity, 56),
            textStyle: const TextStyle(
              fontFamily: 'SF Pro Rounded',
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: gray300,
            textStyle: const TextStyle(
              fontFamily: 'SF Pro Rounded',
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),

        // Input Decoration Theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: gray800,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: gray600, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: gray600, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: blue200, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: red600, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          hintStyle: const TextStyle(
            fontFamily: 'SF Pro Rounded',
            fontSize: 16,
            color: gray500,
          ),
          labelStyle: const TextStyle(
            fontFamily: 'SF Pro Rounded',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: gray300,
          ),
        ),

        // Text Theme
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontFamily: 'SF Pro Rounded',
            fontSize: 32,
            fontWeight: FontWeight.w600,
            color: white,
          ),
          headlineLarge: TextStyle(
            fontFamily: 'SF Pro Rounded',
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: white,
          ),
          headlineMedium: TextStyle(
            fontFamily: 'SF Pro Rounded',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: white,
          ),
          titleLarge: TextStyle(
            fontFamily: 'SF Pro Rounded',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: white,
          ),
          titleMedium: TextStyle(
            fontFamily: 'SF Pro Rounded',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: gray200,
          ),
          bodyLarge: TextStyle(
            fontFamily: 'SF Pro Rounded',
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: white,
          ),
          bodyMedium: TextStyle(
            fontFamily: 'SF Pro Rounded',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: gray300,
          ),
          bodySmall: TextStyle(
            fontFamily: 'SF Pro Rounded',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: gray400,
          ),
          labelLarge: TextStyle(
            fontFamily: 'SF Pro Rounded',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: gray200,
          ),
        ),

        // Icon Theme
        iconTheme: const IconThemeData(
          color: gray300,
          size: 24,
        ),

        // Divider Theme
        dividerTheme: const DividerThemeData(
          color: gray700,
          thickness: 1,
          space: 1,
        ),

        // Card Theme
        cardTheme: CardThemeData(
          elevation: 0,
          color: gray800,
          shadowColor: black.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: gray700, width: 1),
          ),
        ),

        // Bottom Navigation Bar Theme
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: gray900,
          selectedItemColor: white,
          unselectedItemColor: gray500,
          elevation: 8,
          type: BottomNavigationBarType.fixed,
        ),

        // Snackbar Theme
        snackBarTheme: SnackBarThemeData(
          backgroundColor: gray800,
          contentTextStyle: GoogleFonts.poppins(
            fontSize: 14,
            color: white,
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        // Chip Theme
        chipTheme: ChipThemeData(
          backgroundColor: gray800,
          disabledColor: gray800,
          selectedColor: gray700,
          secondarySelectedColor: gray600,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          labelStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: gray300,
          ),
          secondaryLabelStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: blue200,
          ),
          brightness: Brightness.dark,
        ),
      );
}

// Helper Extensions
extension MinimalistSpacing on double {
  SizedBox get verticalSpace => SizedBox(height: this);
  SizedBox get horizontalSpace => SizedBox(width: this);
}

extension MinimalistColors on BuildContext {
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
}
