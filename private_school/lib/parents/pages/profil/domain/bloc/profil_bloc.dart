import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/user_repository.dart';
import 'profil_event.dart';
import 'profil_state.dart';

/// BLoC for managing user profile
/// Handles all profile-related events and state management
class ProfilBloc extends Bloc<ProfilEvent, ProfilState> {
  final UserRepository repository;

  ProfilBloc({required this.repository}) : super(ProfilInitial()) {
    on<LoadUserProfileEvent>(_onLoadUserProfile);
    on<UpdateUserProfileEvent>(_onUpdateUserProfile);
    on<UpdateUserFieldsEvent>(_onUpdateUserFields);
    on<UpdateProfilePhotoEvent>(_onUpdateProfilePhoto);
    on<UpdateProfilePhotoFromPathEvent>(_onUpdateProfilePhotoFromPath);
    on<DeleteProfilePhotoEvent>(_onDeleteProfilePhoto);
    on<LogoutEvent>(_onLogout);
  }

  /// Load user profile
  Future<void> _onLoadUserProfile(
    LoadUserProfileEvent event,
    Emitter<ProfilState> emit,
  ) async {
    emit(ProfilLoading());
    try {
      final user = await repository.getCurrentUser();
      emit(ProfilLoaded(user));
    } catch (e) {
      emit(ProfilError('Unable to load profile: ${e.toString()}'));
    }
  }

  /// Update complete profile
  Future<void> _onUpdateUserProfile(
    UpdateUserProfileEvent event,
    Emitter<ProfilState> emit,
  ) async {
    emit(ProfilUpdating());
    try {
      final updatedUser = await repository.updateUser(event.user);
      emit(ProfilUpdated(updatedUser));
      // Reload profile to get updated data
      emit(ProfilLoaded(updatedUser));
    } catch (e) {
      emit(ProfilError('Unable to update profile: ${e.toString()}'));
    }
  }

  /// Update specific fields only
  Future<void> _onUpdateUserFields(
    UpdateUserFieldsEvent event,
    Emitter<ProfilState> emit,
  ) async {
    emit(ProfilUpdating());
    try {
      final updatedUser = await repository.updateUserFields(
        firstName: event.firstName,
        lastName: event.lastName,
        phone: event.phone,
        email: event.email,
        address: event.address,
      );
      emit(ProfilUpdated(updatedUser));
      emit(ProfilLoaded(updatedUser));
    } catch (e) {
      emit(ProfilError('Unable to update profile: ${e.toString()}'));
    }
  }

  /// Update profile photo
  Future<void> _onUpdateProfilePhoto(
    UpdateProfilePhotoEvent event,
    Emitter<ProfilState> emit,
  ) async {
    emit(PhotoUploading());
    try {
      final photoUrl = await repository.updateProfilePhoto(event.photoFile);
      emit(PhotoUploaded(photoUrl));
      // Reload profile to get new photo
      add(LoadUserProfileEvent());
    } catch (e) {
      emit(ProfilError('Unable to upload photo: ${e.toString()}'));
    }
  }

  /// Update profile photo from path
  Future<void> _onUpdateProfilePhotoFromPath(
    UpdateProfilePhotoFromPathEvent event,
    Emitter<ProfilState> emit,
  ) async {
    emit(PhotoUploading());
    try {
      final photoUrl = await repository.updateProfilePhotoFromPath(event.photoPath);
      emit(PhotoUploaded(photoUrl));
      // Reload profile to get new photo
      add(LoadUserProfileEvent());
    } catch (e) {
      emit(ProfilError('Unable to upload photo: ${e.toString()}'));
    }
  }

  /// Delete profile photo
  Future<void> _onDeleteProfilePhoto(
    DeleteProfilePhotoEvent event,
    Emitter<ProfilState> emit,
  ) async {
    try {
      await repository.deleteProfilePhoto();
      emit(PhotoDeleted());
      // Reload profile
      add(LoadUserProfileEvent());
    } catch (e) {
      emit(ProfilError('Unable to delete photo: ${e.toString()}'));
    }
  }

  /// Logout
  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<ProfilState> emit,
  ) async {
    try {
      // 1. Appel au repository pour informer le serveur (et effacer le token localement)
      await repository.logout();
      
      // 2. Émettre le succès pour déclencher le BlocListener dans ProfilPage
      emit(LogoutSuccess());
    } catch (e) {
      // ✅ ASTUCE : Même si l'API échoue, on émet LogoutSuccess.
      // On veut que l'utilisateur puisse sortir de l'app quoi qu'il arrive.
      emit(LogoutSuccess());
    }
  }
}