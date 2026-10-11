import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;
  SharedPreferences? _prefs;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const String _keyToken = 'auth_access_token';
  static const String _keyRefreshToken = 'auth_refresh_token';
  static const String _keyUserData = 'auth_user_data';
  static const String _keyRegisteredUsers = 'auth_registered_users_list';

  Future<SharedPreferences> _getPrefs() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  // --- Session Tokens ---

  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    try {
      await _storage.write(key: _keyToken, value: accessToken);
      if (refreshToken != null) {
        await _storage.write(key: _keyRefreshToken, value: refreshToken);
      }
    } catch (_) {
      final prefs = await _getPrefs();
      await prefs.setString(_keyToken, accessToken);
      if (refreshToken != null) {
        await prefs.setString(_keyRefreshToken, refreshToken);
      }
    }
  }

  Future<String?> getAccessToken() async {
    try {
      final token = await _storage.read(key: _keyToken);
      if (token != null) return token;
      final prefs = await _getPrefs();
      return prefs.getString(_keyToken);
    } catch (_) {
      final prefs = await _getPrefs();
      return prefs.getString(_keyToken);
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      final token = await _storage.read(key: _keyRefreshToken);
      if (token != null) return token;
      final prefs = await _getPrefs();
      return prefs.getString(_keyRefreshToken);
    } catch (_) {
      final prefs = await _getPrefs();
      return prefs.getString(_keyRefreshToken);
    }
  }

  // --- Current User Session ---

  Future<void> saveUserData(String userJson) async {
    try {
      await _storage.write(key: _keyUserData, value: userJson);
    } catch (_) {
      final prefs = await _getPrefs();
      await prefs.setString(_keyUserData, userJson);
    }
  }

  Future<String?> getUserData() async {
    try {
      final data = await _storage.read(key: _keyUserData);
      if (data != null) return data;
      final prefs = await _getPrefs();
      return prefs.getString(_keyUserData);
    } catch (_) {
      final prefs = await _getPrefs();
      return prefs.getString(_keyUserData);
    }
  }

  // --- Registered Users Persistence (survives logout) ---

  Future<List<Map<String, dynamic>>> getRegisteredUsers() async {
    String? jsonStr;
    try {
      jsonStr = await _storage.read(key: _keyRegisteredUsers);
    } catch (_) {}
    if (jsonStr == null) {
      final prefs = await _getPrefs();
      jsonStr = prefs.getString(_keyRegisteredUsers);
    }
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final decoded = jsonDecode(jsonStr) as List<dynamic>;
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveRegisteredUser(Map<String, dynamic> userRecord) async {
    final list = await getRegisteredUsers();
    // Remove if already existing with same email
    final cleanEmail = (userRecord['email'] as String? ?? '').toLowerCase().trim();
    list.removeWhere((item) => (item['email'] as String? ?? '').toLowerCase().trim() == cleanEmail);
    list.add(userRecord);

    final encoded = jsonEncode(list);
    try {
      await _storage.write(key: _keyRegisteredUsers, value: encoded);
    } catch (_) {}
    final prefs = await _getPrefs();
    await prefs.setString(_keyRegisteredUsers, encoded);
  }

  // --- Logout / Clear Session ---

  Future<void> clearSession() async {
    try {
      await _storage.delete(key: _keyToken);
      await _storage.delete(key: _keyRefreshToken);
      await _storage.delete(key: _keyUserData);
    } catch (_) {}
    try {
      final prefs = await _getPrefs();
      await prefs.remove(_keyToken);
      await prefs.remove(_keyRefreshToken);
      await prefs.remove(_keyUserData);
    } catch (_) {}
  }
}
