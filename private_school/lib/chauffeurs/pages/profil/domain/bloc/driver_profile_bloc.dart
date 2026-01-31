import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:private_school/chauffeurs/pages/profil/data/repositories/driver_profile_repository.dart';
import 'driver_profile_event.dart';
import 'driver_profile_state.dart';

/// BLoC for managing driver profile state
class DriverProfileBloc extends Bloc<DriverProfileEvent, DriverProfileState> {
  final DriverProfileRepository repository;

  DriverProfileBloc({required this.repository}) : super(DriverProfileInitial()) {
    on<LoadDriverProfileEvent>(_onLoadProfile);
    on<UpdateDriverProfileEvent>(_onUpdateProfile);
    on<UpdateDriverProfileWithPhotoEvent>(_onUpdateProfileWithPhoto);
    on<UpdateDriverByIdEvent>(_onUpdateDriverById); // ✅ Nouveau handler
  }

  Future<void> _onLoadProfile(
    LoadDriverProfileEvent event,
    Emitter<DriverProfileState> emit,
  ) async {
    try {
      emit(DriverProfileLoading());
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
    try {
      emit(DriverProfileUpdating());
      final profile = await repository.updateProfile(
        firstName: event.firstName,
        lastName: event.lastName,
        phone: event.phone,
        address: event.address,
      );
      emit(DriverProfileUpdated(profile));
      emit(DriverProfileLoaded(profile));
    } catch (e) {
      emit(DriverProfileError(e.toString()));
      if (state is DriverProfileLoaded) {
        emit(state);
      }
    }
  }

  Future<void> _onUpdateProfileWithPhoto(
    UpdateDriverProfileWithPhotoEvent event,
    Emitter<DriverProfileState> emit,
  ) async {
    try {
      emit(DriverProfileUpdating());
      final profile = await repository.updateProfileWithPhoto(event.formData);
      emit(DriverProfileUpdated(profile));
      emit(DriverProfileLoaded(profile));
    } catch (e) {
      emit(DriverProfileError(e.toString()));
      if (state is DriverProfileLoaded) emit(state);
    }
  }

  /// 🆕 Handler pour UpdateDriverByIdEvent
  /// Utilisé pour mettre à jour le véhicule et les documents via PUT /api/drivers/{id}
 Future<void> _onUpdateDriverById(
  UpdateDriverByIdEvent event,
  Emitter<DriverProfileState> emit,
) async {
  try {
    emit(DriverProfileUpdating());

    final profile = await repository.updateDriverById(
      driverId: event.driverId,
      formData: event.formData,
    );

    // UN SEUL état final
    emit(DriverProfileUpdated(profile));
  } catch (e) {
    emit(DriverProfileError(e.toString()));
  }
}

}