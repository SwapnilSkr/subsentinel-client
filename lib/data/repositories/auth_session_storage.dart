import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';

class AuthSessionStorage {
  static const _userDataKey = 'auth_user_data';
  static const _authTokenKey = 'auth_token';
  static const _userIdKey = 'auth_user_id';

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  Future<void> saveSession({
    required AppUser user,
    required String token,
  }) async {
    await Future.wait([
      _storage.write(key: _userDataKey, value: jsonEncode(user.toJson())),
      _storage.write(key: _authTokenKey, value: token),
      _storage.write(key: _userIdKey, value: user.id),
    ]);
  }

  Future<String?> readUserData() {
    return _storage.read(key: _userDataKey);
  }

  Future<String?> readAuthToken() {
    return _storage.read(key: _authTokenKey);
  }

  Future<String?> readUserId() {
    return _storage.read(key: _userIdKey);
  }

  Future<void> clearSession() async {
    await Future.wait([
      _storage.delete(key: _userDataKey),
      _storage.delete(key: _authTokenKey),
      _storage.delete(key: _userIdKey),
    ]);
  }
}
