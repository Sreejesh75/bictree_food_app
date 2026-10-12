import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';
import '../storage/secure_storage_service.dart';
import 'auth_interceptor.dart';

/// Centralized Dio networking factory with custom configuration and AuthInterceptor.
class DioClient {
  DioClient._();

  /// Creates a configured [Dio] instance with standard timeouts, base URL,
  /// and the [AuthInterceptor] attached.
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
