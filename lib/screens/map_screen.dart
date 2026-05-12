import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../models/puzzle.dart';
import '../services/puzzle_service.dart';
import '../services/game_state_service.dart';
import '../widgets/puzzle_map_marker.dart';

import 'puzzle_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? userLocation;

  final List<Puzzle> puzzles = PuzzleService.getDemoPuzzles();

  static const LatLng rigaOldTown = LatLng(56.9496, 24.1052);

  @override
  void initState() {
    super.initState();
    _getUserLocation();
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

    setState(() {
      userLocation = LatLng(position.latitude, position.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    final solvedPuzzles = PuzzleService.getDemoPuzzles()
        .where((puzzle) => GameStateService.isPuzzleSolved(puzzle.id))
        .toList();
    return FlutterMap(
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
    );
  }
}
