import 'package:flutter/material.dart';
import 'package:enva/theme/app_theme.dart';

class EnhancedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final double progress;
  final VoidCallback? onBackPressed;
  final VoidCallback? onSavePressed;
  final VoidCallback? onPreviewPressed;
  final bool isPreviewMode;
  final bool showSaveButton;

  const EnhancedAppBar({
    Key? key,
    required this.title,
    this.progress = 0.0,
    this.onBackPressed,
    this.onSavePressed,
    this.onPreviewPressed,
    this.isPreviewMode = false,
    this.showSaveButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black,
            Colors.black.withOpacity(0.8),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Main app bar row
                Row(
                  children: [
                    // Back button
                    _buildAnimatedIconButton(
                      icon: Icons.arrow_back_ios_rounded,
                      onPressed:
                          onBackPressed ?? () => Navigator.of(context).pop(),
                    ),

                    const SizedBox(width: 12),

                    // Progress indicator
                    Expanded(
                      child: _buildProgressIndicator(),
                    ),

                    const SizedBox(width: 12),

                    // Action buttons
                    if (showSaveButton) ...[
                      _buildAnimatedIconButton(
                        icon: Icons.save_outlined,
                        onPressed: onSavePressed,
                      ),
                      const SizedBox(width: 8),
                    ],

                    _buildPreviewToggle(),
                  ],
                ),

                const SizedBox(height: 4),

                // Title row
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTypography.headline6.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildTemplateButton(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedIconButton({
    required IconData icon,
    VoidCallback? onPressed,
  }) {
    return TweenAnimationBuilder<double>(
      duration: AppAnimations.fast,
      tween: Tween(begin: 1.0, end: onPressed != null ? 1.0 : 0.5),
      builder: (context, opacity, child) {
        return AnimatedContainer(
          duration: AppAnimations.fast,
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onPressed,
              child: Icon(
                icon,
                color: Colors.white.withOpacity(opacity),
                size: 18,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        Row(
          children: [
            Text(
              'Progress',
              style: AppTypography.caption.copyWith(
                color: Colors.white70,
              ),
            ),
            const Spacer(),
            Text(
              '${(progress * 100).toInt()}%',
              style: AppTypography.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.white.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(
            AppTheme.primaryPurple,
          ),
          minHeight: 3,
        ),
      ],
    );
  }

  Widget _buildPreviewToggle() {
    return AnimatedContainer(
      duration: AppAnimations.medium,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isPreviewMode
            ? AppTheme.primaryPurple.withOpacity(0.2)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPreviewMode
              ? AppTheme.primaryPurple
              : Colors.white.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPreviewMode ? Icons.edit : Icons.visibility,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            isPreviewMode ? 'Edit' : 'Preview',
            style: AppTypography.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPurple.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.dashboard_customize_outlined,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            'Templates',
            style: AppTypography.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(90);
}
