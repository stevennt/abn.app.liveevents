import 'package:intl/intl.dart';

import 'event_location.dart';

class LiveEvent {
  const LiveEvent({
    required this.id,
    required this.title,
    required this.startAt,
    required this.venue,
    required this.location,
    required this.category,
    required this.description,
    required this.source,
    required this.sourceLabel,
    this.endAt,
    this.ownerId,
    this.ownerName,
    this.guestSessionId,
    this.isCancelled = false,
    this.distanceKm,
    this.createdAt,
    this.raw = const <String, dynamic>{},
  });

  final String id;
  final String title;
  final DateTime startAt;
  final DateTime? endAt;
  final String venue;
  final EventLocation location;
  final String category;
  final String description;
  final String source;
  final String sourceLabel;
  final String? ownerId;
  final String? ownerName;
  final String? guestSessionId;
  final bool isCancelled;
  final double? distanceKm;
  final DateTime? createdAt;
  final Map<String, dynamic> raw;

  String get dedupeKey {
    final normalizedTitle = title.trim().toLowerCase().replaceAll(
      RegExp(r'\s+'),
      ' ',
    );
    final normalizedVenue = venue.trim().toLowerCase().replaceAll(
      RegExp(r'\s+'),
      ' ',
    );
    final normalizedDate = DateFormat('yyyy-MM-dd HH').format(startAt.toUtc());
    return '$normalizedTitle|$normalizedVenue|$normalizedDate';
  }

  LiveEvent copyWith({
    String? id,
    String? title,
    DateTime? startAt,
    DateTime? endAt,
    String? venue,
    EventLocation? location,
    String? category,
    String? description,
    String? source,
    String? sourceLabel,
    String? ownerId,
    String? ownerName,
    String? guestSessionId,
    bool? isCancelled,
    double? distanceKm,
    DateTime? createdAt,
    Map<String, dynamic>? raw,
  }) {
    return LiveEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      venue: venue ?? this.venue,
      location: location ?? this.location,
      category: category ?? this.category,
      description: description ?? this.description,
      source: source ?? this.source,
      sourceLabel: sourceLabel ?? this.sourceLabel,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      guestSessionId: guestSessionId ?? this.guestSessionId,
      isCancelled: isCancelled ?? this.isCancelled,
      distanceKm: distanceKm ?? this.distanceKm,
      createdAt: createdAt ?? this.createdAt,
      raw: raw ?? this.raw,
    );
  }

  factory LiveEvent.fromJson(Map<String, dynamic> json) {
    final locationMap = _extractLocationMap(json);
    final title =
        _asString(json, const ['title', 'name', 'event_name']) ??
        'Untitled Event';
    final venue =
        _asString(json, const [
          'venue',
          'locationName',
          'location_name',
          'place',
          'address',
          'location_label',
        ]) ??
        (locationMap['address']?.toString() ?? 'Unknown venue');

    final source =
        _asString(json, const ['source']) ??
        (_asString(json, const ['owner_id', 'submitter_id', 'created_by']) !=
                null
            ? 'user'
            : 'external');

    final eventId =
        _asString(json, const ['id', 'event_id', 'sticky_id']) ??
        'local-${title.hashCode}-${venue.hashCode}-${DateTime.now().microsecondsSinceEpoch}';

    final startAt =
        _asDateTime(json, const [
          'startAt',
          'startsAt',
          'start_at',
          'starts_at',
          'start_time',
          'date_time',
          'datetime',
          'date',
        ]) ??
        DateTime.now().add(const Duration(hours: 2));

    final endAt = _asDateTime(json, const [
      'endAt',
      'endsAt',
      'end_at',
      'ends_at',
      'end_time',
    ]);

    final cancelledRaw =
        json['is_cancelled'] ?? json['cancelled'] ?? json['status'];
    final isCancelled = cancelledRaw is bool
        ? cancelledRaw
        : cancelledRaw?.toString().toLowerCase().contains('cancel') ?? false;

    return LiveEvent(
      id: eventId,
      title: title,
      startAt: startAt,
      endAt: endAt,
      venue: venue,
      location: EventLocation.fromJson(locationMap),
      category: _asString(json, const ['category', 'type']) ?? 'General',
      description:
          _asString(json, const ['description', 'details', 'summary']) ?? '',
      source: source,
      sourceLabel:
          _asString(json, const [
            'sourceLabel',
            'source_label',
            'provider',
            'source',
          ]) ??
          source,
      ownerId: _asString(json, const [
        'submitterId',
        'owner_id',
        'submitter_id',
        'created_by',
        'user_id',
      ]),
      ownerName: _asString(json, const [
        'submitterName',
        'owner_name',
        'submitter_name',
        'created_by_name',
      ]),
      guestSessionId: _asString(json, const [
        'guestSessionId',
        'guest_session_id',
      ]),
      isCancelled: isCancelled,
      distanceKm: _asDouble(json, const ['distanceKm', 'distance_km']),
      createdAt: _asDateTime(json, const ['createdAt', 'created_at']),
      raw: json,
    );
  }

  static Map<String, dynamic> _extractLocationMap(Map<String, dynamic> json) {
    final map = <String, dynamic>{};

    final nested = json['location'];
    if (nested is Map<String, dynamic>) {
      map.addAll(nested);
    }

    map['latitude'] =
        map['latitude'] ?? map['lat'] ?? json['latitude'] ?? json['lat'];
    map['longitude'] =
        map['longitude'] ??
        map['lng'] ??
        map['lon'] ??
        json['longitude'] ??
        json['lng'] ??
        json['lon'];
    map['address'] =
        map['address'] ??
        map['venue'] ??
        map['locationName'] ??
        json['address'] ??
        json['venue'] ??
        json['locationName'] ??
        json['location_label'];
    map['city'] = map['city'] ?? json['city'];

    return map;
  }

  static String? _asString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) {
        continue;
      }

      final stringValue = value.toString().trim();
      if (stringValue.isNotEmpty) {
        return stringValue;
      }
    }

    return null;
  }

  static DateTime? _asDateTime(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) {
        continue;
      }

      if (value is String) {
        final parsed = DateTime.tryParse(value);
        if (parsed != null) {
          return parsed.toLocal();
        }
      }

      if (value is int) {
        final parsed = DateTime.fromMillisecondsSinceEpoch(
          value,
          isUtc: true,
        ).toLocal();
        return parsed;
      }

      if (value is double) {
        final parsed = DateTime.fromMillisecondsSinceEpoch(
          value.toInt(),
          isUtc: true,
        ).toLocal();
        return parsed;
      }
    }

    return null;
  }

  static double? _asDouble(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) {
        continue;
      }

      if (value is num) {
        return value.toDouble();
      }

      if (value is String) {
        final parsed = double.tryParse(value);
        if (parsed != null) {
          return parsed;
        }
      }
    }

    return null;
  }
}
