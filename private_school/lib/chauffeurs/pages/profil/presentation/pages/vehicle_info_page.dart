import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:private_school/chauffeurs/pages/profil/data/models/vehicle_model.dart';
import 'dart:io';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_constants.dart';
import '../../../../../core/utils/image_url_helper.dart';
import '../../data/models/driver_profile_model.dart';
import '../../../profil/domain/bloc/driver_profile_bloc.dart';
import '../../../profil/domain/bloc/driver_profile_event.dart';
import '../../../profil/domain/bloc/driver_profile_state.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class VehicleInfoPage extends StatefulWidget {
  final DriverProfileModel profile;

  const VehicleInfoPage({super.key, required this.profile});

  @override
  State<VehicleInfoPage> createState() => _VehicleInfoPageState();
}

class _VehicleInfoPageState extends State<VehicleInfoPage> {
  bool _isEditMode = false;
  File? _selectedVehicleImage;

  late TextEditingController _brandController;
  late TextEditingController _colorController;
  late TextEditingController _plateController;
  late TextEditingController _capacityController;

  @override
  void initState() {
    super.initState();
    _brandController = TextEditingController();
    _colorController = TextEditingController();
    _plateController = TextEditingController();
    _capacityController = TextEditingController();
    _initializeControllers();
  }

  @override
  void dispose() {
    _brandController.dispose();
    _colorController.dispose();
    _plateController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  void _initializeControllers() {
    final vehicle = widget.profile.vehicle;
    _brandController.text = vehicle?.brand ?? '';
    _colorController.text = vehicle?.color ?? '';
    _plateController.text = vehicle?.plate ?? '';
    _capacityController.text = vehicle?.capacity?.toString() ?? '';
    
    debugPrint('🚗 [VehicleInfoPage] Initializing with data:');
    debugPrint('   Brand: ${vehicle?.brand}');
    debugPrint('   Color: ${vehicle?.color}');
    debugPrint('   Plate: ${vehicle?.plate}');
    debugPrint('   Capacity: ${vehicle?.capacity}');
  }

  Future<void> _pickVehicleImage() async {
    final ImagePicker picker = ImagePicker();
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text('take_photo'.tr()),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text('choose_from_gallery'.tr()),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final XFile? image = await picker.pickImage(source: source);
      if (image != null) {
        setState(() => _selectedVehicleImage = File(image.path));
      }
    }
  }

