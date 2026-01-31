import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';

/// Base event class for driver profile
abstract class DriverProfileEvent extends Equatable {
  const DriverProfileEvent();
  
  @override
  List<Object?> get props => [];
}

/// Event to load driver profile
class LoadDriverProfileEvent extends DriverProfileEvent {}

/// Event to update driver profile (simple text fields) - Infos personnelles
class UpdateDriverProfileEvent extends DriverProfileEvent {
  final String firstName;
  final String lastName;
  final String phone;
  final String address;

  const UpdateDriverProfileEvent({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.address,
  });

  @override
  List<Object?> get props => [firstName, lastName, phone, address];
}

/// Event to update driver profile with photo (FormData) - Infos personnelles + photo_profil
/// ⚠️ Pour véhicule et documents, utiliser UpdateDriverByIdEvent
class UpdateDriverProfileWithPhotoEvent extends DriverProfileEvent {
  final FormData formData;

  const UpdateDriverProfileWithPhotoEvent({required this.formData});

  @override
  List<Object?> get props => [formData];
}


class UpdateDriverByIdEvent extends DriverProfileEvent {
  final String driverId;
  final FormData formData;

  const UpdateDriverByIdEvent({
    required this.driverId,
    required this.formData,
  });

  @override
  List<Object?> get props => [driverId, formData];
}