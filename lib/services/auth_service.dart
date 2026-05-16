import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();

  static const _tokenKey = 'jwt_token';

  static Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: _tokenKey);

    return token != null;
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode != 200) {
      throw Exception('Invalid email or password');
    }

    final data = jsonDecode(response.body);

    await _storage.write(key: _tokenKey, value: data['token']);

    return data;
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to register');
    }

    final data = jsonDecode(response.body);

    await _storage.write(key: _tokenKey, value: data['token']);

    return data;
  }
}
