import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/card_model.dart';

class LocationDisplayWidget extends StatelessWidget {
  final CardModel card;
  final bool showCoordinates;
  final bool showNavigationButtons;

  const LocationDisplayWidget({
    Key? key,
    required this.card,
    this.showCoordinates = false,
    this.showNavigationButtons = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (card.location.isEmpty && !card.hasCoordinates) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Location icon and address
          Row(
            children: [
              const Icon(
                Icons.location_on,
                color: Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  card.location.isNotEmpty
                      ? card.location
                      : 'Location coordinates available',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          // Coordinates display (optional)
          if (showCoordinates && card.hasCoordinates) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.gps_fixed,
                  color: Colors.blue,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  card.coordinatesString,
                  style: TextStyle(
                    color: Colors.blue.withOpacity(0.8),
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ],

          // Navigation buttons
          if (showNavigationButtons && card.hasCoordinates) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                // Google Maps button
                Expanded(
                  child: _buildNavigationButton(
                    icon: Icons.map,
                    label: 'Google Maps',
                    color: Colors.green,
                    onTap: () => _openGoogleMaps(card.googleMapsUrl),
                  ),
                ),
                const SizedBox(width: 8),

                // Apple Maps button (iOS style)
                Expanded(
                  child: _buildNavigationButton(
                    icon: Icons.navigation,
                    label: 'Apple Maps',
                    color: Colors.blue,
                    onTap: () => _openAppleMaps(card.appleMapsUrl),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavigationButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openGoogleMaps(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Error opening Google Maps: $e');
    }
  }

  Future<void> _openAppleMaps(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Error opening Apple Maps: $e');
    }
  }
}

// Compact version for list items
class LocationDisplayCompact extends StatelessWidget {
  final CardModel card;

  const LocationDisplayCompact({
    Key? key,
    required this.card,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (card.location.isEmpty && !card.hasCoordinates) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        Icon(
          Icons.location_on,
          color: Colors.grey.withOpacity(0.7),
          size: 14,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            card.location.isNotEmpty ? card.location : 'Location available',
            style: TextStyle(
              color: Colors.grey.withOpacity(0.8),
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (card.hasCoordinates)
          GestureDetector(
            onTap: () => _showLocationOptions(context),
            child: Icon(
              Icons.navigation,
              color: Colors.blue.withOpacity(0.7),
              size: 14,
            ),
          ),
      ],
    );
  }

  void _showLocationOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Open Location',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            LocationDisplayWidget(
              card: card,
              showCoordinates: true,
              showNavigationButtons: true,
            ),
          ],
        ),
      ),
    );
  }
}
