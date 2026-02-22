import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:private_school/core/storage/secure_storage.dart';
import 'package:private_school/parents/pages/authentification/%20data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository = AuthRepository();

  AuthBloc() : super(const AuthInitial()) {
    on<RegisterEvent>(_onRegister);
    on<LoginEvent>(_onLogin);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<ForgotPasswordEvent>(_onForgotPassword);
    on<ResetPasswordEvent>(_onResetPassword);
    on<LogoutEvent>(_onLogout);
    on<LoadCurrentUserEvent>(_onLoadCurrentUser);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
  }

  /// ✅ Handler : Inscription - AVEC password et homeAddress
  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    try {
      debugPrint('🔄 BLoC: Starting registration...');

      final result = await _authRepository.register(
        firstName: event.firstName,
        lastName: event.lastName,
        phone: event.phone,
        email: event.email,
        password: event.password,
        homeAddress: event.homeAddress,
      );

      debugPrint('✅ BLoC: Registration result: $result');

      if (result['token'] != null) {
        emit(
          RegisterSuccess(message: result['message'] ?? 'Inscription réussie'),
        );
      } else {
        emit(
          RegisterSuccess(message: result['message'] ?? 'Inscription réussie'),
        );
      }
    } catch (e) {
      debugPrint('❌ BLoC: Registration error: $e');
      emit(AuthError(message: e.toString()));
    }
  }

  /// ✅ Handler : Connexion
  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    try {
      debugPrint('🔄 BLoC: Starting login...');

      final result = await _authRepository.login(
        email: event.email,
        password: event.password,
      );

      debugPrint('✅ BLoC: Login result: $result');

      if (result['success'] == true && result['user'] != null) {
        await SecureStorage().saveUserRole('parent');
        emit(
          AuthAuthenticated(user: result['user'], message: 'Connexion réussie'),
        );
      } else {
        emit(const AuthError(message: 'Échec de la connexion'));
      }
    } catch (e) {
      debugPrint('❌ BLoC: Login error: $e');
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
      debugPrint('🔄 BLoC: Verifying OTP...');

      final result = await _authRepository.verifyOtp(
        email: event.email,
        otp: event.otp,
      );

      debugPrint('✅ BLoC: OTP verified');

      emit(
        OtpVerified(
          message: result['message'] ?? 'Code vérifié',
          token: result['token'],
        ),
      );
    } catch (e) {
      debugPrint('❌ BLoC: OTP verification error: $e');
      emit(AuthError(message: e.toString()));
    }
  }

  /// ✅ Handler : Mot de passe oublié - CORRIGÉ
  Future<void> _onForgotPassword(
    ForgotPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      debugPrint('🔄 BLoC: Requesting password reset...');

      final result = await _authRepository.forgotPassword(
        contact: event.contact,
      );

      debugPrint('✅ BLoC: Password reset requested: $result');

      // Récupérer userId depuis la réponse API
      final userId = result['user']?['id'] ?? result['userId'];

      emit(PasswordResetRequested(event.contact, userId: userId));
    } catch (e) {
      debugPrint('❌ BLoC: Forgot password error: $e');
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
      debugPrint('🔄 BLoC: Resetting password...');

      await _authRepository.resetPassword(
        userId: event.userId,
        code: event.code,
        newPassword: event.newPassword,
      );

      debugPrint('✅ BLoC: Password reset successful');

      emit(
        const PasswordResetSuccess(
          message: 'Mot de passe réinitialisé avec succès',
        ),
      );
    } catch (e) {
      debugPrint('❌ BLoC: Reset password error: $e');
      emit(AuthError(message: e.toString()));
    }
  }

  /// ✅ Handler : Déconnexion
  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    try {
      debugPrint('🔄 BLoC: Logging out...');

      await _authRepository.logout();

      debugPrint('✅ BLoC: Logout successful');

      emit(const AuthUnauthenticated());
    } catch (e) {
      debugPrint('❌ BLoC: Logout error: $e');
      emit(AuthError(message: e.toString()));
    }
  }

Future<void> _onLoadCurrentUser(
  LoadCurrentUserEvent event,
  Emitter<AuthState> emit,
) async {
  // ✅ PAS de AuthLoading ici pour ne pas rouvrir le dialog de connexion

  try {
    debugPrint('🔄 BLoC: Loading current user...');
    final user = await _authRepository.getCurrentUser();
    debugPrint('✅ BLoC: User loaded: ${user.fullName}');
    emit(AuthAuthenticated(user: user));
  } catch (e) {
    debugPrint('❌ BLoC: Load current user error: $e');
    // ✅ En cas d'erreur, on garde l'état actuel sans crasher
    debugPrint('⚠️ Impossible de recharger le profil, état conservé');
  }
}

  /// ✅ Handler : Vérifier le statut d'authentification
  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      debugPrint('🔄 BLoC: Checking auth status...');

      final isLoggedIn = await _authRepository.isLoggedIn();

      if (isLoggedIn) {
        debugPrint('✅ BLoC: User is logged in, loading profile...');
        try {
          final user = await _authRepository.getCurrentUser();
          debugPrint('✅ BLoC: User profile loaded');
          emit(AuthAuthenticated(user: user));
        } catch (e) {
          debugPrint('❌ BLoC: Failed to load user profile: $e');
          emit(const AuthUnauthenticated());
        }
      } else {
        debugPrint('ℹ️ BLoC: User is not logged in');
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      debugPrint('❌ BLoC: Check auth status error: $e');
      emit(const AuthUnauthenticated());
    }
  }
}
