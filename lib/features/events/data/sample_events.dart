import '../models/event_location.dart';
import '../models/live_event.dart';

List<LiveEvent> buildSampleEvents({
  required double latitude,
  required double longitude,
}) {
  final now = DateTime.now();

  EventLocation locationOffset(
    double latOffset,
    double lonOffset,
    String address,
    String city,
  ) {
    return EventLocation(
      latitude: latitude + latOffset,
      longitude: longitude + lonOffset,
      address: address,
      city: city,
    );
  }

  return <LiveEvent>[
    LiveEvent(
      id: 'sample-1',
      title: 'Sunset Jazz by the River',
      startAt: DateTime(now.year, now.month, now.day, 19, 30),
      endAt: DateTime(now.year, now.month, now.day, 22),
      venue: 'Riverside Pavilion',
      location: locationOffset(
        0.0042,
        0.0033,
        'Riverside Pavilion',
        'Local City',
      ),
      category: 'Music',
      description:
          'Live jazz performances featuring local artists and open-air seating near the riverfront.',
      source: 'external',
      sourceLabel: 'CityEvents API',
    ),
    LiveEvent(
      id: 'sample-2',
      title: 'Weekend Farmers Market',
      startAt: _nextWeekendAt(9),
      endAt: _nextWeekendAt(14),
      venue: 'Central Market Square',
      location: locationOffset(
        -0.0028,
        0.0017,
        'Central Market Square',
        'Local City',
      ),
      category: 'Food',
      description:
          'Fresh produce, food trucks, and artisan booths from nearby communities.',
      source: 'external',
      sourceLabel: 'Community Board',
    ),
    LiveEvent(
      id: 'sample-3',
      title: 'Startup Pitch Night',
      startAt: now.add(const Duration(days: 2, hours: 3)),
      venue: 'Innovation Hub Auditorium',
      location: locationOffset(
        0.0060,
        -0.0025,
        'Innovation Hub Auditorium',
        'Local City',
      ),
      category: 'Business',
      description:
          'Early-stage founders present products to local investors and community mentors.',
      source: 'user',
      sourceLabel: 'User submission',
      ownerName: 'Guest Host',
      guestSessionId: 'sample-guest',
    ),
    LiveEvent(
      id: 'sample-4',
      title: 'City Lantern Parade',
      startAt: now.add(const Duration(days: 1, hours: 5)),
      venue: 'Old Town Gate',
      location: locationOffset(-0.0051, -0.0048, 'Old Town Gate', 'Local City'),
      category: 'Family',
      description:
          'Evening lantern parade with street performers, family activities, and local food carts.',
      source: 'external',
      sourceLabel: 'Festival Partner',
    ),
    // Duplicate record from a second source to validate dedupe behavior.
    LiveEvent(
      id: 'sample-5',
      title: 'Sunset Jazz by the River',
      startAt: DateTime(now.year, now.month, now.day, 19, 30),
      venue: 'Riverside Pavilion',
      location: locationOffset(
        0.0041,
        0.0033,
        'Riverside Pavilion',
        'Local City',
      ),
      category: 'Music',
      description: 'Duplicate source copy of jazz event.',
      source: 'external',
      sourceLabel: 'Partner feed',
    ),
  ];
}

DateTime _nextWeekendAt(int hour) {
  final now = DateTime.now();
  var date = DateTime(now.year, now.month, now.day, hour);
  while (date.weekday != DateTime.saturday) {
    date = date.add(const Duration(days: 1));
  }
  return date;
}
