// States d'authentification
// Chemin: lib/parents/authentification/domain/bloc/auth_state.dart

import 'package:equatable/equatable.dart';
import 'package:private_school/core/models/user_model.dart';



abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// ✅ État initial
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// ✅ Chargement en cours
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// ✅ Authentification réussie (connexion ou inscription)
class AuthAuthenticated extends AuthState {
  final UserModel? user;
  final String? message;

  const AuthAuthenticated({this.user, this.message});

  @override
  List<Object?> get props => [user, message];
}

/// ✅ Non authentifié (déconnecté)
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// ✅ Inscription réussie (en attente de validation)
class RegisterSuccess extends AuthState {
  final String message;

  const RegisterSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

/// ✅ OTP vérifié avec succès
class OtpVerified extends AuthState {
  final String message;
  final String? token;

  const OtpVerified({required this.message, this.token});

  @override
  List<Object?> get props => [message, token];
}

/// ✅ Code OTP envoyé (mot de passe oublié)
class OtpSent extends AuthState {
  final String message;

  const OtpSent({required this.message});

  @override
  List<Object?> get props => [message];
}

/// ✅ Mot de passe réinitialisé avec succès
class PasswordResetSuccess extends AuthState {
  final String message;

  const PasswordResetSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

/// ✅ Erreur d'authentification
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// ✅ Utilisateur chargé
class UserLoaded extends AuthState {
  final UserModel user;

  const UserLoaded({required this.user});

  @override
  List<Object?> get props => [user];
}