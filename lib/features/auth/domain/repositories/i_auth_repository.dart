import '../entities/auth_user.dart';

/// Abstract Domain Repository Contract defining all Authentication operations.
abstract class IAuthRepository {
  /// Authenticates a user against remote API or local credentials.
  Future<AuthUser> login({
    required String usernameOrEmail,
    required String password,
  });

  /// Automatically authenticates user from existing stored session if valid.
  Future<AuthUser?> autoLogin();

  /// Registers a new user account.
  Future<AuthUser> signUp({
    required String fullName,
    required String email,
    required String mobileNumber,
    required String password,
    required String dateOfBirth,
  });

  /// Terminates the current active session.
  Future<void> logout();
}
