import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/services/location_service.dart';
import '../../../../../core/utils/app_colors.dart';

class LocationTrackingButton extends StatefulWidget {
  final String tripId;
  const LocationTrackingButton({super.key, required this.tripId});

  @override
  State<LocationTrackingButton> createState() => _LocationTrackingButtonState();
}

class _LocationTrackingButtonState extends State<LocationTrackingButton> {
  final LocationService _locationService = LocationService();
  bool _isTracking = false;
  bool _isLoading = true; // ← commence en loading le temps de vérifier

  // Clé unique par trajet pour persister l'état
  String get _prefKey => 'gps_tracking_${widget.tripId}';

  @override
  void initState() {
    super.initState();
    _restoreTrackingState(); // ← vérifier si déjà actif
  }

  @override
  void dispose() {
    // NE PAS arrêter ici — le tracking continue en background
    super.dispose();
  }

  /// Restaurer l'état du tracking depuis SharedPreferences
  Future<void> _restoreTrackingState() async {
    final prefs = await SharedPreferences.getInstance();
    final wasTracking = prefs.getBool(_prefKey) ?? false;

    debugPrint('🔍 [LocationBtn] Restauration état GPS: $wasTracking');

    if (wasTracking) {
      // Reprendre le tracking automatiquement
      try {
        await _locationService.startLocationTracking(widget.tripId);
        if (mounted) {
          setState(() {
            _isTracking = true;
            _isLoading = false;
          });
        }
      } catch (e) {
        debugPrint(' Erreur reprise tracking: $e');
        // Si erreur, remettre à false
        await prefs.setBool(_prefKey, false);
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleTracking() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();

    try {
      if (_isTracking) {
        _locationService.stopLocationTracking();
        await prefs.setBool(_prefKey, false); // ← sauvegarder état
        setState(() {
          _isTracking = false;
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('gps_tracking_stopped'.tr()),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } else {
        await _locationService.startLocationTracking(widget.tripId);
        await prefs.setBool(_prefKey, true);
        setState(() {
          _isTracking = true;
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('gps_tracking_started'.tr()),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return ElevatedButton.icon(
        onPressed: null,
        icon: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        label: const Text('...', style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.grey400,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: _toggleTracking,
      icon: Icon(
        _isTracking ? Icons.stop : Icons.play_arrow,
        color: Colors.white,
      ),
      label: Text(
        _isTracking ? 'stop_gps_tracking'.tr() : 'start_gps_tracking'.tr(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: _isTracking ? AppColors.error : AppColors.success,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
