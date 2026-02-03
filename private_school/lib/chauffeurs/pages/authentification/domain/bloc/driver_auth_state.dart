
import 'package:equatable/equatable.dart';
import '../../data/models/driver_model.dart';

abstract class DriverAuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DriverAuthInitial extends DriverAuthState {}

class DriverAuthLoading extends DriverAuthState {}

class DriverAuthenticated extends DriverAuthState {
  final DriverModel driver;

  DriverAuthenticated(this.driver);

  @override
  List<Object?> get props => [driver];
}

class DriverUnauthenticated extends DriverAuthState {}

class DriverOTPSent extends DriverAuthState {
  final String phone;

  DriverOTPSent(this.phone);

  @override
  List<Object?> get props => [phone];
}

class DriverOTPVerified extends DriverAuthState {}

class DriverPasswordResetRequested extends DriverAuthState {
  final String phone;

  DriverPasswordResetRequested(this.phone);

  @override
  List<Object?> get props => [phone];
}

class DriverPasswordResetSuccess extends DriverAuthState {}

class DriverLogoutSuccess extends DriverAuthState {}

class DriverAuthError extends DriverAuthState {
  final String message;

  DriverAuthError(this.message);

  @override
  List<Object?> get props => [message];
}