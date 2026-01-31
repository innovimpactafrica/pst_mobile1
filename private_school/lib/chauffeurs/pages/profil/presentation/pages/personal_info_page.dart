import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_constants.dart';
import '../../../../../core/utils/image_url_helper.dart'; // 🔧 AJOUT
import '../../data/models/driver_profile_model.dart';
import '../../domain/bloc/driver_profile_bloc.dart';
import '../../domain/bloc/driver_profile_event.dart';
import '../../domain/bloc/driver_profile_state.dart';

/// Personal information page for drivers
/// Displays and allows editing of personal data
class PersonalInfoPage extends StatefulWidget {
  final DriverProfileModel profile;

  const PersonalInfoPage({super.key, required this.profile});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  bool _isEditMode = false;
  File? _selectedImage;

  // Controllers for editable fields
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _initializeControllers(DriverProfileModel profile) {
    _firstNameController.text = profile.firstName;
    _lastNameController.text = profile.lastName;
    _phoneController.text = profile.phone;
    _addressController.text = profile.address ?? '';
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();

      // Ask user to choose between camera and gallery
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (context) => SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Prendre une photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choisir depuis la galerie'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );

      if (source != null) {
        final XFile? image = await picker.pickImage(source: source);

        if (image != null && mounted) {
          setState(() {
            _selectedImage = File(image.path);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo sélectionnée. Cliquez sur "Mettre à jour" pour sauvegarder.'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _saveChanges() async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Envoi des données...'), duration: Duration(seconds: 1)),
    );

    final formDataMap = {
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
    };

    final formData = FormData.fromMap(formDataMap);

    if (_selectedImage != null) {
      formData.files.add(
        MapEntry(
          'photo_profil',
          await MultipartFile.fromFile(
            _selectedImage!.path,
            filename: 'profile.jpg',
          ),
        ),
      );
    }

    if (!mounted) return;
    context.read<DriverProfileBloc>().add(
      UpdateDriverProfileWithPhotoEvent(formData: formData),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.textWhite,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Informations personnelles',
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeXL,
            fontWeight: FontWeight.w600,
            color: AppColors.textWhite,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_isEditMode)
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.textWhite),
              onPressed: () {
                setState(() {
                  _isEditMode = false;
                  _selectedImage = null;
                });
              },
            ),
        ],
      ),
      body: BlocListener<DriverProfileBloc, DriverProfileState>(
        listener: (context, state) {
          if (state is DriverProfileUpdated) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Profil mis à jour avec succès'),
                backgroundColor: AppColors.success,
              ),
            );
            setState(() {
              _isEditMode = false;
              _selectedImage = null;
            });
          }

          if (state is DriverProfileError) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ ${state.message}'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: BlocBuilder<DriverProfileBloc, DriverProfileState>(
          builder: (context, state) {
            final profile = state is DriverProfileLoaded
                ? state.profile
                : widget.profile;

            if (state is DriverProfileLoading ||
                state is DriverProfileUpdating) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            // Initialize controllers when entering edit mode
            if (_isEditMode && _firstNameController.text.isEmpty) {
              _initializeControllers(profile);
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.spacingXL + 4),
              child: Column(
                children: [
                  // Profile photo
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          // 🔧 CORRECTION: Utiliser le helper pour les URLs
                          backgroundImage: _selectedImage != null
                              ? FileImage(_selectedImage!)
                              : (profile.photo != null && profile.photo!.isNotEmpty
                                  ? NetworkImage(
                                      ImageUrlHelper.getFullImageUrl(profile.photo!),
                                    )
                                  : null),
                          child: _selectedImage == null &&
                                  (profile.photo == null || profile.photo!.isEmpty)
                              ? Text(
                                  profile.initials,
                                  style: GoogleFonts.inter(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.white,
                                  width: 3,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: AppColors.textWhite,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacingXXXL),

                  // Fields
                  _buildField(
                    'Prénom',
                    _firstNameController,
                    profile.firstName,
                  ),
                  const SizedBox(height: AppConstants.spacingXL),
                  _buildField(
                    'Nom',
                    _lastNameController,
                    profile.lastName,
                  ),
                  const SizedBox(height: AppConstants.spacingXL),
                  _buildField(
                    'Téléphone',
                    _phoneController,
                    profile.phone,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: AppConstants.spacingXL),
                  _buildField(
                    'Adresse',
                    _addressController,
                    profile.address ?? 'Non renseignée',
                  ),

                  const SizedBox(height: AppConstants.spacingXXXL),

                  // Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: (state is DriverProfileUpdating)
                          ? null
                          : () {
                              if (_isEditMode) {
                                _saveChanges();
                              } else {
                                setState(() {
                                  _isEditMode = true;
                                  _initializeControllers(profile);
                                });
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConstants.radiusL),
                        ),
                        elevation: 0,
                      ),
                      child: (state is DriverProfileUpdating)
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: AppColors.textWhite,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              _isEditMode ? 'Mettre à jour' : 'Modifier',
                              style: GoogleFonts.inter(
                                fontSize: AppConstants.fontSizeL,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textWhite,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    String value, {
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeS + 1,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppConstants.spacingS),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: AppConstants.spacingXL,
            vertical: _isEditMode && enabled ? 0 : 14,
          ),
          decoration: BoxDecoration(
            color: enabled ? AppColors.white : AppColors.grey200,
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
            border: Border.all(
              color: _isEditMode && enabled
                  ? AppColors.primary
                  : AppColors.grey300,
            ),
          ),
          child: _isEditMode && enabled
              ? TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeL - 1,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                )
              : Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeL - 1,
                    color: enabled
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
      ],
    );
  }
}