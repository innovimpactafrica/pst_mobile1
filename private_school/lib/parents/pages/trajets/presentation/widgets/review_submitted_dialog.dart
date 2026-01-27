import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReviewSubmittedDialog extends StatefulWidget {
  const ReviewSubmittedDialog({super.key});

  @override
  State<ReviewSubmittedDialog> createState() => _ReviewSubmittedDialogState();
}

class _ReviewSubmittedDialogState extends State<ReviewSubmittedDialog> {
  @override
  void initState() {
    super.initState();
    // Fermeture automatique après 3 secondes
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ICÔNE SUCCESS
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.green, size: 60),
                ),

                const SizedBox(height: 32),

                // TITRE
                Text(
                  'Merci pour votre feedback !',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // MESSAGE
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue.shade100, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Votre avis est précieux pour nous aider à améliorer notre service.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 24),

                // Message de fermeture automatique
                Text(
                  'Fermeture automatique dans 3 secondes...',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // BOUTON CROIX DE FERMETURE
          Positioned(
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, color: Colors.grey.shade700, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
