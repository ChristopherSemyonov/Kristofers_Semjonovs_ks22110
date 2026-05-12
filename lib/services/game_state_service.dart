class GameStateService {
  static int totalScore = 0;
  static final Set<String> solvedPuzzleIds = {};

  static bool isPuzzleSolved(String puzzleId) {
    return solvedPuzzleIds.contains(puzzleId);
  }

  static void solvePuzzle({required String puzzleId, required int points}) {
    if (!solvedPuzzleIds.contains(puzzleId)) {
      solvedPuzzleIds.add(puzzleId);
      totalScore += points;
    }
  }
}
