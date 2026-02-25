import 'package:equatable/equatable.dart';
import 'package:private_school/core/models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final UserModel? user;
  final String? message;

  const AuthAuthenticated({this.user, this.message});

  @override
  List<Object?> get props => [user, message];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class RegisterSuccess extends AuthState {
  final String message;

  const RegisterSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class OtpVerified extends AuthState {
  final String message;
  final String? token;

  const OtpVerified({required this.message, this.token});

  @override
  List<Object?> get props => [message, token];
}

class OtpSent extends AuthState {
  final String message;

  const OtpSent({required this.message});

  @override
  List<Object?> get props => [message];
}

class PasswordResetSuccess extends AuthState {
  final String message;

  const PasswordResetSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

class UserLoaded extends AuthState {
  final UserModel user;

  const UserLoaded({required this.user});

  @override
  List<Object?> get props => [user];
}

class PasswordResetRequested extends AuthState {
  final String contact;
  final int? userId;

  const PasswordResetRequested(this.contact, {this.userId});

  @override
  List<Object?> get props => [contact, userId];
}
