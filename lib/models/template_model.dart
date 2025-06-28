import 'package:flutter/material.dart';

/// Template model cho card templates
/// Supports free, premium, and pro tiers với rich styling options
class CardTemplate {
  final String id;
  final String name;
  final String description;
  final String category;
  final TemplateTier tier;
  final String? previewImageUrl;
  final TemplateGradient backgroundGradient;
  final TemplateColorScheme colorScheme;
  final String layoutStyle;
  final bool isLocked;
  final int sortOrder;

  CardTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.tier,
    this.previewImageUrl,
    required this.backgroundGradient,
    required this.colorScheme,
    required this.layoutStyle,
    required this.isLocked,
    this.sortOrder = 0,
  });

  factory CardTemplate.fromJson(Map<String, dynamic> json) {
    return CardTemplate(
      id: json['template_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      tier: TemplateTier.fromString(json['tier']?.toString() ?? 'free'),
      previewImageUrl: json['preview_image_url']?.toString(),
      backgroundGradient: TemplateGradient.fromJson(json['background_gradient'] ?? {}),
      colorScheme: TemplateColorScheme.fromJson(json['color_scheme'] ?? {}),
      layoutStyle: json['layout_style']?.toString() ?? 'classic',
      isLocked: json['is_locked'] ?? false,
      sortOrder: json['sort_order'] ?? 0,
    );
  }

  // Helper getters
  bool get isFree => tier == TemplateTier.free;
  bool get isPremium => tier == TemplateTier.premium;
  bool get isPro => tier == TemplateTier.pro;
  bool get isAvailable => !isLocked;

  String get tierDisplayName => tier.displayName;
  Color get tierColor => tier.color;
  IconData get tierIcon => tier.icon;

  // Create gradient for UI
  LinearGradient get uiGradient => backgroundGradient.toLinearGradient();
}

/// Template tier enum với styling
enum TemplateTier {
  free,
  premium,
  pro;

  static TemplateTier fromString(String value) {
    switch (value.toLowerCase()) {
      case 'premium':
        return TemplateTier.premium;
      case 'pro':
        return TemplateTier.pro;
      default:
        return TemplateTier.free;
    }
  }

  String get displayName {
    switch (this) {
      case TemplateTier.free:
        return 'Free';
      case TemplateTier.premium:
        return 'Premium';
      case TemplateTier.pro:
        return 'Pro';
    }
  }

  Color get color {
    switch (this) {
      case TemplateTier.free:
        return Colors.green;
      case TemplateTier.premium:
        return Colors.blue;
      case TemplateTier.pro:
        return Colors.purple;
    }
  }

  IconData get icon {
    switch (this) {
      case TemplateTier.free:
        return Icons.check_circle;
      case TemplateTier.premium:
        return Icons.star;
      case TemplateTier.pro:
        return Icons.diamond;
    }
  }
}

/// Template gradient configuration
class TemplateGradient {
  final List<Color> colors;
  final String direction;

  TemplateGradient({
    required this.colors,
    required this.direction,
  });

  factory TemplateGradient.fromJson(Map<String, dynamic> json) {
    List<Color> colorList = [];
    
    if (json['colors'] is List) {
      colorList = (json['colors'] as List)
          .map((colorHex) => _parseColor(colorHex.toString()))
          .where((color) => color != null)
          .cast<Color>()
          .toList();
    }

    // Default gradient if no colors
    if (colorList.isEmpty) {
      colorList = [Colors.blue.shade400, Colors.blue.shade600];
    }

    return TemplateGradient(
      colors: colorList,
      direction: json['direction']?.toString() ?? 'to bottom right',
    );
  }

  LinearGradient toLinearGradient() {
    Alignment begin = Alignment.topLeft;
    Alignment end = Alignment.bottomRight;

    // Parse direction
    switch (direction.toLowerCase()) {
      case 'to right':
        begin = Alignment.centerLeft;
        end = Alignment.centerRight;
        break;
      case 'to bottom':
        begin = Alignment.topCenter;
        end = Alignment.bottomCenter;
        break;
      case 'to left':
        begin = Alignment.centerRight;
        end = Alignment.centerLeft;
        break;
      case 'to top':
        begin = Alignment.bottomCenter;
        end = Alignment.topCenter;
        break;
      case '45deg':
        begin = Alignment.bottomLeft;
        end = Alignment.topRight;
        break;
      case 'radial':
        // For radial, we'll use a linear approximation
        begin = Alignment.center;
        end = Alignment.bottomRight;
        break;
    }

    return LinearGradient(
      begin: begin,
      end: end,
      colors: colors,
    );
  }

