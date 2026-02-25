import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../core/services/google_places_service.dart';
import '../../core/utils/app_colors.dart';
import '../../parents/pages/school/data/models/school_model.dart';

class SchoolAndPlaceAutocompleteField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final List<SchoolModel> schools;
  final Function(String address, double? lat, double? lng, int? schoolId)
  onPlaceSelected;

  const SchoolAndPlaceAutocompleteField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.schools,
    required this.onPlaceSelected,
  });

  @override
  State<SchoolAndPlaceAutocompleteField> createState() =>
      _SchoolAndPlaceAutocompleteFieldState();
}

class _SchoolAndPlaceAutocompleteFieldState
    extends State<SchoolAndPlaceAutocompleteField> {
  final GooglePlacesService _placesService = GooglePlacesService();
  List<dynamic> _suggestions = [];
  bool _isSearching = false;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showOverlay() {
    _removeOverlay();
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 5),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _isSearching
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : _suggestions.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Aucun résultat',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: _suggestions.length,
                      itemBuilder: (context, index) {
                        final suggestion = _suggestions[index];

                        if (suggestion is SchoolModel) {
                          return ListTile(
                            leading: const Icon(
                              Icons.school,
                              color: AppColors.primary,
                            ),
                            title: Text(
                              suggestion.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              suggestion.address,
                              style: const TextStyle(fontSize: 12),
                            ),
                            onTap: () => _selectSchool(suggestion),
                          );
                        } else if (suggestion is PlacePrediction) {
                          return ListTile(
                            leading: const Icon(
                              Icons.location_on,
                              color: AppColors.textSecondary,
                            ),
                            title: Text(
                              suggestion.mainText,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              suggestion.secondaryText,
                              style: const TextStyle(fontSize: 12),
                            ),
                            onTap: () => _selectPlace(suggestion),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onSearchChanged(String value) async {
    if (value.isEmpty) {
      _removeOverlay();
      setState(() => _suggestions = []);
      return;
    }

    setState(() => _isSearching = true);
    _showOverlay();

    final query = value.toLowerCase();
    final matchingSchools = widget.schools.where((school) {
      return school.name.toLowerCase().contains(query) ||
          school.address.toLowerCase().contains(query);
    }).toList();

    final placePredictions = await _placesService.getPlacePredictions(value);

    if (mounted) {
      setState(() {
        _suggestions = [...matchingSchools, ...placePredictions];
        _isSearching = false;
      });
      if (_overlayEntry != null) {
        _overlayEntry!.markNeedsBuild();
      }
    }
  }

  void _selectSchool(SchoolModel school) {
    widget.controller.text = school.name;
    _removeOverlay();
    setState(() => _suggestions = []);

    widget.onPlaceSelected(
      school.name,
      school.latitude,
      school.longitude,
      school.id,
    );
  }

  Future<void> _selectPlace(PlacePrediction prediction) async {
    widget.controller.text = prediction.mainText;
    _removeOverlay();
    setState(() => _suggestions = []);

    final details = await _placesService.getPlaceDetails(prediction.placeId);
    if (details != null) {
      widget.onPlaceSelected(
        details.address,
        details.latitude,
        details.longitude,
        null,
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Veuillez activer la localisation'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Permission de localisation refusée'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition();
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final address = '${placemark.street}, ${placemark.locality}';
        widget.controller.text = address;

        widget.onPlaceSelected(
          address,
          position.latitude,
          position.longitude,
          null,
        );
      }
    } catch (e) {
      debugPrint('Error getting current location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la récupération de la position'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        CompositedTransformTarget(
          link: _layerLink,
          child: TextField(
            controller: widget.controller,
            onChanged: _onSearchChanged,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.5),
                fontSize: 14,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.textSecondary,
                size: 20,
              ),
              suffixIcon: IconButton(
                icon: const Icon(
                  Icons.my_location,
                  color: AppColors.primary,
                  size: 20,
                ),
                onPressed: _getCurrentLocation,
                tooltip: 'Ma position',
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
          ),
        ),
      ],
    );
  }
}
