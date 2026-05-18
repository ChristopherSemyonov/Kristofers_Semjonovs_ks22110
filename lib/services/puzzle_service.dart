import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../models/puzzle.dart';
import 'api_config.dart';

class PuzzleService {
  static Future<List<Puzzle>> fetchPuzzlesFromBackend() async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/puzzles'));

    if (response.statusCode != 200) {
      throw Exception('Failed to load puzzles');
    }

    final List<dynamic> data = jsonDecode(response.body);

    return data.map((item) => Puzzle.fromJson(item)).toList();
  }

  static List<Puzzle> getDemoPuzzles() {
    return const [
      Puzzle(
        id: 'puzzle_1',
        title: 'Vecrīgas sirds',
        question:
            'Kā sauc Rīgas vēsturisko centru, kas ir iekļauts UNESCO pasaules mantojuma sarakstā?',
        answer: 'vecrīga',
        points: 250,
        difficulty: 'HARD',
        location: LatLng(56.9496, 24.1052),
      ),
      Puzzle(
        id: 'puzzle_2',
        title: 'Doma laukums',
        question: 'Kā sauc vienu no lielākajiem laukumiem Vecrīgā?',
        answer: 'doma laukums',
        points: 120,
        difficulty: 'MEDIUM',
        location: LatLng(56.9491, 24.1040),
      ),
      Puzzle(
        id: 'puzzle_3',
        title: 'Daugavas tuvumā',
        question: 'Pie kuras upes atrodas Rīga?',
        answer: 'daugava',
        points: 150,
        difficulty: 'EASY',
        location: LatLng(56.9478, 24.1016),
      ),
      Puzzle(
        id: 'puzzle_4',
        title: 'Brīvības simbols',
        question:
            'Kā sauc pieminekli Rīgas centrā, kas simbolizē Latvijas brīvību?',
        answer: 'brīvības piemineklis',
        points: 200,
        difficulty: 'MEDIUM',
        location: LatLng(56.9515, 24.1132),
      ),
      Puzzle(
        id: 'puzzle_5',
        title: 'Pulvertornis',
        question: 'Kā sauc torni, kurā atrodas Latvijas Kara muzejs?',
        answer: 'pulvertornis',
        points: 180,
        difficulty: 'MEDIUM',
        location: LatLng(56.9507, 24.1084),
      ),
      Puzzle(
        id: 'puzzle_6',
        title: 'Melngalvju nams',
        question: 'Kā sauc slaveno vēsturisko ēku Rātslaukumā?',
        answer: 'melngalvju nams',
        points: 220,
        difficulty: 'HARD',
        location: LatLng(56.9475, 24.1068),
      ),
      Puzzle(
        id: 'puzzle_7',
        title: 'Rīgas pils',
        question:
            'Kā sauc pili pie Daugavas, kas saistīta ar Latvijas Valsts prezidentu?',
        answer: 'rīgas pils',
        points: 200,
        difficulty: 'MEDIUM',
        location: LatLng(56.9510, 24.1009),
      ),
      Puzzle(
        id: 'puzzle_8',
        title: 'Bastejkalns',
        question:
            'Kā sauc parku pie pilsētas kanāla netālu no Brīvības pieminekļa?',
        answer: 'bastejkalns',
        points: 140,
        difficulty: 'EASY',
        location: LatLng(56.9522, 24.1098),
      ),
      Puzzle(
        id: 'puzzle_9',
        title: 'Līvu laukums',
        question:
            'Kā sauc populāru laukumu Vecrīgā ar kafejnīcām un vēsturisku apbūvi?',
        answer: 'līvu laukums',
        points: 130,
        difficulty: 'EASY',
        location: LatLng(56.9492, 24.1091),
      ),
      Puzzle(
        id: 'puzzle_10',
        title: 'Operas tuvumā',
        question: 'Kā sauc Latvijas galveno operas un baleta ēku?',
        answer: 'latvijas nacionālā opera',
        points: 180,
        difficulty: 'MEDIUM',
        location: LatLng(56.9501, 24.1153),
      ),
      Puzzle(
        id: 'puzzle_11',
        title: 'Centrāltirgus',
        question:
            'Kā sauc lielo tirgu Rīgā, kas izvietots vēsturiskajos paviljonos?',
        answer: 'centrāltirgus',
        points: 160,
        difficulty: 'EASY',
        location: LatLng(56.9447, 24.1146),
      ),
      Puzzle(
        id: 'puzzle_12',
        title: 'Trīs brāļi',
        question: 'Kā sauc trīs vēsturisko ēku grupu Mazajā Pils ielā?',
        answer: 'trīs brāļi',
        points: 190,
        difficulty: 'MEDIUM',
        location: LatLng(56.9504, 24.1032),
      ),
    ];
  }

  static bool isAnswerCorrect({
    required Puzzle puzzle,
    required String userAnswer,
  }) {
    String normalize(String value) {
      return value
          .trim()
          .toLowerCase()
          .replaceAll('ā', 'a')
          .replaceAll('ē', 'e')
          .replaceAll('ī', 'i')
          .replaceAll('ū', 'u')
          .replaceAll('ģ', 'g')
          .replaceAll('ķ', 'k')
          .replaceAll('ļ', 'l')
          .replaceAll('ņ', 'n')
          .replaceAll('š', 's')
          .replaceAll('č', 'c')
          .replaceAll('ž', 'z');
    }

    return normalize(userAnswer) == normalize(puzzle.answer);
  }

  static Future<Map<String, dynamic>> checkAnswerWithBackend({
    required String puzzleId,
    required String answer,
    required double latitude,
    required double longitude,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/puzzles/$puzzleId/check-answer'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'answer': answer,
        'latitude': latitude,
        'longitude': longitude,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to check answer');
    }

    return jsonDecode(response.body);
  }
}
