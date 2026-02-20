import 'event_location.dart';
import 'live_event.dart';

class EventDraft {
  const EventDraft({
    required this.title,
    required this.description,
    required this.venue,
    required this.category,
    required this.startAt,
    this.endAt,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.city,
  });

  final String title;
  final String description;
  final String venue;
  final String category;
  final DateTime startAt;
  final DateTime? endAt;
  final double latitude;
  final double longitude;
  final String address;
  final String? city;

  Map<String, dynamic> toCreatePayload({
    required bool isGuest,
    String? guestSessionId,
  }) {
    return <String, dynamic>{
      'title': title,
      'description': description,
      'locationName': venue,
      'category': category,
      'startsAt': startAt.toUtc().toIso8601String(),
      if (endAt != null) 'endsAt': endAt!.toUtc().toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      if (city != null && city!.trim().isNotEmpty) 'city': city,
      'source': 'user',
      'isGuestSubmission': isGuest,
      if (isGuest && guestSessionId != null) 'guestSessionId': guestSessionId,
    };
  }

  Map<String, dynamic> toUpdatePayload() {
    return <String, dynamic>{
      'title': title,
      'description': description,
      'locationName': venue,
      'category': category,
      'startsAt': startAt.toUtc().toIso8601String(),
      if (endAt != null) 'endsAt': endAt!.toUtc().toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      if (city != null && city!.trim().isNotEmpty) 'city': city,
    };
  }

  LiveEvent toLocalEvent({
    required String id,
    required String source,
    required String sourceLabel,
    String? ownerId,
    String? ownerName,
    String? guestSessionId,
  }) {
    return LiveEvent(
      id: id,
      title: title,
      startAt: startAt,
      endAt: endAt,
      venue: venue,
      location: EventLocation(
        latitude: latitude,
        longitude: longitude,
        address: address,
        city: city,
      ),
      category: category,
      description: description,
      source: source,
      sourceLabel: sourceLabel,
      ownerId: ownerId,
      ownerName: ownerName,
      guestSessionId: guestSessionId,
      createdAt: DateTime.now(),
      raw: const <String, dynamic>{},
    );
  }
}
