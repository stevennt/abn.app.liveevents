class EventLocation {
  const EventLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
    this.city,
  });

  final double latitude;
  final double longitude;
  final String address;
  final String? city;

  factory EventLocation.fromJson(Map<String, dynamic> json) {
    return EventLocation(
      latitude: _toDouble(json['latitude']) ?? _toDouble(json['lat']) ?? 0,
      longitude:
          _toDouble(json['longitude']) ??
          _toDouble(json['lng']) ??
          _toDouble(json['lon']) ??
          0,
      address: (json['address'] ?? json['venue'] ?? '').toString(),
      city: (json['city'] ?? json['locality'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'city': city,
    };
  }

  static double? _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value);
    }

    return null;
  }
}
