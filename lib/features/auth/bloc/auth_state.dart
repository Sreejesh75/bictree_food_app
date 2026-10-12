import 'package:equatable/equatable.dart';
import '../models/auth_user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitialState extends AuthState {
  const AuthInitialState();
}

class AuthLoadingState extends AuthState {
  const AuthLoadingState();
}

class AuthenticatedState extends AuthState {
  final AuthUser user;
  final String? successMessage;

  const AuthenticatedState({required this.user, this.successMessage});

  @override
  List<Object?> get props => [user, successMessage];
}

class UnauthenticatedState extends AuthState {
  const UnauthenticatedState();
}

class AuthErrorState extends AuthState {
  final String message;

  const AuthErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
