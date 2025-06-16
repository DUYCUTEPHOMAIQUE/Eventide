import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'full_screen_map_picker.dart';

class LocationPickerWidget extends StatefulWidget {
  final String location;
  final LatLng? selectedLocation;
  final Function(String) onLocationChanged;
  final Function(LatLng) onLocationSelected;
  final VoidCallback onGetCurrentLocation;

  const LocationPickerWidget({
    Key? key,
    required this.location,
    this.selectedLocation,
    required this.onLocationChanged,
    required this.onLocationSelected,
    required this.onGetCurrentLocation,
  }) : super(key: key);

  @override
  State<LocationPickerWidget> createState() => _LocationPickerWidgetState();
}

class _LocationPickerWidgetState extends State<LocationPickerWidget> {
  final TextEditingController _locationController = TextEditingController();
  bool _showMap = false;
  final MapController _mapController = MapController();
  LatLng _currentMapCenter = const LatLng(21.0285, 105.8542); // Hanoi default

  @override
  void initState() {
    super.initState();
    _locationController.text = widget.location;
    if (widget.selectedLocation != null) {
      _currentMapCenter = widget.selectedLocation!;
    }
  }

  @override
  void didUpdateWidget(LocationPickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.location != oldWidget.location) {
      _locationController.text = widget.location;
    }
    if (widget.selectedLocation != null &&
        widget.selectedLocation != oldWidget.selectedLocation) {
      _currentMapCenter = widget.selectedLocation!;
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _openFullScreenMap() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenMapPicker(
          initialLocation: widget.selectedLocation,
          initialAddress: widget.location,
        ),
      ),
    );

    if (result != null) {
      final LatLng location = result['location'] as LatLng;
      final String address = result['address'] as String;

      widget.onLocationSelected(location);
      if (address.isNotEmpty) {
        widget.onLocationChanged(address);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Location text field
        const Text(
          'Location',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),

        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
            color: Colors.white.withOpacity(0.05),
          ),
          child: Column(
            children: [
              // Text input with buttons
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _locationController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Enter location or select on map',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: widget.onLocationChanged,
                      ),
                    ),

                    // Current location button
                    IconButton(
                      onPressed: widget.onGetCurrentLocation,
                      icon: const Icon(
                        Icons.my_location,
                        color: Colors.blue,
                        size: 20,
                      ),
                      tooltip: 'Get current location',
                    ),

                    // Toggle map button
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _showMap = !_showMap;
                        });
                      },
                      icon: Icon(
                        _showMap ? Icons.keyboard_arrow_up : Icons.map,
                        color: Colors.white70,
                        size: 20,
                      ),
                      tooltip: _showMap ? 'Hide map' : 'Show map',
                    ),

                    // Full-screen map button
                    IconButton(
                      onPressed: _openFullScreenMap,
                      icon: const Icon(
                        Icons.fullscreen,
                        color: Colors.blue,
                        size: 20,
                      ),
                      tooltip: 'Open full-screen map',
                    ),
                  ],
                ),
              ),

              // Map view (expandable)
              if (_showMap) ...[
                Container(
                  height: 200,
                  margin:
                      const EdgeInsets.only(left: 12, right: 12, bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _currentMapCenter,
                        initialZoom: 13,
                        onTap: (tapPosition, point) {
                          widget.onLocationSelected(point);
                          setState(() {
                            _currentMapCenter = point;
                          });
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.eventide',
                        ),

                        // Marker for selected location
                        if (widget.selectedLocation != null)
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: widget.selectedLocation!,
                                width: 40,
                                height: 40,
                                child: const Icon(
                                  Icons.location_pin,
                                  color: Colors.red,
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),

                // Map instructions
                Padding(
                  padding:
                      const EdgeInsets.only(left: 12, right: 12, bottom: 12),
                  child: Text(
                    'Tap on the map to select a location',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),

        // Selected location display
        if (widget.selectedLocation != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_pin,
                  color: Colors.blue,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Selected: ${widget.selectedLocation!.latitude.toStringAsFixed(6)}, ${widget.selectedLocation!.longitude.toStringAsFixed(6)}',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
