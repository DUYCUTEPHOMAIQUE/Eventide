import 'dart:math';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import '../models/card_model.dart';

class LocationService {
  static const Distance _distance = Distance();

  /// Calculate distance between two coordinates in kilometers
  static double calculateDistance(LatLng point1, LatLng point2) {
    return _distance.as(LengthUnit.Kilometer, point1, point2);
  }

  /// Calculate distance between user location and card location
  static double? calculateDistanceToCard(LatLng userLocation, CardModel card) {
    if (!card.hasCoordinates) return null;

    final cardLocation = LatLng(card.latitude!, card.longitude!);
    return calculateDistance(userLocation, cardLocation);
  }

  /// Get current user position
  static Future<LatLng?> getCurrentPosition() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      Position position = await Geolocator.getCurrentPosition();
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      print('Error getting current position: $e');
      return null;
    }
  }

  /// Filter cards by distance from user location
  static Future<List<CardModel>> filterCardsByDistance(
    List<CardModel> cards, {
    double maxDistanceKm = 50.0,
  }) async {
    final userLocation = await getCurrentPosition();
    if (userLocation == null) return cards;

    return cards.where((card) {
      if (!card.hasCoordinates) return true; // Include cards without location

      final distance = calculateDistanceToCard(userLocation, card);
      return distance != null && distance <= maxDistanceKm;
    }).toList();
  }

  /// Sort cards by distance from user location
  static Future<List<CardModel>> sortCardsByDistance(
    List<CardModel> cards, {
    bool ascending = true,
  }) async {
    final userLocation = await getCurrentPosition();
    if (userLocation == null) return cards;

    final cardsWithDistance = cards.map((card) {
      final distance = card.hasCoordinates
          ? calculateDistanceToCard(userLocation, card)
          : double.infinity;
      return MapEntry(card, distance ?? double.infinity);
    }).toList();

    cardsWithDistance.sort((a, b) {
      final comparison = a.value.compareTo(b.value);
      return ascending ? comparison : -comparison;
    });

    return cardsWithDistance.map((entry) => entry.key).toList();
  }

  /// Format distance for display
  static String formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()}m';
    } else if (distanceKm < 10) {
      return '${distanceKm.toStringAsFixed(1)}km';
    } else {
      return '${distanceKm.round()}km';
    }
  }

  /// Get location bounds for a list of cards
  static LatLngBounds? getBoundsForCards(List<CardModel> cards) {
    final cardsWithCoordinates =
        cards.where((card) => card.hasCoordinates).toList();

    if (cardsWithCoordinates.isEmpty) return null;

    double minLat = cardsWithCoordinates.first.latitude!;
    double maxLat = cardsWithCoordinates.first.latitude!;
    double minLng = cardsWithCoordinates.first.longitude!;
    double maxLng = cardsWithCoordinates.first.longitude!;

    for (final card in cardsWithCoordinates) {
      minLat = min(minLat, card.latitude!);
      maxLat = max(maxLat, card.latitude!);
      minLng = min(minLng, card.longitude!);
      maxLng = max(maxLng, card.longitude!);
    }

    return LatLngBounds(
      LatLng(minLat, minLng),
      LatLng(maxLat, maxLng),
    );
  }

  /// Check if location permission is granted
  static Future<bool> isLocationPermissionGranted() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// Request location permission
  static Future<bool> requestLocationPermission() async {
    final permission = await Geolocator.requestPermission();
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// Open location settings
  static Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }
}
