import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'full_screen_map_picker.dart';
import 'package:enva/l10n/app_localizations.dart';

class MinimalistLocationPicker extends StatefulWidget {
  final String location;
  final LatLng? selectedLocation;
  final Function(String) onLocationChanged;
  final Function(LatLng) onLocationSelected;
  final VoidCallback onGetCurrentLocation;

  const MinimalistLocationPicker({
    Key? key,
    required this.location,
    this.selectedLocation,
    required this.onLocationChanged,
    required this.onLocationSelected,
    required this.onGetCurrentLocation,
  }) : super(key: key);

  @override
  State<MinimalistLocationPicker> createState() =>
      _MinimalistLocationPickerState();
}

class _MinimalistLocationPickerState extends State<MinimalistLocationPicker> {
  final TextEditingController _locationController = TextEditingController();
  bool _showPreview = false;

  @override
  void initState() {
    super.initState();
    _locationController.text = widget.location;
  }

  @override
  void didUpdateWidget(MinimalistLocationPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.location != oldWidget.location) {
      _locationController.text = widget.location;
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location input with icon
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 20,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.eventLocation,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Location input field
          TextField(
            controller: _locationController,
            maxLines: 1,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade900,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.eventLocationHint,
              hintStyle: TextStyle(
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w400,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: widget.onLocationChanged,
          ),

          const SizedBox(height: 16),

          // Action buttons row
          Row(
            children: [
              // Current location button
              Expanded(
                child: _buildActionButton(
                  icon: Icons.my_location_outlined,
                  label: AppLocalizations.of(context)!.currentLocationButton,
                  onTap: widget.onGetCurrentLocation,
                ),
              ),

              const SizedBox(width: 12),

              // Map button
              Expanded(
                child: _buildActionButton(
                  icon: Icons.map_outlined,
                  label: AppLocalizations.of(context)!.browseMapButton,
                  onTap: _openFullScreenMap,
                ),
              ),

              const SizedBox(width: 12),

              // Preview toggle
              Expanded(
                child: _buildActionButton(
                  icon: _showPreview
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  label: _showPreview
                      ? AppLocalizations.of(context)!.hidePreviewButton
                      : AppLocalizations.of(context)!.previewButton,
                  onTap: widget.selectedLocation != null
                      ? () => setState(() => _showPreview = !_showPreview)
                      : null,
                ),
              ),
            ],
          ),

          // Selected location info
          if (widget.selectedLocation != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.blue.shade200,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.place,
                    color: Colors.blue.shade600,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${widget.selectedLocation!.latitude.toStringAsFixed(6)}, ${widget.selectedLocation!.longitude.toStringAsFixed(6)}',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Map preview
          if (_showPreview && widget.selectedLocation != null) ...[
            const SizedBox(height: 16),
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: widget.selectedLocation!,
                    initialZoom: 15,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.none,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.eventide',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: widget.selectedLocation!,
                          width: 40,
                          height: 40,
                          child: Icon(
                            Icons.location_pin,
                            color: Colors.red.shade600,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    final isEnabled = onTap != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isEnabled ? Colors.grey.shade100 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEnabled ? Colors.grey.shade300 : Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: isEnabled ? Colors.grey.shade700 : Colors.grey.shade400,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: isEnabled ? Colors.grey.shade700 : Colors.grey.shade400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
