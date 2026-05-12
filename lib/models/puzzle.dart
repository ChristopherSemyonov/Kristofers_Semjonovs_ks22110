import 'package:latlong2/latlong.dart';

class Puzzle {
  final String id;
  final String title;
  final String question;
  final String answer;
  final int points;
  final String difficulty;
  final LatLng location;

  const Puzzle({
    required this.id,
    required this.title,
    required this.question,
    required this.answer,
    required this.points,
    required this.difficulty,
    required this.location,
  });
}
