// Parent Forgot Password Page - Exact Figma Design
// Path: lib/parents/pages/authentification/presentation/pages/mdp_oublie.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_constants.dart';
import '../../domain/bloc/auth_bloc.dart';
import '../../domain/bloc/auth_event.dart';
import '../../domain/bloc/auth_state.dart';
import 'verification.dart';

class MdpOubliePage extends StatefulWidget {
  const MdpOubliePage({super.key});

  @override
  State<MdpOubliePage> createState() => _MdpOubliePageState();
}

class _MdpOubliePageState extends State<MdpOubliePage> {
  bool _isPhoneMode = true; // true = Téléphone, false = Email
  final TextEditingController _contactController = TextEditingController();

  @override
  void dispose() {
    _contactController.dispose();
    super.dispose();
  }

  void _submit() {
    final contact = _contactController.text.trim();

    if (contact.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isPhoneMode
              ? 'Veuillez entrer votre numéro de téléphone'
              : 'Veuillez entrer votre email'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // Validation
    if (_isPhoneMode) {
      final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
      if (!phoneRegex.hasMatch(contact)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Format de téléphone invalide'),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }
    } else {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(contact)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Format d\'email invalide'),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }
    }

    FocusScope.of(context).unfocus();

    // 🔥 Appel API
    context.read<AuthBloc>().add(
          ForgotPasswordEvent(contact: contact),
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
        } else if (state is PasswordResetRequested) {
          if (Navigator.canPop(context)) {
            Navigator.of(context).pop(); // Fermer loading
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Code envoyé avec succès !'),
              backgroundColor: AppColors.success,
            ),
          );

          // 🔥 Navigation vers verification
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => Verification(
                contact: state.contact,
                userId: state.userId,
              ),
            ),
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
                      // Bouton retour
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
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
                      // Langue
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
                    'Mot de passe oublié',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeXXL,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacingL),

                  // 📄 Sous-titre
                  const Text(
                    'Entrer votre numéro de téléphone ou votre\nadresse email pour recevoir un OTP',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeM,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacingXXXL),

                  // 🔀 Toggle Téléphone / Email
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2F8), // Fond toggle exact Figma
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Row(
                      children: [
                        // Téléphone
                        Expanded(
                          child: GestureDetector(
                            onTap: isLoading
                                ? null
                                : () {
                                    setState(() {
                                      _isPhoneMode = true;
                                      _contactController.clear();
                                    });
                                  },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: _isPhoneMode
                                    ? AppColors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(36),
                                boxShadow: _isPhoneMode
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha:0.05),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.phone,
                                    size: 18,
                                    color: _isPhoneMode
                                        ? AppColors.primary
                                        : const Color(0xFF4B5563),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Téléphone',
                                    style: TextStyle(
                                      fontSize: AppConstants.fontSizeM,
                                      fontWeight: _isPhoneMode
                                          ? FontWeight.w700
                                          : FontWeight.w600,
                                      color: _isPhoneMode
                                          ? AppColors.primary
                                          : const Color(0xFF4B5563),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Email
                        Expanded(
                          child: GestureDetector(
                            onTap: isLoading
                                ? null
                                : () {
                                    setState(() {
                                      _isPhoneMode = false;
                                      _contactController.clear();
                                    });
                                  },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: !_isPhoneMode
                                    ? AppColors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(36),
                                boxShadow: !_isPhoneMode
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha:0.05),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.email,
                                    size: 18,
                                    color: !_isPhoneMode
                                        ? AppColors.primary
                                        : const Color(0xFF4B5563),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Email',
                                    style: TextStyle(
                                      fontSize: AppConstants.fontSizeM,
                                      fontWeight: !_isPhoneMode
                                          ? FontWeight.w700
                                          : FontWeight.w600,
                                      color: !_isPhoneMode
                                          ? AppColors.primary
                                          : const Color(0xFF4B5563),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacingXXL),

                  // 📱 Label
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _isPhoneMode
                          ? 'Numéro de téléphone'
                          : 'Adresse email',
                      style: const TextStyle(
                        fontSize: AppConstants.fontSizeM,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacingS),

                  // 📝 Input
                  TextField(
                    controller: _contactController,
                    keyboardType: _isPhoneMode
                        ? TextInputType.phone
                        : TextInputType.emailAddress,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      hintText: _isPhoneMode
                          ? 'Ex: 77 123 45 67'
                          : 'exemple@email.com',
                      hintStyle: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: AppConstants.fontSizeM,
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
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingXL,
                        vertical: AppConstants.spacingM,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacingXXXL),

                  // 🟢 Bouton "Envoyer le code" (VERT comme Figma)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isLoading
                            ? AppColors.success.withValues(alpha:0.6)
                            : AppColors.success, // 🔥 VERT
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        elevation: 0,
                      ),
                      onPressed: isLoading ? null : _submit,
                      child: isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Envoyer le code',
                              style: TextStyle(
                                fontSize: AppConstants.fontSizeL,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
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