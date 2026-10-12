import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final SecureStorageService storageService;
  final Dio dio;

  AuthRepositoryImpl({
    SecureStorageService? storageService,
    Dio? dio,
    AuthRemoteDataSource? remoteDataSource,
    AuthLocalDataSource? localDataSource,
    dynamic httpClient,
  }) : storageService = storageService ?? SecureStorageService(),
       dio = dio ?? DioClient.createDio(storageService: storageService),
       remoteDataSource =
           remoteDataSource ??
           AuthRemoteDataSourceImpl(
             dio: dio ?? DioClient.createDio(storageService: storageService),
           ),
       localDataSource =
           localDataSource ??
           AuthLocalDataSourceImpl(
             storageService: storageService ?? SecureStorageService(),
           );

  @override
  Future<AuthUser> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    final cleanInput = usernameOrEmail.trim().toLowerCase();
    final cleanPassword = password.trim();

    final localUsers = await localDataSource.getRegisteredUsers();
    final matchedLocal = localUsers.firstWhere((u) {
      final email = (u['email'] as String? ?? '').toLowerCase().trim();
      final username = (u['username'] as String? ?? '').toLowerCase().trim();
      final mobile = (u['mobileNumber'] as String? ?? '')
          .replaceAll(' ', '')
          .trim();
      final testInput = cleanInput.replaceAll(' ', '');
      return email == cleanInput ||
          username == cleanInput ||
          mobile == testInput;
    }, orElse: () => {});

    if (matchedLocal.isNotEmpty) {
      final savedPassword = matchedLocal['password'] as String? ?? '';
      if (savedPassword == cleanPassword) {
        final names = (matchedLocal['fullName'] as String? ?? 'User').split(
          ' ',
        );
        final user = AuthUser(
          id: matchedLocal['id'] is int ? matchedLocal['id'] as int : 1,
          username:
              matchedLocal['username'] as String? ??
              cleanInput.split('@').first,
          email: matchedLocal['email'] as String? ?? cleanInput,
          firstName: names.first,
          lastName: names.length > 1 ? names.sublist(1).join(' ') : '',
          accessToken: 'token_usr_${DateTime.now().millisecondsSinceEpoch}',
        );

        await localDataSource.saveTokens(accessToken: user.accessToken!);
        await localDataSource.saveUserData(jsonEncode(user.toJson()));
        return user;
      } else {
        throw Exception('Invalid password. Please try again.');
      }
    }

    final username = cleanInput.contains('@')
        ? cleanInput.split('@').first.replaceAll('.', '').toLowerCase()
        : cleanInput;

    try {
      final user = await remoteDataSource.login(
        username: username,
        password: cleanPassword,
      );

      if (user.accessToken != null) {
        await localDataSource.saveTokens(
          accessToken: user.accessToken!,
          refreshToken: user.refreshToken,
        );
      }
      await localDataSource.saveUserData(jsonEncode(user.toJson()));
      return user;
    } on DioException catch (dioErr) {
      String errorMessage = 'Invalid credentials';
      if (dioErr.response?.data is Map) {
        final msg = dioErr.response!.data['message'];
        if (msg != null) errorMessage = msg.toString();
      }
      throw Exception(errorMessage);
    } catch (e) {
      if (e.toString().contains('Invalid') ||
          e.toString().contains('credentials')) {
        rethrow;
      }
      throw Exception('Invalid username or password.');
    }
  }

  @override
  Future<AuthUser?> autoLogin() async {
    final token = await localDataSource.getAccessToken();
    if (token == null || token.isEmpty) {
      return null;
    }

    if (token.startsWith('token_usr_')) {
      return localDataSource.getCachedUserData();
    }

    try {
      final user = await remoteDataSource.getMe(token: token);
      if (user != null) {
        await localDataSource.saveUserData(jsonEncode(user.toJson()));
        return user;
      } else {
        return localDataSource.getCachedUserData();
      }
    } on DioException catch (dioErr) {
      if (dioErr.response?.statusCode == 401) {
        await logout();
        return null;
      }
      return localDataSource.getCachedUserData();
    } catch (_) {
      return localDataSource.getCachedUserData();
    }
  }

  @override
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

    await localDataSource.saveRegisteredUser({
      'id': userId,
      'fullName': fullName.trim(),
      'username': username,
      'email': email.trim(),
      'mobileNumber': mobileNumber.trim(),
      'dateOfBirth': dateOfBirth.trim(),
      'password': password.trim(),
    });

    await remoteDataSource.addUser(
      firstName: firstName,
      lastName: lastName,
      email: email.trim(),
    );

    final user = AuthUser(
      id: userId,
      username: username,
      email: email.trim(),
      firstName: firstName,
      lastName: lastName,
      accessToken: 'token_usr_${DateTime.now().millisecondsSinceEpoch}',
    );

    await localDataSource.saveTokens(accessToken: user.accessToken!);
    await localDataSource.saveUserData(jsonEncode(user.toJson()));

    return user;
  }

  @override
  Future<void> logout() async {
    await localDataSource.clearSession();
  }
}

class AuthRepository extends AuthRepositoryImpl {
  AuthRepository({
    super.storageService,
    super.dio,
    super.remoteDataSource,
    super.localDataSource,
    super.httpClient,
  });
}
