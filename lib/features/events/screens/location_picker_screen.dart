import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/themes/vision_os_typography.dart';
import '../../../shared/widgets/glass_widgets.dart';
import '../../location/models/location_selection.dart';
import '../../location/services/location_service.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({
    super.key,
    required this.initialLocation,
    required this.locationService,
  });

  final LocationSelection initialLocation;
  final LocationService locationService;

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late final MapController _mapController;
  late LatLng _center;

  final _searchController = TextEditingController();
  bool _isSearching = false;
  List<LocationSelection> _searchResults = const <LocationSelection>[];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _center = LatLng(
      widget.initialLocation.latitude,
      widget.initialLocation.longitude,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await widget.locationService.searchLocations(query);
      setState(() {
        _searchResults = results;
      });
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  Future<void> _confirmSelection() async {
    final label = await widget.locationService.reverseGeocode(
      _center.latitude,
      _center.longitude,
    );
    if (!mounted) {
      return;
    }

    Navigator.of(context).pop(
      LocationSelection(
        latitude: _center.latitude,
        longitude: _center.longitude,
        label: label,
        source: LocationSource.mapPin,
      ),
    );
  }

  void _jumpToResult(LocationSelection selection) {
    final target = LatLng(selection.latitude, selection.longitude);
    _mapController.move(target, 14);
    setState(() {
      _center = target;
      _searchResults = const <LocationSelection>[];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: GlassContainer(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Expanded(
                        child: Text(
                          'Pick Location',
                          style: VisionOSTypography.titleMedium,
                        ),
                      ),
                      GlassButton(
                        label: 'Use Pin',
                        icon: Icons.check,
                        onPressed: _confirmSelection,
                        isPrimary: false,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: GlassContainer(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Search city, area, venue',
                            isDense: true,
                          ),
                          onSubmitted: (_) => _search(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: _isSearching
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.search),
                        onPressed: _isSearching ? null : _search,
                      ),
                    ],
                  ),
                ),
              ),
              if (_searchResults.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: _searchResults
                          .map(
                            (location) => ListTile(
                              dense: true,
                              title: Text(
                                location.label,
                                style: VisionOSTypography.bodySmall,
                              ),
                              onTap: () => _jumpToResult(location),
                            ),
                          )
                          .toList(growable: false),
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Stack(
                      children: [
                        FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: _center,
                            initialZoom: 13,
                            onPositionChanged: (position, _) {
                              setState(() {
                                _center = position.center;
                              });
                            },
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'abn.app.liveevents',
                            ),
                          ],
                        ),
                        const Center(
                          child: Icon(
                            Icons.location_pin,
                            size: 42,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
