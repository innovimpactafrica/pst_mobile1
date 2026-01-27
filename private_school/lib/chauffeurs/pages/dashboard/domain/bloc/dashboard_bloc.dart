
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/dashboard_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository repository;

  DashboardBloc({required this.repository}) : super(DashboardInitial()) {
    on<LoadDashboardEvent>(_onLoadDashboard);
    on<RefreshDashboardEvent>(_onRefreshDashboard);
  }

  Future<void> _onLoadDashboard(
    LoadDashboardEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    try {
      final dashboard = await repository.getDashboard();
      emit(DashboardLoaded(dashboard));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> _onRefreshDashboard(
    RefreshDashboardEvent event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      final dashboard = await repository.getDashboard();
      emit(DashboardLoaded(dashboard));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }
}