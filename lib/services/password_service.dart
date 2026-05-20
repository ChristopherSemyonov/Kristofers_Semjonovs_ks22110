import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'auth_service.dart';

class PasswordService {
  static Future<void> requestPasswordChange() async {
    final token = await AuthService.getToken();

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/request-password-change'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Failed to request password change');
    }
  }

  static Future<void> confirmPasswordChange({
    required String code,
    required String newPassword,
  }) async {
    final token = await AuthService.getToken();

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/confirm-password-change'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'code': code, 'newPassword': newPassword}),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Failed to change password');
    }
  }

  static Future<void> requestForgotPassword({required String email}) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/forgot-password/request'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Failed to request password reset');
    }
  }

  static Future<void> confirmForgotPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/forgot-password/confirm'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'code': code,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Failed to reset password');
    }
  }
}
