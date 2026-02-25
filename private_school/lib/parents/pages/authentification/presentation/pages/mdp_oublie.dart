import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
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
  bool _isPhoneMode = true;
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
          content: Text(
            _isPhoneMode
                ? 'enter_phone_number'.tr()
                : 'enter_email_address'.tr(),
          ),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    if (_isPhoneMode) {
      final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
      if (!phoneRegex.hasMatch(contact)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('invalid_phone_format'.tr()),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }
    } else {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(contact)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('invalid_email_format'.tr()),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }
    }

    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(ForgotPasswordEvent(contact: contact));
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
          if (Navigator.canPop(context)) Navigator.of(context).pop();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('code_sent_successfully'.tr()),
              backgroundColor: AppColors.success,
            ),
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  Verification(contact: state.contact, userId: state.userId),
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
                  Row(
                    children: [
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
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppConstants.spacingXXL),

                  Image.asset(
                    AppConstants.logoPath,
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: AppConstants.spacingXXL),

                  Text(
                    'forgot_password_title'.tr(),
                    style: const TextStyle(
                      fontSize: AppConstants.fontSizeXXL,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacingL),

                  Text(
                    'enter_phone_or_email'.tr(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: AppConstants.fontSizeM,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacingXXXL),

                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2F8),
                      borderRadius: BorderRadius.circular(40),
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
                                          color: AppColors.blackOpacity05,
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
                                    'phone_mode'.tr(),
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
                                          color: AppColors.blackOpacity05,
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
                                    'email_mode'.tr(),
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

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _isPhoneMode
                          ? 'phone_number_label'.tr()
                          : 'email_address'.tr(),
                      style: const TextStyle(
                        fontSize: AppConstants.fontSizeM,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacingS),

                  TextField(
                    controller: _contactController,
                    keyboardType: _isPhoneMode
                        ? TextInputType.phone
                        : TextInputType.emailAddress,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      hintText: _isPhoneMode
                          ? 'phone_example'.tr()
                          : 'email_example_full'.tr(),
                      hintStyle: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: AppConstants.fontSizeM,
                      ),
                      filled: true,
                      fillColor: AppColors.backgroundLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusL,
                        ),
                        borderSide: const BorderSide(
                          color: AppColors.borderLight,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusL,
                        ),
                        borderSide: const BorderSide(
                          color: AppColors.borderLight,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusL,
                        ),
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

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isLoading
                            ? AppColors.success.withValues(alpha: 0.6)
                            : AppColors.success,
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
                                color: AppColors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              'send_code'.tr(),
                              style: const TextStyle(
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
