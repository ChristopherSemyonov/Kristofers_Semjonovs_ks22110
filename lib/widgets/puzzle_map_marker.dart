import 'package:flutter/material.dart';

class PuzzleMapMarker extends StatelessWidget {
  final bool isSolved;

  const PuzzleMapMarker({super.key, required this.isSolved});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: isSolved ? const Color(0xFF2E7D32) : const Color(0xFFD32F2F),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Icon(
        isSolved ? Icons.check : Icons.question_mark,
        color: Colors.white,
        size: 32,
      ),
    );
  }
}
