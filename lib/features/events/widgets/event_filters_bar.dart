import 'package:flutter/material.dart';

import '../../../core/themes/vision_os_typography.dart';
import '../../../shared/widgets/glass_widgets.dart';
import '../models/event_filters.dart';

class EventFiltersBar extends StatelessWidget {
  const EventFiltersBar({
    super.key,
    required this.filters,
    required this.categories,
    required this.onSearchChanged,
    required this.onCategoryChanged,
    required this.onTimeFilterChanged,
  });

  final EventFilters filters;
  final List<String> categories;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onCategoryChanged;
  final Future<void> Function(EventTimeFilter filter, DateTime? customDate)
  onTimeFilterChanged;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassTextField(
            hintText: 'Search events, venues, keywords',
            onChanged: onSearchChanged,
            suffix: const Icon(Icons.search, size: 18),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildTimeChip(
                  context,
                  label: 'All',
                  filter: EventTimeFilter.all,
                ),
                _buildTimeChip(
                  context,
                  label: 'Today',
                  filter: EventTimeFilter.today,
                ),
                _buildTimeChip(
                  context,
                  label: 'Weekend',
                  filter: EventTimeFilter.weekend,
                ),
                _buildTimeChip(
                  context,
                  label: filters.customDate == null
                      ? 'Custom Date'
                      : '${filters.customDate!.month}/${filters.customDate!.day}',
                  filter: EventTimeFilter.customDate,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories
                .map((category) {
                  final selected = filters.category == category;
                  return ChoiceChip(
                    selected: selected,
                    label: Text(
                      category,
                      style: VisionOSTypography.captionStrong,
                    ),
                    onSelected: (_) => onCategoryChanged(category),
                  );
                })
                .toList(growable: false),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeChip(
    BuildContext context, {
    required String label,
    required EventTimeFilter filter,
  }) {
    final selected = filters.timeFilter == filter;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: selected,
        label: Text(label, style: VisionOSTypography.captionStrong),
        onSelected: (_) async {
          if (filter == EventTimeFilter.customDate) {
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: filters.customDate ?? DateTime.now(),
              firstDate: DateTime.now().subtract(const Duration(days: 1)),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (pickedDate == null) {
              return;
            }
            await onTimeFilterChanged(filter, pickedDate);
            return;
          }

          await onTimeFilterChanged(filter, null);
        },
      ),
    );
  }
}
