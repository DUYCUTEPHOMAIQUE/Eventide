import 'package:flutter/material.dart';

enum RSVPStatus { pending, going, notGoing, maybe }

class RSVPSelector extends StatelessWidget {
  final RSVPStatus? selected;
  final ValueChanged<RSVPStatus> onChanged;
  final bool enabled;
  final bool isLoading;

  const RSVPSelector({
    Key? key,
    required this.selected,
    required this.onChanged,
    this.enabled = true,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildOption(context, RSVPStatus.going, Icons.check_circle, 'Going',
              Colors.green),
          _verticalDivider(),
          _buildOption(context, RSVPStatus.notGoing, Icons.cancel, 'Not Going',
              Colors.red),
          _verticalDivider(),
          _buildOption(context, RSVPStatus.maybe, Icons.help_outline, 'Maybe',
              Colors.grey),
        ],
      ),
    );
  }

  Widget _verticalDivider() => Container(
        width: 1,
        height: 32,
        color: Colors.grey.withOpacity(0.2),
      );

  Widget _buildOption(BuildContext context, RSVPStatus status, IconData icon,
      String label, Color color) {
    final isSelected = selected == status;
    final isThisButtonLoading = isLoading && isSelected;

    return Expanded(
      child: GestureDetector(
        onTap: enabled && !isLoading ? () => onChanged(status) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            border: isSelected ? Border.all(color: color, width: 2) : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isThisButtonLoading)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                )
              else
                Icon(icon,
                    color: isSelected ? color : Colors.grey[400], size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
