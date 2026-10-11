import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_endpoints.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../models/auth_user.dart';

class AuthRepository {
  final SecureStorageService storageService;
  final http.Client httpClient;

  AuthRepository({
    required this.storageService,
    http.Client? httpClient,
  }) : httpClient = httpClient ?? http.Client();

  /// Login: Checks both local registered accounts and remote DummyJSON API
  Future<AuthUser> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    final cleanInput = usernameOrEmail.trim().toLowerCase();
    final cleanPassword = password.trim();

    // 1. First, check locally registered users (created via Sign Up screen)
    final localUsers = await storageService.getRegisteredUsers();
    final matchedLocal = localUsers.firstWhere(
      (u) {
        final email = (u['email'] as String? ?? '').toLowerCase().trim();
        final username = (u['username'] as String? ?? '').toLowerCase().trim();
        final mobile = (u['mobileNumber'] as String? ?? '').replaceAll(' ', '').trim();
        final testInput = cleanInput.replaceAll(' ', '');
        return email == cleanInput || username == cleanInput || mobile == testInput;
      },
      orElse: () => {},
    );

    if (matchedLocal.isNotEmpty) {
      final savedPassword = matchedLocal['password'] as String? ?? '';
      if (savedPassword == cleanPassword) {
        final names = (matchedLocal['fullName'] as String? ?? 'User').split(' ');
        final user = AuthUser(
          id: matchedLocal['id'] is int ? matchedLocal['id'] as int : 1,
          username: matchedLocal['username'] as String? ?? cleanInput.split('@').first,
          email: matchedLocal['email'] as String? ?? cleanInput,
          firstName: names.first,
          lastName: names.length > 1 ? names.sublist(1).join(' ') : '',
          accessToken: 'token_usr_${DateTime.now().millisecondsSinceEpoch}',
        );

        await storageService.saveTokens(accessToken: user.accessToken!);
        await storageService.saveUserData(jsonEncode(user.toJson()));
        return user;
      } else {
        throw Exception('Invalid password. Please try again.');
      }
    }

    // 2. If not found locally, authenticate against DummyJSON API (e.g. emilys / emilyspass)
    final username = cleanInput.contains('@')
        ? cleanInput.split('@').first.replaceAll('.', '').toLowerCase()
        : cleanInput;

    try {
      final url = Uri.parse(ApiEndpoints.login);
      final response = await httpClient.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': cleanPassword,
          'expiresInMins': 60,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final user = AuthUser.fromJson(data);

        if (user.accessToken != null) {
          await storageService.saveTokens(
            accessToken: user.accessToken!,
            refreshToken: user.refreshToken,
          );
        }
        await storageService.saveUserData(jsonEncode(user.toJson()));
        return user;
      } else {
        String errorMessage = 'Invalid credentials';
        try {
          final errData = jsonDecode(response.body);
          if (errData is Map && errData['message'] != null) {
            errorMessage = errData['message'].toString();
          }
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e.toString().contains('Invalid') || e.toString().contains('credentials')) {
        rethrow;
      }
      throw Exception('Invalid username or password.');
    }
  }

  /// Check token & auto-login on startup.
  /// If 401 Unauthorized is returned, logs out and returns null.
  Future<AuthUser?> autoLogin() async {
    final token = await storageService.getAccessToken();
    if (token == null || token.isEmpty) {
      return null;
    }

    // If local token
    if (token.startsWith('token_usr_')) {
      final cached = await storageService.getUserData();
      if (cached != null) {
        return AuthUser.fromJson(jsonDecode(cached) as Map<String, dynamic>);
      }
      return null;
    }

    try {
      final url = Uri.parse(ApiEndpoints.authMe);
      final response = await httpClient.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        data['accessToken'] = token;
        final user = AuthUser.fromJson(data);
        await storageService.saveUserData(jsonEncode(user.toJson()));
        return user;
      } else if (response.statusCode == 401) {
        await logout();
        return null;
      } else {
        final cached = await storageService.getUserData();
        if (cached != null) {
          return AuthUser.fromJson(jsonDecode(cached) as Map<String, dynamic>);
        }
        return null;
      }
    } catch (_) {
      final cached = await storageService.getUserData();
      if (cached != null) {
        return AuthUser.fromJson(jsonDecode(cached) as Map<String, dynamic>);
      }
      return null;
    }
  }

  /// Sign Up: Saves account locally for reliable future logins and hits DummyJSON
  Future<AuthUser> signUp({
    required String fullName,
    required String email,
    required String mobileNumber,
    required String password,
    required String dateOfBirth,
  }) async {
    final names = fullName.trim().split(' ');
    final firstName = names.isNotEmpty ? names.first : 'User';
    final lastName = names.length > 1 ? names.sublist(1).join(' ') : '';
    final username = email.trim().split('@').first;
    final userId = DateTime.now().millisecondsSinceEpoch % 100000;

    // 1. Save user in persistent storage so user can log in with this email & password anytime
    await storageService.saveRegisteredUser({
      'id': userId,
      'fullName': fullName.trim(),
      'username': username,
      'email': email.trim(),
      'mobileNumber': mobileNumber.trim(),
      'dateOfBirth': dateOfBirth.trim(),
      'password': password.trim(),
    });

    // 2. Also simulate DummyJSON users/add API call
    try {
      final url = Uri.parse(ApiEndpoints.usersAdd);
      await httpClient.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firstName': firstName,
          'lastName': lastName,
          'email': email.trim(),
          'age': 25,
        }),
      );
    } catch (_) {}

    final user = AuthUser(
      id: userId,
      username: username,
      email: email.trim(),
      firstName: firstName,
      lastName: lastName,
      accessToken: 'token_usr_${DateTime.now().millisecondsSinceEpoch}',
    );

    await storageService.saveTokens(accessToken: user.accessToken!);
    await storageService.saveUserData(jsonEncode(user.toJson()));

    return user;
  }

  /// Clear active session (preserves registered user list)
  Future<void> logout() async {
    await storageService.clearSession();
  }
}
