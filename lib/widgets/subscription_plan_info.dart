import 'package:flutter/material.dart';
import '../models/subscription_model.dart';
import '../services/subscription_service.dart';

class SubscriptionPlanInfoWidget extends StatefulWidget {
  final VoidCallback? onUpgradePressed;
  const SubscriptionPlanInfoWidget({Key? key, this.onUpgradePressed})
      : super(key: key);

  @override
  State<SubscriptionPlanInfoWidget> createState() =>
      _SubscriptionPlanInfoWidgetState();
}

class _SubscriptionPlanInfoWidgetState
    extends State<SubscriptionPlanInfoWidget> {
  UserSubscription? _subscription;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubscription();
  }

  Future<void> _loadSubscription() async {
    final sub = await SubscriptionService.getCurrentSubscription();
    if (mounted) {
      setState(() {
        _subscription = sub;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    if (_subscription == null) {
      return _buildError();
    }
    return _buildPlanInfo(_subscription!);
  }

  Widget _buildPlanInfo(UserSubscription sub) {
    final plan = sub.plan;
    final isFree = plan?.isFree ?? true;
    final isPremium = plan?.isPremium ?? false;
    final color = isPremium ? Colors.blue : Colors.grey;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isPremium ? Icons.star : Icons.workspace_premium,
                  color: color,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  plan?.name ?? 'Free',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const Spacer(),
                if (isFree)
                  ElevatedButton(
                    onPressed: widget.onUpgradePressed ?? _showUpgradeDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Upgrade'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              isPremium
                  ? 'You are enjoying all premium features!'
                  : 'You are using the Free plan. Upgrade for more features.',
              style: TextStyle(fontSize: 15, color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            _buildFeatureList(plan),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureList(SubscriptionPlan? plan) {
    if (plan == null) return SizedBox.shrink();
    final features = plan.features.keys.toList();
    final limits = plan.limits;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Features:', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ...features.map((f) => Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 16),
                const SizedBox(width: 8),
                Text(f
                    .replaceAll('_', ' ')
                    .replaceFirst(f[0], f[0].toUpperCase())),
              ],
            )),
        if (limits.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('Limits:', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...limits.entries.map((e) => Row(
                children: [
                  Icon(Icons.timelapse, color: Colors.orange, size: 16),
                  const SizedBox(width: 8),
                  Text(
                      '${e.key.replaceAll('_', ' ')}: ${e.value == -1 ? 'Unlimited' : e.value}'),
                ],
              )),
        ],
      ],
    );
  }

  Widget _buildError() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 12),
            Text('Could not load subscription info.'),
          ],
        ),
      ),
    );
  }

  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.star, color: Colors.amber),
            const SizedBox(width: 8),
            Text('Upgrade to Premium'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Unlock all premium features:'),
            const SizedBox(height: 12),
            _buildFeatureList(_subscription?.plan),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Maybe Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Premium upgrade coming soon!'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: Text('Upgrade Now'),
          ),
        ],
      ),
    );
  }
}
