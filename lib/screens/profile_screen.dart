import 'package:flutter/material.dart';
import '../widgets/statistic_card.dart';
import '../widgets/score_card.dart';
import '../widgets/completed_puzzle_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
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

          const Text(
            'Urban Explorer',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
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

          const ScoreCard(),

          const SizedBox(height: 16),

          Row(
            children: const [
              Expanded(
                child: StatisticCard(
                  title: 'SOLVED',
                  value: '142',
                  subtitle: 'Puzzles',
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: StatisticCard(
                  title: 'DISTANCE',
                  value: '86.4',
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

          const CompletedPuzzleCard(
            title: 'The Hidden Clock Tower',
            difficulty: 'HARD',
            points: '250 R',
          ),

          const SizedBox(height: 12),

          const CompletedPuzzleCard(
            title: 'Neon Alley Pursuit',
            difficulty: 'MEDIUM',
            points: '120 R',
          ),
        ],
      ),
    );
  }
}
