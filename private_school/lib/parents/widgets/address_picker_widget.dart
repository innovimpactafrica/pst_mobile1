import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:private_school/core/utils/app_colors.dart';

class AddressPickerWidget extends StatelessWidget {
  final TextEditingController controller;
  final Function(double lat, double lng) onLocationSelected;
  final String googleApiKey;
  final String? label;
  final String? hint;

  const AddressPickerWidget({
    super.key,
    required this.controller,
    required this.onLocationSelected,
    required this.googleApiKey,
    this.label,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label ?? 'home_address'.tr(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        GooglePlaceAutoCompleteTextField(
          textEditingController: controller,
          googleAPIKey: googleApiKey,
          inputDecoration: InputDecoration(
            hintText: hint ?? 'address_example'.tr(),
            hintStyle: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            prefixIcon: const Icon(
              Icons.home_outlined,
              color: AppColors.textSecondary,
              size: 20,
            ),
            suffixIcon: IconButton(
              icon: const Icon(
                Icons.my_location,
                color: AppColors.successDark,
                size: 20,
              ),
              onPressed: () => _useCurrentLocation(context),
            ),
            filled: true,
            fillColor: AppColors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.grey300, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.grey300, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.successDark,
                width: 1.5,
              ),
            ),
          ),
          debounceTime: 800,
          countries: const ["sn"],
          isLatLngRequired: true,
          getPlaceDetailWithLatLng: (Prediction prediction) {
            controller.text = prediction.description ?? '';
            final lat = double.tryParse(prediction.lat ?? '');
            final lng = double.tryParse(prediction.lng ?? '');

            if (lat != null && lng != null) {
              onLocationSelected(lat, lng);
            }
          },
          itemClick: (Prediction prediction) {
            controller.text = prediction.description ?? '';
          },
        ),
      ],
    );
  }

  Future<void> _useCurrentLocation(BuildContext context) async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('location_permission_denied'.tr());
        }
      }

      Position position = await Geolocator.getCurrentPosition();

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty && context.mounted) {
        final place = placemarks.first;
        final address = '${place.street}, ${place.locality}, ${place.country}';

        controller.text = address;
        onLocationSelected(position.latitude, position.longitude);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${'error_label'.tr()}: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
