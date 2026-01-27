import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:private_school/core/utils/app_colors.dart';
import 'package:private_school/core/utils/app_constants.dart';
import '../../widgets/money_mode.dart';
import '../../authentification/domain/bloc/driver_auth_bloc.dart';
import '../../authentification/domain/bloc/driver_auth_event.dart';
import '../../authentification/domain/bloc/driver_auth_state.dart';
import 'verification.dart';

/// Forgot password page for drivers
/// Allows password reset via phone or email
class MdpOubliePage extends StatefulWidget {
  const MdpOubliePage({super.key});

  @override
  State<MdpOubliePage> createState() => _MdpOubliePageState();
}

class _MdpOubliePageState extends State<MdpOubliePage> {
  bool usePhone = true;
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _showSubscriptionModal(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Subscription',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (context, anim, _, child) {
        final curved = CurvedAnimation(
          parent: anim,
          curve: Curves.easeOutCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(curved),
          child: PaymentModal(
            onClose: () {
              setState(() {
                usePhone = true;
              });
            },
          ),
        );
      },
    );
  }

  void _onSendCode() {
    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer votre numéro de téléphone'),
        ),
      );
      return;
    }

    context.read<DriverAuthBloc>().add(
          DriverForgotPasswordEvent(phone: _phoneController.text.trim()),
        );
  }

  Widget _buildSegmentedControl() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => usePhone = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.spacingM - 2,
                ),
                decoration: BoxDecoration(
                  color: usePhone ? AppColors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(36),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.phone,
                      color: usePhone
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppConstants.spacingS),
                    Text(
                      'Téléphone',
                      style: TextStyle(
                        color: usePhone
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight:
                            usePhone ? FontWeight.w700 : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                setState(() => usePhone = false);
                await Future.delayed(const Duration(milliseconds: 100));
                // Check if widget is still mounted before using context
                if (mounted) {
                  _showSubscriptionModal(context);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.spacingM - 2,
                ),
                decoration: BoxDecoration(
                  color: !usePhone ? AppColors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(36),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.email,
                      color: !usePhone
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppConstants.spacingS),
                    Text(
                      'Email',
                      style: TextStyle(
                        color: !usePhone
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight:
                            !usePhone ? FontWeight.w700 : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DriverAuthBloc, DriverAuthState>(
      listener: (context, state) {
        if (state is DriverAuthLoading) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        } else if (state is DriverPasswordResetRequested) {
          Navigator.of(context).pop();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => Verification(phone: state.phone),
            ),
          );
        } else if (state is DriverAuthError) {
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
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingXL + 4,
              vertical: AppConstants.spacingL,
            ),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.backgroundLight,
                          shape: BoxShape.circle,
                        ),
                        child: SvgPicture.asset('assets/icons/back.svg'),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        SvgPicture.asset('assets/icons/4.svg'),
                        const SizedBox(width: AppConstants.spacingS),
                        const Text(
                          'Français',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingXL + 2),

                // Logo
                Image.asset(
                  'assets/images/2.jpg',
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: AppConstants.spacingXL + 2),

                // Title
                const Text(
                  'Mot de passe oublié',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingL),

                // Description
                const Text(
                  "Entrer votre numéro de téléphone ou votre\nadresse email pour recevoir un OTP",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeL,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingXXL - 2),

                // Segmented control
                _buildSegmentedControl(),
                const SizedBox(height: AppConstants.spacingXL + 4),

                // Phone input
                if (usePhone) ...[
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Numéro de téléphone',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        fontSize: AppConstants.fontSizeL,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingS),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'Ex: 77 123 45 67',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.success),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingXL,
                        vertical: AppConstants.spacingM - 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingXXL - 2),

                  // Send button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppConstants.spacingXL + 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      onPressed: _onSendCode,
                      child: const Text(
                        'Envoyer le code',
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeL,
                          color: AppColors.textWhite,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}