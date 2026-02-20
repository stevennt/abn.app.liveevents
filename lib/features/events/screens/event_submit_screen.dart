import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/vision_os_typography.dart';
import '../../../shared/widgets/glass_widgets.dart';
import '../../auth/state/auth_state.dart';
import '../../auth/widgets/oneid_login_sheet.dart';
import '../../location/models/location_selection.dart';
import '../../location/services/location_service.dart';
import '../models/event_draft.dart';
import '../state/events_state.dart';
import 'location_picker_screen.dart';

class EventSubmitScreen extends StatefulWidget {
  const EventSubmitScreen({super.key});

  @override
  State<EventSubmitScreen> createState() => _EventSubmitScreenState();
}

class _EventSubmitScreenState extends State<EventSubmitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _venueController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _startAt;
  DateTime? _endAt;
  String _category = 'Music';

  @override
  void dispose() {
    _titleController.dispose();
    _venueController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickStartTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _startAt ?? now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );

    if (date == null || !mounted) {
      return;
    }

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startAt ?? now),
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
      _endAt ??= _startAt!.add(const Duration(hours: 2));
    });
  }

  Future<void> _pickEndTime() async {
    final base = _startAt ?? DateTime.now().add(const Duration(hours: 2));
    final date = await showDatePicker(
      context: context,
      initialDate: _endAt ?? base,
      firstDate: base,
      lastDate: base.add(const Duration(days: 365)),
    );

    if (date == null || !mounted) {
      return;
    }

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_endAt ?? base),
    );

    if (time == null) {
      return;
    }

    setState(() {
      _endAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _pickLocation() async {
    final eventsState = context.read<EventsState>();
    final locationService = context.read<LocationService>();
    final selectedLocation = eventsState.selectedLocation;
    if (selectedLocation == null) {
      return;
    }

    final picked = await Navigator.of(context).push<LocationSelection>(
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(
          initialLocation: selectedLocation,
          locationService: locationService,
        ),
      ),
    );

    if (!mounted || picked == null) {
      return;
    }

    await eventsState.setManualLocation(picked);
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    final eventsState = context.read<EventsState>();
    final authState = context.read<AuthState>();
    final location = eventsState.selectedLocation;

    if (form == null || !form.validate()) {
      return;
    }

    if (_startAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose start date/time.')),
      );
      return;
    }

    if (location == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose event location.')),
      );
      return;
    }

    final draft = EventDraft(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      venue: _venueController.text.trim(),
      category: _category,
      startAt: _startAt!,
      endAt: _endAt,
      latitude: location.latitude,
      longitude: location.longitude,
      address: location.label,
      city: null,
    );

    final result = await eventsState.submitEvent(draft);
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.warningMessage ?? 'Event submitted.')),
    );

    if (result.shouldPromptLogin && !authState.isAuthenticated) {
      final shouldLogin = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Submission saved'),
            content: const Text(
              'You submitted as guest. Login now to link this event to your OneID account?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Later'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Login Now'),
              ),
            ],
          );
        },
      );

      if (shouldLogin == true && mounted) {
        await OneIdLoginSheet.show(
          context,
          onLoggedIn: eventsState.refreshFeed,
        );
      }
    }

    setState(() {
      _titleController.clear();
      _venueController.clear();
      _descriptionController.clear();
      _startAt = null;
      _endAt = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final eventsState = context.watch<EventsState>();
    final authState = context.watch<AuthState>();
    final selectedLocation = eventsState.selectedLocation;

    return Scaffold(
      appBar: AppBar(title: const Text('Submit Event')),
      body: ScreenBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
          children: [
            GlassContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    authState.isAuthenticated
                        ? 'Submitting as ${authState.session?.identifier}'
                        : 'Submitting as Guest',
                    style: VisionOSTypography.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    selectedLocation?.compactLabel ?? 'No location selected',
                    style: VisionOSTypography.bodySmall,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: GlassButton(
                          label: 'Pick Location',
                          icon: Icons.map,
                          onPressed: _pickLocation,
                          isPrimary: false,
                          expand: true,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GlassButton(
                          label: 'Use GPS',
                          icon: Icons.my_location,
                          onPressed: eventsState.useCurrentLocation,
                          isPrimary: false,
                          expand: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            GlassContainer(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    GlassTextField(
                      controller: _titleController,
                      labelText: 'Event title',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Title is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    GlassTextField(
                      controller: _venueController,
                      labelText: 'Venue',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Venue is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _category,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: eventsState.categories
                          .where((category) => category != 'All')
                          .map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setState(() {
                          _category = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    GlassTextField(
                      controller: _descriptionController,
                      labelText: 'Description',
                      maxLines: 4,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: GlassButton(
                            label: _startAt == null
                                ? 'Start Time'
                                : DateFormat('MM/dd HH:mm').format(_startAt!),
                            icon: Icons.schedule,
                            onPressed: _pickStartTime,
                            isPrimary: false,
                            expand: true,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GlassButton(
                            label: _endAt == null
                                ? 'End Time'
                                : DateFormat('MM/dd HH:mm').format(_endAt!),
                            icon: Icons.schedule_send,
                            onPressed: _pickEndTime,
                            isPrimary: false,
                            expand: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GlassButton(
                      label: eventsState.isSubmitting
                          ? 'Submitting...'
                          : 'Submit Event',
                      icon: Icons.send,
                      onPressed: eventsState.isSubmitting ? null : _submit,
                      expand: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
