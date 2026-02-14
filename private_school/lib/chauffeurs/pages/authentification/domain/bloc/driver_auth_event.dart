

import 'dart:io';

abstract class DriverAuthEvent {}

class DriverLoginEvent extends DriverAuthEvent {
  final String phone;
  final String password;

  DriverLoginEvent({
    required this.phone,
    required this.password,
  });
}

class DriverRegisterEvent extends DriverAuthEvent {
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String password;
  final String? licenseNumber;
  final String? vehicleType;
  final String? vehicleColor;
  final int? capacity;
  final File? licenseFile;
  final File? idCardFile;
  final File? vehicleFile;

  DriverRegisterEvent({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.password,
    this.licenseNumber,
    this.vehicleType,
    this.vehicleColor,
    this.capacity,
    this.licenseFile,
    this.idCardFile,
    this.vehicleFile,
  });
}

class DriverVerifyOTPEvent extends DriverAuthEvent {
  final String phone;
  final String otp;

  DriverVerifyOTPEvent({
    required this.phone,
    required this.otp,
  });
}


class DriverForgotPasswordEvent extends DriverAuthEvent {
  final String contact; 

  DriverForgotPasswordEvent({required this.contact});
}


class DriverResetPasswordEvent extends DriverAuthEvent {
  final int userId;         
  final String code;        
  final String newPassword;

  DriverResetPasswordEvent({
    required this.userId,
    required this.code,
    required this.newPassword,
  });
}

class DriverLogoutEvent extends DriverAuthEvent {}

class CheckDriverAuthStatusEvent extends DriverAuthEvent {}