  Future<void> _saveChanges() async {
    final Map<String, dynamic> data = {};

    if (_brandController.text.trim().isNotEmpty) {
      data['vehicle_brand'] = _brandController.text.trim();
    }
    if (_colorController.text.trim().isNotEmpty) {
      data['vehicle_color'] = _colorController.text.trim();
    }
    if (_plateController.text.trim().isNotEmpty) {
      data['vehicle_plate'] = _plateController.text.trim();
    }
    
    final int? capacity = int.tryParse(_capacityController.text.trim());
    if (capacity != null) {
      data['capacity'] = capacity;
    }

    try {
      final FormData formData = FormData.fromMap(data);

      if (_selectedVehicleImage != null) {
        formData.files.add(MapEntry(
          'vehicle_photo',
          await MultipartFile.fromFile(_selectedVehicleImage!.path),
        ));
      }

      final String driverId = widget.profile.driver.id.toString();

      if (driverId.isEmpty) {
        _showSnackBar('error_no_driver_id'.tr(), isError: true);
        return;
      }

      if (!mounted) return;

      context.read<DriverProfileBloc>().add(
        UpdateDriverByIdEvent(driverId: driverId, formData: formData),
      );
    } catch (e) {
      _showSnackBar('${'error_update'.tr()} : $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DriverProfileBloc, DriverProfileState>(
      builder: (context, state) {
        final DriverProfileModel profile =
            state is DriverProfileLoaded ? state.profile : widget.profile;

        final vehicle = profile.vehicle;
        
        // Mettre à jour les contrôleurs si le profil a changé
        if (state is DriverProfileLoaded || state is DriverProfileUpdated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_isEditMode) {
              _brandController.text = vehicle?.brand ?? '';
              _colorController.text = vehicle?.color ?? '';
              _plateController.text = vehicle?.plate ?? '';
              _capacityController.text = vehicle?.capacity?.toString() ?? '';
            }
          });
        }

        return BlocListener<DriverProfileBloc, DriverProfileState>(
          listener: (context, state) {
            if (state is DriverProfileUpdated) {
              setState(() {
                _isEditMode = false;
                _selectedVehicleImage = null;
                _initializeControllers();
              });
              _showSnackBar('vehicle_updated_successfully'.tr(), isError: false);
            } else if (state is DriverProfileError) {
              _showSnackBar(state.message);
            }
          },
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.primary,
              title: Text(
                'vehicle_info'.tr(),
                style: const TextStyle(color: Colors.white),
              ),
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.spacingXXL),
              child: Column(
                children: [
                  _buildVehiclePhoto(vehicle),
                  const SizedBox(height: AppConstants.spacingXXXL),
                  CustomTextField(
                    label: 'brand'.tr(),
                    controller: _brandController,
                    readOnly: !_isEditMode,
                    hintText: 'enter_brand'.tr(),
                  ),
                  const SizedBox(height: AppConstants.spacingM),
                  CustomTextField(
                    label: 'color'.tr(),
                    controller: _colorController,
                    readOnly: !_isEditMode,
                    hintText: 'enter_color'.tr(),
                  ),
                  const SizedBox(height: AppConstants.spacingM),
                  CustomTextField(
                    label: 'license_plate'.tr(),
                    controller: _plateController,
                    readOnly: !_isEditMode,
                    hintText: 'enter_plate'.tr(),
                  ),
                  const SizedBox(height: AppConstants.spacingM),
                  CustomTextField(
                    label: 'capacity'.tr(),
                    controller: _capacityController,
                    readOnly: !_isEditMode,
                    keyboardType: TextInputType.number,
                    hintText: 'enter_capacity'.tr(),
                  ),
                  const SizedBox(height: 40),
                  BlocBuilder<DriverProfileBloc, DriverProfileState>(
                    builder: (context, state) {
                      return PrimaryButton(
                        text: _isEditMode
                            ? 'save'.tr()
                            : 'edit'.tr(),
                        isLoading: state is DriverProfileUpdating,
                        onPressed: () {
                          if (_isEditMode) {
                            _saveChanges();
                          } else {
                            setState(() => _isEditMode = true);
                          }
                        },
                      );
                    },
                  ),
                  if (_isEditMode)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isEditMode = false;
                          _initializeControllers();
                          _selectedVehicleImage = null;
                        });
                      },
                      child: Text(
                        'cancel'.tr(),
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVehiclePhoto(VehicleModel? vehicle) {
  return GestureDetector(
    onTap: _isEditMode ? _pickVehicleImage : null,
    child: Center(
      child: Stack(
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(AppConstants.radiusL),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.radiusL),
              child: _selectedVehicleImage != null
                  // 1. Si on vient de choisir une image sur le téléphone
                  ? Image.file(
                      _selectedVehicleImage!,
                      fit: BoxFit.cover,
                    )
                  : (vehicle?.photo != null && vehicle!.photo!.isNotEmpty)
                      // 2. Si l'image vient du serveur (même si c'est un chemin relatif)
                      ? Image.network(
                          ImageUrlHelper.getFullImageUrl(vehicle.photo!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.directions_car, size: 50, color: AppColors.primary),
                        )
                      // 3. Image par défaut si aucune photo n'existe
                      : const Icon(
                          Icons.directions_car,
                          size: 50,
                          color: AppColors.primary,
                        ),
            ),
          ),
          if (_isEditMode)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(AppConstants.radiusM),
                child: const Icon(
                  Icons.camera_alt,
                  size: AppConstants.iconSizeS,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
}
