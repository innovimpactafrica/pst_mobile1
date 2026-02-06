import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../parents/pages/school/data/models/school_model.dart';
import '../../../../../parents/pages/school/data/services/school_service.dart';
import '../../domain/bloc/trip_bloc.dart';
import '../../domain/bloc/trip_event.dart';
import '../../domain/bloc/trip_state.dart';
import '../../data/services/child_service.dart';

class CreateTripModal extends StatefulWidget {
  const CreateTripModal({super.key});

  @override
  State<CreateTripModal> createState() => _CreateTripModalState();
}

class _CreateTripModalState extends State<CreateTripModal> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _startPointController = TextEditingController();
  final _timeController = TextEditingController();
  final _passengersController = TextEditingController();

  final SchoolService _schoolService = SchoolService();
  final ChildService _childService = ChildService();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  
  // ✅ Une seule école
  List<SchoolModel> _schools = [];
  SchoolModel? _selectedSchool;
  bool _loadingSchools = true;
  
  // ✅ Compteur d'enfants
  int _childrenCount = 0;
  bool _loadingChildrenCount = false;

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
          const SnackBar(
            content: Text('Erreur lors du chargement des écoles'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// ✅ Charger le nombre d'enfants pour l'école sélectionnée
  Future<void> _updateChildrenCount() async {
    if (_selectedSchool == null || _selectedSchool!.id == null) {
      setState(() => _childrenCount = 0);
      return;
    }

    setState(() => _loadingChildrenCount = true);

    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('👶 [CreateTripModal] Chargement enfants...');
      debugPrint('🏫 École: ${_selectedSchool!.name} (ID: ${_selectedSchool!.id})');
      
      final children = await _childService.getChildrenBySchool(_selectedSchool!.id!);

      setState(() {
        _childrenCount = children.length;
        _loadingChildrenCount = false;
      });

      debugPrint('✅ ${children.length} enfant(s) trouvé(s)');
      if (children.isNotEmpty) {
        for (var child in children) {
          debugPrint('   👤 ${child.name} (${child.address})');
        }
      } else {
        debugPrint('⚠️ Aucun enfant inscrit dans cette école');
      }
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    } catch (e) {
      debugPrint('❌ Erreur chargement enfants: $e');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      setState(() => _loadingChildrenCount = false);
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _startPointController.dispose();
    _timeController.dispose();
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
            const SnackBar(
              content: Text('Trajet créé avec succès !'),
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
                        label: 'Date',
                        controller: _dateController,
                        hint: '12/02/2026',
                        readOnly: true,
                        suffixIcon: Icons.calendar_today,
                        onTap: _selectDate,
                      ),
                      const SizedBox(height: 16),
                      _buildCompactField(
                        label: 'Point de départ',
                        controller: _startPointController,
                        hint: 'EX: almadie 2',
                      ),
                      const SizedBox(height: 16),
                      
                      // ✅ Dropdown pour sélectionner UNE école
                      _buildSchoolDropdown(),
                      
                      const SizedBox(height: 16),
                      _buildCompactField(
                        label: 'Heure de départ',
                        controller: _timeController,
                        hint: '10 : 20',
                        readOnly: true,
                        suffixIcon: Icons.access_time,
                        onTap: _selectTime,
                      ),
                      const SizedBox(height: 16),
                      _buildCompactField(
                        label: 'Nombres de passagers',
                        controller: _passengersController,
                        hint: '5',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 24),
                      _buildSubmitButton(),
                      SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
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

  /// ✅ Dropdown pour sélectionner l'école
  Widget _buildSchoolDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'École de destination',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
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
            : _schools.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFF59E0B)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning_amber, color: Color(0xFFF59E0B)),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Aucune école disponible.',
                            style: TextStyle(
                              color: Color(0xFFF59E0B),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<SchoolModel>(
                        initialValue: _selectedSchool,
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
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.error,
                              width: 1,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.error,
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        items: _schools.map((school) {
                          return DropdownMenuItem<SchoolModel>(
                            value: school,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  school.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                if (school.address.isNotEmpty)
                                  Text(
                                    school.address,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary.withValues(alpha: 0.7),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (SchoolModel? school) {
                          setState(() {
                            _selectedSchool = school;
                          });
                          
                          debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
                          debugPrint('✅ École sélectionnée: ${school?.name}');
                          debugPrint('🆔 ID: ${school?.id}');
                          debugPrint('📍 Adresse: ${school?.address}');
                          debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
                          
                          _updateChildrenCount();
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Veuillez sélectionner une école';
                          }
                          return null;
                        },
                      ),
                      
                      // ✅ Afficher le nombre d'enfants
                      if (_selectedSchool != null) ...[
                        const SizedBox(height: 12),
                        if (_loadingChildrenCount)
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
                              color: _childrenCount > 0 
                                  ? AppColors.successBackground 
                                  : const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _childrenCount > 0 
                                    ? AppColors.success 
                                    : const Color(0xFFF59E0B),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _childrenCount > 0 ? Icons.people : Icons.warning_amber,
                                  size: 16,
                                  color: _childrenCount > 0 
                                      ? AppColors.success 
                                      : const Color(0xFFF59E0B),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _childrenCount > 0
                                        ? '$_childrenCount enfant${_childrenCount > 1 ? 's' : ''} inscrit${_childrenCount > 1 ? 's' : ''} dans cette école'
                                        : 'Aucun enfant inscrit dans cette école',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _childrenCount > 0 
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
                  ),
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
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
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Ce champ est requis';
            }
            return null;
          },
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
    
    if (_formKey.currentState!.validate()) {
      debugPrint('✅ Validation du formulaire OK');
      
      // ✅ Vérifier que l'école est sélectionnée
      if (_selectedSchool == null) {
        debugPrint('❌ Aucune école sélectionnée');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner une école'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      if (_selectedSchool!.id == null) {
        debugPrint('❌ École sélectionnée sans ID');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur: École invalide (pas d\'ID)'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      if (_selectedDate == null || _selectedTime == null) {
        debugPrint('❌ Date ou heure manquante');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner la date et l\'heure'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      final departureTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      if (departureTime.isBefore(DateTime.now())) {
        debugPrint('❌ Date dans le passé');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La date et l\'heure doivent être dans le futur'),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      final capacity = int.tryParse(_passengersController.text) ?? 0;

      if (capacity <= 0) {
        debugPrint('❌ Capacité invalide: $capacity');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Le nombre de passagers doit être supérieur à 0'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      // ✅ Tout est OK, on envoie
      debugPrint('✅ Toutes les validations passées');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📤 DONNÉES DU TRAJET:');
      debugPrint('   📍 Point de départ: ${_startPointController.text.trim()}');
      debugPrint('   🏫 École: ${_selectedSchool!.name}');
      debugPrint('   🆔 School ID: ${_selectedSchool!.id}');
      debugPrint('   🕐 Date/Heure: $departureTime');
      debugPrint('   👥 Capacité: $capacity');
      debugPrint('   👶 Enfants inscrits: $_childrenCount');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      context.read<TripBloc>().add(
            CreateTripEvent(
              startPoint: _startPointController.text.trim(),
              endPoint: _selectedSchool!.name,
              departureTime: departureTime,
              capacityMax: capacity,
              schoolId: _selectedSchool!.id!, // ✅ Un seul ID
              isRecurring: false,
            ),
          );
    } else {
      debugPrint('❌ Validation du formulaire échouée');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    }
  }
}

void showCreateTripModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const CreateTripModal(),
  );
}