import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class MapService {
  static const String _googleMapsUrlTemplate =
      'https://www.google.com/maps/search/?api=1&query={lat},{lng}';
  static const String _appleMapsUrlTemplate =
      'http://maps.apple.com/?q={lat},{lng}';
  static const String _googleMapsDirectionsTemplate =
      'https://www.google.com/maps/dir/?api=1&destination={lat},{lng}';

  /// Mở Google Maps tại vị trí cụ thể
  static Future<bool> openGoogleMaps(double latitude, double longitude) async {
    final url = _googleMapsUrlTemplate
        .replaceAll('{lat}', latitude.toString())
        .replaceAll('{lng}', longitude.toString());

    return await _launchUrl(url);
  }

  /// Mở Google Maps với chỉ đường đến vị trí
  static Future<bool> openGoogleMapsDirections(
      double latitude, double longitude) async {
    final url = _googleMapsDirectionsTemplate
        .replaceAll('{lat}', latitude.toString())
        .replaceAll('{lng}', longitude.toString());

    return await _launchUrl(url);
  }

  /// Mở Apple Maps tại vị trí cụ thể
  static Future<bool> openAppleMaps(double latitude, double longitude) async {
    final url = _appleMapsUrlTemplate
        .replaceAll('{lat}', latitude.toString())
        .replaceAll('{lng}', longitude.toString());

    return await _launchUrl(url);
  }

  /// Sao chép tọa độ vào clipboard
  static Future<void> copyCoordinates(double latitude, double longitude) async {
    final coordinates =
        '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
    await Clipboard.setData(ClipboardData(text: coordinates));
  }

  /// Helper method để launch URL với fallback
  static Future<bool> _launchUrl(String url) async {
    final uri = Uri.parse(url);

    // Thử mở trong ứng dụng trước
    if (await canLaunchUrl(uri)) {
      final result = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (result) return true;
    }

    // Nếu không mở được trong ứng dụng, thử mở trong trình duyệt
    try {
      return await launchUrl(
        uri,
        mode: LaunchMode.externalNonBrowserApplication,
      );
    } catch (e) {
      // Cuối cùng, thử mở trong trình duyệt web
      try {
        return await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
        );
      } catch (e) {
        return false;
      }
    }
  }

  /// Kiểm tra xem có thể mở Google Maps không
  static Future<bool> canOpenGoogleMaps() async {
    final testUrl = _googleMapsUrlTemplate
        .replaceAll('{lat}', '0')
        .replaceAll('{lng}', '0');

    return await canLaunchUrl(Uri.parse(testUrl));
  }

  /// Kiểm tra xem có thể mở Apple Maps không
  static Future<bool> canOpenAppleMaps() async {
    final testUrl =
        _appleMapsUrlTemplate.replaceAll('{lat}', '0').replaceAll('{lng}', '0');

    return await canLaunchUrl(Uri.parse(testUrl));
  }

  /// Test method để kiểm tra service
  static Future<Map<String, bool>> testMapServices() async {
    return {
      'google_maps': await canOpenGoogleMaps(),
      'apple_maps': await canOpenAppleMaps(),
    };
  }
}
