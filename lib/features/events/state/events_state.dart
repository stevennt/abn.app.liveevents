import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../../auth/state/auth_state.dart';
import '../../location/models/location_selection.dart';
import '../../location/services/location_service.dart';
import '../models/event_draft.dart';
import '../models/event_filters.dart';
import '../models/event_results.dart';
import '../models/live_event.dart';
import '../repositories/events_repository.dart';

class EventsState extends ChangeNotifier {
  EventsState({
    required EventsRepository repository,
    required LocationService locationService,
    required AuthState authState,
  }) : _repository = repository,
       _locationService = locationService,
       _authState = authState {
    _authState.addListener(_onAuthChanged);
  }

  final EventsRepository _repository;
  final LocationService _locationService;
  final AuthState _authState;

  final List<String> categories = const <String>[
    'All',
    'Music',
    'Food',
    'Sports',
    'Family',
    'Business',
    'Community',
  ];

  bool _initialized = false;
  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _isUsingFallback = false;
  String? _statusMessage;
  LocationSelection? _selectedLocation;
  EventFilters _filters = const EventFilters();
  List<LiveEvent> _events = const <LiveEvent>[];
  String? _claimedOwnerId;

  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  bool get isUsingFallback => _isUsingFallback;
  String? get statusMessage => _statusMessage;
  LocationSelection? get selectedLocation => _selectedLocation;
  EventFilters get filters => _filters;
  List<LiveEvent> get allEvents => _events;

  List<LiveEvent> get filteredEvents {
    var records = _events
        .where((event) {
          if (_filters.category != 'All' &&
              event.category.toLowerCase() != _filters.category.toLowerCase()) {
            return false;
          }

          final normalizedQuery = _filters.query.trim().toLowerCase();
          if (normalizedQuery.isNotEmpty) {
            final inText =
                event.title.toLowerCase().contains(normalizedQuery) ||
                event.description.toLowerCase().contains(normalizedQuery) ||
                event.venue.toLowerCase().contains(normalizedQuery);
            if (!inText) {
              return false;
            }
          }

          if (!_matchesDateFilter(event.startAt)) {
            return false;
          }

          return true;
        })
        .toList(growable: false);

    records.sort(_compareEvents);
    return records;
  }

  List<LiveEvent> get mySubmittedEvents {
    final list = _repository.mySubmittedEvents(
      guestSessionId: _authState.guestSessionId,
      session: _authState.session,
    );

    final sorted = [...list]..sort((a, b) => b.startAt.compareTo(a.startAt));
    return sorted;
  }

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _initialized = true;

