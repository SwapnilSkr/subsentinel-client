import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants.dart';
import '../models/user_model.dart';

class AuthRepository {
  String get baseUrl => AppConstants.apiBaseUrl;

  // Send OTP
  Future<bool> sendOtp(String phone) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/otp/send'),
        body: jsonEncode({'phone': phone}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to send OTP: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error sending OTP: $e');
    }
  }

  // Verify OTP
  Future<Map<String, dynamic>> verifyOtp(String phone, String code) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/otp/verify'),
        body: jsonEncode({'phone': phone, 'code': code}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final user = AppUser.fromJson(data['user']);
          final token = data['token'];
          return {'user': user, 'token': token};
        } else {
          throw Exception(data['error'] ?? 'Verification failed');
        }
      } else {
        throw Exception('Failed to verify OTP: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error verifying OTP: $e');
    }
  }

  // Google Login
  Future<Map<String, dynamic>> googleLogin(String idToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/google'),
        body: jsonEncode({'token': idToken}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final user = AppUser.fromJson(data['user']);
          final token = data['token'];
          return {'user': user, 'token': token};
        }
        throw Exception(data['error']);
      }
      throw Exception('Google Login Failed');
    } catch (e) {
      throw Exception('Error logging in with Google: $e');
    }
  }
}
