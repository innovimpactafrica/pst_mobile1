// Events d'authentification - MODIFIÉ pour inclure password
// Chemin: lib/parents/authentification/domain/bloc/auth_event.dart

import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// ✅ Event : Inscription d'un parent - AVEC password optionnel
class RegisterEvent extends AuthEvent {
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String? password; // ← AJOUTÉ

  const RegisterEvent({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    this.password, // ← OPTIONNEL
  });

  @override
  List<Object?> get props => [firstName, lastName, phone, email, password];
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

/// ✅ Event : Déconnexion
class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

/// ✅ Event : Charger l'utilisateur actuel
class LoadCurrentUserEvent extends AuthEvent {
  const LoadCurrentUserEvent();
}

class ForgotPasswordEvent extends AuthEvent {
  final String contact; // Email ou téléphone

  const ForgotPasswordEvent({required this.contact});

  @override
  List<Object?> get props => [contact];
}

class ResetPasswordEvent extends AuthEvent {
  final int userId;
  final String code;
  final String newPassword;

  const ResetPasswordEvent({
    required this.userId,
    required this.code,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [userId, code, newPassword];
}

/// ✅ Event : Vérifier si l'utilisateur est connecté
class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}