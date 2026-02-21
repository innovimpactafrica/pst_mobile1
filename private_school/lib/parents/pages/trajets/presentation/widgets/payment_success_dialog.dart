import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../data/models/trip_model.dart';
import '../pages/trip_tracking_page.dart';

class PaymentSuccessDialog extends StatelessWidget {
  final TripModel trip;

  const PaymentSuccessDialog({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ICÔNE SUCCESS
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.green, size: 50),
            ),
            const SizedBox(height: 24),
            // TITRE
            Text(
              'payment_successful'.tr(),
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            // MESSAGE
            Text(
              'reservation_confirmed_message'.tr(),
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // BOUTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // ✅ CORRECTION : pushAndRemoveUntil ferme TOUT la stack
                  // (dialog + PaymentPage + TripDetailPage) et pousse TripTrackingPage
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => TripTrackingPage(trip: trip),
                    ),
                    // Garder seulement la première route (accueil/liste des trajets)
                    (route) => route.isFirst,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B4FC7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'track_trip'.tr(),
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}