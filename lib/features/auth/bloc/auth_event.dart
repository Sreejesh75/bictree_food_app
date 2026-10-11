import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check secure storage & auto-login on startup
class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}

/// User submits login form
class LoginSubmittedEvent extends AuthEvent {
  final String usernameOrEmail;
  final String password;

  const LoginSubmittedEvent({
    required this.usernameOrEmail,
    required this.password,
  });

  @override
  List<Object?> get props => [usernameOrEmail, password];
}

/// User submits sign up form
class SignUpSubmittedEvent extends AuthEvent {
  final String fullName;
  final String email;
  final String mobileNumber;
  final String password;
  final String dateOfBirth;

  const SignUpSubmittedEvent({
    required this.fullName,
    required this.email,
    required this.mobileNumber,
    required this.password,
    required this.dateOfBirth,
  });

  @override
  List<Object?> get props => [fullName, email, mobileNumber, password, dateOfBirth];
}

/// User requests logout or received 401
class LogoutRequestedEvent extends AuthEvent {
  const LogoutRequestedEvent();
}
