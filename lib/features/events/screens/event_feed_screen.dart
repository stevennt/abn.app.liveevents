import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/vision_os_colors.dart';
import '../../../core/themes/vision_os_typography.dart';
import '../../../shared/widgets/glass_widgets.dart';
import '../../auth/state/auth_state.dart';
import '../../location/models/location_selection.dart';
import '../../location/services/location_service.dart';
import '../models/live_event.dart';
import '../state/events_state.dart';
import '../widgets/event_details_sheet.dart';
import '../widgets/event_feed_card.dart';
import '../widgets/event_filters_bar.dart';
import 'location_picker_screen.dart';

class EventFeedScreen extends StatefulWidget {
  const EventFeedScreen({super.key});

  @override
  State<EventFeedScreen> createState() => _EventFeedScreenState();
}

class _EventFeedScreenState extends State<EventFeedScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }

    _initialized = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventsState>().initialize();
    });
  }

  Future<void> _openLocationPicker(BuildContext context) async {
    final eventsState = context.read<EventsState>();
    final locationService = context.read<LocationService>();
    final current = eventsState.selectedLocation;
    if (current == null) {
      return;
    }

    final selected = await Navigator.of(context).push<LocationSelection>(
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(
          initialLocation: current,
          locationService: locationService,
        ),
      ),
    );

    if (!mounted || selected == null) {
      return;
    }

    await eventsState.setManualLocation(selected);
  }

  bool _canManageEvent(LiveEvent event, AuthState authState) {
    if (authState.isAuthenticated) {
      final ownerId = authState.session?.userId;
      if (ownerId == null) {
        return false;
      }
      return event.ownerId == ownerId;
    }

    return event.guestSessionId == authState.guestSessionId;
  }

  @override
  Widget build(BuildContext context) {
    final eventsState = context.watch<EventsState>();
    final authState = context.watch<AuthState>();
    final events = eventsState.filteredEvents;

    return Scaffold(
      appBar: AppBar(
        title: const Text('LiveEvents Feed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: eventsState.useCurrentLocation,
            tooltip: 'Use current GPS',
          ),
        ],
      ),
      body: ScreenBackground(
        child: RefreshIndicator(
          onRefresh: eventsState.refreshFeed,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
            children: [
              _LocationCard(
                locationLabel:
                    eventsState.selectedLocation?.compactLabel ??
                    'No location selected',
                onUseCurrent: eventsState.useCurrentLocation,
                onPickManual: () => _openLocationPicker(context),
              ),
              const SizedBox(height: 10),
              EventFiltersBar(
                filters: eventsState.filters,
                categories: eventsState.categories,
                onSearchChanged: eventsState.setSearchQuery,
                onCategoryChanged: eventsState.setCategory,
                onTimeFilterChanged: (filter, customDate) =>
                    eventsState.setTimeFilter(filter, customDate: customDate),
              ),
              if (eventsState.statusMessage != null) ...[
                const SizedBox(height: 10),
                GlassContainer(
                  padding: const EdgeInsets.all(10),
                  color: eventsState.isUsingFallback
                      ? VisionOSColors.warning.withValues(alpha: 0.12)
                      : VisionOSColors.accentBlue.withValues(alpha: 0.08),
                  borderColor: eventsState.isUsingFallback
                      ? VisionOSColors.warning.withValues(alpha: 0.28)
                      : VisionOSColors.accentBlue.withValues(alpha: 0.22),
                  child: Text(
                    eventsState.statusMessage!,
                    style: VisionOSTypography.bodySmall,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              if (eventsState.isLoading)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (events.isEmpty)
                GlassContainer(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No events match your current filters. Try changing date/category/location.',
                    style: VisionOSTypography.bodyMedium,
                  ),
                )
              else
                ...events.map(
                  (event) => EventFeedCard(
                    event: event,
                    onTap: () {
                      EventDetailsSheet.show(
                        context,
                        event: event,
                        onLoadReport: eventsState.fetchEventReport,
                        onCancel: _canManageEvent(event, authState)
                            ? () => eventsState.cancelEvent(event.id)
                            : null,
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({
    required this.locationLabel,
    required this.onUseCurrent,
    required this.onPickManual,
  });

  final String locationLabel;
  final Future<void> Function() onUseCurrent;
  final VoidCallback onPickManual;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Location', style: VisionOSTypography.titleSmall),
          const SizedBox(height: 6),
          Text(locationLabel, style: VisionOSTypography.bodySmall),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GlassButton(
                  label: 'Current GPS',
                  icon: Icons.my_location,
                  onPressed: onUseCurrent,
                  isPrimary: false,
                  expand: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GlassButton(
                  label: 'Pick on Map',
                  icon: Icons.map_outlined,
                  onPressed: onPickManual,
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
