import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/report_repository.dart';
import '../../data/models/report_model.dart';
import 'report_event.dart';
import 'report_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final ReportRepository _repository = ReportRepository();

  ReportBloc() : super(ReportInitial()) {
    on<LoadReportsEvent>(_onLoadReports);
    on<RefreshReportsEvent>(_onRefreshReports);
    on<FilterReportsEvent>(_onFilterReports);
    on<SearchReportsEvent>(_onSearchReports);
    on<CreateReportEvent>(_onCreateReport);
    on<UpdateReportEvent>(_onUpdateReport);
    on<UpdateReportStatusEvent>(_onUpdateReportStatus);
    on<DeleteReportEvent>(_onDeleteReport);
  }

  Future<void> _onLoadReports(
    LoadReportsEvent event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportLoading());

    try {
      final reports = await _repository.getReports();

      emit(ReportsLoaded(
        reports: reports,
        filteredReports: reports,
        currentFilter: 'Tous',
        searchQuery: '',
      ));
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }

  Future<void> _onRefreshReports(
    RefreshReportsEvent event,
    Emitter<ReportState> emit,
  ) async {
    try {
      final reports = await _repository.getReports();

      if (state is ReportsLoaded) {
        final currentState = state as ReportsLoaded;
        final filtered = _applyFilters(
          reports,
          currentState.currentFilter,
          currentState.searchQuery,
        );

        emit(currentState.copyWith(
          reports: reports,
          filteredReports: filtered,
        ));
      } else {
        emit(ReportsLoaded(
          reports: reports,
          filteredReports: reports,
        ));
      }
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }

  void _onFilterReports(
    FilterReportsEvent event,
    Emitter<ReportState> emit,
  ) {
    if (state is ReportsLoaded) {
      final currentState = state as ReportsLoaded;
      final filtered = _applyFilters(
        currentState.reports,
        event.filter,
        currentState.searchQuery,
      );

      emit(currentState.copyWith(
        filteredReports: filtered,
        currentFilter: event.filter,
      ));
    }
  }

  void _onSearchReports(
    SearchReportsEvent event,
    Emitter<ReportState> emit,
  ) {
    if (state is ReportsLoaded) {
      final currentState = state as ReportsLoaded;
      final filtered = _applyFilters(
        currentState.reports,
        currentState.currentFilter,
        event.query,
      );

      emit(currentState.copyWith(
        filteredReports: filtered,
        searchQuery: event.query,
      ));
    }
  }

  List<ReportModel> _applyFilters(
    List<ReportModel> reports,
    String filter,
    String searchQuery,
  ) {
    var filtered = reports;

    // Apply type filter
    if (filter != 'Tous') {
      filtered = filtered.where((report) {
        switch (filter) {
          case 'Incident':
            return report.type.toLowerCase() == 'incident';
          case 'Litiges':
            return report.type.toLowerCase() == 'litige';
          case 'Sécurité':
            return report.type.toLowerCase() == 'securite' ||
                report.type.toLowerCase() == 'sécurité';
          default:
            return true;
        }
      }).toList();
    }

    // Apply search query
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((report) {
        return report.category.toLowerCase().contains(query) ||
            report.description.toLowerCase().contains(query) ||
            report.status.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  Future<void> _onCreateReport(
    CreateReportEvent event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportCreating());

    try {
      final newReport = await _repository.createReport(
        type: event.type,
        category: event.category,
        description: event.description,
        files: event.files,
      );

      emit(ReportCreated(newReport));

     
      await Future.delayed(const Duration(milliseconds: 500));
      add(LoadReportsEvent());
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }

 
  Future<void> _onUpdateReport(
    UpdateReportEvent event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportUpdating()); // 🆕 État de chargement

    try {
      final updatedReport = await _repository.updateReport(
        id: event.id,
        type: event.type,
        description: event.description,
      );

      emit(ReportUpdated(updatedReport)); // 🆕 État de succès

      // Reload reports to reflect changes
      await Future.delayed(const Duration(milliseconds: 500));
      add(LoadReportsEvent());
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }

  Future<void> _onUpdateReportStatus(
    UpdateReportStatusEvent event,
    Emitter<ReportState> emit,
  ) async {
    try {
      await _repository.updateReportStatus(
        id: event.id,
        status: event.status,
      );

      // Reload reports
      add(RefreshReportsEvent());
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }

 
  Future<void> _onDeleteReport(
    DeleteReportEvent event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportDeleting()); // 🆕 État de chargement

    try {
     await _repository.deleteReport(
  event.id,
  event.userId,
);


      emit(ReportDeleted()); // 🆕 État de succès

      // Reload reports after deletion
      await Future.delayed(const Duration(milliseconds: 500));
      add(LoadReportsEvent());
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }
}