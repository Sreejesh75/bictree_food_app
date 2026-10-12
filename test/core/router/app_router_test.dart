import 'package:flutter_test/flutter_test.dart';
import 'package:bictree_food_app/core/router/app_router.dart';
import 'package:bictree_food_app/features/auth/bloc/auth_bloc.dart';
import 'package:bictree_food_app/features/auth/bloc/auth_state.dart';
import 'package:bictree_food_app/features/auth/models/auth_user.dart';
import 'package:bictree_food_app/features/auth/repository/auth_repository.dart';
import 'package:bictree_food_app/core/storage/secure_storage_service.dart';

class _FakeStorageService extends SecureStorageService {
  @override
  Future<String?> getAccessToken() async => null;
  @override
  Future<String?> getUserData() async => null;
  @override
  Future<List<Map<String, dynamic>>> getRegisteredUsers() async => [];
}

class _FakeAuthRepository extends AuthRepository {
  _FakeAuthRepository() : super(storageService: _FakeStorageService());

  @override
  Future<AuthUser?> autoLogin() async => null;
}

void main() {
  group('GoRouter & AppRouter Tests', () {
    late AuthBloc authBloc;

    setUp(() {
      authBloc = AuthBloc(repository: _FakeAuthRepository());
    });

    tearDown(() {
      authBloc.close();
    });

    test('1. Route constants are well-defined', () {
      expect(AppRoutes.login, equals('/login'));
      expect(AppRoutes.signup, equals('/signup'));
      expect(AppRoutes.home, equals('/home'));
      expect(AppRoutes.recipeDetail, equals('/recipe-detail'));
      expect(AppRoutes.cart, equals('/cart'));
      expect(AppRoutes.favorites, equals('/favorites'));
    });

    test('2. Router is initialized with initial route /login', () {
      final router = createRouter(authBloc);
      expect(
        router.routeInformationProvider.value.uri.toString(),
        equals('/login'),
      );
      router.dispose();
    });

    test(
      '3. Redirect guard logic redirects unauthenticated user to /login',
      () {
        final router = createRouter(authBloc);
        authBloc.emit(const UnauthenticatedState());

        expect(
          router.routeInformationProvider.value.uri.toString(),
          equals('/login'),
        );
        router.dispose();
      },
    );
  });
}