  static Color? _parseColor(String colorHex) {
    try {
      String hex = colorHex.replaceAll('#', '');
      if (hex.length == 6) {
        hex = 'FF$hex'; // Add alpha if not present
      }
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return null;
    }
  }
}

/// Template color scheme
class TemplateColorScheme {
  final Color primary;
  final Color secondary;
  final Color text;
  final Color accent;

  TemplateColorScheme({
    required this.primary,
    required this.secondary,
    required this.text,
    required this.accent,
  });

  factory TemplateColorScheme.fromJson(Map<String, dynamic> json) {
    return TemplateColorScheme(
      primary: _parseColor(json['primary']?.toString()) ?? Colors.blue,
      secondary: _parseColor(json['secondary']?.toString()) ?? Colors.blue.shade300,
      text: _parseColor(json['text']?.toString()) ?? Colors.black87,
      accent: _parseColor(json['accent']?.toString()) ?? Colors.white,
    );
  }

  static Color _parseColor(String? colorHex) {
    if (colorHex == null) return Colors.blue;
    try {
      String hex = colorHex.replaceAll('#', '');
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return Colors.blue;
    }
  }

  // Helper for creating themed text styles
  TextStyle titleStyle({double fontSize = 24, FontWeight? fontWeight}) {
    return TextStyle(
      color: text,
      fontSize: fontSize,
      fontWeight: fontWeight ?? FontWeight.w600,
      fontFamily: 'SF Pro Rounded',
    );
  }

  TextStyle bodyStyle({double fontSize = 16}) {
    return TextStyle(
      color: text.withOpacity(0.8),
      fontSize: fontSize,
      fontFamily: 'SF Pro Rounded',
    );
  }

  TextStyle accentStyle({double fontSize = 14}) {
    return TextStyle(
      color: accent,
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      fontFamily: 'SF Pro Rounded',
    );
  }
}

/// Template categories enum
enum TemplateCategory {
  birthday,
  wedding,
  business,
  party,
  babyShower,
  graduation,
  anniversary,
  conference,
  workshop;

  static TemplateCategory fromString(String value) {
    switch (value.toLowerCase()) {
      case 'birthday':
        return TemplateCategory.birthday;
      case 'wedding':
        return TemplateCategory.wedding;
      case 'business':
        return TemplateCategory.business;
      case 'party':
        return TemplateCategory.party;
      case 'baby_shower':
        return TemplateCategory.babyShower;
      case 'graduation':
        return TemplateCategory.graduation;
      case 'anniversary':
        return TemplateCategory.anniversary;
      case 'conference':
        return TemplateCategory.conference;
      case 'workshop':
        return TemplateCategory.workshop;
      default:
        return TemplateCategory.party;
    }
  }

  String get displayName {
    switch (this) {
      case TemplateCategory.birthday:
        return 'Birthday';
      case TemplateCategory.wedding:
        return 'Wedding';
      case TemplateCategory.business:
        return 'Business';
      case TemplateCategory.party:
        return 'Party';
      case TemplateCategory.babyShower:
        return 'Baby Shower';
      case TemplateCategory.graduation:
        return 'Graduation';
      case TemplateCategory.anniversary:
        return 'Anniversary';
      case TemplateCategory.conference:
        return 'Conference';
      case TemplateCategory.workshop:
        return 'Workshop';
    }
  }

  IconData get icon {
    switch (this) {
      case TemplateCategory.birthday:
        return Icons.cake;
      case TemplateCategory.wedding:
        return Icons.favorite;
      case TemplateCategory.business:
        return Icons.business;
      case TemplateCategory.party:
        return Icons.celebration;
      case TemplateCategory.babyShower:
        return Icons.child_friendly;
      case TemplateCategory.graduation:
        return Icons.school;
      case TemplateCategory.anniversary:
        return Icons.favorite_border;
      case TemplateCategory.conference:
        return Icons.groups;
      case TemplateCategory.workshop:
        return Icons.build;
    }
  }
}
