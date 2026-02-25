import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';

abstract class DriverProfileEvent extends Equatable {
  const DriverProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadDriverProfileEvent extends DriverProfileEvent {}

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

class UpdateDriverProfileWithPhotoEvent extends DriverProfileEvent {
  final FormData formData;

  const UpdateDriverProfileWithPhotoEvent({required this.formData});

  @override
  List<Object?> get props => [formData];
}

class UpdateDriverByIdEvent extends DriverProfileEvent {
  final String driverId;
  final FormData formData;

  const UpdateDriverByIdEvent({required this.driverId, required this.formData});

  @override
  List<Object?> get props => [driverId, formData];
}
