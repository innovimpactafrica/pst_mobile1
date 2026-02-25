import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../core/services/google_places_service.dart';
import '../../core/utils/app_colors.dart';

class PlaceAutocompleteField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final Function(PlaceDetails) onPlaceSelected;
  final bool showCurrentLocationButton;

  const PlaceAutocompleteField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.onPlaceSelected,
    this.showCurrentLocationButton = true,
  });

  @override
  State<PlaceAutocompleteField> createState() => _PlaceAutocompleteFieldState();
}

class _PlaceAutocompleteFieldState extends State<PlaceAutocompleteField> {
  final GooglePlacesService _placesService = GooglePlacesService();
  List<PlacePrediction> _predictions = [];
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
                  : _predictions.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Aucun résultat',
                        style: GoogleFonts.inter(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: _predictions.length,
                      itemBuilder: (context, index) {
                        final prediction = _predictions[index];
                        return ListTile(
                          leading: const Icon(
                            Icons.location_on,
                            color: AppColors.primary,
                          ),
                          title: Text(
                            prediction.mainText,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            prediction.secondaryText,
                            style: GoogleFonts.inter(fontSize: 12),
                          ),
                          onTap: () => _selectPlace(prediction),
                        );
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
      setState(() => _predictions = []);
      return;
    }

    setState(() => _isSearching = true);
    _showOverlay();

    final predictions = await _placesService.getPlacePredictions(value);

    if (mounted) {
      setState(() {
        _predictions = predictions;
        _isSearching = false;
      });
      if (_overlayEntry != null) {
        _overlayEntry!.markNeedsBuild();
      }
    }
  }

  Future<void> _selectPlace(PlacePrediction prediction) async {
    widget.controller.text = prediction.mainText;
    _removeOverlay();
    setState(() => _predictions = []);

    final details = await _placesService.getPlaceDetails(prediction.placeId);
    if (details != null) {
      widget.onPlaceSelected(details);
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Veuillez activer la localisation',
                style: GoogleFonts.inter(),
              ),
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
              SnackBar(
                content: Text(
                  'Permission de localisation refusée',
                  style: GoogleFonts.inter(),
                ),
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
          PlaceDetails(
            address: address,
            latitude: position.latitude,
            longitude: position.longitude,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error getting current location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erreur lors de la récupération de la position',
              style: GoogleFonts.inter(),
            ),
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
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        CompositedTransformTarget(
          link: _layerLink,
          child: TextField(
            controller: widget.controller,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: GoogleFonts.inter(color: Colors.grey),
              prefixIcon: const Icon(Icons.search, color: AppColors.primary),
              suffixIcon: widget.showCurrentLocationButton
                  ? IconButton(
                      icon: const Icon(
                        Icons.my_location,
                        color: AppColors.primary,
                      ),
                      onPressed: _getCurrentLocation,
                      tooltip: 'Ma position',
                    )
                  : null,
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
