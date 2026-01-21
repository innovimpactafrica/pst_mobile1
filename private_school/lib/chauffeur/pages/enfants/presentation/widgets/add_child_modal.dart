import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../utils/app_colors.dart';
import '../../data/models/child_model.dart';
import '../../domain/bloc/child_bloc.dart';
import '../../domain/bloc/child_event.dart';

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
  final _schoolController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _schoolController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();

      final child = ChildModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        firstName: firstName,
        lastName: lastName,
        fullAddress: _addressController.text.trim(),
        school: _schoolController.text.trim(),
        initials: '${firstName[0]}${lastName[0]}', // génère les initiales automatiquement
        schedule: _getDefaultSchedule(),           // utiliser 'schedule' au lieu de 'weeklySchedule'
      );


      context.read<ChildBloc>().add(AddChildEvent(child));
      Navigator.pop(context);
    }
  }

  Map<String, DaySchedule> _getDefaultSchedule() {
    return {
      'Lun': DaySchedule(isOpen: false),
      'Mar': DaySchedule(isOpen: false),
      'Mer': DaySchedule(isOpen: false),
      'Jeu': DaySchedule(isOpen: false),
      'Ven': DaySchedule(isOpen: false),
      'Sam': DaySchedule(isOpen: false),
      'Dim': DaySchedule(isOpen: false),
    };
  }


  @override
  Widget build(BuildContext context) {
    return Container(
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
                  _buildTextField(
                    controller: _firstNameController,
                    label: 'Prénom',
                    hint: 'Ex: Khadi',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _lastNameController,
                    label: 'Nom',
                    hint: 'Ex: Diop',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _addressController,
                    label: 'Adresse complète',
                    hint: 'Ex: Ouakam cité avions, Dakar',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _schoolController,
                    label: 'Écoles',
                    hint: 'Ex: Lycée jean mermoz',
                  ),
                  const SizedBox(height: 24),
                  _buildSubmitButton(),
                ],
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
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
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
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
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
              borderSide: BorderSide(color: AppColors.primaryGreen, width: 2),
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
        onPressed: _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
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