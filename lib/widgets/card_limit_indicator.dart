import 'package:flutter/material.dart';
import '../services/card_limit_service.dart';

/// Widget hiển thị card usage với progress indicator
/// Follows Material Design principles và reusable component pattern
class CardLimitIndicator extends StatefulWidget {
  final bool showLabel;
  final bool showProgress;
  final VoidCallback? onUpgradePressed;

  const CardLimitIndicator({
    Key? key,
    this.showLabel = true,
    this.showProgress = true,
    this.onUpgradePressed,
  }) : super(key: key);

  @override
  State<CardLimitIndicator> createState() => _CardLimitIndicatorState();
}

class _CardLimitIndicatorState extends State<CardLimitIndicator> {
  CardUsageSummary? _summary;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsageData();
  }

  Future<void> _loadUsageData() async {
    try {
      final summary = await CardLimitService.getCardUsageSummary();
      setState(() {
        _summary = summary;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_summary == null) {
      return _buildErrorState();
    }

    return _buildUsageIndicator();
  }

  Widget _buildLoadingState() {
    return const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }

  Widget _buildErrorState() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.error_outline, size: 16, color: Colors.red),
        if (widget.showLabel) ...[
          const SizedBox(width: 4),
          Text('Error', style: TextStyle(color: Colors.red, fontSize: 12)),
        ],
      ],
    );
  }

  Widget _buildUsageIndicator() {
    final summary = _summary!;
    final color = _getProgressColor(summary);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showLabel) ...[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.credit_card, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                summary.displayText,
                style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500),
              ),
              if (summary.isNearLimit && !summary.isUnlimited) ...[
                const SizedBox(width: 4),
                _buildUpgradeButton(),
              ],
            ],
          ),
          if (widget.showProgress && !summary.isUnlimited)
            const SizedBox(height: 4),
        ],
        if (widget.showProgress && !summary.isUnlimited)
          _buildProgressBar(summary, color),
      ],
    );
  }

  Widget _buildProgressBar(CardUsageSummary summary, Color color) {
    return SizedBox(
      width: 120,
      height: 8,
      child: LinearProgressIndicator(
        value: summary.percentageUsed / 100,
        backgroundColor: Colors.grey[300],
        valueColor: AlwaysStoppedAnimation<Color>(color),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildUpgradeButton() {
    return GestureDetector(
      onTap: widget.onUpgradePressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          'Upgrade',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Color _getProgressColor(CardUsageSummary summary) {
    if (summary.isUnlimited) return Colors.green;
    if (summary.isAtLimit) return Colors.red;
    if (summary.isNearLimit) return Colors.orange;
    return Colors.green;
  }

  /// Refresh usage data programmatically
  Future<void> refresh() async {
    await _loadUsageData();
  }
}

/// Compact card limit badge for headers/toolbars
class CardLimitBadge extends StatelessWidget {
  final CardUsageSummary summary;
  final VoidCallback? onTap;

  const CardLimitBadge({
    Key? key,
    required this.summary,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (summary.isUnlimited) {
      return _buildUnlimitedBadge();
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _getBadgeColor().withOpacity(0.1),
          border: Border.all(color: _getBadgeColor()),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.credit_card, size: 14, color: _getBadgeColor()),
            const SizedBox(width: 4),
            Text(
              summary.displayText,
              style: TextStyle(
                color: _getBadgeColor(),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnlimitedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.all_inclusive, size: 14, color: Colors.green),
          const SizedBox(width: 4),
          Text(
            'Unlimited',
            style: TextStyle(
              color: Colors.green,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getBadgeColor() {
    if (summary.isAtLimit) return Colors.red;
    if (summary.isNearLimit) return Colors.orange;
    return Colors.green;
  }
}
