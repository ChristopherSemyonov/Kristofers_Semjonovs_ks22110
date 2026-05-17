import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../models/puzzle.dart';
import '../services/puzzle_service.dart';
import '../services/game_state_service.dart';
import '../services/user_api_service.dart';
import '../widgets/puzzle_map_marker.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_compass/flutter_compass.dart';
import '../services/location_tracking_service.dart';

import 'puzzle_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? userLocation;
  final MapController mapController = MapController();
  StreamSubscription<CompassEvent>? compassStream;
  double userHeading = 0;
  bool hasCenteredOnUser = false;

  List<Puzzle> puzzles = [];
  bool isLoadingPuzzles = true;
  String? puzzleLoadingError;

  static const LatLng rigaOldTown = LatLng(56.9496, 24.1052);

  @override
  void initState() {
    super.initState();
    _loadPuzzles();
    _listenToLocationUpdates();
    _startCompassTracking();
  }

  void _startCompassTracking() {
    compassStream = FlutterCompass.events?.listen((CompassEvent event) {
      final heading = event.heading;

      if (heading == null) {
        return;
      }

      setState(() {
        userHeading = heading;
      });
    });
  }

  @override
  void dispose() {
    compassStream?.cancel();
    super.dispose();
  }

  void _showPuzzleBottomSheet({
    required Puzzle puzzle,
    required double distance,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isSolved = GameStateService.isPuzzleSolved(puzzle.id);

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                puzzle.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Distance: ${distance.toStringAsFixed(0)} m',
                style: const TextStyle(
                  color: Color(0xFF5C4037),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Chip(label: Text(puzzle.difficulty)),
                  const SizedBox(width: 8),
                  Chip(label: Text('${puzzle.points} R')),
                  const SizedBox(width: 8),
                  Chip(label: Text(isSolved ? 'SOLVED' : 'UNSOLVED')),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isSolved
                      ? null
                      : () {
                          Navigator.pop(context);

                          if (distance <= 80) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PuzzleScreen(puzzle: puzzle),
                              ),
                            ).then((_) {
                              setState(() {});
                            });
                          } else {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Tu esi pārāk tālu no mīklas (${distance.toStringAsFixed(0)} m)',
                                ),
                              ),
                            );
                          }
                        },
                  child: Text(
                    isSolved ? 'Already solved' : 'Start puzzle',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _centerMapOnUser() {
    if (userLocation == null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lietotāja atrašanās vieta vēl nav noteikta.'),
        ),
      );
      return;
    }

    mapController.move(userLocation!, 16);
  }

  Future<void> _loadPuzzles() async {
    try {
      final loadedPuzzles = await PuzzleService.fetchPuzzlesFromBackend();

      setState(() {
        puzzles = loadedPuzzles;
        isLoadingPuzzles = false;
        puzzleLoadingError = null;
      });
    } catch (error) {
      setState(() {
        isLoadingPuzzles = false;
        puzzleLoadingError = 'Neizdevās ielādēt mīklas no servera.';
      });
    }
  }

  void _listenToLocationUpdates() {
    userLocation = LocationTrackingService.currentLocation;

    LocationTrackingService.locationStream.listen((location) {
      if (!mounted) return;

      setState(() {
        userLocation = location;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
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
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Šī mīkla jau ir atrisināta.'),
                            ),
                          );
                          return;
                        }
                        if (userLocation == null) {
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Lietotāja atrašanās vieta nav noteikta.',
                              ),
                            ),
                          );
                          return;
                        }

                        if (LocationTrackingService.locationAccuracy != null &&
                            LocationTrackingService.locationAccuracy! > 100) {
                          ScaffoldMessenger.of(context).clearSnackBars();
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

                        if (distance <= 80) {
                          _showPuzzleBottomSheet(
                            puzzle: puzzle,
                            distance: distance,
                          );
                        } else {
                          ScaffoldMessenger.of(context).clearSnackBars();
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
                    alignment: Alignment.center,
                    child: IgnorePointer(
                      child: SizedBox(
                        width: 80,
                        height: 80,
                        child: Center(
                          child: Transform.rotate(
                            angle: userHeading * (math.pi / 180),
                            alignment: Alignment.center,
                            child: const Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  Icons.navigation,
                                  color: Colors.white,
                                  size: 54,
                                ),
                                Icon(
                                  Icons.navigation,
                                  color: Colors.blue,
                                  size: 42,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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
            onPressed: () async {
              await LocationTrackingService.refreshLocation();
              _centerMapOnUser();
            },
            child: const Icon(Icons.my_location),
          ),
        ),
        if (LocationTrackingService.locationAccuracy != null)
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
                'GPS ±${LocationTrackingService.locationAccuracy!.toStringAsFixed(0)} m',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.black, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundColor: Color(0xFFE0E3E1),
                  child: Icon(Icons.person, color: Color(0xFF5C4037)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    GameStateService.userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0266FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '${GameStateService.totalScore} R',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isLoadingPuzzles)
          const Positioned(
            left: 20,
            right: 20,
            bottom: 90,
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Mīklas tiek ielādētas...'),
              ),
            ),
          ),

        if (puzzleLoadingError != null)
          Positioned(
            left: 20,
            right: 20,
            bottom: 90,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(puzzleLoadingError!),
              ),
            ),
          ),
      ],
    );
  }
}
