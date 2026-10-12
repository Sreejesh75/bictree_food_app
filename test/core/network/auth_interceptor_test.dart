import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:bictree_food_app/core/network/auth_interceptor.dart';
import 'package:bictree_food_app/core/network/dio_client.dart';
import 'package:bictree_food_app/core/storage/secure_storage_service.dart';

class _MockStorageService extends SecureStorageService {
  String? token;

  _MockStorageService({this.token});

  @override
  Future<String?> getAccessToken() async => token;
}

class _FakeErrorHandler extends ErrorInterceptorHandler {
  DioException? receivedError;

  @override
  void next(DioException err) {
    receivedError = err;
  }
}

void main() {
  group('AuthInterceptor & DioClient Tests', () {
    test('1. Attaches Bearer token to request when token exists', () async {
      final mockStorage = _MockStorageService(token: 'valid_jwt_token_123');
      final interceptor = AuthInterceptor(storageService: mockStorage);

      final options = RequestOptions(path: '/recipes');
      final handler = RequestInterceptorHandler();

      await interceptor.onRequest(options, handler);

      expect(options.headers['Authorization'], equals('Bearer valid_jwt_token_123'));
      expect(options.headers['Content-Type'], equals('application/json'));
    });

    test('2. Does not attach local synthetic token (token_usr_)', () async {
      final mockStorage = _MockStorageService(token: 'token_usr_123456');
      final interceptor = AuthInterceptor(storageService: mockStorage);

      final options = RequestOptions(path: '/recipes');
      final handler = RequestInterceptorHandler();

      await interceptor.onRequest(options, handler);

      expect(options.headers.containsKey('Authorization'), isFalse);
    });

    test('3. Calls onUnauthorized callback on 401 response error', () {
      bool unauthorizedCalled = false;
      final mockStorage = _MockStorageService();
      final interceptor = AuthInterceptor(
        storageService: mockStorage,
        onUnauthorized: () {
          unauthorizedCalled = true;
        },
      );

      final dioError = DioException(
        requestOptions: RequestOptions(path: '/auth/me'),
        response: Response(
          requestOptions: RequestOptions(path: '/auth/me'),
          statusCode: 401,
        ),
      );

      final handler = _FakeErrorHandler();
      interceptor.onError(dioError, handler);

      expect(unauthorizedCalled, isTrue);
      expect(handler.receivedError, equals(dioError));
    });

    test('4. DioClient.createDio initializes Dio with BaseOptions and AuthInterceptor', () {
      final mockStorage = _MockStorageService();
      final dio = DioClient.createDio(storageService: mockStorage);

      expect(dio.options.connectTimeout, equals(const Duration(seconds: 15)));
      expect(dio.options.receiveTimeout, equals(const Duration(seconds: 15)));
      expect(
        dio.interceptors.any((i) => i is AuthInterceptor),
        isTrue,
      );
    });
  });
}
