import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/utils/app_colors.dart';

class InviteFriendsPage extends StatelessWidget {
  const InviteFriendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          const SizedBox(height: 20),
          _buildSearchBar(),
          const SizedBox(height: 20),
          _buildSocialButtons(),
          const SizedBox(height: 32),
          _buildSectionTitle(),
          const SizedBox(height: 16),
          _buildFriendsList(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.success,
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
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Trouver des amis',
            hintStyle: GoogleFonts.inter(
              color: AppColors.textGrey,
              fontSize: 14,
            ),
            border: InputBorder.none,
            icon: Icon(Icons.search, color: AppColors.textGrey, size: 20),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSocialButton(
            label: 'Copier',
            imagePath: 'assets/icons/link.svg',
            color: AppColors.success,
            isSvg: true,
          ),
          _buildSocialButton(
            label: 'WhatsApp',
            imagePath: 'assets/icons/whatsapp.svg',
            color: AppColors.whatsapp,
            isSvg: true,
          ),
          _buildSocialButton(
            label: 'Instagram',
            imagePath: 'assets/icons/instagram.svg',
            color: AppColors.instagram,
            isSvg: true,
          ),
          _buildSocialButton(
            label: 'Messenger',
            imagePath: 'assets/icons/messenger.svg',
            color: AppColors.messenger,
            isSvg: true,
          ),
          _buildSocialButton(
            label: 'Twitter',
            imagePath: 'assets/images/twiter.jpeg',
            color: AppColors.twitter,
            isSvg: false, // ✅ Pour Twitter qui est un JPEG
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required String label,
    required String imagePath,
    required Color color,
    required bool isSvg,
  }) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Center(
            child: isSvg
                ? SvgPicture.asset(
                    imagePath,
                    width: 28,
                    height: 28,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  )
                : ClipOval(
                    child: Image.asset(
                      imagePath,
                      width: 28,
                      height: 28,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.image,
                          color: Colors.white,
                          size: 28,
                        );
                      },
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 11, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildSectionTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Inviter à rejoindre',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildFriendsList() {
    return Expanded(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _buildFriendCard(
            name: 'Moussa Faye',
            phone: '+221 77 123 45 67',
            photo: 'assets/images/friend1.png',
          ),
          _buildFriendCard(
            name: 'Michel Correa',
            phone: '+221 77 123 45 67',
            photo: 'assets/images/friend2.png',
          ),
          _buildFriendCard(
            name: 'Jules Mendy',
            phone: '+221 77 000 33 27',
            photo: 'assets/images/friend3.png',
          ),
          _buildFriendCard(
            name: 'Edouard Faye',
            phone: '+221 77 000 33 27',
            photo: 'assets/images/friend4.png',
          ),
          _buildFriendCard(
            name: 'John Doe',
            phone: '+221 77 765 43 21',
            photo: 'assets/images/friend5.png',
          ),
          _buildFriendCard(
            name: 'Lamine Coly',
            phone: '+221 77 123 45 67',
            photo: 'assets/images/friend6.png',
          ),
        ],
      ),
    );
  }

  Widget _buildFriendCard({
    required String name,
    required String phone,
    required String photo,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildAvatar(photo),
          const SizedBox(width: 12),
          Expanded(child: _buildFriendInfo(name, phone)),
          _buildInviteButton(),
        ],
      ),
    );
  }

  Widget _buildAvatar(String photo) {
    return CircleAvatar(
      radius: 28,
      backgroundColor: AppColors.imagePlaceholder,
      backgroundImage: AssetImage(photo),
      onBackgroundImageError: (_, __) {},
      child: Icon(Icons.person, color: AppColors.textGrey, size: 28),
    );
  }

  Widget _buildFriendInfo(String name, String phone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          phone,
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.textGrey),
        ),
      ],
    );
  }

  Widget _buildInviteButton() {
    return ElevatedButton(
      onPressed: () {
        // TODO: Envoyer invitation
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.success,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.person_add, size: 16),
          const SizedBox(width: 4),
          Text(
            'Inviter',
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
