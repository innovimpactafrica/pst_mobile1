import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:private_school/parents/pages/school/data/models/school_model.dart';
import 'package:private_school/parents/pages/school/data/services/school_service.dart';
import 'package:private_school/parents/widgets/address_picker_widget.dart';
import 'package:private_school/shared/widgets/school_autocomplete_field.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/google_maps_config.dart';
import '../../data/models/child_model.dart';
import '../../domain/bloc/child_bloc.dart';
import '../../domain/bloc/child_event.dart';
import '../../domain/bloc/child_state.dart';

class EditChildModal extends StatefulWidget {
  final ChildModel child;

  const EditChildModal({super.key, required this.child});

  @override
  State<EditChildModal> createState() => _EditChildModalState();
}

class _EditChildModalState extends State<EditChildModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _addressController;
  late final TextEditingController _schoolNameController;
  late final TextEditingController _schoolAddressController;

  final SchoolService _schoolService = SchoolService();
  List<SchoolModel> _schools = [];
  bool _loadingSchools = true;
  SchoolModel? _selectedSchool;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    final nameParts = widget.child.name.split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    _firstNameController = TextEditingController(text: firstName);
    _lastNameController = TextEditingController(text: lastName);
    _addressController = TextEditingController(text: widget.child.address);
    _schoolNameController = TextEditingController(
      text: widget.child.schoolName ?? '',
    );
    _schoolAddressController = TextEditingController(
      text: widget.child.schoolAddress ?? '',
    );

    _loadSchools();
  }

  Future<void> _loadSchools() async {
    try {
      final schools = await _schoolService.fetchSchools();
      setState(() {
        _schools = schools;
        _loadingSchools = false;

        _selectedSchool = schools.firstWhere(
          (s) => s.id == widget.child.schoolId,
          orElse: () => schools.firstWhere(
            (s) => s.name == widget.child.schoolName,
            orElse: () => SchoolModel(
              id: widget.child.schoolId,
              name: widget.child.schoolName ?? '',
              address: widget.child.schoolAddress ?? '',
            ),
          ),
        );
      });
    } catch (e) {
      debugPrint('❌ Erreur chargement écoles: $e');
      setState(() => _loadingSchools = false);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _schoolNameController.dispose();
    _schoolAddressController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedSchool == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('select_school_from_list'.tr()),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();
      final fullName = '$firstName $lastName';

      final updatedChild = widget.child.copyWith(
        name: fullName,
        address: _addressController.text.trim(),
        schoolId: _selectedSchool!.id!,
      );

      debugPrint('📤 Mise à jour enfant:');
      debugPrint('   Name: ${updatedChild.name}');
      debugPrint('   School ID: ${updatedChild.schoolId}');

      context.read<ChildBloc>().add(UpdateChildEvent(updatedChild));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChildBloc, ChildState>(
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
                    _buildSectionTitle('child_information'.tr()),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _firstNameController,
                      label: 'first_name'.tr(),
                      hint: 'first_name_example'.tr(),
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _lastNameController,
                      label: 'last_name'.tr(),
                      hint: 'last_name_example'.tr(),
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 16),
                    AddressPickerWidget(
                      controller: _addressController,
                      googleApiKey: GoogleMapsConfig.apiKey,
                      label: 'child_address'.tr(),
                      hint: 'child_address_example'.tr(),
                      onLocationSelected: (lat, lng) {},
                    ),

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 24),

                    _buildSectionTitle('school_information'.tr()),
                    const SizedBox(height: 12),
                    _loadingSchools
                        ? const Center(child: CircularProgressIndicator())
                        : _schools.isEmpty
                        ? Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFF59E0B),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.warning_amber,
                                  color: Color(0xFFF59E0B),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'no_schools_available_message'.tr(),
                                    style: const TextStyle(
                                      color: Color(0xFFF59E0B),
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : SchoolAutocompleteField(
                            label: 'school_name'.tr(),
                            hint: 'school_name_example'.tr(),
                            controller: _schoolNameController,
                            schools: _schools,
                            enabled: !_isLoading,
                            onSchoolSelected: (school, schoolName) {
                              setState(() {
                                _selectedSchool = school;
                                if (school != null &&
                                    school.address.isNotEmpty) {
                                  _schoolAddressController.text =
                                      school.address;
                                }
                              });
                            },
                          ),

                    if (_selectedSchool != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.success.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: AppColors.success,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedSchool!.name,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.success,
                                    ),
                                  ),
                                  if (_selectedSchool!.address.isNotEmpty)
                                    Text(
                                      _selectedSchool!.address,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),
                    _buildSubmitButton(),
                    const SizedBox(height: 80),
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
          'edit_child'.tr(),
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
                ' (${'optional'.tr()})',
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
          style: GoogleFonts.inter(fontSize: 14, color: Colors.black87),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
            prefixIcon: Icon(
              icon,
              color: AppColors.success.withValues(alpha: 0.7),
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
                    return 'field_required'.tr();
                  }
                  return null;
                }
              : null,
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
                'update'.tr(),
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
