import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/school_service.dart';
import 'school_event.dart';
import 'school_state.dart';

class SchoolBloc extends Bloc<SchoolEvent, SchoolState> {
  final SchoolService _schoolService = SchoolService();

  SchoolBloc() : super(SchoolInitialState()) {
    on<LoadSchoolsEvent>(_onLoadSchools);
    on<CreateSchoolEvent>(_onCreateSchool);
    on<UpdateSchoolEvent>(_onUpdateSchool);
    on<FindOrCreateSchoolEvent>(_onFindOrCreateSchool);
  }

  Future<void> _onLoadSchools(
    LoadSchoolsEvent event,
    Emitter<SchoolState> emit,
  ) async {
    try {
      emit(SchoolLoadingState());
      final schools = await _schoolService.fetchSchools();
      emit(SchoolLoadedState(schools));
    } catch (e) {
      emit(SchoolErrorState(e.toString()));
    }
  }

  Future<void> _onCreateSchool(
    CreateSchoolEvent event,
    Emitter<SchoolState> emit,
  ) async {
    try {
      emit(SchoolLoadingState());
      final school = await _schoolService.createSchool(event.school);
      emit(SchoolCreatedState(school));
      
      // Recharger la liste après création
      add(LoadSchoolsEvent());
    } catch (e) {
      emit(SchoolErrorState(e.toString()));
    }
  }

  Future<void> _onUpdateSchool(
    UpdateSchoolEvent event,
    Emitter<SchoolState> emit,
  ) async {
    try {
      emit(SchoolLoadingState());
      await _schoolService.updateSchool(event.school);
      
      // Recharger la liste après mise à jour
      add(LoadSchoolsEvent());
    } catch (e) {
      emit(SchoolErrorState(e.toString()));
    }
  }

  Future<void> _onFindOrCreateSchool(
    FindOrCreateSchoolEvent event,
    Emitter<SchoolState> emit,
  ) async {
    try {
      emit(SchoolLoadingState());
      final school = await _schoolService.findOrCreateSchool(
        event.schoolName,
        event.address,
      );
      emit(SchoolCreatedState(school));
    } catch (e) {
      emit(SchoolErrorState(e.toString()));
    }
  }
}