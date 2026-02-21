import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../../core/utils/app_colors.dart';

class InviteFriendsPage extends StatefulWidget {
  const InviteFriendsPage({super.key});

  @override
  State<InviteFriendsPage> createState() => _InviteFriendsPageState();
}

class _InviteFriendsPageState extends State<InviteFriendsPage> {
  List<Contact> _contacts = [];
  List<Contact> _filteredContacts = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  
  // Lien d'invitation (remplacez par votre vrai lien)
  final String _inviteLink = 'https://privateschool.app/invite?ref=USER123';
  final String _inviteMessage = '🚌 Rejoignez-moi sur Private School Transport ! Une app sécurisée pour le transport scolaire. Téléchargez maintenant : ';

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _searchController.addListener(_filterContacts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    try {
      if (await FlutterContacts.requestPermission()) {
        final contacts = await FlutterContacts.getContacts(
          withProperties: true,
          withPhoto: false,
        );
        setState(() {
          _contacts = contacts.where((c) => c.phones.isNotEmpty).toList();
          _filteredContacts = _contacts;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('contacts_permission_denied'.tr(), style: GoogleFonts.inter()),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Erreur chargement contacts: $e');
      setState(() => _isLoading = false);
    }
  }

  void _filterContacts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredContacts = _contacts.where((contact) {
        final name = contact.displayName.toLowerCase();
        return name.contains(query);
      }).toList();
    });
  }

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
        'invite_friends'.tr(),
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
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'find_friends'.tr(),
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
            label: 'copy'.tr(),
            imagePath: 'assets/icons/link.svg',
            color: const Color(0xFF6366F1),
            isSvg: true,
            onTap: _copyLink,
          ),
          _buildSocialButton(
            label: 'WhatsApp',
            imagePath: 'assets/icons/whatsapp.svg',
            color: const Color(0xFF25D366),
            isSvg: true,
            onTap: _shareViaWhatsApp,
          ),
          _buildSocialButton(
            label: 'Instagram',
            imagePath: 'assets/icons/instagram.svg',
            color: const Color(0xFFE4405F),
            isSvg: true,
            onTap: _shareViaInstagram,
          ),
          _buildSocialButton(
            label: 'Messenger',
            imagePath: 'assets/icons/messenger.svg',
            color: const Color(0xFF0084FF),
            isSvg: true,
            onTap: _shareViaMessenger,
          ),
          _buildSocialButton(
            label: 'Twitter',
            imagePath: 'assets/images/twiter.jpeg',
            color: const Color(0xFF1DA1F2),
            isSvg: false,
            onTap: _shareViaTwitter,
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
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
            ),
            child: Center(
              child: isSvg
                  ? SvgPicture.asset(
                      imagePath,
                      width: 32,
                      height: 32,
                      colorFilter: ColorFilter.mode(
                        color,
                        BlendMode.srcIn,
                      ),
                    )
                  : ClipOval(
                      child: Image.asset(
                        imagePath,
                        width: 32,
                        height: 32,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.image,
                            color: color,
                            size: 32,
                          );
                        },
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'invite_to_join'.tr(),
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
    if (_isLoading) {
      return const Expanded(
        child: Center(
          child: CircularProgressIndicator(color: AppColors.success),
        ),
      );
    }

    if (_filteredContacts.isEmpty) {
      return Expanded(
        child: Center(
          child: Text(
            _contacts.isEmpty 
                ? 'no_contacts_available'.tr()
                : 'no_contacts_found'.tr(),
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textGrey,
            ),
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _filteredContacts.length,
        itemBuilder: (context, index) {
          final contact = _filteredContacts[index];
          final phone = contact.phones.isNotEmpty ? contact.phones.first.number : '';
          return _buildFriendCard(
            name: contact.displayName,
            phone: phone,
            contact: contact,
          );
        },
      ),
    );
  }

  Widget _buildFriendCard({
    required String name,
    required String phone,
    required Contact contact,
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
          _buildAvatar(name),
          const SizedBox(width: 12),
          Expanded(child: _buildFriendInfo(name, phone)),
          _buildInviteButton(contact),
        ],
      ),
    );
  }

  Widget _buildAvatar(String name) {
    return CircleAvatar(
      radius: 28,
      backgroundColor: AppColors.success.withValues(alpha: 0.2),
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.success,
        ),
      ),
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

  Widget _buildInviteButton(Contact contact) {
    return ElevatedButton(
      onPressed: () => _inviteContact(contact),
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
            'invite'.tr(),
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // MÉTHODES DE PARTAGE
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  void _copyLink() async {
    await Clipboard.setData(ClipboardData(text: _inviteLink));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('link_copied'.tr(), style: GoogleFonts.inter()),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _shareViaWhatsApp() async {
    final message = '$_inviteMessage$_inviteLink';
    final url = Uri.parse('whatsapp://send?text=${Uri.encodeComponent(message)}');
    
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        // Fallback: utiliser share_plus
        await Share.share(message, subject: 'Invitation Private School Transport');
      }
    } catch (e) {
      debugPrint('❌ Erreur WhatsApp: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du partage', style: GoogleFonts.inter()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _shareViaInstagram() async {
    final message = '$_inviteMessage$_inviteLink';
    
    try {
      // Instagram Stories - nécessite une image, donc on utilise share_plus
      await Share.share(
        message,
        subject: 'Invitation Private School Transport',
      );
    } catch (e) {
      debugPrint('❌ Erreur Instagram: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('instagram_unavailable'.tr(), style: GoogleFonts.inter()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _shareViaMessenger() async {
    final message = '$_inviteMessage$_inviteLink';
    
    try {
      // Essayer d'ouvrir Messenger
      final url = Uri.parse('fb-messenger://share?link=${Uri.encodeComponent(_inviteLink)}&app_id=YOUR_APP_ID');
      
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        // Fallback: utiliser share_plus
        await Share.share(message, subject: 'Invitation Private School Transport');
      }
    } catch (e) {
      debugPrint('❌ Erreur Messenger: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du partage', style: GoogleFonts.inter()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _shareViaTwitter() async {
    final message = '$_inviteMessage$_inviteLink';
    final text = Uri.encodeComponent(message);
    
    try {
      // Essayer Twitter/X app (nouveau schéma)
      final twitterUrl = Uri.parse('twitter://post?message=$text');
      final xUrl = Uri.parse('x://post?message=$text');
      
      bool launched = false;
      
      // Essayer X (nouveau nom de Twitter)
      if (await canLaunchUrl(xUrl)) {
        await launchUrl(xUrl, mode: LaunchMode.externalApplication);
        launched = true;
      } else if (await canLaunchUrl(twitterUrl)) {
        await launchUrl(twitterUrl, mode: LaunchMode.externalApplication);
        launched = true;
      }
      
      if (!launched) {
        // Fallback vers le web
        final webUrl = Uri.parse('https://twitter.com/intent/tweet?text=$text');
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('❌ Erreur Twitter: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du partage', style: GoogleFonts.inter()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _inviteContact(Contact contact) async {
    if (contact.phones.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('no_phone_number'.tr(), style: GoogleFonts.inter()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final phone = contact.phones.first.number.replaceAll(RegExp(r'[^0-9+]'), '');
    final message = '$_inviteMessage$_inviteLink';
    
    // Afficher un dialogue pour choisir la méthode d'invitation
    if (!mounted) return;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textGrey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '${'invite'.tr()} ${contact.displayName}',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            _buildInviteOption(
              icon: Icons.message,
              label: 'sms'.tr(),
              color: AppColors.success,
              onTap: () {
                Navigator.pop(context);
                _sendViaSMS(phone, message);
              },
            ),
            const SizedBox(height: 12),
            _buildInviteOption(
              icon: Icons.chat,
              label: 'WhatsApp',
              color: AppColors.whatsapp,
              onTap: () {
                Navigator.pop(context);
                _sendViaWhatsAppToContact(phone, message);
              },
            ),
            const SizedBox(height: 12),
            _buildInviteOption(
              icon: Icons.share,
              label: 'other_options'.tr(),
              color: AppColors.textGrey,
              onTap: () {
                Navigator.pop(context);
                Share.share(message, subject: 'Invitation Private School Transport');
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInviteOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textGrey),
          ],
        ),
      ),
    );
  }

  Future<void> _sendViaSMS(String phone, String message) async {
    try {
      final smsUrl = Uri.parse('sms:$phone?body=${Uri.encodeComponent(message)}');
      if (await canLaunchUrl(smsUrl)) {
        await launchUrl(smsUrl);
      } else {
        throw Exception('SMS non disponible');
      }
    } catch (e) {
      debugPrint('❌ Erreur SMS: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('cannot_send_sms'.tr(), style: GoogleFonts.inter()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendViaWhatsAppToContact(String phone, String message) async {
    try {
      // Nettoyer le numéro de téléphone
      final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
      final url = Uri.parse('whatsapp://send?phone=$cleanPhone&text=${Uri.encodeComponent(message)}');
      
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('WhatsApp non disponible');
      }
    } catch (e) {
      debugPrint('❌ Erreur WhatsApp: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('whatsapp_not_installed'.tr(), style: GoogleFonts.inter()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
