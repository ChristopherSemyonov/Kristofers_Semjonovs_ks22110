import 'package:flutter/material.dart';

import '../models/puzzle.dart';
import '../services/game_state_service.dart';
import '../services/puzzle_service.dart';

class PuzzleScreen extends StatefulWidget {
  final Puzzle puzzle;

  const PuzzleScreen({super.key, required this.puzzle});

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  final TextEditingController _answerController = TextEditingController();

  void _checkAnswer() {
    final answer = _answerController.text.trim();

    if (PuzzleService.isAnswerCorrect(
      puzzle: widget.puzzle,
      userAnswer: answer,
    )) {
      GameStateService.solvePuzzle(
        puzzleId: widget.puzzle.id,
        points: widget.puzzle.points,
      );

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Pareizi!'),
            content: Text('Tu ieguvi ${widget.puzzle.points} punktus.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('Atgriezties kartē'),
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Atbilde nav pareiza. Mēģini vēlreiz.')),
      );
    }
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
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
      body: Padding(
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
            TextField(
              controller: _answerController,
              decoration: InputDecoration(
                labelText: 'Tava atbilde',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _checkAnswer,
                child: const Text(
                  'Iesniegt atbildi',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
