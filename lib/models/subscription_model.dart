class SubscriptionPlan {
  final String id;
  final String name;
  final double price;
  final int durationMonths;
  final Map<String, dynamic> features;
  final Map<String, dynamic> limits;
  final DateTime createdAt;
  final DateTime updatedAt;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.durationMonths,
    required this.features,
    required this.limits,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    try {
      return SubscriptionPlan(
        id: (json['id'] ?? '').toString(),
        name: (json['name'] ?? 'Free').toString(),
        price: (json['price'] ?? 0).toDouble(),
        durationMonths: json['duration_months'] ?? 0,
        features: Map<String, dynamic>.from(json['features'] ?? {}),
        limits: Map<String, dynamic>.from(json['limits'] ?? {}),
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'])
            : DateTime.now(),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'])
            : DateTime.now(),
      );
    } catch (e) {
      print('Error parsing SubscriptionPlan: $e');
      print('JSON data: $json');
      // Return default plan
      return SubscriptionPlan(
        id: 'default',
        name: 'Free',
        price: 0.0,
        durationMonths: 12,
        features: {'ai_generation': true, 'basic_templates': true},
        limits: {'max_cards': 5, 'ai_generations_per_month': 3},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'duration_months': durationMonths,
      'features': features,
      'limits': limits,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper methods to check features
  bool hasFeature(String featureName) {
    return features[featureName] == true;
  }

  int getLimit(String limitName) {
    final limit = limits[limitName];
    if (limit == null) return 0;
    if (limit == -1) return -1; // unlimited
    return limit as int;
  }

  bool isUnlimited(String limitName) {
    return getLimit(limitName) == -1;
  }

  bool get isFree => name.toLowerCase() == 'free';
  bool get isPremium => name.toLowerCase() == 'premium';
}

class UserSubscription {
  final String id;
  final String userId;
  final String planId;
  final String status;
  final DateTime startedAt;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final SubscriptionPlan? plan; // Join with plan data

  UserSubscription({
    required this.id,
    required this.userId,
    required this.planId,
    required this.status,
    required this.startedAt,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
    this.plan,
  });

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    try {
      return UserSubscription(
        id: (json['id'] ?? json['subscription_id'] ?? '').toString(),
        userId: (json['user_id'] ?? '').toString(),
        planId: (json['plan_id'] ?? '').toString(),
        status: (json['status'] ?? 'active').toString(),
        startedAt: json['started_at'] != null
            ? DateTime.parse(json['started_at'])
            : DateTime.now(),
        expiresAt: json['expires_at'] != null
            ? DateTime.parse(json['expires_at'])
            : null,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'])
            : DateTime.now(),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'])
            : DateTime.now(),
        plan: json['plan_name'] != null
            ? SubscriptionPlan(
                id: (json['plan_id'] ?? '').toString(),
                name: (json['plan_name'] ?? 'Free').toString(),
                price: 0.0,
                durationMonths: 0,
                features: Map<String, dynamic>.from(json['features'] ?? {}),
                limits: Map<String, dynamic>.from(json['limits'] ?? {}),
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              )
            : null,
      );
    } catch (e) {
      print('Error parsing UserSubscription: $e');
      print('JSON data: $json');
      // Return default subscription
      return UserSubscription(
        id: 'default',
        userId: json['user_id']?.toString() ?? '',
        planId: 'free',
        status: 'active',
        startedAt: DateTime.now(),
        expiresAt: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        plan: null,
      );
    }
  }

  bool get isActive => status == 'active';
  bool get isExpired =>
      expiresAt != null && expiresAt!.isBefore(DateTime.now());
  bool get isValid => isActive && !isExpired;

  // Helper methods using plan data
  bool hasFeature(String featureName) {
    return plan?.hasFeature(featureName) ?? false;
  }

  int getLimit(String limitName) {
    return plan?.getLimit(limitName) ?? 0;
  }

  bool isUnlimited(String limitName) {
    return plan?.isUnlimited(limitName) ?? false;
  }
}

class UserUsage {
  final String id;
  final String userId;
  final String featureName;
  final int usageCount;
  final DateTime periodStart;
  final DateTime periodEnd;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserUsage({
    required this.id,
    required this.userId,
    required this.featureName,
    required this.usageCount,
    required this.periodStart,
    required this.periodEnd,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserUsage.fromJson(Map<String, dynamic> json) {
    return UserUsage(
      id: json['id'],
      userId: json['user_id'],
      featureName: json['feature_name'],
      usageCount: json['usage_count'],
      periodStart: DateTime.parse(json['period_start']),
      periodEnd: DateTime.parse(json['period_end']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'feature_name': featureName,
      'usage_count': usageCount,
      'period_start': periodStart.toIso8601String(),
      'period_end': periodEnd.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isCurrentPeriod {
    final now = DateTime.now();
    return now.isAfter(periodStart) &&
        now.isBefore(periodEnd.add(Duration(days: 1)));
  }
}

enum AppFeature {
  aiGeneration,
  unlimitedCards,
  premiumTemplates,
  advancedAnalytics,
  teamCollaboration,
  customBranding,
}

extension AppFeatureExtension on AppFeature {
  String get key {
    switch (this) {
      case AppFeature.aiGeneration:
        return 'ai_generation';
      case AppFeature.unlimitedCards:
        return 'unlimited_cards';
      case AppFeature.premiumTemplates:
        return 'premium_templates';
      case AppFeature.advancedAnalytics:
        return 'analytics';
      case AppFeature.teamCollaboration:
        return 'team_collaboration';
      case AppFeature.customBranding:
        return 'custom_branding';
    }
  }

  String get displayName {
    switch (this) {
      case AppFeature.aiGeneration:
        return 'AI Card Generation';
      case AppFeature.unlimitedCards:
        return 'Unlimited Cards';
      case AppFeature.premiumTemplates:
        return 'Premium Templates';
      case AppFeature.advancedAnalytics:
        return 'Advanced Analytics';
      case AppFeature.teamCollaboration:
        return 'Team Collaboration';
      case AppFeature.customBranding:
        return 'Custom Branding';
    }
  }

  String get limitKey {
    switch (this) {
      case AppFeature.aiGeneration:
        return 'ai_generation';
      case AppFeature.unlimitedCards:
        return 'max_cards';
      default:
        return key;
    }
  }
}
