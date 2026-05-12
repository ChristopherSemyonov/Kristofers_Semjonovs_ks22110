import 'package:flutter/material.dart';

import '../services/game_state_service.dart';

class RankScreen extends StatelessWidget {
  const RankScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final players = [
      {
        'name': 'Urban Explorer',
        'score': GameStateService.totalScore,
        'isCurrentUser': true,
      },
      {'name': 'Map Master', 'score': 4980, 'isCurrentUser': false},
      {'name': 'Puzzle Hunter', 'score': 4720, 'isCurrentUser': false},
      {'name': 'City Runner', 'score': 4310, 'isCurrentUser': false},
    ];

    players.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: players.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final player = players[index];

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: player['isCurrentUser'] == true
                ? const Color(0xFFFFDBD0)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black, width: 2),
            boxShadow: const [
              BoxShadow(
                offset: Offset(3, 3),
                blurRadius: 0,
                color: Colors.black,
              ),
            ],
          ),
          child: Row(
            children: [
              Text(
                '${index + 1}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 16),
              const CircleAvatar(
                backgroundColor: Color(0xFFE0E3E1),
                child: Icon(Icons.person),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  player['name'].toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${player['score']} R',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFAA3000),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
