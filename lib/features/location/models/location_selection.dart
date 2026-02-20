class LocationSelection {
  const LocationSelection({
    required this.latitude,
    required this.longitude,
    required this.label,
    required this.source,
  });

  final double latitude;
  final double longitude;
  final String label;
  final LocationSource source;

  String get compactLabel => label.trim().isEmpty ? 'Selected location' : label;
}

enum LocationSource { gps, mapPin, search }
