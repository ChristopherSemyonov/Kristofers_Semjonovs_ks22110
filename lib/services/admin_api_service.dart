import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'auth_service.dart';

class AdminApiService {
  static Future<Map<String, dynamic>> createPuzzle({
    required String id,
    required String title,
    required String question,
    required String answer,
    required int points,
    required String difficulty,
    required double latitude,
    required double longitude,
  }) async {
    final token = await AuthService.getToken();

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/puzzles'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'id': id,
        'title': title,
        'question': question,
        'answer': answer,
        'points': points,
        'difficulty': difficulty,
        'latitude': latitude,
        'longitude': longitude,
      }),
    );

    if (response.statusCode != 201) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Failed to create puzzle');
    }

    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> fetchPuzzles() async {
    final token = await AuthService.getToken();

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/puzzles/admin/all'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch admin puzzles');
    }

    return jsonDecode(response.body);
  }

  static Future<void> deletePuzzle(String puzzleId) async {
    final token = await AuthService.getToken();

    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/puzzles/$puzzleId'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Failed to delete puzzle');
    }
  }

  static Future<void> hidePuzzle(String puzzleId) async {
    final token = await AuthService.getToken();

    final response = await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/puzzles/$puzzleId/hide'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Failed to hide puzzle');
    }
  }

  static Future<void> unhidePuzzle(String puzzleId) async {
    final token = await AuthService.getToken();

    final response = await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/puzzles/$puzzleId/unhide'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Failed to restore puzzle');
    }
  }
}
