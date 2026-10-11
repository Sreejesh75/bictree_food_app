import 'package:flutter_test/flutter_test.dart';
import 'package:bictree_food_app/main.dart';
import 'package:bictree_food_app/features/auth/repository/auth_repository.dart';
import 'package:bictree_food_app/features/auth/models/auth_user.dart';
import 'package:bictree_food_app/core/storage/secure_storage_service.dart';
import 'package:bictree_food_app/core/constants/app_strings.dart';

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

  @override
  Future<AuthUser?> autoLogin() async => null;

  @override
  Future<AuthUser> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    return const AuthUser(
      id: 1,
      username: 'emilys',
      email: 'emily.johnson@x.dummyjson.com',
      firstName: 'Emily',
      lastName: 'Johnson',
      accessToken: 'test_token',
    );
  }

  @override
  Future<void> logout() async {}
}

void main() {
  testWidgets('Renders LoginScreen with expected form fields', (WidgetTester tester) async {
    final fakeRepo = FakeAuthRepository();

    await tester.pumpWidget(BictreeFoodApp(authRepository: fakeRepo));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.logIn), findsWidgets);
    expect(find.text(AppStrings.welcome), findsOneWidget);
    expect(find.text(AppStrings.emailOrMobileLabel), findsOneWidget);
    expect(find.text(AppStrings.passwordLabel), findsOneWidget);
    expect(find.text(AppStrings.forgetPassword), findsOneWidget);
  });
}
