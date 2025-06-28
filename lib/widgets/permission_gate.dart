import 'package:flutter/material.dart';
import '../models/subscription_model.dart';
import '../services/subscription_service.dart';
import 'package:enva/l10n/app_localizations.dart';

class PermissionGate extends StatefulWidget {
  final AppFeature feature;
  final Widget child;
  final Widget? fallbackWidget;
  final bool showUpgradePrompt;
  final String? customMessage;

  const PermissionGate({
    Key? key,
    required this.feature,
    required this.child,
    this.fallbackWidget,
    this.showUpgradePrompt = true,
    this.customMessage,
  }) : super(key: key);

  @override
  State<PermissionGate> createState() => _PermissionGateState();
}

class _PermissionGateState extends State<PermissionGate> {
  bool _hasAccess = false;
  bool _canUse = false;
  bool _isLoading = true;
  bool _isPremium = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    try {
      final subscription = await SubscriptionService.getCurrentSubscription();
      final isPremium = subscription?.plan?.isPremium ?? false;
      if (isPremium) {
        setState(() {
          _hasAccess = true;
          _canUse = true;
          _isPremium = true;
          _isLoading = false;
        });
        return;
      }
      final hasAccess =
          await SubscriptionService.hasFeatureAccess(widget.feature);
      final canUse = await SubscriptionService.canUseFeature(widget.feature);
      setState(() {
        _hasAccess = hasAccess;
        _canUse = canUse;
        _isPremium = false;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasAccess = false;
        _canUse = false;
        _isPremium = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Nếu là Premium, luôn cho phép truy cập feature
    if (_isPremium) {
      return widget.child;
    }

    // Nếu user có quyền và còn lượt dùng
    if (_hasAccess && _canUse) {
      return widget.child;
    }

    // Nếu user có quyền nhưng hết lượt
    if (_hasAccess && !_canUse) {
      return _buildLimitReachedWidget();
    }

    // Nếu user không có quyền
    return _buildNoAccessWidget();
  }

  Widget _buildLimitReachedWidget() {
    if (widget.fallbackWidget != null) {
      return widget.fallbackWidget!;
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_amber,
              size: 48,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              widget.customMessage ??
                  AppLocalizations.of(context)!.limitReached,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!
                  .limitReachedMessage(widget.feature.displayName),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (widget.showUpgradePrompt)
              ElevatedButton(
                onPressed: () => _showUpgradeDialog(),
                child: Text(AppLocalizations.of(context)!.upgradeButton),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoAccessWidget() {
    if (widget.fallbackWidget != null) {
      return widget.fallbackWidget!;
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock,
              size: 48,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.premiumFeature,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.customMessage ??
                  AppLocalizations.of(context)!
                      .premiumFeatureMessage(widget.feature.displayName),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (widget.showUpgradePrompt)
              ElevatedButton(
                onPressed: () => _showUpgradeDialog(),
                child: Text(AppLocalizations.of(context)!.upgradeNowButton),
              ),
          ],
        ),
      ),
    );
  }

  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.upgradeTitle),
        content: Text(AppLocalizations.of(context)!
            .upgradeDialogMessage(widget.feature.displayName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.maybeLaterButton),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to subscription page
            },
            child: Text(AppLocalizations.of(context)!.upgradeNowButton),
          ),
        ],
      ),
    );
  }
}
