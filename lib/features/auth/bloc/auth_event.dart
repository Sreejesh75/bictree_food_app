import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}

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
  List<Object?> get props => [
    fullName,
    email,
    mobileNumber,
    password,
    dateOfBirth,
  ];
}

class LogoutRequestedEvent extends AuthEvent {
  const LogoutRequestedEvent();
}
