// Driver profile BLoC
// Path: lib/chauffeurs/pages/profil/domain/bloc/driver_profile_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/driver_profile_repository.dart';
import 'driver_profile_event.dart';
import 'driver_profile_state.dart';

class DriverProfileBloc extends Bloc<DriverProfileEvent, DriverProfileState> {
  final DriverProfileRepository repository;

  DriverProfileBloc({required this.repository}) : super(DriverProfileInitial()) {
    on<LoadDriverProfileEvent>(_onLoadProfile);
    on<UpdateDriverProfileEvent>(_onUpdateProfile);
    on<UpdateDriverProfilePhotoEvent>(_onUpdatePhoto);
    on<DeleteDriverProfilePhotoEvent>(_onDeletePhoto);
    on<RefreshDriverProfileEvent>(_onRefreshProfile);
  }

  Future<void> _onLoadProfile(
    LoadDriverProfileEvent event,
    Emitter<DriverProfileState> emit,
  ) async {
    emit(DriverProfileLoading());
    try {
      final profile = await repository.getProfile();
      emit(DriverProfileLoaded(profile));
    } catch (e) {
      emit(DriverProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateDriverProfileEvent event,
    Emitter<DriverProfileState> emit,
  ) async {
    emit(DriverProfileUpdating());
    try {
      // Call repository with individual fields instead of profile object
      final profile = await repository.updateProfile(
        firstName: event.firstName,
        lastName: event.lastName,
        phone: event.phone,
        email: event.email,
        address: event.address,
      );
      emit(DriverProfileUpdated(profile));
      emit(DriverProfileLoaded(profile));
    } catch (e) {
      emit(DriverProfileError(e.toString()));
    }
  }

  Future<void> _onUpdatePhoto(
    UpdateDriverProfilePhotoEvent event,
    Emitter<DriverProfileState> emit,
  ) async {
    emit(DriverProfilePhotoUploading());
    try {
      // Photo upload not implemented yet
      emit(DriverProfileError('Photo upload not yet implemented'));
    } catch (e) {
      emit(DriverProfileError(e.toString()));
    }
  }

  Future<void> _onDeletePhoto(
    DeleteDriverProfilePhotoEvent event,
    Emitter<DriverProfileState> emit,
  ) async {
    try {
      // Photo delete not implemented yet
      emit(DriverProfileError('Photo delete not yet implemented'));
    } catch (e) {
      emit(DriverProfileError(e.toString()));
    }
  }

  Future<void> _onRefreshProfile(
    RefreshDriverProfileEvent event,
    Emitter<DriverProfileState> emit,
  ) async {
    try {
      final profile = await repository.getProfile();
      emit(DriverProfileLoaded(profile));
    } catch (e) {
      emit(DriverProfileError(e.toString()));
    }
  }
}