// Driver profile events
// Path: lib/chauffeurs/pages/profil/domain/bloc/driver_profile_event.dart

import 'dart:io';

abstract class DriverProfileEvent {}

class LoadDriverProfileEvent extends DriverProfileEvent {}

class UpdateDriverProfileEvent extends DriverProfileEvent {
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? email;
  final String? address;

  UpdateDriverProfileEvent({
    this.firstName,
    this.lastName,
    this.phone,
    this.email,
    this.address,
  });
}

class UpdateDriverProfilePhotoEvent extends DriverProfileEvent {
  final File photoFile;

  UpdateDriverProfilePhotoEvent(this.photoFile);
}

class DeleteDriverProfilePhotoEvent extends DriverProfileEvent {}

class RefreshDriverProfileEvent extends DriverProfileEvent {}