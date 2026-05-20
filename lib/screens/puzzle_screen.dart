import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../models/puzzle.dart';
import '../services/game_state_service.dart';
import '../services/puzzle_service.dart';
import '../services/user_api_service.dart';
import '../services/location_tracking_service.dart';
import '../services/game_rules_service.dart';

import 'dart:async';

class PuzzleScreen extends StatefulWidget {
  final Puzzle puzzle;

  const PuzzleScreen({super.key, required this.puzzle});

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  StreamSubscription<LatLng?>? locationSubscription;
  String? selectedAnswer;
  String? puzzleInfoMessage;

  Future<void> _checkAnswer(String answer) async {
    final currentLocation = LocationTrackingService.currentLocation;

    if (currentLocation == null) {
      _showPuzzleInfoMessage('Neizdevās noteikt tavu atrašanās vietu.');
      return;
    }

    final result = await PuzzleService.checkAnswerWithBackend(
      puzzleId: widget.puzzle.id,
      answer: answer,
      latitude: currentLocation.latitude,
      longitude: currentLocation.longitude,
    );

    if (!mounted) return;

    if (result['correct'] == true) {
      await UserApiService.markPuzzleAsSolved(widget.puzzle.id);

      final backendUser = await UserApiService.fetchCurrentUser();
      GameStateService.updateFromBackendUser(backendUser);

      final solvedPuzzles = await UserApiService.fetchSolvedPuzzles();
      GameStateService.loadSolvedPuzzlesFromBackend(solvedPuzzles);

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Pareizi!'),
            content: Text('Tu ieguvi ${widget.puzzle.points} punktus.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  Navigator.pop(context);
                },
                child: const Text('Atgriezties kartē'),
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Atbilde nav pareiza. Mēģini vēlreiz.')),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    locationSubscription = LocationTrackingService.locationStream.listen((
      location,
    ) {
      if (location == null) return;

      final distance = Geolocator.distanceBetween(
        location.latitude,
        location.longitude,
        widget.puzzle.location.latitude,
        widget.puzzle.location.longitude,
      );

      if (distance > GameRulesService.unlockRadiusMeters) {
        if (!mounted) return;

        Navigator.pop(context, 'left_puzzle_zone');
      }
    });
  }

  @override
  void dispose() {
    locationSubscription?.cancel();
    super.dispose();
  }

  void _showPuzzleInfoMessage(String message) {
    setState(() {
      puzzleInfoMessage = message;
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;

      setState(() {
        puzzleInfoMessage = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      appBar: AppBar(
        title: Text(
          widget.puzzle.title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: const Color(0xFFF7FAF8),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mīkla atbloķēta',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Atrodi atbildi uz jautājumu par šo vietu.',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 28),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.black, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        offset: Offset(4, 4),
                        blurRadius: 0,
                        color: Colors.black,
                      ),
                    ],
                  ),
                  child: Text(
                    widget.puzzle.question,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ...List<String>.from(widget.puzzle.options).map(
                  (option) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            selectedAnswer = option;
                          });

                          _checkAnswer(option);
                        },
                        child: Text(
                          option,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (puzzleInfoMessage != null)
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Colors.black, width: 2),
                ),
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    puzzleInfoMessage!,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
