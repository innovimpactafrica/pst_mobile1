import 'dart:io';

abstract class ReportEvent {}

class LoadReportsEvent extends ReportEvent {}

class LoadMoreReportsEvent extends ReportEvent {}

class LoadPageEvent extends ReportEvent {
  final int page;

  LoadPageEvent(this.page);
}

class RefreshReportsEvent extends ReportEvent {}

class FilterReportsEvent extends ReportEvent {
  final String filter;

  FilterReportsEvent(this.filter);
}

class SearchReportsEvent extends ReportEvent {
  final String query;

  SearchReportsEvent(this.query);
}

class CreateReportEvent extends ReportEvent {
  final String type;
  final String category;
  final String description;
  final List<File>? files;

  CreateReportEvent({
    required this.type,
    required this.category,
    required this.description,
    this.files,
  });
}

class UpdateReportEvent extends ReportEvent {
  final int id;
  final String type;
  final String category;
  final String description;
  final List<File>? files;

  UpdateReportEvent({
    required this.id,
    required this.type,
    required this.category,
    required this.description,
    this.files,
  });
}

class UpdateReportStatusEvent extends ReportEvent {
  final int id;
  final String status;

  UpdateReportStatusEvent({required this.id, required this.status});
}

class DeleteReportEvent extends ReportEvent {
  final int id;
  final int userId;

  DeleteReportEvent({required this.id, required this.userId});
}
