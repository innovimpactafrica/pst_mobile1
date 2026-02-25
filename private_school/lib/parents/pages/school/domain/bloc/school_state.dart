import 'package:private_school/parents/pages/school/data/models/school_model.dart';

abstract class SchoolState {}

class SchoolInitialState extends SchoolState {}

class SchoolLoadingState extends SchoolState {}

class SchoolLoadedState extends SchoolState {
  final List<SchoolModel> schools;
  SchoolLoadedState(this.schools);
}

class SchoolCreatedState extends SchoolState {
  final SchoolModel school;
  SchoolCreatedState(this.school);
}

class SchoolErrorState extends SchoolState {
  final String error;
  SchoolErrorState(this.error);
}
