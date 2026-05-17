import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'api_config.dart';

class UserApiService {
  static Future<Map<String, String>> _authHeaders() async {
    final token = await AuthService.getToken();

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<void> updateCurrentUserDistance(double distanceKm) async {
    final response = await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/users/me'),
      headers: await _authHeaders(),
      body: jsonEncode({'total_distance_km': distanceKm}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update user distance');
    }
  }

  static Future<void> updateCurrentUserName(String name) async {
    final response = await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/users/me'),
      headers: await _authHeaders(),
      body: jsonEncode({'name': name}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update user name');
    }
  }

  static Future<void> markPuzzleAsSolved(String puzzleId) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/users/me/solved-puzzles'),
      headers: await _authHeaders(),
      body: jsonEncode({'puzzle_id': puzzleId}),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to mark puzzle as solved');
    }
  }

  static Future<Map<String, dynamic>> fetchCurrentUser() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/users/me'),
      headers: await _authHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch user');
    }

    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> fetchSolvedPuzzles() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/users/me/solved-puzzles'),
      headers: await _authHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch solved puzzles');
    }

    return jsonDecode(response.body);
  }
}
