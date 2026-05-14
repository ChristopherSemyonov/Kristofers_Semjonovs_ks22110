import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../models/puzzle.dart';
import '../services/puzzle_service.dart';
import '../services/game_state_service.dart';
import '../widgets/puzzle_map_marker.dart';
import 'dart:async';

import 'puzzle_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? userLocation;
  LatLng? previousUserLocation;
  double? locationAccuracy;
  StreamSubscription<Position>? positionStream;

  final List<Puzzle> puzzles = PuzzleService.getDemoPuzzles();

  static const LatLng rigaOldTown = LatLng(56.9496, 24.1052);

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _startLocationTracking();
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    final position = await Geolocator.getCurrentPosition();

    final newLocation = LatLng(position.latitude, position.longitude);

    if (userLocation != null) {
      final distanceInMeters = Geolocator.distanceBetween(
        userLocation!.latitude,
        userLocation!.longitude,
        newLocation.latitude,
        newLocation.longitude,
      );

      if (distanceInMeters > 5 && distanceInMeters < 1000) {
        await GameStateService.addDistance(distanceInMeters / 1000);
      }
    }

    setState(() {
      previousUserLocation = userLocation;
      userLocation = newLocation;
      locationAccuracy = position.accuracy;
    });
  }

  void _startLocationTracking() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position position) async {
            final newLocation = LatLng(position.latitude, position.longitude);

            if (userLocation != null) {
              final distanceInMeters = Geolocator.distanceBetween(
                userLocation!.latitude,
                userLocation!.longitude,
                newLocation.latitude,
                newLocation.longitude,
              );

              if (distanceInMeters > 5 && distanceInMeters < 1000) {
                await GameStateService.addDistance(distanceInMeters / 1000);
              }
            }

            setState(() {
              previousUserLocation = userLocation;
              userLocation = newLocation;
              locationAccuracy = position.accuracy;
            });
          },
        );
  }

  @override
  void dispose() {
    positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: userLocation ?? rigaOldTown,
            initialZoom: 16,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.urban_quest',
            ),

            MarkerLayer(
              markers: [
                ...puzzles.map(
                  (puzzle) => Marker(
                    point: puzzle.location,
                    width: 60,
                    height: 60,
                    child: GestureDetector(
                      onTap: () {
                        if (GameStateService.isPuzzleSolved(puzzle.id)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Šī mīkla jau ir atrisināta.'),
                            ),
                          );
                          return;
                        }
                        if (userLocation == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Lietotāja atrašanās vieta nav noteikta.',
                              ),
                            ),
                          );
                          return;
                        }

                        if (locationAccuracy != null &&
                            locationAccuracy! > 100) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'GPS precizitāte ir pārāk zema. Pamēģini vēlreiz atklātākā vietā.',
                              ),
                            ),
                          );
                          return;
                        }

                        final distance = Geolocator.distanceBetween(
                          userLocation!.latitude,
                          userLocation!.longitude,
                          puzzle.location.latitude,
                          puzzle.location.longitude,
                        );

                        if (distance <= 200) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text(puzzle.title),
                                content: const Text(
                                  'Tu esi pietiekami tuvu, lai atrisinātu mīklu.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PuzzleScreen(puzzle: puzzle),
                                        ),
                                      ).then((_) {
                                        setState(() {});
                                      });
                                    },
                                    child: const Text('Sākt'),
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Tu esi pārāk tālu no mīklas (${distance.toStringAsFixed(0)} m)',
                              ),
                            ),
                          );
                        }
                      },
                      child: PuzzleMapMarker(
                        isSolved: GameStateService.isPuzzleSolved(puzzle.id),
                      ),
                    ),
                  ),
                ),

                if (userLocation != null)
                  Marker(
                    point: userLocation!,
                    width: 80,
                    height: 80,
                    child: const Icon(
                      Icons.my_location,
                      color: Colors.blue,
                      size: 40,
                    ),
                  ),
              ],
            ),
          ],
        ),

        Positioned(
          right: 20,
          bottom: 20,
          child: FloatingActionButton(
            backgroundColor: const Color(0xFF0050CC),
            foregroundColor: Colors.white,
            onPressed: _getUserLocation,
            child: const Icon(Icons.my_location),
          ),
        ),
        if (locationAccuracy != null)
          Positioned(
            left: 20,
            bottom: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                'GPS ±${locationAccuracy!.toStringAsFixed(0)} m',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
      ],
    );
  }
}
