import 'dart:convert';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/auth_user.dart';

abstract class AuthLocalDataSource {
  Future<String?> getAccessToken();
  Future<void> saveTokens({required String accessToken, String? refreshToken});
  Future<void> saveUserData(String userJson);
  Future<AuthUser?> getCachedUserData();
  Future<void> clearSession();
  Future<List<Map<String, dynamic>>> getRegisteredUsers();
  Future<void> saveRegisteredUser(Map<String, dynamic> userRecord);
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SecureStorageService storageService;

  AuthLocalDataSourceImpl({SecureStorageService? storageService})
    : storageService = storageService ?? SecureStorageService();

  @override
  Future<String?> getAccessToken() => storageService.getAccessToken();

  @override
  Future<void> saveTokens({required String accessToken, String? refreshToken}) {
    return storageService.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  @override
  Future<void> saveUserData(String userJson) =>
      storageService.saveUserData(userJson);

  @override
  Future<AuthUser?> getCachedUserData() async {
    final cached = await storageService.getUserData();
    if (cached != null && cached.isNotEmpty) {
      try {
        return AuthUser.fromJson(jsonDecode(cached) as Map<String, dynamic>);
      } catch (_) {}
    }
    return null;
  }

  @override
  Future<void> clearSession() => storageService.clearSession();

  @override
  Future<List<Map<String, dynamic>>> getRegisteredUsers() =>
      storageService.getRegisteredUsers();

  @override
  Future<void> saveRegisteredUser(Map<String, dynamic> userRecord) =>
      storageService.saveRegisteredUser(userRecord);
}
