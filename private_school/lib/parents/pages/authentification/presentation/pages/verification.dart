import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_constants.dart';
import '../../domain/bloc/auth_bloc.dart';
import 'creer_mdp.dart';

class Verification extends StatefulWidget {
  final String? contact;
  final int? userId;

  const Verification({super.key, this.contact, this.userId});

  @override
  State<Verification> createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  final List<TextEditingController> _otpControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(4, (_) => FocusNode());

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _verifyOtp() {
    final otp = _otpControllers.map((c) => c.text).join();

    if (otp.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('enter_4_digit_code'.tr()),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    if (widget.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('error_missing_user_id'.tr()),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<AuthBloc>(),
          child: PasswordCreationPage(userId: widget.userId!, code: otp),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              //  Header
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
                  Row(
                    children: [
                      const Icon(
                        Icons.language,
                        color: AppColors.primary,
                        size: AppConstants.iconSizeM,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'french'.tr(),
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

              Image.asset(
                AppConstants.logoPath,
                width: 100,
                height: 100,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: AppConstants.spacingXXL),

              Text(
                'verification_code'.tr(),
                style: const TextStyle(
                  fontSize: AppConstants.fontSizeXXL,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: AppConstants.spacingL),

              Text(
                'enter_4_digit_code_sent'.tr(
                  namedArgs: {'contact': widget.contact ?? 'your_email'.tr()},
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: AppConstants.fontSizeM,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) {
                  return SizedBox(
                    width: 60,
                    height: 60,
                    child: TextField(
                      controller: _otpControllers[index],
                      focusNode: _otpFocusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: AppConstants.fontSizeXXL,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
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
                            color: AppColors.success,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.length == 1 && index < 3) {
                          _otpFocusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          _otpFocusNodes[index - 1].requestFocus();
                        }
                      },
                    ),
                  );
                }),
              ),

              const SizedBox(height: AppConstants.spacingXXL),

              Text(
                'did_not_receive_code'.tr(),
                style: const TextStyle(
                  fontSize: AppConstants.fontSizeM,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: AppConstants.spacingS),

              TextButton(
                onPressed: () {},
                child: Text(
                  'resend_code_in'.tr(namedArgs: {'seconds': '23'}),
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeM,
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _verifyOtp,
                  child: Text(
                    'verify'.tr(),
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
  }
}
