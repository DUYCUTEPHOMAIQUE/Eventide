import 'package:flutter/material.dart';
import '../services/subscription_service.dart';
import '../models/subscription_model.dart';

class SubscriptionPlanSection extends StatefulWidget {
  const SubscriptionPlanSection({Key? key}) : super(key: key);

  @override
  State<SubscriptionPlanSection> createState() =>
      _SubscriptionPlanSectionState();
}

class _SubscriptionPlanSectionState extends State<SubscriptionPlanSection> {
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
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final plan = _subscription?.plan;
    final isPremium = plan?.isPremium ?? false;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  isPremium ? Icons.workspace_premium : Icons.verified_user,
                  color: isPremium ? Colors.amber : Colors.blue,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  isPremium ? 'Premium Plan' : 'Free Plan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isPremium ? Colors.amber[800] : Colors.blue[800],
                  ),
                ),
                const Spacer(),
                if (!isPremium)
                  ElevatedButton(
                    onPressed: _showUpgradeDialog,
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
                  ? 'Bạn đang sử dụng gói Premium với toàn bộ tính năng không giới hạn.'
                  : 'Bạn đang sử dụng gói Free. Nâng cấp để mở khóa nhiều tính năng hơn!',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            _buildFeatureList(isPremium),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureList(bool isPremium) {
    final features = isPremium
        ? [
            'Tạo sự kiện không giới hạn',
            'Tạo thiệp AI không giới hạn',
            'Sử dụng template cao cấp',
            'Thống kê nâng cao',
            'Hỗ trợ ưu tiên',
          ]
        : [
            'Tối đa 5 sự kiện',
            '3 lần tạo thiệp AI/tháng',
            'Template cơ bản',
            'Có thể nâng cấp bất cứ lúc nào',
          ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: features
          .map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 16, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(child: Text(f, style: TextStyle(fontSize: 13))),
                  ],
                ),
              ))
          .toList(),
    );
  }

  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.workspace_premium, color: Colors.amber),
            const SizedBox(width: 8),
            Text('Nâng cấp Premium'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mở khóa toàn bộ tính năng không giới hạn:'),
            const SizedBox(height: 12),
            _buildFeatureList(true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Để sau'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Tính năng nâng cấp sẽ sớm ra mắt!'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: Text('Nâng cấp ngay'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
