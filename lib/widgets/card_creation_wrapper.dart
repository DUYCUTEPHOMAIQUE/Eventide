import 'package:flutter/material.dart';
import '../services/card_limit_service.dart';
import '../screens/card/minimalist_card_creation_screen.dart';
import '../models/subscription_model.dart';
import '../services/subscription_service.dart';
import '../screens/upgrade/upgrade_screen.dart';
import 'package:enva/l10n/app_localizations.dart';

/// Wrapper để handle optimistic navigation với background validation
/// Shows card creation screen immediately, validates permissions in background
class CardCreationScreenWrapper extends StatefulWidget {
  const CardCreationScreenWrapper({Key? key}) : super(key: key);

  @override
  State<CardCreationScreenWrapper> createState() =>
      _CardCreationScreenWrapperState();
}

class _CardCreationScreenWrapperState extends State<CardCreationScreenWrapper> {
  bool _isValidating = true;
  bool _hasPermission = true;
  CardCreationValidationResult? _validationResult;
  bool _hasShownDialog = false;

  @override
  void initState() {
    super.initState();
    // Start background validation immediately
    _validateInBackground();
  }

  Future<void> _validateInBackground() async {
    try {
      // Small delay để user thấy screen load
      await Future.delayed(const Duration(milliseconds: 300));

      final result = await CardLimitService.validateCardCreation();

      if (mounted) {
        setState(() {
          _isValidating = false;
          _hasPermission = result.canCreate;
          _validationResult = result;
        });

        // Nếu không có permission và chưa show dialog
        if (!result.canCreate && !_hasShownDialog) {
          _hasShownDialog = true;
          _showPermissionDialog();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isValidating = false;
          _hasPermission = false;
        });
        _showErrorDialog();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Simply show the card creation screen - validation happens silently in background
    return const MinimalistCardCreationScreen();
  }

  void _showPermissionDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildPermissionDialog(),
    );
  }

  Widget _buildPermissionDialog() {
    final result = _validationResult!;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange, size: 24),
          const SizedBox(width: 12),
          Text(
            AppLocalizations.of(context)!.cardLimitReachedTitle,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            result.reason,
            style: TextStyle(fontSize: 14, height: 1.4),
          ),
          if (result.usageSummary != null &&
              !result.usageSummary!.isUnlimited) ...[
            const SizedBox(height: 16),
            _buildUsageProgress(result.usageSummary!),
          ],
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.blue),
                    const SizedBox(width: 6),
                    Text(
                      AppLocalizations.of(context)!.upgradeTitle,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.upgradeBenefits,
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close dialog
            Navigator.of(context).pop(); // Close card creation screen
          },
          child: Text(AppLocalizations.of(context)!.maybeLaterButton),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).pop(); // Close dialog
            Navigator.of(context).pop(); // Close card creation screen
            _handleUpgradePressed();
          },
          icon: Icon(Icons.upgrade, size: 18),
          label: Text(AppLocalizations.of(context)!.upgradeNowButton),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildUsageProgress(CardUsageSummary summary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Current Usage',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              summary.displayText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: summary.isAtLimit ? Colors.red : Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: summary.percentageUsed / 100,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(
            summary.isAtLimit ? Colors.red : Colors.orange,
          ),
          borderRadius: BorderRadius.circular(2),
        ),
      ],
    );
  }

  void _showErrorDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Text('Connection Error'),
          ],
        ),
        content: Text(
            'Unable to verify your subscription. Please check your connection and try again.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text('Go Back'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _validateInBackground(); // Retry validation
            },
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _handleUpgradePressed() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const UpgradeScreen()),
    );
  }
}
