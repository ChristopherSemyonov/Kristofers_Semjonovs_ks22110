import 'package:flutter/material.dart';

class ScoreCard extends StatelessWidget {
  final int score;

  const ScoreCard({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0266FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [
          BoxShadow(offset: Offset(4, 4), blurRadius: 0, color: Colors.black),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TOTAL SCORE',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$score R',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const Icon(Icons.stars, color: Colors.white, size: 52),
        ],
      ),
    );
  }
}
