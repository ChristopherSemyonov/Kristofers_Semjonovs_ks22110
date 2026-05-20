import 'package:shared_preferences/shared_preferences.dart';

class GameStateService {
  static int totalScore = 0;
  static double totalDistanceKm = 0.0;
  static String userName = 'Urban Explorer';
  static String userRole = 'user';
  static String? profileImageUrl;
  static final Set<String> solvedPuzzleIds = {};
  static List<dynamic> solvedPuzzles = [];

  static const String _scoreKey = 'totalScore';
  static const String _solvedPuzzlesKey = 'solvedPuzzleIds';
  static const String _distanceKey = 'totalDistanceKm';
  static const String _userNameKey = 'userName';

  static Future<void> loadGameState() async {
    final prefs = await SharedPreferences.getInstance();

    totalScore = prefs.getInt(_scoreKey) ?? 0;
    totalDistanceKm = prefs.getDouble(_distanceKey) ?? 0.0;
    userName = prefs.getString(_userNameKey) ?? 'Urban Explorer';

    final savedPuzzleIds = prefs.getStringList(_solvedPuzzlesKey) ?? [];
    solvedPuzzleIds
      ..clear()
      ..addAll(savedPuzzleIds);
  }

  static Future<void> saveGameState() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_scoreKey, totalScore);
    await prefs.setStringList(_solvedPuzzlesKey, solvedPuzzleIds.toList());
    await prefs.setDouble(_distanceKey, totalDistanceKm);
    await prefs.setString(_userNameKey, userName);
  }

  static bool isPuzzleSolved(String puzzleId) {
    return solvedPuzzleIds.contains(puzzleId);
  }

  static Future<void> solvePuzzle({
    required String puzzleId,
    required int points,
  }) async {
    if (!solvedPuzzleIds.contains(puzzleId)) {
      solvedPuzzleIds.add(puzzleId);
      totalScore += points;
      await saveGameState();
    }
  }

  static Future<void> addDistance(double distanceKm) async {
    if (distanceKm > 0) {
      totalDistanceKm += distanceKm;
      await saveGameState();
    }
  }

  static Future<void> resetProgress() async {
    totalScore = 0;
    totalDistanceKm = 0.0;
    solvedPuzzleIds.clear();
    solvedPuzzles.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_scoreKey);
    await prefs.remove(_distanceKey);
    await prefs.remove(_solvedPuzzlesKey);
  }

  static Future<void> updateUserName(String newName) async {
    final trimmedName = newName.trim();

    if (trimmedName.isNotEmpty) {
      userName = trimmedName;
      await saveGameState();
    }
  }

  static void updateFromBackendUser(Map<String, dynamic> user) {
    userName = user['name'] ?? userName;
    userRole = user['role'] ?? userRole;
    profileImageUrl = user['profile_image_url'];
    totalScore = user['total_score'] ?? totalScore;
    totalDistanceKm = (user['total_distance_km'] ?? totalDistanceKm).toDouble();
  }

  static void loadSolvedPuzzlesFromBackend(List<dynamic> puzzles) {
    solvedPuzzles = puzzles;

    solvedPuzzleIds.clear();

    solvedPuzzleIds.addAll(puzzles.map((puzzle) => puzzle['id'].toString()));
  }

  static void clearUserSessionData() {
    userName = 'Urban Explorer';
    userRole = 'user';
    profileImageUrl = null;
    totalScore = 0;
    totalDistanceKm = 0;
    solvedPuzzleIds.clear();
  }

  static String getPlayerTitle() {
    if (totalScore >= 5000) return 'Leģendārais ceļotājs';
    if (totalScore >= 3000) return 'Pilsētas meistars';
    if (totalScore >= 2000) return 'Noslēpumu meklētājs';
    if (totalScore >= 1000) return 'Pieredzējis ceļotājs';
    if (totalScore >= 500) return 'Uzmanīgais ceļotājs';
    if (totalScore >= 200) return 'Jaunais ceļotājs';

    return 'Iesācējs';
  }

  static int profileImageVersion = 0;

  static void refreshProfileImage() {
    profileImageVersion++;
  }

  static Map<String, dynamic> getNextTitleProgress() {
    final milestones = [
      {'score': 200, 'title': 'Jaunais orientierists'},
      {'score': 500, 'title': 'Uzmanīgais meklētājs'},
      {'score': 1000, 'title': 'Pieredzējis pētnieks'},
      {'score': 2000, 'title': 'Noslēpumu pēddzinis'},
      {'score': 3000, 'title': 'Pilsētas meistars'},
      {'score': 5000, 'title': 'Leģendārais ceļinieks'},
    ];

    for (final milestone in milestones) {
      final requiredScore = milestone['score'] as int;

      if (totalScore < requiredScore) {
        final previousScore = milestones
            .where((m) => (m['score'] as int) < requiredScore)
            .fold<int>(0, (prev, m) => m['score'] as int);

        final progress =
            (totalScore - previousScore) / (requiredScore - previousScore);

        return {
          'nextTitle': milestone['title'],
          'requiredScore': requiredScore,
          'previousScore': previousScore,
          'progress': progress.clamp(0.0, 1.0),
        };
      }
    }

    return {
      'nextTitle': 'Maksimālais rangs sasniegts',
      'requiredScore': totalScore,
      'previousScore': totalScore,
      'progress': 1.0,
    };
  }
}
