import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:private_school/core/utils/app_colors.dart';
import 'package:private_school/core/utils/app_constants.dart';
import 'package:private_school/parents/pages/authentification/presentation/pages/parent_inscription.dart';
import '../../domain/bloc/auth_bloc.dart';
import '../../domain/bloc/auth_event.dart';
import '../../domain/bloc/auth_state.dart';
import '../../../acceuil/presentation/pages/home.dart';
import 'mdp_oublie.dart';

class Connexion extends StatefulWidget {
  const Connexion({super.key});

  @override
  State<Connexion> createState() => _ConnexionState();
}

class _ConnexionState extends State<Connexion> {
  bool _obscurePassword = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        } else if (state is AuthAuthenticated) {
          if (Navigator.canPop(context)) Navigator.of(context).pop();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('login_success'.tr()),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state is AuthError) {
          if (Navigator.canPop(context)) Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingXXL,
              vertical: AppConstants.spacingM,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ======== Langue ========
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/4.svg',
                          colorFilter: const ColorFilter.mode(
                            AppColors.primary,
                            BlendMode.srcIn,
                          ),
                          width: AppConstants.iconSizeM,
                        ),
                        const SizedBox(width: AppConstants.spacingS),
                        Text(
                          "french".tr(),
                          style: const TextStyle(
                            fontSize: AppConstants.fontSizeM,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacingXXXL),

                  // ======== Logo ========
                  Image.asset(
                    AppConstants.logoPath,
                    width: 120,
                    height: 120,
                  ),

                  const SizedBox(height: AppConstants.spacingXXL),

                  // ======== Titre & Description ========
                  Text(
                    "login".tr(),
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeXXL,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingS),
                  const Text(
                    "Connectez-vous pour explorer toutes les\nfonctionnalités de l’application.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeM,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacingXXXL),

                  // ======== Champ Identification (Email) ========
                  _buildInputLabel("identification".tr()),
                  const SizedBox(height: AppConstants.spacingS),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _buildInputDecoration(
                      hint: "email_example".tr(),
                      prefixIcon: Icons.email_outlined,
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacingXL),

                  // ======== Champ Mot de passe ========
                  _buildInputLabel("password".tr()),
                  const SizedBox(height: AppConstants.spacingS),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: _buildInputDecoration(
                      hint: "password_placeholder".tr(),
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacingM),

                  // ======== Mot de passe oublié ========
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MdpOubliePage()),
                      ),
                      child: Text(
                        "forgot_password".tr(),
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacingXXL),

                  // ======== Bouton Se connecter ========
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConstants.radiusXXL),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _handleLogin,
                      child: Text(
                        "connect".tr(),
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeL,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacingXXXL),

                  // ======== Lien Inscription ========
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "no_account_question".tr(),
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ParentInscription()),
                        ),
                        child: const Text(
                          "S’inscrire",
                          style: TextStyle(
                            color: AppColors.successDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Helpers UI ---

  Widget _buildInputLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          fontSize: AppConstants.fontSizeM,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData prefixIcon,
    bool isPassword = false,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textGrey),
      prefixIcon: Icon(prefixIcon, color: AppColors.textGrey, size: 20),
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: AppColors.textGrey,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            )
          : null,
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        borderSide: const BorderSide(color: AppColors.secondary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    );
  }

  void _handleLogin() {
    if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('please_fill_all_fields'.tr())),
      );
      return;
    }
    context.read<AuthBloc>().add(
          LoginEvent(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ),
        );
  }
}