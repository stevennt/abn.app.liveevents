import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/themes/vision_os_colors.dart';
import '../../../core/themes/vision_os_typography.dart';
import '../../../shared/widgets/glass_widgets.dart';
import '../models/live_event.dart';

class EventFeedCard extends StatelessWidget {
  const EventFeedCard({super.key, required this.event, this.onTap});

  final LiveEvent event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('EEE, MMM d - HH:mm').format(event.startAt);

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(event.title, style: VisionOSTypography.titleMedium),
              ),
              if (event.isCancelled)
                const GlassTag(text: 'Cancelled', color: VisionOSColors.error),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.schedule,
                size: 16,
                color: VisionOSColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(dateLabel, style: VisionOSTypography.bodySmall),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.place_outlined,
                size: 16,
                color: VisionOSColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  event.venue,
                  style: VisionOSTypography.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              GlassTag(
                text: event.category,
                color: VisionOSColors.accentBlueDark,
              ),
              GlassTag(
                text: event.sourceLabel,
                color: event.source == 'user'
                    ? VisionOSColors.sourceUser
                    : VisionOSColors.sourceExternal,
              ),
              if (event.distanceKm != null)
                GlassTag(
                  text: '${event.distanceKm!.toStringAsFixed(1)} km',
                  color: VisionOSColors.textSecondary,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
