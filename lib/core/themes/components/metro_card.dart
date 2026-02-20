import 'package:flutter/material.dart';

import '../colors.dart';
import '../spacing.dart';
import '../typography.dart';

class MetroCard extends StatelessWidget {
  const MetroCard({super.key, this.title, required this.child, this.onTap});

  final String? title;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: MetroColors.surface,
      shape: const RoundedRectangleBorder(),
      margin: const EdgeInsets.all(MetroSpacing.cardMargin),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(MetroSpacing.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null) ...[
                Text(title!, style: MetroTypography.titleNormal),
                const SizedBox(height: MetroSpacing.s12),
              ],
              child,
            ],
          ),
        ),
      ),
    );
  }
}
