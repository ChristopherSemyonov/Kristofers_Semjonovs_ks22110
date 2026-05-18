class GameRulesService {
  static const double unlockRadiusMeters = 50;

  static double remainingDistanceToUnlock(double distanceToCenterMeters) {
    final remaining = distanceToCenterMeters - unlockRadiusMeters;

    if (remaining < 0) {
      return 0;
    }

    return remaining;
  }
}
