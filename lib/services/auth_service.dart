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
      final data = jsonDecode(response.body);
      throw Exception(
        _friendlyAuthError(data['error'] ?? 'Invalid email or password'),
      );
    }

    final data = jsonDecode(response.body);

    await _storage.write(key: _tokenKey, value: data['token']);

    return data;
  }

  static String _friendlyAuthError(String backendMessage) {
    switch (backendMessage) {
      case 'Invalid email or password':
        return 'Nepareizs e-pasts vai parole.';
      case 'User with this email already exists':
        return 'Lietotājs ar šādu e-pastu jau eksistē.';
      case 'Name, email and password are required':
        return 'Lūdzu aizpildi visus laukus.';
      case 'Email and password are required':
        return 'Lūdzu ievadi e-pastu un paroli.';
      case 'Password must be at least 6 characters long':
        return 'Parolei jābūt vismaz 6 rakstzīmes garai.';
      default:
        return backendMessage;
    }
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
      final data = jsonDecode(response.body);
      throw Exception(
        _friendlyAuthError(data['error'] ?? 'Failed to register'),
      );
    }

    final data = jsonDecode(response.body);

    await _storage.write(key: _tokenKey, value: data['token']);

    return data;
  }
}
