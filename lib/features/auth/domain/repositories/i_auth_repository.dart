import '../entities/auth_user.dart';

abstract class IAuthRepository {
  Future<AuthUser> login({
    required String usernameOrEmail,
    required String password,
  });

  Future<AuthUser?> autoLogin();

  Future<AuthUser> signUp({
    required String fullName,
    required String email,
    required String mobileNumber,
    required String password,
    required String dateOfBirth,
  });

  Future<void> logout();
}
