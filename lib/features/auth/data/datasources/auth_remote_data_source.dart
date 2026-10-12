import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/auth_user.dart';

abstract class AuthRemoteDataSource {
  Future<AuthUser> login({required String username, required String password});

  Future<AuthUser?> getMe({required String token});

  Future<void> addUser({
    required String firstName,
    required String lastName,
    required String email,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({Dio? dio}) : dio = dio ?? DioClient.createDio();

  @override
  Future<AuthUser> login({
    required String username,
    required String password,
  }) async {
    final response = await dio.post(
      ApiEndpoints.login,
      data: {'username': username, 'password': password, 'expiresInMins': 60},
    );

    if (response.statusCode == 200) {
      final data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : jsonDecode(response.data.toString()) as Map<String, dynamic>;
      return AuthUser.fromJson(data);
    } else {
      throw Exception('Invalid credentials');
    }
  }

  @override
  Future<AuthUser?> getMe({required String token}) async {
    final response = await dio.get(
      ApiEndpoints.authMe,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.statusCode == 200) {
      final data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : jsonDecode(response.data.toString()) as Map<String, dynamic>;
      data['accessToken'] = token;
      return AuthUser.fromJson(data);
    }
    return null;
  }

  @override
  Future<void> addUser({
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    try {
      await dio.post(
        ApiEndpoints.usersAdd,
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'age': 25,
        },
      );
    } catch (_) {}
  }
}
