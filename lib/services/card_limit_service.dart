import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/subscription_model.dart';
import 'subscription_service.dart';

/// Service để quản lý card creation limits
/// Follows Repository pattern với clear separation of concerns
class CardLimitService {
  static final _supabase = Supabase.instance.client;

  /// Card usage summary model
  static const String _cardUsageSummaryRPC = 'get_card_usage_summary';
  static const String _canCreateCardRPC = 'can_create_card';

  /// Get comprehensive card usage summary for current user
  static Future<CardUsageSummary?> getCardUsageSummary() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await _supabase.rpc(
        _cardUsageSummaryRPC,
        params: {'p_user_id': userId},
      );

      if (response == null || response.isEmpty) return null;

      final data = response.first;
      return CardUsageSummary.fromJson(data);
    } catch (e) {
      print('Error getting card usage summary: $e');
      return null;
    }
  }

  /// Check if current user can create more cards
  static Future<bool> canCreateCard() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final response = await _supabase.rpc(
        _canCreateCardRPC,
        params: {'p_user_id': userId},
      );

      return response == true;
    } catch (e) {
      print('Error checking card creation permission: $e');
      return false;
    }
  }

  /// Get card creation status with detailed info
  static Future<CardCreationStatus> getCardCreationStatus() async {
    try {
      final summary = await getCardUsageSummary();
      if (summary == null) {
        return CardCreationStatus.error('Unable to fetch card limits');
      }

      if (summary.canCreateMore) {
        return CardCreationStatus.allowed(summary);
      }

      // Check if user has premium subscription
      final subscription = await SubscriptionService.getCurrentSubscription();
      final isPremium = subscription?.plan?.isPremium ?? false;

      if (isPremium) {
        return CardCreationStatus.allowed(summary);
      }

      return CardCreationStatus.limitReached(summary);
    } catch (e) {
      return CardCreationStatus.error('Error checking card creation status: $e');
    }
  }

  /// Validate card creation before allowing UI interaction
  static Future<CardCreationValidationResult> validateCardCreation() async {
    final status = await getCardCreationStatus();
    
    return CardCreationValidationResult(
      canCreate: status.isAllowed,
      reason: status.message,
      usageSummary: status.summary,
      shouldShowUpgrade: status.isLimitReached,
    );
  }
}

/// Card usage summary model
class CardUsageSummary {
  final int currentCards;
  final int maxCards;
  final bool canCreateMore;
  final double percentageUsed;

  CardUsageSummary({
    required this.currentCards,
    required this.maxCards,
    required this.canCreateMore,
    required this.percentageUsed,
  });

  factory CardUsageSummary.fromJson(Map<String, dynamic> json) {
    return CardUsageSummary(
      currentCards: json['current_cards'] ?? 0,
      maxCards: json['max_cards'] ?? 0,
      canCreateMore: json['can_create_more'] ?? false,
      percentageUsed: (json['percentage_used'] ?? 0).toDouble(),
    );
  }

  bool get isUnlimited => maxCards == -1;
  bool get isNearLimit => percentageUsed >= 80.0;
  bool get isAtLimit => !canCreateMore && !isUnlimited;
  
  String get displayText {
    if (isUnlimited) return 'Unlimited';
    return '$currentCards/$maxCards cards';
  }

  String get progressText {
    if (isUnlimited) return 'Unlimited cards';
    return '$currentCards of $maxCards cards used';
  }
}

/// Card creation status with detailed information
class CardCreationStatus {
  final bool isAllowed;
  final bool isLimitReached;
  final bool isError;
  final String message;
  final CardUsageSummary? summary;

  CardCreationStatus._({
    required this.isAllowed,
    required this.isLimitReached,
    required this.isError,
    required this.message,
    this.summary,
  });

  factory CardCreationStatus.allowed(CardUsageSummary summary) {
    return CardCreationStatus._(
      isAllowed: true,
      isLimitReached: false,
      isError: false,
      message: 'You can create more cards',
      summary: summary,
    );
  }

  factory CardCreationStatus.limitReached(CardUsageSummary summary) {
    return CardCreationStatus._(
      isAllowed: false,
      isLimitReached: true,
      isError: false,
      message: 'You have reached your card creation limit (${summary.currentCards}/${summary.maxCards})',
      summary: summary,
    );
  }

  factory CardCreationStatus.error(String errorMessage) {
    return CardCreationStatus._(
      isAllowed: false,
      isLimitReached: false,
      isError: true,
      message: errorMessage,
    );
  }
}

/// Validation result for card creation
class CardCreationValidationResult {
  final bool canCreate;
  final String reason;
  final CardUsageSummary? usageSummary;
  final bool shouldShowUpgrade;

  CardCreationValidationResult({
    required this.canCreate,
    required this.reason,
    this.usageSummary,
    required this.shouldShowUpgrade,
  });

  bool get isValid => canCreate;
  bool get shouldBlockCreation => !canCreate;
}
