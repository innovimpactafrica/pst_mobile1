import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class RegisterEvent extends AuthEvent {
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String? password;
  final String? homeAddress;

  const RegisterEvent({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    this.password,
    this.homeAddress,
  });

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    phone,
    email,
    password,
    homeAddress,
  ];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class VerifyOtpEvent extends AuthEvent {
  final String email;
  final String otp;

  const VerifyOtpEvent({required this.email, required this.otp});

  @override
  List<Object?> get props => [email, otp];
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

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

class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}
