import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'game_state_service.dart';
import 'user_api_service.dart';

class LocationTrackingService {
  static LatLng? currentLocation;
  static LatLng? previousLocation;
  static double? locationAccuracy;

  static final StreamController<LatLng?> _locationController =
      StreamController<LatLng?>.broadcast();

  static Stream<LatLng?> get locationStream => _locationController.stream;

  static StreamSubscription<Position>? _positionStream;

  static Future<void> startTracking() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return;
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    final initialPosition = await Geolocator.getCurrentPosition();

    _updateLocation(initialPosition);

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    _positionStream ??=
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (position) async {
            await _updateLocation(position);
          },
        );
  }

  static Future<void> _updateLocation(Position position) async {
    final newLocation = LatLng(position.latitude, position.longitude);

    if (currentLocation != null) {
      final distanceInMeters = Geolocator.distanceBetween(
        currentLocation!.latitude,
        currentLocation!.longitude,
        newLocation.latitude,
        newLocation.longitude,
      );

      if (distanceInMeters > 5 && distanceInMeters < 1000) {
        await GameStateService.addDistance(distanceInMeters / 1000);

        await UserApiService.updateCurrentUserDistance(
          GameStateService.totalDistanceKm,
        );
      }
    }

    previousLocation = currentLocation;
    currentLocation = newLocation;
    locationAccuracy = position.accuracy;

    _locationController.add(currentLocation);
  }

  static Future<void> refreshLocation() async {
    final position = await Geolocator.getCurrentPosition();
    await _updateLocation(position);
  }

  static void stopTracking() {
    _positionStream?.cancel();
    _positionStream = null;
  }
}
