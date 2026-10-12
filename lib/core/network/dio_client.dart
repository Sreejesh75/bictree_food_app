import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';
import '../storage/secure_storage_service.dart';
import 'auth_interceptor.dart';

class DioClient {
  DioClient._();

  static Dio createDio({
    SecureStorageService? storageService,
    String? baseUrl,
    void Function()? onUnauthorized,
  }) {
    final effectiveStorage = storageService ?? SecureStorageService();

    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      AuthInterceptor(
        storageService: effectiveStorage,
        onUnauthorized: onUnauthorized,
      ),
    );

    return dio;
  }
}
