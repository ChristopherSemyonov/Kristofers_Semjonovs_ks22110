import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_config.dart';

class UserApiService {
  static const String userId = 'user_1';

  static Future<void> createDefaultUser() async {
    await http.post(
      Uri.parse('${ApiConfig.baseUrl}/users'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': userId, 'name': 'Urban Explorer'}),
    );
  }

  static Future<void> markPuzzleAsSolved(String puzzleId) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/users/$userId/solved-puzzles'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'puzzle_id': puzzleId}),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to mark puzzle as solved');
    }
  }

  static Future<Map<String, dynamic>> fetchCurrentUser() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/users/$userId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch user');
    }

    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> fetchSolvedPuzzles() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/users/$userId/solved-puzzles'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch solved puzzles');
    }

    return jsonDecode(response.body);
  }
}
