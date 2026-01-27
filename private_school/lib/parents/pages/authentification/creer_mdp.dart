import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:private_school/core/utils/app_colors.dart';
import 'package:private_school/core/utils/app_constants.dart';
import 'connexion.dart';

class PasswordCreationPage extends StatefulWidget {
  const PasswordCreationPage({super.key});

  @override
  State<PasswordCreationPage> createState() => _PasswordCreationPageState();
}

class _PasswordCreationPageState extends State<PasswordCreationPage> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  @override
  void dispose() {
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  // ----- Fenêtre modale de succès -----
  void _showSuccessModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusXL)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset('assets/icons/12.svg', height: 80),
              const SizedBox(height: AppConstants.spacingM),
              const Text(
                "Votre mot de passe a été créé avec succès. Veuillez vous connecter maintenant.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: AppConstants.fontSizeM,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppConstants.spacingXXL),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Ferme la modale
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const Connexion()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusL),
                    ),
                  ),
                  child: const Text(
                    "OK",
                    style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Image.asset(AppConstants.logoPath, height: 100),
                    const SizedBox(height: AppConstants.spacingL),
                    const Text(
                      "Créez votre mot de passe",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeXXL,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingS),
                    const Text(
                      "Choisissez un nouveau mot de passe sécurisé pour protéger votre compte.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: AppConstants.fontSizeS),
                    ),
                    const SizedBox(height: AppConstants.spacingXXL),
                    
                    _buildPasswordField(
                      label: "Nouveau mot de passe",
                      controller: _passController,
                      isObscured: _obscurePassword,
                      onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    
                    const SizedBox(height: AppConstants.spacingM),
                    
                    _buildPasswordField(
                      label: "Confirmer mot de passe",
                      controller: _confirmPassController,
                      isObscured: _obscureConfirmPassword,
                      onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                  ],
                ),
              ),
            ),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/icons/4.svg',
                colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
                width: 18,
              ),
              const SizedBox(width: 6),
              const Text(
                "Français",
                style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool isObscured,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isObscured,
          decoration: InputDecoration(
            hintText: "********",
            prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textGrey, size: 20),
            suffixIcon: IconButton(
              icon: Icon(isObscured ? Icons.visibility_off : Icons.visibility, color: AppColors.textGrey),
              onPressed: onToggle,
            ),
            filled: true,
            fillColor: AppColors.backgroundLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusXXL),
            ),
          ),
          onPressed: _showSuccessModal,
          child: const Text(
            "Confirmer",
            style: TextStyle(fontSize: 16, color: AppColors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}