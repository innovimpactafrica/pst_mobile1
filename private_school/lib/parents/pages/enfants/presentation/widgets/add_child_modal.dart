import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:private_school/core/utils/google_maps_config.dart';
import 'package:private_school/parents/pages/school/domain/bloc/school_bloc.dart';
import 'package:private_school/parents/pages/school/domain/bloc/school_event.dart' show FindOrCreateSchoolEvent;
import 'package:private_school/parents/pages/school/domain/bloc/school_state.dart';
import 'package:private_school/parents/widgets/address_picker_widget.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../data/models/child_model.dart';
import '../../domain/bloc/child_bloc.dart';
import '../../domain/bloc/child_event.dart';
import '../../domain/bloc/child_state.dart';


class AddChildModal extends StatefulWidget {
  const AddChildModal({super.key});

  @override
  State<AddChildModal> createState() => _AddChildModalState();
}

class _AddChildModalState extends State<AddChildModal> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _schoolNameController = TextEditingController();
  final _schoolAddressController = TextEditingController();
  final _birthDateController = TextEditingController(); // ✅ AJOUTÉ
  final _gradeController = TextEditingController(); // ✅ AJOUTÉ

  bool _isLoading = false;
  int? _createdSchoolId;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _schoolNameController.dispose();
    _schoolAddressController.dispose();
    _birthDateController.dispose(); // ✅ AJOUTÉ
    _gradeController.dispose(); // ✅ AJOUTÉ
    super.dispose();
  }

  // ✅ NOUVELLE MÉTHODE : Sélectionner la date de naissance
  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2015, 1, 1),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.success),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _birthDateController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final schoolName = _schoolNameController.text.trim();
      final schoolAddress = _schoolAddressController.text.trim();

      context.read<SchoolBloc>().add(
        FindOrCreateSchoolEvent(schoolName, schoolAddress),
      );
    }
  }

  void _createChildWithSchool(int schoolId) {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final fullName = '$firstName $lastName';

    final child = ChildModel(
      name: fullName,
      address: _addressController.text.trim(),
      schoolId: schoolId,
      birthDate: _birthDateController.text.trim().isNotEmpty 
          ? _birthDateController.text.trim() 
          : null, // ✅ AJOUTÉ
      grade: _gradeController.text.trim().isNotEmpty 
          ? _gradeController.text.trim() 
          : null, // ✅ AJOUTÉ
    );

    debugPrint('📤 Création enfant avec école ID: $schoolId');
    debugPrint('   Name: ${child.name}');
    debugPrint('   Address: ${child.address}');
    debugPrint('   Birth Date: ${child.birthDate}');
    debugPrint('   Grade: ${child.grade}');

    context.read<ChildBloc>().add(AddChildEvent(child));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<SchoolBloc, SchoolState>(
          listener: (context, state) {
            if (state is SchoolCreatedState) {
              debugPrint('✅ École créée/trouvée: ${state.school.name} (ID: ${state.school.id})');
              _createdSchoolId = state.school.id;
              
              if (_createdSchoolId != null) {
                _createChildWithSchool(_createdSchoolId!);
              }
            } else if (state is SchoolErrorState) {
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Erreur école: ${state.error}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
        
        BlocListener<ChildBloc, ChildState>(
          listener: (context, state) {
            if (state is ChildActionSuccessState) {
              setState(() => _isLoading = false);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (state is ChildErrorState) {
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        ),
      ],
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    
                    // ===== INFORMATIONS ENFANT =====
                    _buildSectionTitle('Informations de l\'enfant'),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _firstNameController,
                      label: 'Prénom',
                      hint: 'Ex: Ornella',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _lastNameController,
                      label: 'Nom',
                      hint: 'Ex: Diop',
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 16),
                    AddressPickerWidget(
                      controller: _addressController,
                      googleApiKey: GoogleMapsConfig.apiKey,
                      label: 'Adresse de l\'enfant',
                      hint: 'Ex: Ouakam cité avions',
                      onLocationSelected: (lat, lng) {
                        // Coordonnées reçues mais non utilisées pour l'instant
                      },
                    ),
                    
                    // ✅ AJOUTÉ : Date de naissance
                    const SizedBox(height: 16),
                    _buildDateField(
                      controller: _birthDateController,
                      label: 'Date de naissance',
                      hint: 'Ex: 2015-05-15',
                      icon: Icons.cake_outlined,
                      onTap: _selectBirthDate,
                    ),
                    
                    // ✅ AJOUTÉ : Classe
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _gradeController,
                      label: 'Classe',
                      hint: 'Ex: CE1',
                      icon: Icons.school,
                    ),
                    
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 24),
                    
                    // ===== INFORMATIONS ÉCOLE =====
                    _buildSectionTitle('Informations de l\'école'),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _schoolNameController,
                      label: 'Nom de l\'école',
                      hint: 'Ex: Lycée Jean Mermoz',
                      icon: Icons.school_outlined,
                    ),
                    const SizedBox(height: 16),
                    AddressPickerWidget(
                      controller: _schoolAddressController,
                      googleApiKey: GoogleMapsConfig.apiKey,
                      label: 'Adresse de l\'école',
                      hint: 'Ex: Ouakam, Dakar',
                      onLocationSelected: (lat, lng) {
                        // Coordonnées reçues mais non utilisées pour l'instant
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Ajouter un enfant',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        IconButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: Colors.black54),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool required = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            if (!required)
              Text(
                ' (optionnel)',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: !_isLoading,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
            prefixIcon: Icon(icon, color: AppColors.success.withValues(alpha: 0.7)),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.success, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          validator: required
              ? (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ce champ est requis';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }

  // ✅ NOUVELLE MÉTHODE : Champ de date avec sélecteur
  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            Text(
              ' (optionnel)',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: !_isLoading,
          readOnly: true,
          onTap: onTap,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
            prefixIcon: Icon(icon, color: AppColors.success.withValues(alpha: 0.7)),
            suffixIcon: Icon(Icons.calendar_today, color: Colors.grey.shade400, size: 18),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.success, width: 2),
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
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.success,
          disabledBackgroundColor: AppColors.success.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Ajouter',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}