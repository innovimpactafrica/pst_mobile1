import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../utils/app_colors.dart';

class InviteFriendsPage extends StatelessWidget {
  const InviteFriendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Inviter des amis',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // BARRE DE RECHERCHE
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Trouver des amis',
                  hintStyle: GoogleFonts.inter(color: Colors.grey.shade400),
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.grey.shade400),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // ICÔNES RÉSEAUX SOCIAUX
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSocialButton('Copier', Icons.copy, AppColors.primaryGreen),
                _buildSocialButton('WhatsApp', Icons.message, const Color(0xFF25D366)),
                _buildSocialButton('Instagram', Icons.camera_alt, const Color(0xFFE4405F)),
                _buildSocialButton('Messenger', Icons.facebook, const Color(0xFF0084FF)),
                _buildSocialButton('Twitter', Icons.close, Colors.black),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // TITRE
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Inviter à rejoindre',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // LISTE DES AMIS
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildFriendCard(
                  name: 'Moussa Faye',
                  phone: '+221 77 123 45 67',
                  photo: 'assets/images/friend1.png',
                  isInvited: false,
                ),
                _buildFriendCard(
                  name: 'Michel Correa',
                  phone: '+221 77 123 45 67',
                  photo: 'assets/images/friend2.png',
                  isInvited: false,
                ),
                _buildFriendCard(
                  name: 'Jules Mendy',
                  phone: '+221 77 000 33 27',
                  photo: 'assets/images/friend3.png',
                  isInvited: false,
                ),
                _buildFriendCard(
                  name: 'Edouard Faye',
                  phone: '+221 77 000 33 27',
                  photo: 'assets/images/friend4.png',
                  isInvited: false,
                ),
                _buildFriendCard(
                  name: 'John Doe',
                  phone: '+221 77 765 43 21',
                  photo: 'assets/images/friend5.png',
                  isInvited: false,
                ),
                _buildFriendCard(
                  name: 'Lamine Coly',
                  phone: '+221 77 123 45 67',
                  photo: 'assets/images/friend6.png',
                  isInvited: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildFriendCard({
    required String name,
    required String phone,
    required String photo,
    required bool isInvited,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: AssetImage(photo),
            onBackgroundImageError: (_, __) {},
            child: Icon(Icons.person, color: Colors.grey.shade600, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  phone,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Envoyer invitation
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
            child: Row(
              children: [
                const Icon(Icons.person_add, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Inviter',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}