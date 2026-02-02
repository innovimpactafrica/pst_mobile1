

import '../../data/models/report_model.dart';

abstract class ReportState {}

class ReportInitial extends ReportState {}

class ReportLoading extends ReportState {}

class ReportsLoaded extends ReportState {
  final List<ReportModel> reports;
  final List<ReportModel> filteredReports;
  final String currentFilter;
  final String searchQuery;

  ReportsLoaded({
    required this.reports,
    required this.filteredReports,
    this.currentFilter = 'Tous',
    this.searchQuery = '',
  });

  ReportsLoaded copyWith({
    List<ReportModel>? reports,
    List<ReportModel>? filteredReports,
    String? currentFilter,
    String? searchQuery,
  }) {
    return ReportsLoaded(
      reports: reports ?? this.reports,
      filteredReports: filteredReports ?? this.filteredReports,
      currentFilter: currentFilter ?? this.currentFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class ReportCreating extends ReportState {}

class ReportCreated extends ReportState {
  final ReportModel report;

  ReportCreated(this.report);
}


class ReportUpdating extends ReportState {}

class ReportUpdated extends ReportState {
  final ReportModel report;

  ReportUpdated(this.report);
}


class ReportDeleting extends ReportState {}

class ReportDeleted extends ReportState {}

class ReportError extends ReportState {
  final String message;

  ReportError(this.message);
}