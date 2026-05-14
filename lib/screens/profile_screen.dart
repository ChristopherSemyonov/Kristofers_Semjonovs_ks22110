import 'package:flutter/material.dart';
import '../widgets/statistic_card.dart';
import '../widgets/score_card.dart';
import '../widgets/completed_puzzle_card.dart';
import '../services/game_state_service.dart';
import '../services/puzzle_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _showEditNameDialog(BuildContext context) {
    final controller = TextEditingController(text: GameStateService.userName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit profile name'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await GameStateService.updateUserName(controller.text);

                if (context.mounted) {
                  Navigator.pop(context);
                  setState(() {});
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final solvedPuzzles = PuzzleService.getDemoPuzzles()
        .where((puzzle) => GameStateService.isPuzzleSolved(puzzle.id))
        .toList();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 56,
            backgroundColor: Color(0xFFE0E3E1),
            child: Icon(Icons.person, size: 64, color: Color(0xFF5C4037)),
          ),

          const SizedBox(height: 16),

          Text(
            GameStateService.userName,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),

          TextButton(
            onPressed: () {
              _showEditNameDialog(context);
            },
            child: const Text('Edit name'),
          ),

          const SizedBox(height: 4),

          const Text(
            'ELITE NAVIGATOR',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: Color(0xFF5C4037),
            ),
          ),

          const SizedBox(height: 28),

          ScoreCard(score: GameStateService.totalScore),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: StatisticCard(
                  title: 'SOLVED',
                  value: GameStateService.solvedPuzzleIds.length.toString(),
                  subtitle: 'Puzzles',
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: StatisticCard(
                  title: 'DISTANCE',
                  value: GameStateService.totalDistanceKm.toStringAsFixed(2),
                  subtitle: 'Kilometers',
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Completed Puzzles',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
          ),

          const SizedBox(height: 12),

          if (solvedPuzzles.isEmpty)
            const Text(
              'Vēl nav atrisinātu mīklu.',
              style: TextStyle(color: Color(0xFF5C4037)),
            )
          else
            ...solvedPuzzles.map(
              (puzzle) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CompletedPuzzleCard(
                  title: puzzle.title,
                  difficulty: puzzle.difficulty,
                  points: '${puzzle.points} R',
                ),
              ),
            ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () async {
                await GameStateService.resetProgress();

                if (context.mounted) {
                  setState(() {});

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Progress ir atiestatīts.')),
                  );
                }
              },
              child: const Text(
                'Reset progress',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
