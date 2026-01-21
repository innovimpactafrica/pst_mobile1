import '../../data/models/ user_model.dart';


abstract class ProfilState {}

class ProfilInitial extends ProfilState {}

class ProfilLoading extends ProfilState {}

class ProfilLoaded extends ProfilState {
  final UserModel user;

  ProfilLoaded(this.user);
}

class ProfilUpdating extends ProfilState {}

class ProfilUpdated extends ProfilState {
  final UserModel user;

  ProfilUpdated(this.user);
}

class ProfilError extends ProfilState {
  final String message;

  ProfilError(this.message);
}

class LogoutSuccess extends ProfilState {}