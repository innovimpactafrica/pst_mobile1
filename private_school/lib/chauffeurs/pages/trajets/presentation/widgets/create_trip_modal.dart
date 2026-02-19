import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart' as easy;

import '../../../../../core/utils/app_colors.dart';
import '../../../../../parents/pages/school/data/models/school_model.dart';
import '../../../../../parents/pages/school/data/services/school_service.dart';
import '../../domain/bloc/trip_bloc.dart';
import '../../domain/bloc/trip_event.dart';
import '../../domain/bloc/trip_state.dart';
import '../../data/services/child_service.dart';
import '../../../../../shared/widgets/place_autocomplete_field.dart';
class CreateTripModal extends StatefulWidget {
  const CreateTripModal({super.key});

  @override
  State<CreateTripModal> createState() => _CreateTripModalState();
}

class _CreateTripModalState extends State<CreateTripModal> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _startPointController = TextEditingController();
  final _endPointController = TextEditingController();
  final _timeController = TextEditingController();
  final _returnTimeController = TextEditingController();
  final _passengersController = TextEditingController();

  final SchoolService _schoolService = SchoolService();
  final ChildService _childService = ChildService();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  TimeOfDay? _selectedReturnTime;
  
  List<SchoolModel> _schools = [];
  bool _loadingSchools = true;
  
  // Liste des arrêts (écoles sélectionnées)
  List<SchoolStop> _stops = [SchoolStop()];
  
  double? _startLatitude;
  double? _startLongitude;
  double? _endLatitude;
  double? _endLongitude;

  @override
  void initState() {
    super.initState();
    _loadSchools();
  }

  Future<void> _loadSchools() async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔵 [CreateTripModal] Chargement des écoles...');
      
      final schools = await _schoolService.fetchSchools();
      
      setState(() {
        _schools = schools;
        _loadingSchools = false;
      });
      
      debugPrint('✅ ${schools.length} école(s) chargée(s)');
      for (var school in schools) {
        debugPrint('   📚 ${school.name} (ID: ${school.id})');
      }
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    } catch (e) {
      debugPrint('❌ Erreur chargement écoles: $e');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      setState(() => _loadingSchools = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('error_loading_schools'.tr()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _updateChildrenCount(int index) async {
    final stop = _stops[index];
    if (stop.selectedSchoolId == null) {
      setState(() {
        stop.childrenCount = 0;
        stop.loadingChildrenCount = false;
      });
      return;
    }

    setState(() => stop.loadingChildrenCount = true);

    try {
      final children = await _childService.getChildrenBySchool(stop.selectedSchoolId!);
      setState(() {
        stop.childrenCount = children.length;
        stop.loadingChildrenCount = false;
      });
      debugPrint('✅ ${children.length} enfant(s) trouvé(s) pour école ID: ${stop.selectedSchoolId}');
    } catch (e) {
      debugPrint('❌ Erreur chargement enfants: $e');
      setState(() => stop.loadingChildrenCount = false);
    }
  }

  void _addStop() {
    setState(() {
      _stops.add(SchoolStop());
    });
  }

  void _removeStop(int index) {
    if (_stops.length > 1) {
      setState(() {
        _stops.removeAt(index);
      });
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _startPointController.dispose();
    _endPointController.dispose();
    _timeController.dispose();
    _returnTimeController.dispose();
    _passengersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TripBloc, TripState>(
      listener: (context, state) {
        if (state is TripCreated) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('trip_created_successfully'.tr()),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state is TripError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_getErrorMessage(state.message)),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(),
            _buildHeader(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCompactField(
                        label: 'date'.tr(),
                        controller: _dateController,
                        hint: '12/02/2026',
                        readOnly: true,
                        suffixIcon: Icons.calendar_today,
                        onTap: _selectDate,
                      ),
                      const SizedBox(height: 16),
                      PlaceAutocompleteField(
                        label: 'start_point'.tr(),
                        hint: 'Ex: Ouakam, Almadies...',
                        controller: _startPointController,
                        onPlaceSelected: (details) {
                          setState(() {
                            _startLatitude = details.latitude;
                            _startLongitude = details.longitude;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      PlaceAutocompleteField(
                        label: 'Point d\'arrivée',
                        hint: 'Ex: Ouakam, Almadies...',
                        controller: _endPointController,
                        onPlaceSelected: (details) {
                          setState(() {
                            _endLatitude = details.latitude;
                            _endLongitude = details.longitude;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      ..._buildStopsSection(),
                      
                      const SizedBox(height: 16),
                      _buildTimeField(
                        label: 'departure_time'.tr(),
                        controller: _timeController,
                        hint: '10 : 20 (optionnel)',
                        onTap: _selectTime,
                        onClear: () {
                          setState(() {
                            _selectedTime = null;
                            _timeController.clear();
                          });
                        },
                        hasValue: _selectedTime != null,
                      ),
                      const SizedBox(height: 16),
                      _buildTimeField(
                        label: 'return_time'.tr(),
                        controller: _returnTimeController,
                        hint: '14 : 30 (optionnel)',
                        onTap: _selectReturnTime,
                        onClear: () {
                          setState(() {
                            _selectedReturnTime = null;
                            _returnTimeController.clear();
                          });
                        },
                        hasValue: _selectedReturnTime != null,
                      ),
                      const SizedBox(height: 16),
                      _buildCompactField(
                        label: 'number_of_passengers'.tr(),
                        controller: _passengersController,
                        hint: '5',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 24),
                      _buildSubmitButton(),
                      SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE5E5E5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Proposer un trajet',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(4),
              child: const Icon(
                Icons.close,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStopsSection() {
    List<Widget> widgets = [];
    
    for (int i = 0; i < _stops.length; i++) {
      widgets.add(_buildStopDropdown(i));
      if (i < _stops.length - 1) {
        widgets.add(const SizedBox(height: 16));
      }
    }
    
    // Bouton pour ajouter un autre arrêt
    widgets.add(const SizedBox(height: 12));
    widgets.add(
      OutlinedButton.icon(
        onPressed: _addStop,
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Ajouter un autre arrêt'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),
    );
    
    return widgets;
  }

  Widget _buildStopDropdown(int index) {
    final stop = _stops[index];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Arrêt ${index + 1}',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            if (_stops.length > 1)
              IconButton(
                icon: const Icon(Icons.close, size: 18, color: AppColors.error),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => _removeStop(index),
              ),
          ],
        ),
        const SizedBox(height: 8),
        
        _loadingSchools
            ? Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Chargement des écoles...',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
            : DropdownButtonFormField<SchoolModel>(
                value: stop.selectedSchool,
                menuMaxHeight: 300,
                itemHeight: 56, 
                decoration: InputDecoration(
                  hintText: 'Sélectionnez une école',
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.school_outlined,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              items: _schools.reversed.map((school) {
  return DropdownMenuItem<SchoolModel>(
    value: school,
    child: SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            school.name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          if (school.address.isNotEmpty)
            Text(
              school.address,
              style: TextStyle(
                fontSize: 11, // réduit de 12 à 11
                color: AppColors.textSecondary.withValues(alpha: 0.7),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
        ],
      ),
    ),
  );
}).toList(),
                onChanged: (SchoolModel? school) {
                  setState(() {
                    stop.selectedSchool = school;
                    stop.selectedSchoolId = school?.id;
                  });
                  _updateChildrenCount(index);
                },
                validator: (value) {
                  if (value == null) {
                    return 'Veuillez sélectionner une école';
                  }
                  return null;
                },
              ),
        
        if (stop.selectedSchoolId != null) ...[
          const SizedBox(height: 12),
          if (stop.loadingChildrenCount)
            const Row(
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Calcul du nombre d\'enfants...',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: stop.childrenCount > 0 
                    ? AppColors.successBackground 
                    : const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: stop.childrenCount > 0 
                      ? AppColors.success 
                      : const Color(0xFFF59E0B),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    stop.childrenCount > 0 ? Icons.people : Icons.warning_amber,
                    size: 16,
                    color: stop.childrenCount > 0 
                        ? AppColors.success 
                        : const Color(0xFFF59E0B),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      stop.childrenCount > 0
                          ? '${stop.childrenCount} enfant${stop.childrenCount > 1 ? 's' : ''} inscrit${stop.childrenCount > 1 ? 's' : ''} dans cette école'
                          : 'Aucun enfant inscrit dans cette école',
                      style: TextStyle(
                        fontSize: 12,
                        color: stop.childrenCount > 0 
                            ? AppColors.success 
                            : const Color(0xFFF59E0B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildCompactField({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool readOnly = false,
    IconData? suffixIcon,
    VoidCallback? onTap,
    TextInputType? keyboardType,
    bool isOptional = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isOptional)
              Text(
                ' (optionnel)',
                style: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          keyboardType: keyboardType,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.5),
              fontSize: 14,
            ),
            suffixIcon: suffixIcon != null
                ? Icon(
                    suffixIcon,
                    color: AppColors.textSecondary,
                    size: 20,
                  )
                : null,
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          validator: isOptional
              ? null
              : (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ce champ est requis';
                  }
                  return null;
                },
        ),
      ],
    );
  }

  Widget _buildTimeField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required VoidCallback onTap,
    required VoidCallback onClear,
    required bool hasValue,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              ' (optionnel)',
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.7),
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: onTap,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.5),
              fontSize: 14,
            ),
            suffixIcon: hasValue
                ? IconButton(
                    icon: const Icon(
                      Icons.clear,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: onClear,
                  )
                : const Icon(
                    Icons.access_time,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<TripBloc, TripState>(
      builder: (context, state) {
        final isLoading = state is TripCreating;

        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: isLoading ? null : _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                    ),
                  )
                : const Text(
                    'Confirmer',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Future<void> _selectDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('fr', 'FR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        final hour = picked.hour.toString().padLeft(2, '0');
        final minute = picked.minute.toString().padLeft(2, '0');
        _timeController.text = '$hour : $minute';
      });
    }
  }

  Future<void> _selectReturnTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedReturnTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedReturnTime = picked;
        final hour = picked.hour.toString().padLeft(2, '0');
        final minute = picked.minute.toString().padLeft(2, '0');
        _returnTimeController.text = '$hour : $minute';
      });
    }
  }

  String _getErrorMessage(String error) {
    if (error.contains('passé')) {
      return 'La date et l\'heure doivent être dans le futur';
    } else if (error.contains('Champs obligatoires')) {
      return 'Veuillez remplir tous les champs';
    } else if (error.contains('school_id')) {
      return 'École invalide';
    }
    return 'Erreur lors de la création du trajet';
  }

  void _submitForm() {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('📤 [CreateTripModal] SUBMIT FORM');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    
    // Validation manuelle des champs PlaceAutocomplete
    if (_startPointController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un point de départ'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_endPointController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un point d\'arrivée'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    if (_formKey.currentState!.validate()) {
      debugPrint('✅ Validation du formulaire OK');

      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner une date'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      if (_selectedTime == null && _selectedReturnTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez renseigner au moins une heure (départ ou retour)'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      DateTime? departureTime;
      if (_selectedTime != null) {
        departureTime = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        );

        if (departureTime.isBefore(DateTime.now())) {
          debugPrint('❌ Date de départ dans le passé');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('La date et l\'heure de départ doivent être dans le futur'),
              backgroundColor: AppColors.error,
              duration: Duration(seconds: 3),
            ),
          );
          return;
        }
      }

      DateTime? returnTime;
      if (_selectedReturnTime != null) {
        returnTime = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedReturnTime!.hour,
          _selectedReturnTime!.minute,
        );

        if (returnTime.isBefore(DateTime.now())) {
          debugPrint('❌ Date de retour dans le passé');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('La date et l\'heure de retour doivent être dans le futur'),
              backgroundColor: AppColors.error,
              duration: Duration(seconds: 3),
            ),
          );
          return;
        }
      }

      final capacity = int.tryParse(_passengersController.text) ?? 0;

      if (capacity <= 0) {
        debugPrint('❌ Capacité invalide: $capacity');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Le nombre de passagers doit être supérieur à 0'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      // Récupérer les IDs des écoles sélectionnées
      final schoolIds = _stops
          .where((stop) => stop.selectedSchoolId != null)
          .map((stop) => stop.selectedSchoolId!)
          .toList();

      if (schoolIds.isEmpty) {
        debugPrint('❌ Aucune école sélectionnée');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner au moins une école'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      debugPrint('✅ Toutes les validations passées');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📤 DONNÉES DU TRAJET:');
      debugPrint('   📍 Départ: ${_startPointController.text.trim()}');
      debugPrint('   🎯 Arrivée: ${_endPointController.text.trim()}');
      debugPrint('   🏫 Écoles IDs: $schoolIds');
      debugPrint('   🕐 Date/Heure départ: ${departureTime ?? "Non spécifiée"}');
      debugPrint('   🕐 Date/Heure retour: ${returnTime ?? "Non spécifiée"}');
      debugPrint('   👥 Capacité: $capacity');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      context.read<TripBloc>().add(
            CreateTripEvent(
              startPoint: _startPointController.text.trim(),
              endPoint: _endPointController.text.trim(),
              departureTime: departureTime,
              returnTime: returnTime,
              capacityMax: capacity,
              schoolIds: schoolIds,
              isRecurring: false,
              startLatitude: _startLatitude,
              startLongitude: _startLongitude,
              endLatitude: _endLatitude,
              endLongitude: _endLongitude,
            ),
          );
    } else {
      debugPrint('❌ Validation du formulaire échouée');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    }
  }
}

// Classe pour gérer chaque arrêt (école)
class SchoolStop {
  SchoolModel? selectedSchool;
  int? selectedSchoolId;
  int childrenCount = 0;
  bool loadingChildrenCount = false;

  SchoolStop({
    this.selectedSchool,
    this.selectedSchoolId,
    this.childrenCount = 0,
    this.loadingChildrenCount = false,
  });
}

void showCreateTripModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const CreateTripModal(),
  );
}