    await _resolveInitialLocation();
    await refreshFeed();
  }

  Future<void> _resolveInitialLocation() async {
    try {
      _selectedLocation = await _locationService.detectCurrentLocation();
      _statusMessage = null;
    } catch (_) {
      _selectedLocation = const LocationSelection(
        latitude: 10.7769,
        longitude: 106.7009,
        label: 'Default: Ho Chi Minh City',
        source: LocationSource.search,
      );
      _statusMessage =
          'GPS unavailable. Using default city until you pick a location.';
    }
    notifyListeners();
  }

  Future<void> useCurrentLocation() async {
    _isLoading = true;
    notifyListeners();

    try {
      _selectedLocation = await _locationService.detectCurrentLocation();
      _statusMessage = null;
    } catch (error) {
      _statusMessage = error.toString();
    }

    _isLoading = false;
    notifyListeners();
    await refreshFeed();
  }

  Future<void> setManualLocation(LocationSelection location) async {
    _selectedLocation = location;
    _statusMessage = null;
    notifyListeners();
    await refreshFeed();
  }

  Future<void> refreshFeed() async {
    final location = _selectedLocation;
    if (location == null) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    final dateFilter = _filters.timeFilter == EventTimeFilter.customDate
        ? _filters.customDate
        : null;

    final result = await _repository.fetchFeed(
      latitude: location.latitude,
      longitude: location.longitude,
      category: _filters.category,
      date: dateFilter,
    );

    _events = result.events.map(_attachDistance).toList(growable: false);
    _isUsingFallback = result.usedFallback;
    _statusMessage = result.warningMessage;

    _isLoading = false;
    notifyListeners();
  }

  void setCategory(String category) {
    if (_filters.category == category) {
      return;
    }
    _filters = _filters.copyWith(category: category);
    notifyListeners();
    refreshFeed();
  }

  Future<void> setTimeFilter(
    EventTimeFilter filter, {
    DateTime? customDate,
  }) async {
    _filters = _filters.copyWith(
      timeFilter: filter,
      customDate: customDate,
      clearCustomDate: filter != EventTimeFilter.customDate,
    );
    notifyListeners();
    await refreshFeed();
  }

  void setSearchQuery(String query) {
    _filters = _filters.copyWith(query: query);
    notifyListeners();
  }

  Future<EventMutationResult> submitEvent(EventDraft draft) async {
    _isSubmitting = true;
    notifyListeners();

    final result = await _repository.submitEvent(
      draft: draft,
      isGuest: !_authState.isAuthenticated,
      guestSessionId: _authState.guestSessionId,
      session: _authState.session,
    );

    _isSubmitting = false;
    _statusMessage = result.warningMessage;
    notifyListeners();

    await refreshFeed();
    return result;
  }

  Future<EventMutationResult> updateEvent({
    required String eventId,
    required EventDraft draft,
  }) async {
    _isSubmitting = true;
    notifyListeners();

    final result = await _repository.updateEvent(
      eventId: eventId,
      draft: draft,
      session: _authState.session,
    );

    _isSubmitting = false;
    _statusMessage = result.warningMessage;
    notifyListeners();

    await refreshFeed();
    return result;
  }

  Future<String?> cancelEvent(String eventId) async {
    final warning = await _repository.cancelEvent(
      eventId: eventId,
      session: _authState.session,
    );
    _statusMessage = warning;
    notifyListeners();
    await refreshFeed();
    return warning;
  }

  Future<Map<String, dynamic>> fetchEventReport(String eventId) async {
    try {
      return await _repository.fetchEventReport(
        eventId: eventId,
        session: _authState.session,
      );
    } catch (error) {
      return <String, dynamic>{'error': error.toString()};
    }
  }

  bool _matchesDateFilter(DateTime startAt) {
    final localStart = startAt.toLocal();
    final now = DateTime.now();

    switch (_filters.timeFilter) {
      case EventTimeFilter.all:
        return true;
      case EventTimeFilter.today:
        return localStart.year == now.year &&
            localStart.month == now.month &&
            localStart.day == now.day;
      case EventTimeFilter.weekend:
        return localStart.weekday == DateTime.saturday ||
            localStart.weekday == DateTime.sunday;
      case EventTimeFilter.customDate:
        final custom = _filters.customDate;
        if (custom == null) {
          return true;
        }
        return localStart.year == custom.year &&
            localStart.month == custom.month &&
            localStart.day == custom.day;
    }
  }

  LiveEvent _attachDistance(LiveEvent event) {
    final location = _selectedLocation;
    if (location == null) {
      return event;
    }

    final meters = Geolocator.distanceBetween(
      location.latitude,
      location.longitude,
      event.location.latitude,
      event.location.longitude,
    );

    return event.copyWith(distanceKm: meters / 1000);
  }

  int _compareEvents(LiveEvent a, LiveEvent b) {
    final aDistance = a.distanceKm ?? 99999;
    final bDistance = b.distanceKm ?? 99999;

    final distanceCompare = aDistance.compareTo(bDistance);
    if (distanceCompare != 0) {
      return distanceCompare;
    }

    return a.startAt.compareTo(b.startAt);
  }

  void _onAuthChanged() {
    final session = _authState.session;
    if (session == null || !_authState.isAuthenticated) {
      _claimedOwnerId = null;
      notifyListeners();
      return;
    }

    final ownerId = session.userId ?? session.identifier;
    if (_claimedOwnerId == ownerId) {
      return;
    }

    _claimedOwnerId = ownerId;
    _repository.claimGuestEvents(
      guestSessionId: _authState.guestSessionId,
      ownerId: ownerId,
      ownerName: session.identifier,
    );

    refreshFeed();
    notifyListeners();
  }

  @override
  void dispose() {
    _authState.removeListener(_onAuthChanged);
    super.dispose();
  }
}
