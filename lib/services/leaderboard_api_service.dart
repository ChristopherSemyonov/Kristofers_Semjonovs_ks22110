import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_config.dart';

class LeaderboardApiService {
  static Future<List<dynamic>> fetchLeaderboard() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/leaderboard'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch leaderboard');
    }

    return jsonDecode(response.body);
  }
}
