import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../models/location_selection.dart';

class LocationServiceException implements Exception {
  LocationServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

class LocationService {
  const LocationService();

  Future<LocationSelection> detectCurrentLocation() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw LocationServiceException('Location services are disabled.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw LocationServiceException('Location permission is denied.');
    }

    final current = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    final label = await reverseGeocode(current.latitude, current.longitude);
    return LocationSelection(
      latitude: current.latitude,
      longitude: current.longitude,
      label: label,
      source: LocationSource.gps,
    );
  }

  Future<String> reverseGeocode(double latitude, double longitude) async {
    try {
      final places = await placemarkFromCoordinates(latitude, longitude);
      if (places.isEmpty) {
        return '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
      }

      final place = places.first;
      final parts = <String>[
        if ((place.street ?? '').trim().isNotEmpty) place.street!.trim(),
        if ((place.locality ?? '').trim().isNotEmpty) place.locality!.trim(),
        if ((place.administrativeArea ?? '').trim().isNotEmpty)
          place.administrativeArea!.trim(),
      ];

      if (parts.isEmpty) {
        return '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
      }

      return parts.join(', ');
    } catch (_) {
      return '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
    }
  }

  Future<List<LocationSelection>> searchLocations(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return const <LocationSelection>[];
    }

    final locations = await locationFromAddress(trimmed);
    final results = <LocationSelection>[];

    for (final item in locations.take(5)) {
      final label = await reverseGeocode(item.latitude, item.longitude);
      results.add(
        LocationSelection(
          latitude: item.latitude,
          longitude: item.longitude,
          label: label,
          source: LocationSource.search,
        ),
      );
    }

    return results;
  }
}
