import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:private_school/parents/pages/school/domain/bloc/school_bloc.dart';
import 'package:private_school/parents/pages/school/domain/bloc/school_event.dart';
import 'package:private_school/parents/pages/school/domain/bloc/school_state.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../data/models/child_model.dart';
import '../../domain/bloc/child_bloc.dart';
import '../../domain/bloc/child_event.dart';
import '../../domain/bloc/child_state.dart';


class EditChildModal extends StatefulWidget {
  final ChildModel child;

  const EditChildModal({
    super.key,
    required this.child,
  });

  @override
  State<EditChildModal> createState() => _EditChildModalState();
}

class _EditChildModalState extends State<EditChildModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _schoolNameController; 
  late final TextEditingController _schoolAddressController; 
  late final TextEditingController _gradeController;

  bool _isLoading = false;
  int? _newSchoolId; // ✅ Pour stocker le nouvel ID si l'école change

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.child.name);
    _addressController = TextEditingController(text: widget.child.address);
    _schoolNameController = TextEditingController(
      text: widget.child.schoolName ?? 'École ID: ${widget.child.schoolId}'
    );
    _schoolAddressController = TextEditingController(
      text: widget.child.schoolAddress ?? ''
    );
    _gradeController = TextEditingController(text: widget.child.grade ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _schoolNameController.dispose();
    _schoolAddressController.dispose();
    _gradeController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final schoolName = _schoolNameController.text.trim();
      final schoolAddress = _schoolAddressController.text.trim();

      // ✅ Vérifier si l'école a changé
      final hasSchoolChanged = schoolName != widget.child.schoolName ||
                              schoolAddress != widget.child.schoolAddress;

      if (hasSchoolChanged) {
        // ✅ Créer ou trouver la nouvelle école
        debugPrint('🔄 École modifiée, création/recherche...');
        context.read<SchoolBloc>().add(
          FindOrCreateSchoolEvent(schoolName, schoolAddress),
        );
      } else {
        // ✅ L'école n'a pas changé, mettre à jour directement
        _updateChild(widget.child.schoolId);
      }
    }
  }

  void _updateChild(int schoolId) {
    final updatedChild = widget.child.copyWith(
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      schoolId: schoolId,
      grade: _gradeController.text.trim(),
    );

    debugPrint('📤 Mise à jour enfant:');
    debugPrint('   Name: ${updatedChild.name}');
    debugPrint('   School ID: ${updatedChild.schoolId}');

    context.read<ChildBloc>().add(UpdateChildEvent(updatedChild));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // ✅ Écouter le SchoolBloc
        BlocListener<SchoolBloc, SchoolState>(
          listener: (context, state) {
            if (state is SchoolCreatedState) {
              debugPrint('✅ École créée/trouvée: ${state.school.name} (ID: ${state.school.id})');
              _newSchoolId = state.school.id;
              
              // ✅ Mettre à jour l'enfant avec le nouvel ID d'école
              if (_newSchoolId != null) {
                _updateChild(_newSchoolId!);
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
        
        // ✅ Écouter le ChildBloc
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
                      controller: _nameController,
                      label: 'Nom complet',
                      hint: 'Ex: Marie Dupont',
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _addressController,
                      label: 'Adresse de l\'enfant',
                      hint: 'Ex: Ouakam cité avions',
                      icon: Icons.home_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _gradeController,
                      label: 'Classe',
                      hint: 'Ex: CE1',
                      icon: Icons.class_outlined,
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
                    _buildTextField(
                      controller: _schoolAddressController,
                      label: 'Adresse de l\'école',
                      hint: 'Ex: Ouakam, Dakar',
                      icon: Icons.location_on_outlined,
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
          'Modifier un enfant',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        IconButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          icon: const Icon(Icons.close),
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: !_isLoading,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
            prefixIcon: Icon(icon, color: AppColors.success.withValues(alpha:0.7)),
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
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Ce champ est requis';
            }
            return null;
          },
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
          disabledBackgroundColor: AppColors.success.withValues(alpha:.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
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
                'Mettre à jour',
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