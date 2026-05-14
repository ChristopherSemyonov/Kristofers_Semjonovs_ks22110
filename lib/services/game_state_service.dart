import 'package:shared_preferences/shared_preferences.dart';

class GameStateService {
  static int totalScore = 0;
  static double totalDistanceKm = 0.0;
  static final Set<String> solvedPuzzleIds = {};

  static const String _scoreKey = 'totalScore';
  static const String _solvedPuzzlesKey = 'solvedPuzzleIds';
  static const String _distanceKey = 'totalDistanceKm';

  static Future<void> loadGameState() async {
    final prefs = await SharedPreferences.getInstance();

    totalScore = prefs.getInt(_scoreKey) ?? 0;
    totalDistanceKm = prefs.getDouble(_distanceKey) ?? 0.0;

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
}
