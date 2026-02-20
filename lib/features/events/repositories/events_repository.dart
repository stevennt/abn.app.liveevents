import 'package:uuid/uuid.dart';

import '../../../core/network/api_client.dart';
import '../../auth/models/auth_session.dart';
import '../data/sample_events.dart';
import '../models/event_draft.dart';
import '../models/event_results.dart';
import '../models/live_event.dart';
import '../services/events_service.dart';

class EventsRepository {
  EventsRepository(this._eventsService);

  final EventsService _eventsService;
  final List<LiveEvent> _localSubmitted = <LiveEvent>[];

  Future<FeedLoadResult> fetchFeed({
    required double latitude,
    required double longitude,
    String? category,
    DateTime? date,
  }) async {
    try {
      final remoteEvents = await _eventsService.fetchEvents(
        latitude: latitude,
        longitude: longitude,
        category: category,
        date: date,
      );

      final merged = _dedupe(<LiveEvent>[...remoteEvents, ..._localSubmitted]);
      return FeedLoadResult(events: merged);
    } on ApiException catch (error) {
      final fallback = buildSampleEvents(
        latitude: latitude,
        longitude: longitude,
      );
      final merged = _dedupe(<LiveEvent>[...fallback, ..._localSubmitted]);
      return FeedLoadResult(
        events: merged,
        warningMessage:
            'Live API unavailable (${error.statusCode ?? 'network'}). Showing sample + local events.',
        usedFallback: true,
      );
    } catch (_) {
      final fallback = buildSampleEvents(
        latitude: latitude,
        longitude: longitude,
      );
      final merged = _dedupe(<LiveEvent>[...fallback, ..._localSubmitted]);
      return const FeedLoadResult(
        events: <LiveEvent>[],
        warningMessage: 'Unexpected issue loading events.',
        usedFallback: true,
      ).copyWith(events: merged);
    }
  }

  Future<EventMutationResult> submitEvent({
    required EventDraft draft,
    required bool isGuest,
    String? guestSessionId,
    AuthSession? session,
  }) async {
    final ownerId = session?.userId;
    final ownerName = session?.identifier;

    try {
      final event = await _eventsService.createEvent(
        draft: draft,
        bearerToken: session?.accessToken,
        isGuest: isGuest,
        guestSessionId: guestSessionId,
      );

      final normalized = event.copyWith(
        source: 'user',
        sourceLabel: event.sourceLabel.isEmpty
            ? 'User submission'
            : event.sourceLabel,
        ownerId: event.ownerId ?? ownerId,
        ownerName: event.ownerName ?? ownerName,
        guestSessionId: event.guestSessionId ?? guestSessionId,
      );

      _upsertLocal(normalized);
      return EventMutationResult(event: normalized, shouldPromptLogin: isGuest);
    } on ApiException catch (error) {
      final localEvent = draft.toLocalEvent(
        id: 'local-${const Uuid().v4()}',
        source: 'user',
        sourceLabel: 'Local draft (offline)',
        ownerId: ownerId,
        ownerName: ownerName,
        guestSessionId: guestSessionId,
      );

      _upsertLocal(localEvent);
      return EventMutationResult(
        event: localEvent,
        warningMessage:
            'Submitted locally because API failed: ${error.message}',
        usedFallback: true,
        shouldPromptLogin: isGuest,
      );
    }
  }

  Future<EventMutationResult> updateEvent({
    required String eventId,
    required EventDraft draft,
    AuthSession? session,
  }) async {
    try {
      final updated = await _eventsService.updateEvent(
        eventId: eventId,
        draft: draft,
        bearerToken: session?.accessToken,
      );

      final normalized = updated.copyWith(
        source: 'user',
        sourceLabel: updated.sourceLabel.isEmpty
            ? 'User submission'
            : updated.sourceLabel,
        ownerId: updated.ownerId ?? session?.userId,
        ownerName: updated.ownerName ?? session?.identifier,
      );
      _upsertLocal(normalized);
      return EventMutationResult(event: normalized);
    } on ApiException catch (error) {
      final existing = _findLocal(eventId);
      final fallback = draft.toLocalEvent(
        id: eventId,
        source: 'user',
        sourceLabel: 'Local draft (offline)',
        ownerId: existing?.ownerId ?? session?.userId,
        ownerName: existing?.ownerName ?? session?.identifier,
        guestSessionId: existing?.guestSessionId,
      );
      _upsertLocal(fallback);
      return EventMutationResult(
        event: fallback,
        warningMessage:
            'Saved locally because API update failed: ${error.message}',
        usedFallback: true,
      );
    }
  }

