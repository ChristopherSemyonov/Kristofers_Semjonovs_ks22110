import 'package:flutter/material.dart';

import '../services/game_state_service.dart';
import '../services/leaderboard_api_service.dart';
import '../services/api_config.dart';

class RankScreen extends StatefulWidget {
  const RankScreen({super.key});

  @override
  State<RankScreen> createState() => _RankScreenState();
}

class _RankScreenState extends State<RankScreen> {
  List<dynamic> players = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    try {
      final leaderboard = await LeaderboardApiService.fetchLeaderboard();

      if (!mounted) return;

      setState(() {
        players = leaderboard;
        isLoading = false;
        errorMessage = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Neizdevās ielādēt līderu sarakstu.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(child: Text(errorMessage!));
    }

    if (players.isEmpty) {
      return const Center(child: Text('Līderu saraksts vēl ir tukšs.'));
    }

    return RefreshIndicator(
      onRefresh: _loadLeaderboard,
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: players.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final player = players[index];

          final isCurrentUser = player['name'] == GameStateService.userName;

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isCurrentUser ? const Color(0xFFFFDBD0) : Colors.white,
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
                CircleAvatar(
                  backgroundColor: const Color(0xFFE0E3E1),
                  backgroundImage: player['profile_image_url'] != null
                      ? NetworkImage(
                          '${ApiConfig.baseUrl}${player['profile_image_url']}',
                        )
                      : null,
                  child: player['profile_image_url'] == null
                      ? const Icon(Icons.person)
                      : null,
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
                  '${player['total_score']} R',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFAA3000),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
