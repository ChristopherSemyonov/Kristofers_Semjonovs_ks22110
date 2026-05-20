import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'auth_service.dart';

class PuzzleImageService {
  static Future<Map<String, dynamic>> uploadPuzzleImage({
    required String puzzleId,
    required File imageFile,
  }) async {
    final token = await AuthService.getToken();

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConfig.baseUrl}/puzzles/$puzzleId/image'),
    );

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.files.add(
      await http.MultipartFile.fromPath('puzzleImage', imageFile.path),
    );

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception(responseBody);
    }

    return jsonDecode(responseBody);
  }
}
