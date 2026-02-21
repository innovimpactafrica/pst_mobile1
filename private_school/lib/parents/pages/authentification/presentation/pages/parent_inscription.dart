// Page d'inscription parent - Version Simple FINALE
// Path: lib/parents/authentification/presentation/pages/parent_inscription_simple.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:private_school/core/utils/app_colors.dart';
import 'package:private_school/core/utils/google_maps_config.dart';
import 'package:private_school/parents/widgets/address_picker_widget.dart';
import '../../domain/bloc/auth_bloc.dart';
import '../../domain/bloc/auth_event.dart';
import '../../domain/bloc/auth_state.dart';

class ParentInscription extends StatefulWidget {
  const ParentInscription({super.key});

  @override
  State<ParentInscription> createState() => _ParentInscriptionSimpleState();
}

class _ParentInscriptionSimpleState extends State<ParentInscription> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _homeAddressController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _homeAddressController.dispose();
    super.dispose();
  }

  void _register() {
    // Validation des champs vides
    if (_nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _confirmPasswordController.text.trim().isEmpty ||
        _homeAddressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('please_fill_all_fields'.tr()),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Validation email
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(_emailController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('invalid_email'.tr()),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Validation longueur mot de passe
    if (_passwordController.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('password_min_length'.tr()),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Vérifier correspondance mots de passe
    if (_passwordController.text.trim() != _confirmPasswordController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('passwords_do_not_match'.tr()),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Séparer prénom et nom
    final nameParts = _nameController.text.trim().split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts[0] : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    if (firstName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('please_enter_first_last_name'.tr()),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // ✅ Envoyer l'inscription AVEC le password, l'adresse et les coordonnées
    context.read<AuthBloc>().add(
          RegisterEvent(
            firstName: firstName,
            lastName: lastName,
            phone: _phoneController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            homeAddress: _homeAddressController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(
              child: CircularProgressIndicator(color: AppColors.successDark),
            ),
          );
        } else if (state is RegisterSuccess) {
          // Fermer le loading
          if (Navigator.canPop(context)) Navigator.of(context).pop();

          // ✅ Afficher le message de succès
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('registration_success_message'.tr()),
              backgroundColor: AppColors.successDark,
              duration: Duration(seconds: 2),
            ),
          );

          
          final navigator = Navigator.of(context);
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              navigator.pushReplacementNamed('/parent/connexion');
            }
          });
        } else if (state is AuthError) {
          // Fermer le loading
          if (Navigator.canPop(context)) Navigator.of(context).pop();

          // Nettoyer le message d'erreur (enlever "Exception:")
          String errorMessage = state.message;
          if (errorMessage.startsWith('Exception:')) {
            errorMessage = errorMessage.replaceFirst('Exception:', '').trim();
          }
          if (errorMessage.startsWith('Inscription échouée:')) {
            errorMessage = errorMessage.replaceFirst('Inscription échouée:', '').trim();
          }
          if (errorMessage.startsWith('Erreur lors de l\'inscription:')) {
            errorMessage = errorMessage.replaceFirst('Erreur lors de l\'inscription:', '').trim();
          }

          // Afficher l'erreur propre
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildLogo(),
                  const SizedBox(height: 20),
                  _buildTitle(),
                  const SizedBox(height: 8),
                  _buildSubtitle(),
                  const SizedBox(height: 32),
                  _buildForm(),
                  const SizedBox(height: 32),
                  _buildRegisterButton(),
                  const SizedBox(height: 20),
                  _buildLoginLink(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        GestureDetector(
          onTap: () {
            final currentLocale = context.locale;
            if (currentLocale.languageCode == 'fr') {
              context.setLocale(const Locale('en'));
            } else {
              context.setLocale(const Locale('fr'));
            }
            setState(() {});
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/4.svg',
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(
                    AppColors.primary,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  context.locale.languageCode == 'fr' ? 'Français' : 'English',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogo() {
    return Center(
      child: Image.asset(
        'assets/images/2.jpg',
        height: 70,
      ),
    );
  }

  Widget _buildTitle() {
    return Center(
      child: Text(
        'sign_up_in_one_click'.tr(),
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    return Center(
      child: Text(
        'create_account_description'.tr(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          label: 'first_last_name'.tr(),
          hint: 'name_example'.tr(),
          controller: _nameController,
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'phone_number'.tr(),
          hint: 'phone_example'.tr(),
          controller: _phoneController,
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'email'.tr(),
          hint: 'email_example'.tr(),
          controller: _emailController,
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        AddressPickerWidget(
          controller: _homeAddressController,
          googleApiKey: GoogleMapsConfig.apiKey,
          onLocationSelected: (lat, lng) {
            // Coordonnées reçues mais non utilisées pour l'instant
          },
        ),
        const SizedBox(height: 16),
        _buildPasswordField(
          label: 'password'.tr(),
          controller: _passwordController,
          obscureText: _obscurePassword,
          onToggleVisibility: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        const SizedBox(height: 16),
        _buildPasswordField(
          label: 'confirm_password'.tr(),
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          onToggleVisibility: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            prefixIcon: Icon(
              icon,
              color: AppColors.textSecondary,
              size: 20,
            ),
            filled: true,
            fillColor: AppColors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.grey300,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.grey300,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.successDark,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: '••••••••••',
            hintStyle: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.textSecondary,
                size: 20,
              ),
              onPressed: onToggleVisibility,
            ),
            filled: true,
            fillColor: AppColors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.grey300,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.grey300,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.successDark,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }



  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _register,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.successDark,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Text(
          'sign_up'.tr(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'already_have_account'.tr(),
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushReplacementNamed(context, '/parent/connexion');
            },
            child: Text(
              'login'.tr(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.successDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}