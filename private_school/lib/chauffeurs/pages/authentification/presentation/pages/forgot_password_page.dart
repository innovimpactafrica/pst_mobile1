

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:private_school/chauffeurs/pages/authentification/presentation/pages/verify_otp_page.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../domain/bloc/driver_auth_bloc.dart';
import '../../domain/bloc/driver_auth_event.dart';
import '../../domain/bloc/driver_auth_state.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _contactController = TextEditingController();
  bool _isPhoneMode = true; // true = Téléphone, false = Email

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
          duration: const Duration(seconds: 2),
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
            duration: Duration(seconds: 2),
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
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
    }

    FocusScope.of(context).unfocus();
    context.read<DriverAuthBloc>().add(
          DriverForgotPasswordEvent(contact: contact),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DriverAuthBloc, DriverAuthState>(
      listener: (context, state) {
  if (state is DriverAuthLoading) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      ),
    );
  } else if (state is DriverPasswordResetRequested) {
    // Close loading
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Code envoyé avec succès !'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );

    // ✅ PASSER userId à VerifyOtpForgotPage
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<DriverAuthBloc>(),
          child: VerifyOtpForgotPage(
            contact: _contactController.text.trim(),
            userId: state.userId,  // ✅ Récupéré depuis le state
          ),
        ),
      ),
    );
  } else if (state is DriverAuthError) {
          if (Navigator.canPop(context)) {
            Navigator.of(context).pop();
          }

          String errorMessage = state.message;
          if (errorMessage.contains('Exception:')) {
            errorMessage = errorMessage.replaceAll('Exception:', '').trim();
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is DriverAuthLoading;

        return Scaffold(
          backgroundColor: AppColors.textWhite,
          appBar: AppBar(
            backgroundColor: AppColors.textWhite,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: isLoading ? null : () => Navigator.pop(context),
            ),
            title: const Text(
              'Mot de passe oublié',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: false,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // Logo
                  Image.asset('assets/images/2.jpg', height: 100),

                  const SizedBox(height: 30),

                  // Title
                  const Text(
                    'Mot de passe oublié',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Subtitle
                  const Text(
                    'Entrer votre numéro de téléphone ou votre\nadresse email pour recevoir un OTP',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Toggle Téléphone / Email
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.background.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
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
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _isPhoneMode
                                    ? AppColors.textWhite
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: _isPhoneMode
                                    ? [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.05),
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
                                    Icons.phone_android,
                                    size: 18,
                                    color: _isPhoneMode
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Téléphone',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: _isPhoneMode
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      color: _isPhoneMode
                                          ? AppColors.primary
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
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
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !_isPhoneMode
                                    ? AppColors.textWhite
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: !_isPhoneMode
                                    ? [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.05),
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
                                    Icons.email_outlined,
                                    size: 18,
                                    color: !_isPhoneMode
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Email',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: !_isPhoneMode
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      color: !_isPhoneMode
                                          ? AppColors.primary
                                          : AppColors.textSecondary,
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

                  const SizedBox(height: 24),

                  // Input Field
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _isPhoneMode
                          ? 'Numéro de téléphone'
                          : 'Adresse email',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _contactController,
                    keyboardType: _isPhoneMode
                        ? TextInputType.phone
                        : TextInputType.emailAddress,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      hintText: _isPhoneMode
                          ? 'Ex: +221771234567'
                          : 'exemple@email.com',
                      hintStyle: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.5),
                      ),
                      filled: true,
                      fillColor: AppColors.background.withValues(alpha: 0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      prefixIcon: Icon(
                        _isPhoneMode
                            ? Icons.phone_android
                            : Icons.email_outlined,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isLoading
                            ? AppColors.primary.withValues(alpha: 0.6)
                            : AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textWhite,
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