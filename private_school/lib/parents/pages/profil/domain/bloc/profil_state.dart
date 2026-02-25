import 'package:equatable/equatable.dart';
import 'package:private_school/core/models/user_model.dart';

abstract class ProfilState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// État initial
class ProfilInitial extends ProfilState {}

/// Chargement du profil
class ProfilLoading extends ProfilState {}

/// Profil chargé avec succès
class ProfilLoaded extends ProfilState {
  final UserModel user;

  ProfilLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

/// Mise à jour en cours
class ProfilUpdating extends ProfilState {}

/// Profil mis à jour avec succès
class ProfilUpdated extends ProfilState {
  final UserModel user;

  ProfilUpdated(this.user);

  @override
  List<Object?> get props => [user];
}

/// Photo en cours de téléchargement
class PhotoUploading extends ProfilState {}

/// Photo téléchargée avec succès
class PhotoUploaded extends ProfilState {
  final String photoUrl;

  PhotoUploaded(this.photoUrl);

  @override
  List<Object?> get props => [photoUrl];
}

/// Photo supprimée avec succès
class PhotoDeleted extends ProfilState {}

/// Déconnexion réussie
class LogoutSuccess extends ProfilState {}

/// Erreur
class ProfilError extends ProfilState {
  final String message;

  ProfilError(this.message);

  @override
  List<Object?> get props => [message];
}
