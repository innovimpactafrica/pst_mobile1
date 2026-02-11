// Parent Reset Password Page - Exact Figma Design
// Path: lib/parents/pages/authentification/presentation/pages/creer_mdp.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_constants.dart';
import '../../domain/bloc/auth_bloc.dart';
import '../../domain/bloc/auth_event.dart';
import '../../domain/bloc/auth_state.dart';
import 'connexion.dart';

class PasswordCreationPage extends StatefulWidget {
  final int? userId;
  final String? code;

  const PasswordCreationPage({
    super.key,
    this.userId,
    this.code,
  });

  @override
  State<PasswordCreationPage> createState() => _PasswordCreationPageState();
}

class _PasswordCreationPageState extends State<PasswordCreationPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le mot de passe doit contenir au moins 8 caractères'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Les mots de passe ne correspondent pas'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    if (widget.userId == null || widget.code == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur: Données manquantes'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // 🔥 Appel API reset password
    context.read<AuthBloc>().add(
          ResetPasswordEvent(
            userId: widget.userId!,
            code: widget.code!,
            newPassword: password,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(
              child: CircularProgressIndicator(color: AppColors.success),
            ),
          );
        } else if (state is PasswordResetSuccess) {
          if (Navigator.canPop(context)) {
            Navigator.of(context).pop(); // Fermer loading
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mot de passe réinitialisé avec succès !'),
              backgroundColor: AppColors.success,
            ),
          );

          // 🔥 REDIRECTION vers page de connexion parent
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => const Connexion(),
            ),
            (route) => false, // Supprimer toutes les pages précédentes
          );
        } else if (state is AuthError) {
          if (Navigator.canPop(context)) {
            Navigator.of(context).pop();
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: AppColors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingXL,
                vertical: AppConstants.spacingM,
              ),
              child: Column(
                children: [
                  // 🔝 Header
                  Row(
                    children: [
                      GestureDetector(
                        onTap: isLoading ? null : () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: AppColors.backgroundLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: AppColors.textPrimary,
                            size: AppConstants.iconSizeM,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(
                            Icons.language,
                            color: AppColors.primary,
                            size: AppConstants.iconSizeM,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Français',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                              fontSize: AppConstants.fontSizeM,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: AppConstants.spacingXXL),

                  // 🏢 Logo
                  Image.asset(
                    AppConstants.logoPath,
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: AppConstants.spacingXXL),

                  // 📝 Titre
                  const Text(
                    'Créez votre mot de passe',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeXXL,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacingL),

                  // 📄 Sous-titre
                  const Text(
                    'Choisissez un mot de passe sécurisé pour\nprotéger votre compte.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeM,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacingXXXL),

                  // 🔐 Nouveau mot de passe
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Nouveau mot de passe',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeM,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacingS),

                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      hintText: '••••••••••',
                      hintStyle: const TextStyle(
                        color: AppColors.textTertiary,
                      ),
                      filled: true,
                      fillColor: AppColors.backgroundLight,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusL),
                        borderSide: const BorderSide(
                          color: AppColors.borderLight,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusL),
                        borderSide: const BorderSide(
                          color: AppColors.borderLight,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusL),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingXL,
                        vertical: AppConstants.spacingM,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacingXL),

                  // 🔐 Confirmation mot de passe
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Confirmation de mot de passe',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeM,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacingS),

                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      hintText: '••••••••••',
                      hintStyle: const TextStyle(
                        color: AppColors.textTertiary,
                      ),
                      filled: true,
                      fillColor: AppColors.backgroundLight,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusL),
                        borderSide: const BorderSide(
                          color: AppColors.borderLight,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusL),
                        borderSide: const BorderSide(
                          color: AppColors.borderLight,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusL),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingXL,
                        vertical: AppConstants.spacingM,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 🟢 Bouton "Confirmer" (VERT)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isLoading
                            ? AppColors.success.withValues(alpha:0.6)
                            : AppColors.success,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        elevation: 0,
                      ),
                      onPressed: isLoading ? null : _submit,
                      child: isLoading
                          ? const CircularProgressIndicator(color: AppColors.white)
                          : const Text(
                              'Confirmer',
                              style: TextStyle(
                                fontSize: AppConstants.fontSizeL,
                                fontWeight: FontWeight.w600,
                                color: AppColors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}