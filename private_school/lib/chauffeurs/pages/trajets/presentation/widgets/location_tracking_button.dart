import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../core/services/location_service.dart';
import '../../../../../core/utils/app_colors.dart';

/// Widget bouton pour démarrer/arrêter le suivi GPS
class LocationTrackingButton extends StatefulWidget {
  final String tripId;
  
  const LocationTrackingButton({
    super.key,
    required this.tripId,
  });

  @override
  State<LocationTrackingButton> createState() => _LocationTrackingButtonState();
}

class _LocationTrackingButtonState extends State<LocationTrackingButton> {
  final LocationService _locationService = LocationService();
  bool _isTracking = false;
  bool _isLoading = false;
  
  @override
  void dispose() {
    _locationService.stopLocationTracking();
    super.dispose();
  }
  
  Future<void> _toggleTracking() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    
    try {
      if (_isTracking) {
        // Arrêter le suivi
        _locationService.stopLocationTracking();
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
        // Démarrer le suivi
        await _locationService.startLocationTracking(widget.tripId);
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
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : _toggleTracking,
      icon: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Icon(
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
