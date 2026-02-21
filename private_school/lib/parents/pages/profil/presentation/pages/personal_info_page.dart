import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:private_school/core/utils/google_maps_config.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_constants.dart';
import '../../domain/bloc/profil_bloc.dart';
import '../../domain/bloc/profil_event.dart';
import '../../domain/bloc/profil_state.dart';

/// Personal information page
/// Allows users to view and edit their profile information
class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  bool _isEditMode = false;
  File? _selectedImageFile;

  // Controllers for editable fields
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;

  @override
  @override
void initState() {
  super.initState();
  _firstNameController = TextEditingController();
  _lastNameController = TextEditingController();
  _phoneController = TextEditingController();
  _emailController = TextEditingController();
  _addressController = TextEditingController();

  // Initialiser immédiatement si le state est déjà chargé
  final state = context.read<ProfilBloc>().state;
  if (state is ProfilLoaded) {
    _firstNameController.text = state.user.firstName;
    _lastNameController.text = state.user.lastName;
    _phoneController.text = state.user.phone ?? '';
    _emailController.text = state.user.email;
    _addressController.text = state.user.address ?? '';
  }
}

  

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();

      // Demander à l'utilisateur de choisir entre caméra et galerie
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_camera, color: AppColors.success),
                  title: Text('take_photo'.tr()),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: AppColors.success),
                  title: Text('choose_from_gallery'.tr()),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
              ],
            ),
          ),
        ),
      );

      if (source != null) {
        final XFile? image = await picker.pickImage(
          source: source,
          imageQuality: 80, // Compresser l'image à 80%
        );

        if (image != null && mounted) {
          setState(() {
            _selectedImageFile = File(image.path);
          });
          
          // Envoyer immédiatement la photo à l'API
          if (mounted) {
            context.read<ProfilBloc>().add(
                  UpdateProfilePhotoFromPathEvent(image.path),
                );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${'error_selecting_image'.tr()}: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _saveChanges() {
    // Validation basique
    if (_firstNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('first_name_required'.tr()),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_lastNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('last_name_required'.tr()),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('email_required'.tr()),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Envoyer les modifications à l'API
    context.read<ProfilBloc>().add(
          UpdateUserFieldsEvent(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            phone: _phoneController.text.trim().isEmpty 
                ? null 
                : _phoneController.text.trim(),
            email: _emailController.text.trim(),
            address: _addressController.text.trim().isEmpty 
                ? null 
                : _addressController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.success,
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
          'personal_information'.tr(),
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
                  _selectedImageFile = null;
                });
              },
            ),
        ],
      ),
      body: BlocListener<ProfilBloc, ProfilState>(
        listener: (context, state) {
          if (state is ProfilUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('profile_updated_success'.tr()),
                backgroundColor: AppColors.success,
                duration: const Duration(seconds: 2),
              ),
            );
            setState(() {
              _isEditMode = false;
              _selectedImageFile = null;
            });
          }

          if (state is PhotoUploaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('photo_updated_success'.tr()),
                backgroundColor: AppColors.success,
                duration: const Duration(seconds: 2),
              ),
            );
          }

          if (state is ProfilError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        child: BlocBuilder<ProfilBloc, ProfilState>(
          builder: (context, state) {
            if (state is ProfilLoading || state is ProfilUpdating) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.success),
              );
            }

            if (state is PhotoUploading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: AppColors.success),
                    const SizedBox(height: AppConstants.spacingXL),
                    Text(
                      'uploading_photo'.tr(),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: AppConstants.fontSizeM,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is ProfilLoaded) {
              final user = state.user;

            return SingleChildScrollView(
  padding: EdgeInsets.fromLTRB(
    AppConstants.spacingXL + 4,
    AppConstants.spacingXL + 4,
    AppConstants.spacingXL + 4,
    MediaQuery.of(context).padding.bottom + 80,
  ),
  child: Column(
                  children: [
                    // Photo de profil
                    Center(
                      child: Stack(
                        children: [
                          // Afficher l'image sélectionnée localement OU l'image de l'API
                          _selectedImageFile != null
                              ? CircleAvatar(
                                  radius: 60,
                                  backgroundImage: FileImage(_selectedImageFile!),
                                )
                              : _buildProfileAvatar(user.photo),
                          
                          // Bouton caméra
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

                    // Champs
                    _buildField(
                      'first_name'.tr(),
                      _firstNameController,
                      user.firstName,
                    ),
                    const SizedBox(height: AppConstants.spacingXL),
                    
                    _buildField(
                      'last_name'.tr(),
                      _lastNameController,
                      user.lastName,
                    ),
                    const SizedBox(height: AppConstants.spacingXL),
                    
                    _buildField(
                      'phone'.tr(),
                      _phoneController,
                      user.phone ?? 'not_specified'.tr(),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: AppConstants.spacingXL),
                    
                    _buildField(
                      'email'.tr(),
                      _emailController,
                      user.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: AppConstants.spacingXL),
                    
                    _buildAddressField(
                      'address'.tr(),
                      _addressController,
                      user.address ?? 'not_provided'.tr(),
                    ),

                    const SizedBox(height: AppConstants.spacingXXXL),

                    // Bouton Modifier / Enregistrer
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_isEditMode) {
                            _saveChanges();
                          } else {
                            setState(() {
                              _isEditMode = true;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppConstants.radiusL,
                            ),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _isEditMode ? 'save'.tr() : 'update'.tr(),
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
            }

            return const Center(
              child: CircularProgressIndicator(color: AppColors.success),
            );
          },
        ),
      ),
    );
  }


Widget _buildAddressField(
  String label,
  TextEditingController controller,
  String value,
) {
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
      if (!_isEditMode)
        // ✅ Mode lecture : simple Text dans un Container
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
            border: Border.all(color: AppColors.grey300),
          ),
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeL - 1,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        )
      else
        // ✅ Mode édition : Google Places dans son propre Container
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
            border: Border.all(color: AppColors.success),
          ),
          child: GooglePlaceAutoCompleteTextField(
            textEditingController: controller,
            googleAPIKey: GoogleMapsConfig.apiKey,
            inputDecoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              hintText: 'address_example'.tr(),
              hintStyle: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeL - 1,
                color: AppColors.grey400,
              ),
            ),
            textStyle: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeL - 1,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            debounceTime: 800,
            countries: const ["sn"],
            isLatLngRequired: false,
            getPlaceDetailWithLatLng: (prediction) {
              setState(() {
                controller.text = prediction.description ?? '';
              });
            },
            itemClick: (prediction) {
              controller.text = prediction.description ?? '';
              controller.selection = TextSelection.fromPosition(
                TextPosition(offset: controller.text.length),
              );
            },
          ),
        ),
    ],
  );
}

  Widget _buildField(
    String label,
    TextEditingController controller,
    String value, {
    TextInputType? keyboardType,
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
            vertical: _isEditMode ? 0 : 14,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
            border: Border.all(
              color: _isEditMode ? AppColors.success : AppColors.grey300,
            ),
          ),
          child: _isEditMode
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
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
      ],
    );
  }

  /// Construit l'avatar depuis l'URL de l'API
  Widget _buildProfileAvatar(String? photoUrl) {
    // Pas de photo
    if (photoUrl == null || photoUrl.isEmpty) {
      return CircleAvatar(
        radius: 60,
        backgroundColor: AppColors.grey200,
        child: Icon(
          Icons.person,
          size: 60,
          color: AppColors.grey600,
        ),
      );
    }

    // URL complète
    if (photoUrl.startsWith('http://') || photoUrl.startsWith('https://')) {
      return CircleAvatar(
        radius: 60,
        backgroundColor: AppColors.grey200,
        backgroundImage: NetworkImage(photoUrl),
        onBackgroundImageError: (exception, stackTrace) {
          debugPrint('⚠️ Erreur chargement photo: $exception');
        },
      );
    }

    // URL relative
    final fullUrl = 'http://86.106.181.31:3000$photoUrl';
    return CircleAvatar(
      radius: 60,
      backgroundColor: AppColors.grey200,
      backgroundImage: NetworkImage(fullUrl),
      onBackgroundImageError: (exception, stackTrace) {
        debugPrint('⚠️ Erreur chargement photo: $exception');
      },
    );
  }
}