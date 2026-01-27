import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:private_school/core/utils/app_colors.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER VERT
            Container(
              color: AppColors.success,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      'Notifications',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // Pour centrer le titre
                ],
              ),
            ),

            const SizedBox(height: 20),

            // BARRE DE RECHERCHE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Rechercher',
                    hintStyle: GoogleFonts.inter(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey.shade400,
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // TITRE AUJOURD'HUI
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Aujourd\'hui',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // LISTE DES NOTIFICATIONS
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // TRAJET COMMENCÉ (BLEU)
                  _buildNotificationCard(
                    icon: Icons.car_repair,
                    iconColor: Colors.blue.shade600,
                    backgroundColor: Colors.blue.shade50,
                    borderColor: Colors.blue.shade100,
                    title: 'Trajet commencé',
                    subtitle:
                        'Le conducteur a commencé le trajet vers ÉcolePrimaire Saint-Joseph',
                    time: 'Aujourd\'hui, 07:35',
                    hasLeftBorder: true,
                    leftBorderColor: Colors.blue.shade600,
                  ),

                  // TRAJET TERMINÉ (VERT)
                  _buildNotificationCard(
                    icon: Icons.check_circle,
                    iconColor: AppColors.success,
                    backgroundColor: Colors.white,
                    borderColor: Colors.grey.shade200,
                    title: 'Trajet terminé',
                    subtitle:
                        'Votre enfant est arrivé à destination en toute sécurité',
                    time: 'Aujourd\'hui, 07:55',
                    hasLeftBorder: false,
                  ),

                  // INVITATION À REJOINDRE (AVEC BOUTONS)
                  _buildInvitationCard(),

                  const SizedBox(height: 20),

                  // TITRE HIER
                  Text(
                    'Hier',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // PLANNING À CONFIRMER (AVEC BOUTONS)
                  _buildPlanningCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required Color borderColor,
    required String title,
    required String subtitle,
    required String time,
    bool hasLeftBorder = false,
    Color? leftBorderColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // BARRE GAUCHE (si notification non lue)
            if (hasLeftBorder)
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: leftBorderColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),

            // CONTENU
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ICÔNE
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: iconColor, size: 22),
                    ),

                    const SizedBox(width: 12),

                    // TEXTE
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // HEURE
                    Text(
                      time,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvitationCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AVATAR
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                'S',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // TEXTE
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Invitation à rejoindre',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Abdou Diallo vous invite à rejoindre Sencov',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // BOUTONS X et ✓
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.close, size: 16, color: Colors.red.shade400),
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    // Refuser
                  },
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.check,
                    size: 16,
                    color: Colors.green.shade600,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    // Accepter
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlanningCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ICÔNE CALENDRIER
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.calendar_today,
                  color: Colors.orange.shade600,
                  size: 20,
                ),
              ),

              const SizedBox(width: 12),

              // TEXTE
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Planning à confirmer',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Veuillez confirmer votre disponibilité pour les jours où vous êtes assigné(e).',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              // TEMPS
              Text(
                'il y a 2 jours',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // BOUTONS ANNULER / CONFIRMER
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // Annuler
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade600,
                    side: BorderSide(color: Colors.red.shade200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Annuler',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Confirmer
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Confirmer',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
