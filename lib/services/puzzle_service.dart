import 'dart:convert';
import 'package:http/http.dart' as http;

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
