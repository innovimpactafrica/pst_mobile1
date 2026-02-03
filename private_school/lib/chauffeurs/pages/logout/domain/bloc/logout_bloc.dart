

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/logout_service.dart';
import 'logout_event.dart';
import 'logout_state.dart';

class LogoutBloc extends Bloc<LogoutEvent, LogoutState> {
  final LogoutService _logoutService = LogoutService();

  LogoutBloc() : super(LogoutInitial()) {
    on<LogoutRequestedEvent>(_onLogoutRequested);
  }

  Future<void> _onLogoutRequested(
    LogoutRequestedEvent event,
    Emitter<LogoutState> emit,
  ) async {
    emit(LogoutLoading());

    try {
      await _logoutService.logout();
      emit(LogoutSuccess());
    } catch (e) {
      emit(LogoutError(e.toString()));
    }
  }
}