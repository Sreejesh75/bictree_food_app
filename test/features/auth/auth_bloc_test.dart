import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bictree_food_app/features/auth/bloc/auth_bloc.dart';
import 'package:bictree_food_app/features/auth/bloc/auth_event.dart';
import 'package:bictree_food_app/features/auth/bloc/auth_state.dart';
import 'package:bictree_food_app/features/auth/models/auth_user.dart';
import 'package:bictree_food_app/features/auth/repository/auth_repository.dart';
import 'package:bictree_food_app/core/storage/secure_storage_service.dart';

class MockSecureStorageService extends SecureStorageService {
  @override
  Future<String?> getAccessToken() async => null;
  @override
  Future<String?> getUserData() async => null;
  @override
  Future<void> saveTokens({required String accessToken, String? refreshToken}) async {}
  @override
  Future<void> saveUserData(String userJson) async {}
  @override
  Future<void> clearSession() async {}
  @override
  Future<List<Map<String, dynamic>>> getRegisteredUsers() async => [];
  @override
  Future<void> saveRegisteredUser(Map<String, dynamic> userRecord) async {}
}

class FakeAuthRepository extends AuthRepository {
  FakeAuthRepository() : super(storageService: MockSecureStorageService());

  AuthUser? currentUser;
  bool shouldThrow = false;

  @override
  Future<AuthUser?> autoLogin() async => currentUser;

  @override
  Future<AuthUser> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    if (shouldThrow) throw Exception('Invalid credentials');
    final user = AuthUser(
      id: 1,
      username: usernameOrEmail,
      email: '$usernameOrEmail@dummyjson.com',
      firstName: 'Emily',
      lastName: 'Johnson',
      accessToken: 'token_123',
    );
    currentUser = user;
    return user;
  }

  @override
  Future<AuthUser> signUp({
    required String fullName,
    required String email,
    required String mobileNumber,
    required String password,
    required String dateOfBirth,
  }) async {
    if (shouldThrow) throw Exception('Email already exists');
    final user = AuthUser(
      id: 2,
      username: email.split('@').first,
      email: email,
      firstName: fullName,
      lastName: '',
      accessToken: 'token_456',
    );
    currentUser = user;
    return user;
  }

  @override
  Future<void> logout() async {
    currentUser = null;
  }
}

void main() {
  group('AuthBloc Tests', () {
    late FakeAuthRepository fakeRepo;
    late AuthBloc authBloc;

    setUp(() {
      fakeRepo = FakeAuthRepository();
      authBloc = AuthBloc(repository: fakeRepo);
    });

    tearDown(() {
      authBloc.close();
    });

    test('initial state is AuthInitialState', () {
      expect(authBloc.state, const AuthInitialState());
    });

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoadingState, AuthenticatedState] when LoginSubmittedEvent succeeds',
      build: () => authBloc,
      act: (bloc) => bloc.add(const LoginSubmittedEvent(
        usernameOrEmail: 'emilys',
        password: 'emilyspass',
      )),
      expect: () => [
        const AuthLoadingState(),
        const AuthenticatedState(
          user: AuthUser(
            id: 1,
            username: 'emilys',
            email: 'emilys@dummyjson.com',
            firstName: 'Emily',
            lastName: 'Johnson',
            accessToken: 'token_123',
          ),
          successMessage: 'Welcome back, Emily!',
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoadingState, AuthErrorState] when LoginSubmittedEvent fails',
      build: () {
        fakeRepo.shouldThrow = true;
        return authBloc;
      },
      act: (bloc) => bloc.add(const LoginSubmittedEvent(
        usernameOrEmail: 'wrong',
        password: 'wrong',
      )),
      expect: () => [
        const AuthLoadingState(),
        const AuthErrorState('Invalid credentials'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoadingState, UnauthenticatedState] on LogoutRequestedEvent',
      build: () => authBloc,
      act: (bloc) => bloc.add(const LogoutRequestedEvent()),
      expect: () => [
        const AuthLoadingState(),
        const UnauthenticatedState(),
      ],
    );
  });
}
