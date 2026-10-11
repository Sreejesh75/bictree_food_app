import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;

  AuthBloc({required this.repository}) : super(const AuthInitialState()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LoginSubmittedEvent>(_onLoginSubmitted);
    on<SignUpSubmittedEvent>(_onSignUpSubmitted);
    on<LogoutRequestedEvent>(_onLogoutRequested);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());
    try {
      final user = await repository.autoLogin();
      if (user != null) {
        emit(AuthenticatedState(user: user));
      } else {
        emit(const UnauthenticatedState());
      }
    } catch (_) {
      emit(const UnauthenticatedState());
    }
  }

  Future<void> _onLoginSubmitted(
    LoginSubmittedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());
    try {
      final user = await repository.login(
        usernameOrEmail: event.usernameOrEmail,
        password: event.password,
      );
      emit(AuthenticatedState(
        user: user,
        successMessage: 'Welcome back, ${user.firstName}!',
      ));
    } catch (e) {
      emit(AuthErrorState(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onSignUpSubmitted(
    SignUpSubmittedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());
    try {
      final user = await repository.signUp(
        fullName: event.fullName,
        email: event.email,
        mobileNumber: event.mobileNumber,
        password: event.password,
        dateOfBirth: event.dateOfBirth,
      );
      emit(AuthenticatedState(
        user: user,
        successMessage: 'Account created successfully!',
      ));
    } catch (e) {
      emit(AuthErrorState(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());
    await repository.logout();
    emit(const UnauthenticatedState());
  }
}
