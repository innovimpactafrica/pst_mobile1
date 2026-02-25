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

  // Lien d'invitation
  final String _inviteLink = 'https://privateschool.app/invite?ref=USER123';
  final String _inviteMessage =
      ' Rejoignez-moi sur Private School Transport ! Une app sécurisée pour le transport scolaire. Téléchargez maintenant : ';

  // ─── SVG inline

  static const String _whatsappSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">
  <path fill="#fff" d="M24 4C13 4 4 13 4 24c0 3.6.97 7 2.66 9.9L4 44l10.4-2.62A19.9 19.9 0 0 0 24 44c11 0 20-9 20-20S35 4 24 4z"/>
  <path fill="#25D366" d="M24 6.5c-9.65 0-17.5 7.85-17.5 17.5 0 3.24.89 6.27 2.44 8.86L7.5 40.5l7.88-2.38A17.43 17.43 0 0 0 24 41.5c9.65 0 17.5-7.85 17.5-17.5S33.65 6.5 24 6.5z"/>
  <path fill="#fff" d="M19.05 15.5c-.4-1-.82-1.02-1.2-1.04-.31-.02-.67-.02-1.02-.02-.36 0-.94.13-1.43.65-.49.52-1.88 1.83-1.88 4.47s1.93 5.18 2.2 5.54c.27.36 3.72 5.95 9.17 8.1 4.54 1.79 5.46 1.43 6.45 1.34.98-.09 3.17-1.3 3.62-2.55.45-1.25.45-2.32.31-2.55-.13-.22-.49-.35-.85-.53s-2.1-1.03-2.42-1.16c-.32-.13-.54-.2-.77.2s-.88 1.16-1.08 1.4c-.2.23-.4.26-.76.09-.36-.18-1.52-.56-2.9-1.79-1.07-.95-1.79-2.13-2-2.49-.2-.36-.02-.56.15-.74.16-.16.36-.4.54-.6.18-.2.24-.36.36-.6.12-.23.06-.45-.03-.63-.09-.18-.77-1.87-1.08-2.56z"/>
</svg>''';

  static const String _instagramSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">
  <radialGradient id="ig1" cx="19.4" cy="42.8" r="44.9" gradientUnits="userSpaceOnUse">
    <stop offset="0" stop-color="#fd5"/>
    <stop offset=".3" stop-color="#ff543e"/>
    <stop offset=".6" stop-color="#c837ab"/>
  </radialGradient>
  <path fill="url(#ig1)" d="M34.02 5H13.98C9.02 5 5 9.02 5 13.98v20.04C5 38.98 9.02 43 13.98 43h20.04C38.98 43 43 38.98 43 34.02V13.98C43 9.02 38.98 5 34.02 5z"/>
  <path fill="#fff" d="M24 13a11 11 0 1 0 0 22 11 11 0 0 0 0-22zm0 18a7 7 0 1 1 0-14 7 7 0 0 1 0 14zm11.5-18.5a2.5 2.5 0 1 1-5 0 2.5 2.5 0 0 1 5 0z"/>
</svg>''';

  static const String _messengerSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">
  <linearGradient id="mg1" x1="6" y1="24" x2="42" y2="24" gradientUnits="userSpaceOnUse">
    <stop offset="0" stop-color="#0099ff"/>
    <stop offset="1" stop-color="#a033ff"/>
  </linearGradient>
  <path fill="url(#mg1)" d="M24 4C13 4 4 12.5 4 23c0 5.8 2.6 11 6.8 14.6V44l6.4-3.5c1.7.5 3.5.7 5.3.7 11 0 20-8.5 20-19C42 12.5 33 4 24 4z"/>
  <path fill="#fff" d="M26.4 29.5 21 23.5l-10.2 6 11.2-11.9 5.5 6 10-6z"/>
