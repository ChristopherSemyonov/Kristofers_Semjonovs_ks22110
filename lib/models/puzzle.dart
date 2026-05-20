import 'package:latlong2/latlong.dart';

class Puzzle {
  final String id;
  final String title;
  final String question;
  final String answer;
  final List<String> options;
  final int points;
  final String difficulty;
  final LatLng location;

  const Puzzle({
    required this.id,
    required this.title,
    required this.question,
    required this.answer,
    required this.options,
    required this.points,
    required this.difficulty,
    required this.location,
  });

  factory Puzzle.fromJson(Map<String, dynamic> json) {
    return Puzzle(
      id: json['id'],
      title: json['title'],
      question: json['question'],
      answer: json['answer'],
      options: json['options'] != null
          ? List<String>.from(json['options'])
          : [],
      points: json['points'],
      difficulty: json['difficulty'],
      location: LatLng(
        (json['latitude'] as num).toDouble(),
        (json['longitude'] as num).toDouble(),
      ),
    );
  }
}
