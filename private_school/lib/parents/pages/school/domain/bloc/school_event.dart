import 'package:private_school/parents/pages/school/data/models/school_model.dart';

abstract class SchoolEvent {}

class LoadSchoolsEvent extends SchoolEvent {}

class CreateSchoolEvent extends SchoolEvent {
  final SchoolModel school;
  CreateSchoolEvent(this.school);
}

class UpdateSchoolEvent extends SchoolEvent {
  final SchoolModel school;
  UpdateSchoolEvent(this.school);
}

class FindOrCreateSchoolEvent extends SchoolEvent {
  final String schoolName;
  final String address;
  FindOrCreateSchoolEvent(this.schoolName, this.address);
}