</svg>''';

  static const String _twitterSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">
  <path fill="#fff" d="M36.45 6h5.9L29.1 20.6 44.5 42h-12.1L23 30.1 12.45 42H6.53l14.1-16.1L5.5 6h12.4l8.62 11.4zm-2.07 32.4h3.27L14.08 9.3h-3.5z"/>
</svg>''';

  // ─────────────────────────────────────────────────────────────────────────

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
              content: Text(
                'contacts_permission_denied'.tr(),
                style: GoogleFonts.inter(),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint(' Erreur chargement contacts: $e');
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
          // ── Copier lien ──
          _buildSocialButton(
            label: 'copy'.tr(),
            color: const Color(0xFF6366F1),
            onTap: _copyLink,
            child: const Icon(Icons.link, color: Colors.white, size: 28),
          ),
          // ── WhatsApp ──
          _buildSocialButton(
            label: 'WhatsApp',
            color: const Color(0xFF25D366),
            onTap: _shareViaWhatsApp,
            child: SvgPicture.string(_whatsappSvg, width: 34, height: 34),
          ),
          // ── Instagram ──
          _buildSocialButton(
            label: 'Instagram',
            color: const Color(0xFFE4405F),
            onTap: _shareViaInstagram,
            child: SvgPicture.string(_instagramSvg, width: 34, height: 34),
          ),
          // ── Messenger ──
          _buildSocialButton(
            label: 'Messenger',
            color: const Color(0xFF0084FF),
            onTap: _shareViaMessenger,
            child: SvgPicture.string(_messengerSvg, width: 34, height: 34),
          ),
          // ── Twitter / X ──
          _buildSocialButton(
            label: 'Twitter',
            color: Colors.black,
            onTap: _shareViaTwitter,
            child: SvgPicture.string(_twitterSvg, width: 28, height: 28),
          ),
        ],
      ),
    );
  }

  // ── Widget bouton social
  Widget _buildSocialButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(child: child),
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
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.textGrey),
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
          final phone = contact.phones.isNotEmpty
              ? contact.phones.first.number
              : '';
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
    final url = Uri.parse(
      'whatsapp://send?text=${Uri.encodeComponent(message)}',
    );
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        await Share.share(
          message,
          subject: 'Invitation Private School Transport',
        );
      }
    } catch (e) {
      debugPrint(' Erreur WhatsApp: $e');
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
      await Share.share(
        message,
        subject: 'Invitation Private School Transport',
      );
    } catch (e) {
      debugPrint(' Erreur Instagram: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'instagram_unavailable'.tr(),
              style: GoogleFonts.inter(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _shareViaMessenger() async {
    final message = '$_inviteMessage$_inviteLink';
    try {
      final url = Uri.parse(
        'fb-messenger://share?link=${Uri.encodeComponent(_inviteLink)}&app_id=YOUR_APP_ID',
      );
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        await Share.share(
          message,
          subject: 'Invitation Private School Transport',
        );
      }
    } catch (e) {
      debugPrint(' Erreur Messenger: $e');
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
      final twitterUrl = Uri.parse('twitter://post?message=$text');
      final xUrl = Uri.parse('x://post?message=$text');
      bool launched = false;

      if (await canLaunchUrl(xUrl)) {
        await launchUrl(xUrl, mode: LaunchMode.externalApplication);
        launched = true;
      } else if (await canLaunchUrl(twitterUrl)) {
        await launchUrl(twitterUrl, mode: LaunchMode.externalApplication);
        launched = true;
      }

      if (!launched) {
        final webUrl = Uri.parse('https://twitter.com/intent/tweet?text=$text');
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint(' Erreur Twitter: $e');
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

    final phone = contact.phones.first.number.replaceAll(
      RegExp(r'[^0-9+]'),
      '',
    );
    final message = '$_inviteMessage$_inviteLink';

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
                Share.share(
                  message,
                  subject: 'Invitation Private School Transport',
                );
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
      final smsUrl = Uri.parse(
        'sms:$phone?body=${Uri.encodeComponent(message)}',
      );
      if (await canLaunchUrl(smsUrl)) {
        await launchUrl(smsUrl);
      } else {
        throw Exception('SMS non disponible');
      }
    } catch (e) {
      debugPrint(' Erreur SMS: $e');
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
      final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
      final url = Uri.parse(
        'whatsapp://send?phone=$cleanPhone&text=${Uri.encodeComponent(message)}',
      );
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('WhatsApp non disponible');
      }
    } catch (e) {
      debugPrint('Erreur WhatsApp: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'whatsapp_not_installed'.tr(),
              style: GoogleFonts.inter(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
