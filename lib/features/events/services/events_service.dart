import '../../../core/network/api_client.dart';
import '../models/event_draft.dart';
import '../models/live_event.dart';

class EventsService {
  EventsService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<LiveEvent>> fetchEvents({
    double? latitude,
    double? longitude,
    String? category,
    DateTime? date,
  }) async {
    final query = <String, String>{
      if (latitude != null) 'lat': latitude.toString(),
      if (longitude != null) 'lng': longitude.toString(),
      if (category != null && category != 'All') 'category': category,
      if (date != null)
        'date':
            '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
    };

    final response = await _apiClient.get(
      '/api/v1/events',
      queryParameters: query,
    );
    final records = _extractList(response);

    return records
        .whereType<Map<String, dynamic>>()
        .map(LiveEvent.fromJson)
        .toList(growable: false);
  }

  Future<LiveEvent> createEvent({
    required EventDraft draft,
    String? bearerToken,
    required bool isGuest,
    String? guestSessionId,
  }) async {
    final response = await _apiClient.post(
      '/api/v1/events',
      bearerToken: bearerToken,
      body: draft.toCreatePayload(
        isGuest: isGuest,
        guestSessionId: guestSessionId,
      ),
    );

    return _extractEvent(response) ??
        draft.toLocalEvent(
          id: 'remote-${DateTime.now().millisecondsSinceEpoch}',
          source: 'user',
          sourceLabel: 'User submission',
          guestSessionId: guestSessionId,
        );
  }

  Future<LiveEvent> updateEvent({
    required String eventId,
    required EventDraft draft,
    String? bearerToken,
  }) async {
    final response = await _apiClient.put(
      '/api/v1/events/$eventId',
      bearerToken: bearerToken,
      body: draft.toUpdatePayload(),
    );

    return _extractEvent(response) ??
        draft.toLocalEvent(
          id: eventId,
          source: 'user',
          sourceLabel: 'User submission',
        );
  }

  Future<void> cancelEvent({
    required String eventId,
    String? bearerToken,
  }) async {
    await _apiClient.post(
      '/api/v1/events/$eventId/cancel',
      bearerToken: bearerToken,
    );
  }

  Future<Map<String, dynamic>> fetchEventReport({
    required String eventId,
    String? bearerToken,
  }) async {
    final response = await _apiClient.get(
      '/api/v1/events/$eventId/report',
      bearerToken: bearerToken,
    );

    if (response is Map<String, dynamic>) {
      return response;
    }

    return <String, dynamic>{'raw': response.toString()};
  }

  LiveEvent? _extractEvent(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      if (_looksLikeEvent(payload)) {
        return LiveEvent.fromJson(payload);
      }

      for (final key in const ['event', 'data', 'item']) {
        final nested = payload[key];
        if (nested is Map<String, dynamic> && _looksLikeEvent(nested)) {
          return LiveEvent.fromJson(nested);
        }
      }
    }

    return null;
  }

  List<dynamic> _extractList(dynamic payload) {
    if (payload is List<dynamic>) {
      return payload;
    }

    if (payload is Map<String, dynamic>) {
      for (final key in const ['events', 'items', 'data', 'results']) {
        final nested = payload[key];
        if (nested is List<dynamic>) {
          return nested;
        }
      }
    }

    return const <dynamic>[];
  }

  bool _looksLikeEvent(Map<String, dynamic> value) {
    return value.containsKey('id') ||
        value.containsKey('event_id') ||
        value.containsKey('title') ||
        value.containsKey('name');
  }
}
