// Events d'authentification
// Chemin: lib/parents/authentification/domain/bloc/auth_event.dart

import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// ✅ Event : Inscription d'un parent
class RegisterEvent extends AuthEvent {
  final String firstName;
  final String lastName;
  final String phone;
  final String email;

  const RegisterEvent({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
  });

  @override
  List<Object?> get props => [firstName, lastName, phone, email];
}

/// ✅ Event : Connexion d'un parent
class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// ✅ Event : Vérifier le code OTP
class VerifyOtpEvent extends AuthEvent {
  final String email;
  final String otp;

  const VerifyOtpEvent({
    required this.email,
    required this.otp,
  });

  @override
  List<Object?> get props => [email, otp];
}

/// ✅ Event : Mot de passe oublié (envoyer OTP)
class ForgotPasswordEvent extends AuthEvent {
  final String email;

  const ForgotPasswordEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

/// ✅ Event : Réinitialiser le mot de passe
class ResetPasswordEvent extends AuthEvent {
  final String email;
  final String otp;
  final String newPassword;

  const ResetPasswordEvent({
    required this.email,
    required this.otp,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [email, otp, newPassword];
}

/// ✅ Event : Déconnexion
class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

/// ✅ Event : Charger l'utilisateur actuel
class LoadCurrentUserEvent extends AuthEvent {
  const LoadCurrentUserEvent();
}

/// ✅ Event : Vérifier si l'utilisateur est connecté
class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}