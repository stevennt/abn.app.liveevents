import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/vision_os_colors.dart';
import '../../../core/themes/vision_os_typography.dart';
import '../../../shared/widgets/glass_widgets.dart';
import '../../auth/state/auth_state.dart';
import '../../auth/widgets/oneid_login_sheet.dart';
import '../models/event_draft.dart';
import '../models/live_event.dart';
import '../state/events_state.dart';
import '../widgets/event_details_sheet.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthState>();
    final eventsState = context.watch<EventsState>();
    final myEvents = eventsState.mySubmittedEvents;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ScreenBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
          children: [
            GlassContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          authState.isAuthenticated
                              ? 'Authenticated'
                              : 'Guest mode',
                          style: VisionOSTypography.titleMedium,
                        ),
                      ),
                      GlassTag(
                        text: authState.isAuthenticated ? 'OneID' : 'Guest',
                        color: authState.isAuthenticated
                            ? VisionOSColors.sourceUser
                            : VisionOSColors.warning,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    authState.isAuthenticated
                        ? 'Logged in as ${authState.session?.identifier}'
                        : 'You can browse and submit events without login.',
                    style: VisionOSTypography.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  if (!authState.isAuthenticated)
                    GlassButton(
                      label: 'Login with OneID',
                      icon: Icons.login,
                      onPressed: () => OneIdLoginSheet.show(
                        context,
                        onLoggedIn: eventsState.refreshFeed,
                      ),
                      expand: true,
                    )
                  else
                    GlassButton(
                      label: 'Logout',
                      icon: Icons.logout,
                      isPrimary: false,
                      onPressed: authState.logout,
                      expand: true,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text('My Submitted Events', style: VisionOSTypography.titleMedium),
            const SizedBox(height: 8),
            if (myEvents.isEmpty)
              GlassContainer(
                child: Text(
                  'No submitted events yet. Add one in the Submit tab.',
                  style: VisionOSTypography.bodyMedium,
                ),
              )
            else
              ...myEvents.map(
                (event) => _MyEventCard(
                  event: event,
                  onView: () {
                    EventDetailsSheet.show(
                      context,
                      event: event,
                      onLoadReport: eventsState.fetchEventReport,
                      onCancel: () => eventsState.cancelEvent(event.id),
                    );
                  },
                  onEdit: () => _openEditDialog(context, event),
                  onCancel: () async {
                    final shouldCancel = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Cancel event?'),
                          content: const Text(
                            'This marks the event as cancelled.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('No'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Yes, cancel'),
                            ),
                          ],
                        );
                      },
                    );

                    if (shouldCancel == true) {
                      final warning = await eventsState.cancelEvent(event.id);
                      if (context.mounted && warning != null) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(warning)));
                      }
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _openEditDialog(BuildContext context, LiveEvent event) async {
    final updatedDraft = await showDialog<EventDraft>(
      context: context,
      builder: (_) => _EditEventDialog(event: event),
    );

    if (!context.mounted || updatedDraft == null) {
      return;
    }

    final eventsState = context.read<EventsState>();
    final result = await eventsState.updateEvent(
      eventId: event.id,
      draft: updatedDraft,
    );
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.warningMessage ?? 'Event updated.')),
    );
  }
}

class _MyEventCard extends StatelessWidget {
  const _MyEventCard({
    required this.event,
    required this.onView,
    required this.onEdit,
    required this.onCancel,
  });

  final LiveEvent event;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final Future<void> Function() onCancel;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(event.title, style: VisionOSTypography.titleSmall),
              ),
              if (event.isCancelled)
                const GlassTag(text: 'Cancelled', color: VisionOSColors.error),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            DateFormat('MMM d, yyyy HH:mm').format(event.startAt),
            style: VisionOSTypography.bodySmall,
          ),
          Text(event.venue, style: VisionOSTypography.bodySmall),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: GlassButton(
                  label: 'Details',
                  icon: Icons.visibility_outlined,
                  onPressed: onView,
                  isPrimary: false,
                  expand: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GlassButton(
                  label: 'Edit',
                  icon: Icons.edit_outlined,
                  onPressed: onEdit,
                  isPrimary: false,
                  expand: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GlassButton(
                  label: 'Cancel',
                  icon: Icons.cancel_outlined,
                  onPressed: event.isCancelled ? null : () async => onCancel(),
                  isPrimary: false,
                  expand: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EditEventDialog extends StatefulWidget {
  const _EditEventDialog({required this.event});

  final LiveEvent event;

  @override
  State<_EditEventDialog> createState() => _EditEventDialogState();
}

class _EditEventDialogState extends State<_EditEventDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _venueController;
  late final TextEditingController _descriptionController;
  late DateTime _startAt;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event.title);
    _venueController = TextEditingController(text: widget.event.venue);
    _descriptionController = TextEditingController(
      text: widget.event.description,
    );
    _startAt = widget.event.startAt;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _venueController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startAt,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date == null || !mounted) {
      return;
    }

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startAt),
    );

    if (time == null) {
      return;
    }

    setState(() {
      _startAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Event'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Title is required'
                    : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _venueController,
                decoration: const InputDecoration(labelText: 'Venue'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Venue is required'
                    : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _pickTime,
                  icon: const Icon(Icons.schedule),
                  label: Text(DateFormat('MM/dd/yyyy HH:mm').format(_startAt)),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final form = _formKey.currentState;
            if (form == null || !form.validate()) {
              return;
            }

            Navigator.of(context).pop(
              EventDraft(
                title: _titleController.text.trim(),
                description: _descriptionController.text.trim(),
                venue: _venueController.text.trim(),
                category: widget.event.category,
                startAt: _startAt,
                endAt: widget.event.endAt,
                latitude: widget.event.location.latitude,
                longitude: widget.event.location.longitude,
                address: widget.event.location.address,
                city: widget.event.location.city,
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
