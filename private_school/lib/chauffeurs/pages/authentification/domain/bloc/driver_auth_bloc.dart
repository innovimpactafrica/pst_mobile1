

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:private_school/core/storage/secure_storage.dart';
import '../../data/repositories/driver_auth_repository.dart';
import 'driver_auth_event.dart';
import 'driver_auth_state.dart';

class DriverAuthBloc extends Bloc<DriverAuthEvent, DriverAuthState> {
  final DriverAuthRepository repository;

  DriverAuthBloc({required this.repository}) : super(DriverAuthInitial()) {
    on<DriverLoginEvent>(_onLogin);
    on<DriverRegisterEvent>(_onRegister);
    on<DriverVerifyOTPEvent>(_onVerifyOTP);
    on<DriverForgotPasswordEvent>(_onForgotPassword);
    on<DriverResetPasswordEvent>(_onResetPassword);
    on<DriverLogoutEvent>(_onLogout);
    on<CheckDriverAuthStatusEvent>(_onCheckAuthStatus);
  }

  Future<void> _onLogin(
    DriverLoginEvent event,
    Emitter<DriverAuthState> emit,
  ) async {
    emit(DriverAuthLoading());
    try {
      final driver = await repository.login(
        phone: event.phone,
        password: event.password,
      );
      // ✅ Sauvegarder le rôle
await SecureStorage().saveUserRole('driver');
emit(DriverAuthenticated(driver));
      emit(DriverAuthenticated(driver));
    } catch (e) {
      emit(DriverAuthError(e.toString()));
    }
  }

  Future<void> _onRegister(
    DriverRegisterEvent event,
    Emitter<DriverAuthState> emit,
  ) async {
    emit(DriverAuthLoading());
    try {
      await repository.register(
        firstName: event.firstName,
        lastName: event.lastName,
        phone: event.phone,
        email: event.email,
        password: event.password,
        licenseNumber: event.licenseNumber,
        vehicleType: event.vehicleType,
        vehicleColor: event.vehicleColor,
        capacity: event.capacity,
        licenseFile: event.licenseFile,
        idCardFile: event.idCardFile,
        vehicleFile: event.vehicleFile,
      );
      emit(DriverOTPSent(event.phone));
    } catch (e) {
      emit(DriverAuthError(e.toString()));
    }
  }

  Future<void> _onVerifyOTP(
    DriverVerifyOTPEvent event,
    Emitter<DriverAuthState> emit,
  ) async {
    emit(DriverAuthLoading());
    try {
      await repository.verifyOTP(
        phone: event.phone,
        otp: event.otp,
      );
      emit(DriverOTPVerified());
    } catch (e) {
      emit(DriverAuthError(e.toString()));
    }
  }


  Future<void> _onForgotPassword(
  DriverForgotPasswordEvent event,
  Emitter<DriverAuthState> emit,
) async {
  emit(DriverAuthLoading());
  try {
    final response = await repository.forgotPassword(contact: event.contact);
    
    final userId = response['userId'] as int?;
    
    if (userId == null) {
      emit(DriverAuthError('ID utilisateur manquant dans la réponse'));
      return;
    }
    
    emit(DriverPasswordResetRequested(event.contact, userId: userId));
  } catch (e) {
    emit(DriverAuthError(e.toString()));
  }
}

  Future<void> _onResetPassword(
    DriverResetPasswordEvent event,
    Emitter<DriverAuthState> emit,
  ) async {
    emit(DriverAuthLoading());
    try {
      await repository.resetPassword(
        userId: event.userId,
        code: event.code,
        newPassword: event.newPassword,
      );
      emit(DriverPasswordResetSuccess());
    } catch (e) {
      emit(DriverAuthError(e.toString()));
    }
  }

  Future<void> _onLogout(
    DriverLogoutEvent event,
    Emitter<DriverAuthState> emit,
  ) async {
    emit(DriverAuthLoading());
    try {
      await repository.logout();
      emit(DriverLogoutSuccess());
    } catch (e) {
      emit(DriverAuthError(e.toString()));
    }
  }

  Future<void> _onCheckAuthStatus(
    CheckDriverAuthStatusEvent event,
    Emitter<DriverAuthState> emit,
  ) async {
    try {
      final isLoggedIn = await repository.isLoggedIn();
      if (isLoggedIn) {
        emit(DriverAuthenticatedFromStorage());
      } else {
        emit(DriverUnauthenticated());
      }
    } catch (e) {
      emit(DriverUnauthenticated());
    }
  }
}