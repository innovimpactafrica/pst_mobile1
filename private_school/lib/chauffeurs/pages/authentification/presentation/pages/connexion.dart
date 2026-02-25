import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../domain/bloc/driver_auth_bloc.dart';
import '../../domain/bloc/driver_auth_event.dart';
import '../../domain/bloc/driver_auth_state.dart';
import '../../../../widgets/main_layout.dart';
import 'inscription.dart';
import 'forgot_password_page.dart';

class Connexion extends StatefulWidget {
  const Connexion({super.key});

  @override
  State<Connexion> createState() => _ConnexionState();
}

class _ConnexionState extends State<Connexion> {
  bool _obscurePassword = true;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DriverAuthBloc, DriverAuthState>(
      listener: (context, state) {
        if (state is DriverAuthLoading) {
          ScaffoldMessenger.of(context).clearSnackBars();

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => PopScope(
              canPop: false,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
          );
        } else if (state is DriverAuthenticated) {
          if (Navigator.canPop(context)) {
            Navigator.of(context).pop();
          }

          ScaffoldMessenger.of(context).clearSnackBars();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('login_success'.tr()),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainLayout()),
          );
        } else if (state is DriverAuthError) {
          if (Navigator.canPop(context)) {
            Navigator.of(context).pop();
          }

          ScaffoldMessenger.of(context).clearSnackBars();

          String errorMessage = state.message;

          if (errorMessage.contains('User not found')) {
            errorMessage = 'invalid_email'.tr();
          } else if (errorMessage.contains('Exception:')) {
            errorMessage = errorMessage.replaceAll('Exception:', '').trim();
          } else if (errorMessage.contains('Login failed:')) {
            errorMessage = errorMessage.replaceAll('Login failed:', '').trim();
          }

          if (errorMessage.contains('Exception:')) {
            final parts = errorMessage.split('Exception:');
            errorMessage = parts.last.trim();
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
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
            title: Text(
              'login'.tr(),
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: false,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.language,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          context.locale.languageCode == 'fr'
                              ? 'Français'
                              : 'English',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  Image.asset('assets/images/2.jpg', height: 100),

                  const SizedBox(height: 30),

                  Text(
                    'login'.tr(),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'connection_description'.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 40),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'identification'.tr(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.emailAddress,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      hintText: 'email_example'.tr(),
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
                    ),
                  ),

                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'password'.tr(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      hintText: 'password_placeholder'.tr(),
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
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: isLoading
                            ? null
                            : () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

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
                      onPressed: isLoading
                          ? null
                          : () {
                              // Validation
                              if (_phoneController.text.trim().isEmpty ||
                                  _passwordController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'please_fill_all_fields'.tr(),
                                    ),
                                    backgroundColor: AppColors.warning,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                return;
                              }

                              final emailRegex = RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              );
                              if (!emailRegex.hasMatch(
                                _phoneController.text.trim(),
                              )) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('invalid_email'.tr()),
                                    backgroundColor: AppColors.warning,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                return;
                              }

                              // Close keyboard
                              FocusScope.of(context).unfocus();

                              // Trigger login event
                              context.read<DriverAuthBloc>().add(
                                DriverLoginEvent(
                                  phone: _phoneController.text.trim(),
                                  password: _passwordController.text,
                                ),
                              );
                            },
                      child: isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              'connect'.tr(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textWhite,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Forgot Password
                  GestureDetector(
                    onTap: isLoading
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ForgotPasswordPage(),
                              ),
                            );
                          },
                    child: Text(
                      'forgot_password'.tr(),
                      style: TextStyle(
                        color: isLoading
                            ? AppColors.primary.withValues(alpha: 0.5)
                            : AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'no_account_question'.tr(),
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: isLoading
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const InscriptionPage(),
                                  ),
                                );
                              },
                        child: Text(
                          'sign_up_link'.tr(),
                          style: TextStyle(
                            color: isLoading
                                ? AppColors.success.withValues(alpha: 0.5)
                                : AppColors.success,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
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
