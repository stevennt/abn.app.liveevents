import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/themes/vision_os_colors.dart';
import '../../../core/themes/vision_os_typography.dart';
import '../../../shared/widgets/glass_widgets.dart';
import '../models/live_event.dart';

class EventDetailsSheet extends StatefulWidget {
  const EventDetailsSheet({
    super.key,
    required this.event,
    required this.onLoadReport,
    this.onEdit,
    this.onCancel,
  });

  final LiveEvent event;
  final Future<Map<String, dynamic>> Function(String eventId) onLoadReport;
  final VoidCallback? onEdit;
  final Future<void> Function()? onCancel;

  static Future<void> show(
    BuildContext context, {
    required LiveEvent event,
    required Future<Map<String, dynamic>> Function(String eventId) onLoadReport,
    VoidCallback? onEdit,
    Future<void> Function()? onCancel,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EventDetailsSheet(
        event: event,
        onLoadReport: onLoadReport,
        onEdit: onEdit,
        onCancel: onCancel,
      ),
    );
  }

  @override
  State<EventDetailsSheet> createState() => _EventDetailsSheetState();
}

class _EventDetailsSheetState extends State<EventDetailsSheet> {
  bool _loadingReport = false;

  Future<void> _showReport() async {
    setState(() {
      _loadingReport = true;
    });

    final report = await widget.onLoadReport(widget.event.id);

    if (!mounted) {
      return;
    }

    setState(() {
      _loadingReport = false;
    });

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Event Report'),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: SelectableText(
                const JsonEncoder.withIndent('  ').convert(report),
                style: VisionOSTypography.bodySmall,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
      child: GlassContainer(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    event.title,
                    style: VisionOSTypography.titleLarge,
                  ),
                ),
                GlassTag(
                  text: event.sourceLabel,
                  color: event.source == 'user'
                      ? VisionOSColors.sourceUser
                      : VisionOSColors.sourceExternal,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _infoRow(
              Icons.schedule,
              DateFormat('EEE, MMM d yyyy - HH:mm').format(event.startAt),
            ),
            _infoRow(
              Icons.place_outlined,
              '${event.venue} - ${event.location.address}',
            ),
            _infoRow(Icons.category_outlined, event.category),
            if ((event.ownerName ?? '').trim().isNotEmpty)
              _infoRow(Icons.person_outline, 'Submitted by ${event.ownerName}'),
            const SizedBox(height: 12),
            Text(
              event.description.isEmpty
                  ? 'No description provided.'
                  : event.description,
              style: VisionOSTypography.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                GlassButton(
                  label: _loadingReport ? 'Loading...' : 'Event Report',
                  icon: Icons.assessment_outlined,
                  onPressed: _loadingReport ? null : _showReport,
                  isPrimary: false,
                ),
                if (widget.onEdit != null)
                  GlassButton(
                    label: 'Edit',
                    icon: Icons.edit_outlined,
                    onPressed: widget.onEdit,
                    isPrimary: false,
                  ),
                if (widget.onCancel != null)
                  GlassButton(
                    label: 'Cancel Event',
                    icon: Icons.cancel_outlined,
                    onPressed: () async {
                      final navigator = Navigator.of(context);
                      await widget.onCancel?.call();
                      if (mounted) {
                        navigator.pop();
                      }
                    },
                    isPrimary: false,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: VisionOSColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: VisionOSTypography.bodySmall)),
        ],
      ),
    );
  }
}
