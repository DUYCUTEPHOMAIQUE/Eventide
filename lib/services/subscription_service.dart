import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/subscription_model.dart';
import 'supabase_service.dart';

class SubscriptionService {
  static final _supabase = Supabase.instance.client;

  // Get current user's subscription
  static Future<UserSubscription?> getCurrentSubscription() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await _supabase
          .rpc('get_user_subscription', params: {'p_user_id': userId});

      if (response == null || response.isEmpty) {
        // Auto-assign free plan if no subscription exists
        await _assignFreePlan(userId);
        return await getCurrentSubscription();
      }

      return UserSubscription.fromJson(response.first);
    } catch (e) {
      print('Error getting current subscription: $e');
      return null;
    }
  }

  // Check if user has access to a feature
  static Future<bool> hasFeatureAccess(AppFeature feature) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final response = await _supabase.rpc('check_feature_access', params: {
        'p_user_id': userId,
        'p_feature_name': feature.key,
      });

      return response == true;
    } catch (e) {
      print('Error checking feature access: $e');
      return false;
    }
  }

  // Check if user can use a feature (considering usage limits)
  // Thay thế method canUseFeature trong SubscriptionService
  static Future<bool> canUseFeature(AppFeature feature) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        print('❌ canUseFeature: User not logged in');
        return false;
      }

      print('🔍 canUseFeature: Start check for user: $userId');
      print('🔍 canUseFeature: Feature: ${feature.key}');
      print('🔍 canUseFeature: Feature limitKey: ${feature.limitKey}');

      // Test trực tiếp database functions
      print('📞 Calling can_use_feature RPC...');
      final response = await _supabase.rpc('can_use_feature', params: {
        'p_user_id': userId,
        'p_feature_name': feature.limitKey,
      });

      print('📞 RPC Response: $response');
      print('📞 RPC Response type: ${response.runtimeType}');
      print('📞 RPC Response == true: ${response == true}');
      print('📞 RPC Response as bool: ${response as bool? ?? false}');

      // Test các functions riêng lẻ để debug
      try {
        print('🧪 Testing check_feature_access...');
        final accessResponse =
            await _supabase.rpc('check_feature_access', params: {
          'p_user_id': userId,
          'p_feature_name': feature.limitKey,
        });
        print('🧪 check_feature_access result: $accessResponse');

        print('🧪 Testing get_user_limits...');
        final limitsResponse = await _supabase.rpc('get_user_limits', params: {
          'p_user_id': userId,
        });
        print('🧪 get_user_limits result: $limitsResponse');

        print('🧪 Testing get_user_subscription...');
        final subResponse =
            await _supabase.rpc('get_user_subscription', params: {
          'p_user_id': userId,
        });
        print('🧪 get_user_subscription result: $subResponse');
      } catch (debugError) {
        print('🚨 Debug error: $debugError');
      }

      // Thử các cách parse response khác nhau
      bool result = false;
      if (response is bool) {
        result = response;
      } else if (response is String) {
        result = response == 'true';
      } else if (response is num) {
        result = response == 1;
      } else {
        print('⚠️ Unexpected response type: ${response.runtimeType}');
        result = false;
      }

      print('✅ Final canUseFeature result: $result');
      return result;
    } catch (e, stackTrace) {
      print('❌ Error checking feature usage: $e');
      print('❌ Stack trace: $stackTrace');
      return false;
    }
  }

  // Track feature usage
  static Future<int> trackFeatureUsage(AppFeature feature,
      {int increment = 1}) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return 0;

      final response = await _supabase.rpc('track_feature_usage', params: {
        'p_user_id': userId,
        'p_feature_name': feature.limitKey,
        'p_increment': increment,
      });

      return response ?? 0;
    } catch (e) {
      print('Error tracking feature usage: $e');
      return 0;
    }
  }

  // Get user's usage limits
  static Future<Map<String, dynamic>> getUserLimits() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return {};

      final response = await _supabase.rpc('get_user_limits', params: {
        'p_user_id': userId,
      });

      return Map<String, dynamic>.from(response ?? {});
    } catch (e) {
      print('Error getting user limits: $e');
      return {};
    }
  }

  // Get current usage for a feature
  static Future<int> getCurrentUsage(AppFeature feature) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return 0;

      final now = DateTime.now();
      final periodStart = DateTime(now.year, now.month, 1);

      final response = await _supabase
          .from('user_usage')
          .select('usage_count')
          .eq('user_id', userId)
          .eq('feature_name', feature.limitKey)
          .eq('period_start', periodStart.toIso8601String().split('T')[0])
          .maybeSingle();

      return response?['usage_count'] ?? 0;
    } catch (e) {
      print('Error getting current usage: $e');
      return 0;
    }
  }

  // Get all subscription plans
  static Future<List<SubscriptionPlan>> getSubscriptionPlans() async {
    try {
      final response =
          await _supabase.from('subscription_plans').select().order('price');

      return (response as List)
          .map((json) => SubscriptionPlan.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting subscription plans: $e');
      return [];
    }
  }

  // Upgrade subscription (placeholder for future payment integration)
  static Future<bool> upgradeSubscription(String planId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      // TODO: Integrate with payment system (Stripe, etc.)
      // For now, just update the subscription directly

      final response = await _supabase
          .from('user_subscriptions')
          .update({
            'status': 'cancelled',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .eq('status', 'active');

      // Create new subscription
      await _supabase.from('user_subscriptions').insert({
        'user_id': userId,
        'plan_id': planId,
        'status': 'active',
        'started_at': DateTime.now().toIso8601String(),
        'expires_at': DateTime.now().add(Duration(days: 30)).toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Error upgrading subscription: $e');
      return false;
    }
  }

  // Auto-assign free plan to user
  static Future<void> _assignFreePlan(String userId) async {
    try {
      await _supabase.rpc('assign_free_plan', params: {
        'p_user_id': userId,
      });
    } catch (e) {
      print('Error assigning free plan: $e');
    }
  }

  // Get feature usage summary for display
  static Future<Map<String, dynamic>> getUsageSummary() async {
    try {
      final subscription = await getCurrentSubscription();
      final limits = await getUserLimits();

      Map<String, dynamic> summary = {};

      for (AppFeature feature in AppFeature.values) {
        final currentUsage = await getCurrentUsage(feature);
        final limit = limits[feature.limitKey + '_per_month'] ?? 0;

        summary[feature.key] = {
          'current': currentUsage,
          'limit': limit,
          'unlimited': limit == -1,
          'percentage':
              limit > 0 ? (currentUsage / limit * 100).clamp(0, 100) : 0,
        };
      }

      return summary;
    } catch (e) {
      print('Error getting usage summary: $e');
      return {};
    }
  }

  // Check if user should see upgrade prompt
  static Future<bool> shouldShowUpgradePrompt(AppFeature feature) async {
    try {
      final canUse = await canUseFeature(feature);
      if (canUse) return false;

      final hasAccess = await hasFeatureAccess(feature);
      if (!hasAccess) return true; // Feature not available in current plan

      // Feature available but limit reached
      final currentUsage = await getCurrentUsage(feature);
      final limits = await getUserLimits();
      final limit = limits[feature.limitKey + '_per_month'] ?? 0;

      return limit > 0 && currentUsage >= limit;
    } catch (e) {
      print('Error checking upgrade prompt: $e');
      return false;
    }
  }

  static Future<String> redeemPremiumCode(String code) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return 'error';
      final result = await _supabase.rpc(
        'redeem_premium_code',
        params: {'p_user_id': userId, 'p_code': code},
      );
      if (result == 'success') return 'success';
      if (result == 'invalid') return 'invalid';
      return 'error';
    } catch (e) {
      return 'error';
    }
  }
}
