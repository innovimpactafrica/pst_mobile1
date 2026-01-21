import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/user_repository.dart';
import 'profil_event.dart';
import 'profil_state.dart';

class ProfilBloc extends Bloc<ProfilEvent, ProfilState> {
  final UserRepository repository;

  ProfilBloc({required this.repository}) : super(ProfilInitial()) {
    on<LoadUserProfileEvent>(_onLoadUserProfile);
    on<UpdateUserProfileEvent>(_onUpdateUserProfile);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onLoadUserProfile(
      LoadUserProfileEvent event,
      Emitter<ProfilState> emit,
      ) async {
    emit(ProfilLoading());
    try {
      final user = await repository.getCurrentUser();
      emit(ProfilLoaded(user));
    } catch (e) {
      emit(ProfilError('Erreur lors du chargement du profil'));
    }
  }

  Future<void> _onUpdateUserProfile(
      UpdateUserProfileEvent event,
      Emitter<ProfilState> emit,
      ) async {
    emit(ProfilUpdating());
    try {
      final updatedUser = await repository.updateUser(event.user);
      emit(ProfilUpdated(updatedUser));
      emit(ProfilLoaded(updatedUser));
    } catch (e) {
      emit(ProfilError('Erreur lors de la mise à jour'));
    }
  }

  Future<void> _onLogout(
      LogoutEvent event,
      Emitter<ProfilState> emit,
      ) async {
    try {
      await repository.logout();
      emit(LogoutSuccess());
    } catch (e) {
      emit(ProfilError('Erreur lors de la déconnexion'));
    }
  }
}