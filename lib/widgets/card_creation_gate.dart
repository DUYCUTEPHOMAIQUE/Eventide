import 'package:flutter/material.dart';
import '../services/card_limit_service.dart';
import '../models/subscription_model.dart';
import '../services/subscription_service.dart';
import '../screens/upgrade/upgrade_screen.dart';
import 'package:enva/l10n/app_localizations.dart';

/// Gate widget để kiểm tra card creation limits
/// Implements Strategy pattern cho different subscription types
class CardCreationGate extends StatefulWidget {
  final Widget child;
  final Widget? fallbackWidget;
  final bool showUpgradePrompt;
  final String? customMessage;
  final VoidCallback? onUpgradeRequested;

  const CardCreationGate({
    Key? key,
    required this.child,
    this.fallbackWidget,
    this.showUpgradePrompt = true,
    this.customMessage,
    this.onUpgradeRequested,
  }) : super(key: key);

  @override
  State<CardCreationGate> createState() => _CardCreationGateState();
}

class _CardCreationGateState extends State<CardCreationGate> {
  CardCreationValidationResult? _validationResult;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _validateCardCreation();
  }

  Future<void> _validateCardCreation() async {
    try {
      final result = await CardLimitService.validateCardCreation();
      setState(() {
        _validationResult = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _validationResult = CardCreationValidationResult(
          canCreate: false,
          reason: 'Error validating card creation: $e',
          shouldShowUpgrade: false,
        );
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    final result = _validationResult!;

    if (result.canCreate) {
      return widget.child;
    }

    return widget.fallbackWidget ?? _buildLimitReachedWidget(result);
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildLimitReachedWidget(CardCreationValidationResult result) {
    final summary = result.usageSummary;

    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLimitIcon(),
              const SizedBox(height: 16),
              _buildLimitTitle(),
              const SizedBox(height: 8),
              _buildLimitDescription(result),
              if (summary != null) ...[
                const SizedBox(height: 16),
                _buildUsageProgress(summary),
              ],
              const SizedBox(height: 24),
              _buildActionButtons(result),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLimitIcon() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.credit_card_off,
        size: 32,
        color: Colors.orange,
      ),
    );
  }

  Widget _buildLimitTitle() {
    return Text(
      widget.customMessage ??
          AppLocalizations.of(context)!.cardLimitReachedTitle,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildLimitDescription(CardCreationValidationResult result) {
    final summary = result.usageSummary;
    String description = result.reason;

    if (summary != null && !summary.isUnlimited) {
      description =
          'You have created ${summary.currentCards} out of ${summary.maxCards} cards allowed on your current plan.';
    }

    return Text(
      description,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
            height: 1.5,
          ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildUsageProgress(CardUsageSummary summary) {
    if (summary.isUnlimited) return const SizedBox.shrink();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Usage',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              summary.displayText,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: summary.percentageUsed / 100,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(
            summary.isAtLimit ? Colors.red : Colors.orange,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildActionButtons(CardCreationValidationResult result) {
    return Column(
      children: [
        if (result.shouldShowUpgrade && widget.showUpgradePrompt) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _handleUpgradePressed(),
              icon: Icon(Icons.upgrade, size: 20),
              label: Text(AppLocalizations.of(context)!.upgradeTitle),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Go Back'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  void _handleUpgradePressed() {
    if (widget.onUpgradeRequested != null) {
      widget.onUpgradeRequested!();
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const UpgradeScreen()),
      );
    }
  }

  void _showUpgradeDialog() {
    // Đã chuyển sang UpgradeScreen, không dùng dialog nữa
  }

  /// Refresh validation state
  Future<void> refresh() async {
    setState(() {
      _isLoading = true;
    });
    await _validateCardCreation();
  }
}
