import '../../data/models/ user_model.dart';


abstract class ProfilEvent {}

class LoadUserProfileEvent extends ProfilEvent {}

class UpdateUserProfileEvent extends ProfilEvent {
  final UserModel user;

  UpdateUserProfileEvent(this.user);
}

class LogoutEvent extends ProfilEvent {}