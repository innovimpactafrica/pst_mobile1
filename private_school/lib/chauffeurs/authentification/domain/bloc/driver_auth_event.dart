
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

  DriverRegisterEvent({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.password,
    this.licenseNumber,
    this.vehicleType,
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
  final String phone;

  DriverForgotPasswordEvent({required this.phone});
}

class DriverResetPasswordEvent extends DriverAuthEvent {
  final String phone;
  final String otp;
  final String newPassword;

  DriverResetPasswordEvent({
    required this.phone,
    required this.otp,
    required this.newPassword,
  });
}

class DriverLogoutEvent extends DriverAuthEvent {}

class CheckDriverAuthStatusEvent extends DriverAuthEvent {}