import 'package:shared_preferences/shared_preferences.dart';

class GameStateService {
  static int totalScore = 0;
  static double totalDistanceKm = 0.0;
  static String userName = 'Urban Explorer';
  static final Set<String> solvedPuzzleIds = {};

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
    totalScore = user['total_score'] ?? totalScore;
    totalDistanceKm = (user['total_distance_km'] ?? totalDistanceKm).toDouble();
  }

  static void loadSolvedPuzzlesFromBackend(List<dynamic> solvedPuzzles) {
    solvedPuzzleIds.clear();

    solvedPuzzleIds.addAll(
      solvedPuzzles.map((puzzle) => puzzle['id'].toString()),
    );
  }
}
