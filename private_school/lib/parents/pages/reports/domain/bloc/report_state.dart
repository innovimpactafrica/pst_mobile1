

import '../../data/models/report_model.dart';

abstract class ReportState {}

class ReportInitial extends ReportState {}

class ReportLoading extends ReportState {}

class ReportsLoaded extends ReportState {
  final List<ReportModel> reports;
  final List<ReportModel> filteredReports;
  final String currentFilter;
  final String searchQuery;
  final int currentPage;
  final int totalPages;
  final int total;
  final bool hasMore;
  final bool isLoadingMore;

  ReportsLoaded({
    required this.reports,
    required this.filteredReports,
    this.currentFilter = 'Tous',
    this.searchQuery = '',
    this.currentPage = 1,
    this.totalPages = 1,
    this.total = 0,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  ReportsLoaded copyWith({
    List<ReportModel>? reports,
    List<ReportModel>? filteredReports,
    String? currentFilter,
    String? searchQuery,
    int? currentPage,
    int? totalPages,
    int? total,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return ReportsLoaded(
      reports: reports ?? this.reports,
      filteredReports: filteredReports ?? this.filteredReports,
      currentFilter: currentFilter ?? this.currentFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
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