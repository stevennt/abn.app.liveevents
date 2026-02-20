import 'package:flutter/material.dart';

import '../colors.dart';
import '../typography.dart';

enum MetroButtonVariant { filled, outlined }

class MetroActionButton extends StatelessWidget {
  const MetroActionButton({
    super.key,
    required this.label,
    required this.icon,
    this.onTap,
    this.variant = MetroButtonVariant.filled,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final MetroButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final isFilled = variant == MetroButtonVariant.filled;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isFilled ? MetroColors.primary : Colors.transparent,
          border: isFilled ? null : Border.all(color: MetroColors.primary),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: MetroColors.textPrimary),
            const SizedBox(width: 8),
            Text(label.toUpperCase(), style: MetroTypography.button),
          ],
        ),
      ),
    );
  }
}
