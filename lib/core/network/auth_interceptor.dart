import 'package:dio/dio.dart';
import '../storage/secure_storage_service.dart';

/// Interceptor that automatically attaches Bearer tokens from [SecureStorageService]
/// to outgoing requests and handles unauthorized (401) responses.
class AuthInterceptor extends QueuedInterceptor {
  final SecureStorageService storageService;
  final void Function()? onUnauthorized;

  AuthInterceptor({
    required this.storageService,
    this.onUnauthorized,
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Standard application headers
    options.headers['Content-Type'] ??= 'application/json';
    options.headers['Accept'] ??= 'application/json';

    // If Authorization header is not already explicitly set
    if (!options.headers.containsKey('Authorization')) {
      final token = await storageService.getAccessToken();
      if (token != null && token.isNotEmpty && !token.startsWith('token_usr_')) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      onUnauthorized?.call();
    }
    return handler.next(err);
  }
}
