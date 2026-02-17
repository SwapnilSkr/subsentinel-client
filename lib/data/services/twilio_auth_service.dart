import 'package:flutter/foundation.dart';
import '../../data/repositories/auth_repository.dart';

class TwilioAuthService {
  final AuthRepository _repo = AuthRepository();

  /// Requests an OTP to be sent to the given phone number.
  /// Returns [true] if successful, throws an [Exception] otherwise.
  Future<bool> sendOtp(String phone) async {
    try {
      debugPrint('📲 Requesting OTP for: $phone');
      final result = await _repo.sendOtp(phone);
      if (result) {
        debugPrint('✅ OTP sent successfully');
      }
      return result;
    } catch (e) {
      debugPrint('❌ Failed to request OTP: $e');
      rethrow;
    }
  }

  /// Verifies the OTP code for the given phone number.
  /// Returns a [Map] containing the [AppUser] and [token] if successful.
  Future<Map<String, dynamic>> verifyOtp(String phone, String code) async {
    try {
      debugPrint('🔐 Verifying OTP $code for: $phone');
      final result = await _repo.verifyOtp(phone, code);
      debugPrint('✅ OTP verification successful');
      return result;
    } catch (e) {
      debugPrint('❌ OTP verification failed: $e');
      rethrow;
    }
  }
}
