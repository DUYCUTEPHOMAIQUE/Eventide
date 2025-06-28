import 'dart:async';
import 'package:flutter/material.dart';
import 'package:enva/l10n/app_localizations.dart';
import 'package:enva/services/subscription_service.dart';

class UpgradeScreen extends StatefulWidget {
  final VoidCallback? onUpgraded;
  const UpgradeScreen({Key? key, this.onUpgraded}) : super(key: key);

  @override
  State<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends State<UpgradeScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool isLoading = false;
  bool isSuccess = false;
  String? errorText;
  double _iconScale = 0.7;

  @override
  void initState() {
    super.initState();
    // Animation: scale up icon khi vào màn hình
    Timer(const Duration(milliseconds: 80), () {
      if (mounted) setState(() => _iconScale = 1.0);
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _onConfirm() async {
    setState(() {
      isLoading = true;
      errorText = null;
    });
    final code = _codeController.text.trim();
    final loc = AppLocalizations.of(context)!;
    if (code.isEmpty) {
      setState(() {
        errorText = loc.upgradeInputEmpty;
        isLoading = false;
      });
      return;
    }
    try {
      final result = await SubscriptionService.redeemPremiumCode(code);
      if (result == 'success') {
        setState(() {
          isSuccess = true;
          isLoading = false;
        });
        widget.onUpgraded?.call();
      } else if (result == 'invalid') {
        setState(() {
          errorText = loc.upgradeInputError;
          isLoading = false;
        });
      } else {
        setState(() {
          errorText = 'Có lỗi xảy ra. Vui lòng thử lại.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorText = 'Lỗi kết nối hoặc server.';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.grey.shade700),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          loc.upgradeTitle,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 400,
                minHeight: 320,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.7, end: _iconScale),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutBack,
                    builder: (context, scale, child) => Transform.scale(
                      scale: scale,
                      child: child,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.13),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.workspace_premium,
                          color: Colors.amber.shade800, size: 54),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    loc.upgradeSubtitle,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        height: 1.4),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  // Benefits checklist
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _benefitItem(Icons.all_inclusive,
                          loc.upgradeBenefits.split('\n')[0]),
                      const SizedBox(height: 10),
                      _benefitItem(Icons.auto_awesome,
                          loc.upgradeBenefits.split('\n')[1]),
                      const SizedBox(height: 10),
                      _benefitItem(
                          Icons.star, loc.upgradeBenefits.split('\n')[2]),
                      const SizedBox(height: 10),
                      _benefitItem(Icons.support_agent,
                          loc.upgradeBenefits.split('\n')[3]),
                    ],
                  ),
                  const SizedBox(height: 36),
                  if (!isSuccess) ...[
                    // Input code minimalist
                    TextField(
                      controller: _codeController,
                      decoration: InputDecoration(
                        labelText: loc.upgradeInputLabel,
                        hintText: loc.upgradeInputHint,
                        errorText: errorText,
                        border: const UnderlineInputBorder(),
                        filled: false,
                        labelStyle: TextStyle(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500),
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                      ),
                      enabled: !isLoading,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 16),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _onConfirm(),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isLoading
                                ? null
                                : () => Navigator.pop(context, false),
                            child: Text(loc.upgradeCancel,
                                style: const TextStyle(fontSize: 16)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey[700],
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                            ),
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _onConfirm,
                            child: Text(loc.upgradeButton,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    const SizedBox(height: 18),
                    Icon(Icons.verified, color: Colors.green, size: 54),
                    const SizedBox(height: 22),
                    Text(
                      loc.upgradeSuccessTitle,
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      loc.upgradeSuccessDesc,
                      style:
                          const TextStyle(fontSize: 16, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(loc.upgradeSuccessButton,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 36, vertical: 18),
                      ),
                    ),
                  ],
                  if (isLoading)
                    Padding(
                      padding: const EdgeInsets.only(top: 32.0),
                      child: Center(
                        child: CircularProgressIndicator(
                            strokeWidth: 3, color: Colors.amber),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _benefitItem(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.amber.shade800, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text.replaceAll('• ', ''),
            style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
