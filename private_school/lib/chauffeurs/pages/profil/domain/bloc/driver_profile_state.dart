import 'package:equatable/equatable.dart';
import '../../data/models/driver_profile_model.dart';

abstract class DriverProfileState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DriverProfileInitial extends DriverProfileState {}

class DriverProfileLoading extends DriverProfileState {}

class DriverProfileLoaded extends DriverProfileState {
  final DriverProfileModel profile;

  DriverProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class DriverProfileUpdating extends DriverProfileState {}

class DriverProfileUpdated extends DriverProfileState {
  final DriverProfileModel profile;

  DriverProfileUpdated(this.profile);

  @override
  List<Object?> get props => [profile];
}

class DriverProfilePhotoUploading extends DriverProfileState {}

class DriverProfilePhotoUploaded extends DriverProfileState {
  final String photoUrl;

  DriverProfilePhotoUploaded(this.photoUrl);

  @override
  List<Object?> get props => [photoUrl];
}

class DriverProfilePhotoDeleted extends DriverProfileState {}

class DriverProfileError extends DriverProfileState {
  final String message;

  DriverProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
