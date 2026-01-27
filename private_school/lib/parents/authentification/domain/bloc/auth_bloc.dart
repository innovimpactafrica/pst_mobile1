// BLoC d'authentification
// Chemin: lib/parents/authentification/domain/bloc/auth_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../ data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository = AuthRepository();

  AuthBloc() : super(const AuthInitial()) {
    //  Inscription
    on<RegisterEvent>(_onRegister);

    //  Connexion
    on<LoginEvent>(_onLogin);

    //  Vérifier OTP
    on<VerifyOtpEvent>(_onVerifyOtp);

    //  Mot de passe oublié
    on<ForgotPasswordEvent>(_onForgotPassword);

    //  Réinitialiser mot de passe
    on<ResetPasswordEvent>(_onResetPassword);

    //  Déconnexion
    on<LogoutEvent>(_onLogout);

    //  Charger l'utilisateur actuel
    on<LoadCurrentUserEvent>(_onLoadCurrentUser);

    //  Vérifier le statut d'authentification
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
  }

  ///  Handler : Inscription
  Future<void> _onRegister(
      RegisterEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoading());

    try {
      final result = await _authRepository.register(
        firstName: event.firstName,
        lastName: event.lastName,
        phone: event.phone,
        email: event.email,
      );

      emit(RegisterSuccess(
        message: result['message'] ?? 'Inscription réussie',
      ));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  /// ✅ Handler : Connexion
  Future<void> _onLogin(
      LoginEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoading());

    try {
      final result = await _authRepository.login(
        email: event.email,
        password: event.password,
      );

      if (result['success'] == true) {
        emit(AuthAuthenticated(
          user: result['user'],
          message: 'Connexion réussie',
        ));
      } else {
        emit(const AuthError(message: 'Échec de la connexion'));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  /// ✅ Handler : Vérifier OTP
  Future<void> _onVerifyOtp(
      VerifyOtpEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoading());

    try {
      final result = await _authRepository.verifyOtp(
        email: event.email,
        otp: event.otp,
      );

      emit(OtpVerified(
        message: result['message'] ?? 'Code vérifié',
        token: result['token'],
      ));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  /// ✅ Handler : Mot de passe oublié
  Future<void> _onForgotPassword(
      ForgotPasswordEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoading());

    try {
      final result = await _authRepository.forgotPassword(
        email: event.email,
      );

      emit(OtpSent(
        message: result['message'] ?? 'Code OTP envoyé',
      ));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  /// ✅ Handler : Réinitialiser mot de passe
  Future<void> _onResetPassword(
      ResetPasswordEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoading());

    try {
      final result = await _authRepository.resetPassword(
        email: event.email,
        otp: event.otp,
        newPassword: event.newPassword,
      );

      emit(PasswordResetSuccess(
        message: result['message'] ?? 'Mot de passe réinitialisé',
      ));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  /// ✅ Handler : Déconnexion
  Future<void> _onLogout(
      LogoutEvent event,
      Emitter<AuthState> emit,
      ) async {
    try {
      await _authRepository.logout();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  /// ✅ Handler : Charger l'utilisateur actuel
  Future<void> _onLoadCurrentUser(
      LoadCurrentUserEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoading());

    try {
      final user = await _authRepository.getCurrentUser();
      emit(UserLoaded(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  /// ✅ Handler : Vérifier le statut d'authentification
  Future<void> _onCheckAuthStatus(
      CheckAuthStatusEvent event,
      Emitter<AuthState> emit,
      ) async {
    try {
      final isLoggedIn = await _authRepository.isLoggedIn();

      if (isLoggedIn) {
        // Charger les infos de l'utilisateur
        try {
          final user = await _authRepository.getCurrentUser();
          emit(AuthAuthenticated(user: user));
        } catch (e) {
          // Si on ne peut pas charger l'utilisateur, on est déconnecté
          emit(const AuthUnauthenticated());
        }
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(const AuthUnauthenticated());
    }
  }
}