  Future<String?> cancelEvent({
    required String eventId,
    AuthSession? session,
  }) async {
    try {
      await _eventsService.cancelEvent(
        eventId: eventId,
        bearerToken: session?.accessToken,
      );
      final local = _findLocal(eventId);
      if (local != null) {
        _upsertLocal(local.copyWith(isCancelled: true));
      }
      return null;
    } on ApiException catch (error) {
      final local = _findLocal(eventId);
      if (local != null) {
        _upsertLocal(local.copyWith(isCancelled: true));
      }
      return 'Cancelled locally because API failed: ${error.message}';
    }
  }

  Future<Map<String, dynamic>> fetchEventReport({
    required String eventId,
    AuthSession? session,
  }) {
    return _eventsService.fetchEventReport(
      eventId: eventId,
      bearerToken: session?.accessToken,
    );
  }

  List<LiveEvent> mySubmittedEvents({
    required String guestSessionId,
    AuthSession? session,
  }) {
    final ownerId = session?.userId;
    final identifier = session?.identifier;

    return _localSubmitted
        .where((event) {
          if (ownerId != null && ownerId.isNotEmpty) {
            return event.ownerId == ownerId || event.ownerName == identifier;
          }

          return event.guestSessionId == guestSessionId;
        })
        .toList(growable: false);
  }

  void claimGuestEvents({
    required String guestSessionId,
    required String ownerId,
    required String ownerName,
  }) {
    var changed = false;
    final updated = <LiveEvent>[];
    for (final event in _localSubmitted) {
      if (event.guestSessionId == guestSessionId &&
          (event.ownerId == null || event.ownerId!.isEmpty)) {
        updated.add(event.copyWith(ownerId: ownerId, ownerName: ownerName));
        changed = true;
      } else {
        updated.add(event);
      }
    }

    if (changed) {
      _localSubmitted
        ..clear()
        ..addAll(updated);
    }
  }

  void _upsertLocal(LiveEvent event) {
    final index = _localSubmitted.indexWhere((item) => item.id == event.id);
    if (index == -1) {
      _localSubmitted.add(event);
    } else {
      _localSubmitted[index] = event;
    }
  }

  LiveEvent? _findLocal(String id) {
    try {
      return _localSubmitted.firstWhere((event) => event.id == id);
    } catch (_) {
      return null;
    }
  }

  List<LiveEvent> _dedupe(List<LiveEvent> source) {
    final map = <String, LiveEvent>{};

    for (final event in source) {
      final existing = map[event.dedupeKey];
      if (existing == null) {
        map[event.dedupeKey] = event;
        continue;
      }

      map[event.dedupeKey] = _mergeEvents(existing, event);
    }

    return map.values.toList(growable: false);
  }

  LiveEvent _mergeEvents(LiveEvent a, LiveEvent b) {
    final preferred = a.source == 'user'
        ? a
        : b.source == 'user'
        ? b
        : a;
    final secondary = identical(preferred, a) ? b : a;

    final sourceLabelSet = <String>{
      if (preferred.sourceLabel.trim().isNotEmpty) preferred.sourceLabel,
      if (secondary.sourceLabel.trim().isNotEmpty) secondary.sourceLabel,
    };

    return preferred.copyWith(
      description: preferred.description.isNotEmpty
          ? preferred.description
          : secondary.description,
      sourceLabel: sourceLabelSet.join(' + '),
      ownerId: preferred.ownerId ?? secondary.ownerId,
      ownerName: preferred.ownerName ?? secondary.ownerName,
      guestSessionId: preferred.guestSessionId ?? secondary.guestSessionId,
      isCancelled: preferred.isCancelled || secondary.isCancelled,
    );
  }
}

extension on FeedLoadResult {
  FeedLoadResult copyWith({
    List<LiveEvent>? events,
    String? warningMessage,
    bool? usedFallback,
  }) {
    return FeedLoadResult(
      events: events ?? this.events,
      warningMessage: warningMessage ?? this.warningMessage,
      usedFallback: usedFallback ?? this.usedFallback,
    );
  }
}
