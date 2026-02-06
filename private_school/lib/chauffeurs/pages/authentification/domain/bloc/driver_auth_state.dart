

import '../../data/models/driver_model.dart';

abstract class DriverAuthState {}

class DriverAuthInitial extends DriverAuthState {}

class DriverAuthLoading extends DriverAuthState {}

class DriverAuthenticated extends DriverAuthState {
  final DriverModel driver;

  DriverAuthenticated(this.driver);
}

class DriverOTPSent extends DriverAuthState {
  final String phone;

  DriverOTPSent(this.phone);
}

class DriverOTPVerified extends DriverAuthState {}


class DriverPasswordResetRequested extends DriverAuthState {
  final String contact;
  final int? userId; 

  DriverPasswordResetRequested(this.contact, {this.userId});
}

class DriverPasswordResetSuccess extends DriverAuthState {}

class DriverLogoutSuccess extends DriverAuthState {}

class DriverUnauthenticated extends DriverAuthState {}

class DriverAuthError extends DriverAuthState {
  final String message;

  DriverAuthError(this.message);
}