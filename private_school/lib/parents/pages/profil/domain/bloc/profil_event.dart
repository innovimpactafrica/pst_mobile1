// Events pour le profil utilisateur
// Chemin: lib/parents/profil/domain/bloc/profil_event.dart

import 'dart:io';
import 'package:private_school/core/models/user_model.dart';


abstract class ProfilEvent {}

/// Charger le profil utilisateur
class LoadUserProfileEvent extends ProfilEvent {}

/// Mettre à jour le profil utilisateur complet
class UpdateUserProfileEvent extends ProfilEvent {
  final UserModel user;

  UpdateUserProfileEvent(this.user);
}

/// Mettre à jour uniquement certains champs
class UpdateUserFieldsEvent extends ProfilEvent {
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? email;
  final String? address;

  UpdateUserFieldsEvent({
    this.firstName,
    this.lastName,
    this.phone,
    this.email,
    this.address,
  });
}

/// Mettre à jour la photo de profil
class UpdateProfilePhotoEvent extends ProfilEvent {
  final File photoFile;

  UpdateProfilePhotoEvent(this.photoFile);
}

/// Mettre à jour la photo de profil depuis un chemin
class UpdateProfilePhotoFromPathEvent extends ProfilEvent {
  final String photoPath;

  UpdateProfilePhotoFromPathEvent(this.photoPath);
}

/// Supprimer la photo de profil
class DeleteProfilePhotoEvent extends ProfilEvent {}

/// Déconnexion
class LogoutEvent extends ProfilEvent {}