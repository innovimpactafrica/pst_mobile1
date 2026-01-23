/// BLoC pour gérer le profil utilisateur
/// Chemin: lib/parents/profil/domain/bloc/profil_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/user_repository.dart';
import 'profil_event.dart';
import 'profil_state.dart';

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

  /// Charger le profil utilisateur
  Future<void> _onLoadUserProfile(
      LoadUserProfileEvent event,
      Emitter<ProfilState> emit,
      ) async {
    emit(ProfilLoading());
    try {
      final user = await repository.getCurrentUser();
      emit(ProfilLoaded(user));
    } catch (e) {
      emit(ProfilError('Erreur lors du chargement du profil: ${e.toString()}'));
    }
  }

  /// Mettre à jour le profil complet
  Future<void> _onUpdateUserProfile(
      UpdateUserProfileEvent event,
      Emitter<ProfilState> emit,
      ) async {
    emit(ProfilUpdating());
    try {
      final updatedUser = await repository.updateUser(event.user);
      emit(ProfilUpdated(updatedUser));
      // Recharger le profil pour avoir les données à jour
      emit(ProfilLoaded(updatedUser));
    } catch (e) {
      emit(ProfilError('Erreur lors de la mise à jour: ${e.toString()}'));
    }
  }

  /// Mettre à jour uniquement certains champs
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
      emit(ProfilError('Erreur lors de la mise à jour: ${e.toString()}'));
    }
  }

  /// Mettre à jour la photo de profil
  Future<void> _onUpdateProfilePhoto(
      UpdateProfilePhotoEvent event,
      Emitter<ProfilState> emit,
      ) async {
    emit(PhotoUploading());
    try {
      final photoUrl = await repository.updateProfilePhoto(event.photoFile);
      emit(PhotoUploaded(photoUrl));
      // Recharger le profil pour avoir la nouvelle photo
      add(LoadUserProfileEvent());
    } catch (e) {
      emit(ProfilError('Erreur lors du téléchargement de la photo: ${e.toString()}'));
    }
  }

  /// Mettre à jour la photo de profil depuis un chemin
  Future<void> _onUpdateProfilePhotoFromPath(
      UpdateProfilePhotoFromPathEvent event,
      Emitter<ProfilState> emit,
      ) async {
    emit(PhotoUploading());
    try {
      final photoUrl = await repository.updateProfilePhotoFromPath(event.photoPath);
      emit(PhotoUploaded(photoUrl));
      // Recharger le profil pour avoir la nouvelle photo
      add(LoadUserProfileEvent());
    } catch (e) {
      emit(ProfilError('Erreur lors du téléchargement de la photo: ${e.toString()}'));
    }
  }

  /// Supprimer la photo de profil
  Future<void> _onDeleteProfilePhoto(
      DeleteProfilePhotoEvent event,
      Emitter<ProfilState> emit,
      ) async {
    try {
      await repository.deleteProfilePhoto();
      emit(PhotoDeleted());
      // Recharger le profil
      add(LoadUserProfileEvent());
    } catch (e) {
      emit(ProfilError('Erreur lors de la suppression de la photo: ${e.toString()}'));
    }
  }

  /// Déconnexion
  Future<void> _onLogout(
      LogoutEvent event,
      Emitter<ProfilState> emit,
      ) async {
    try {
      await repository.logout(); 
      emit(LogoutSuccess());
    } catch (e) {
      emit(ProfilError('Erreur lors de la déconnexion: ${e.toString()}'));
    }
  }
}