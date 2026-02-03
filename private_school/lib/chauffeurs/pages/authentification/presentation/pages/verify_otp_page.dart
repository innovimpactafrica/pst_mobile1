// Verify OTP for Forgot Password - Step 2/3
// Path: lib/chauffeurs/pages/authentication/presentation/pages/verify_otp_forgot_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../domain/bloc/driver_auth_bloc.dart';
import '../../domain/bloc/driver_auth_event.dart';
import '../../domain/bloc/driver_auth_state.dart';
import 'reset_password_page.dart';

class VerifyOtpForgotPage extends StatefulWidget {
  final String contact;

  const VerifyOtpForgotPage({super.key, required this.contact});

  @override
  State<VerifyOtpForgotPage> createState() => _VerifyOtpForgotPageState();
}

class _VerifyOtpForgotPageState extends State<VerifyOtpForgotPage> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );

  int _secondsRemaining = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _secondsRemaining = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
      } else {
        if (mounted) {
          setState(() {
            _secondsRemaining--;
          });
        }
      }
    });
  }

  void _checkOTPCompletion() {
    if (_controllers.every((c) => c.text.isNotEmpty)) {
      final otp = _controllers.map((c) => c.text).join();

      // Trigger verify OTP event
      context.read<DriverAuthBloc>().add(
            DriverVerifyOTPEvent(phone: widget.contact, otp: otp),
          );
    }
  }

  void _resendCode() {
    if (_secondsRemaining == 0) {
      _startCountdown();
      context.read<DriverAuthBloc>().add(
            DriverForgotPasswordEvent(phone: widget.contact),
          );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nouveau code envoyé'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Widget _buildOTPField(int index) {
    bool isSelected = _controllers[index].selection.baseOffset >= 0;

    return SizedBox(
      width: 60,
      height: 60,
      child: TextField(
        controller: _controllers[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          counterText: "",
          filled: true,
          fillColor: isSelected 
              ? AppColors.primary.withValues(alpha: 0.1) 
              : AppColors.background.withValues(alpha: 0.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.border,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.primary,
              width: 2,
            ),
          ),
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 3) {
            FocusScope.of(context).nextFocus();
          }
          _checkOTPCompletion();
          setState(() {});
        },
        onTap: () {
          setState(() {});
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DriverAuthBloc, DriverAuthState>(
      listener: (context, state) {
        if (state is DriverAuthLoading) {
          if (!mounted) return;

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
        } else if (state is DriverOTPVerified) {
          if (!mounted) return;
          Navigator.of(context).pop(); // Close loading

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Code vérifié avec succès !'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 2),
            ),
          );

          // Navigate to reset password page
          final otp = _controllers.map((c) => c.text).join();
          Timer(const Duration(milliseconds: 500), () {
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => ResetPasswordPage(
                  contact: widget.contact,
                  otp: otp,
                ),
              ),
            );
          });
        } else if (state is DriverAuthError) {
          if (!mounted) return;
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
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.textWhite,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.textWhite,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Vérification',
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
              child: Row(
                children: [
                  const Icon(Icons.language, color: AppColors.primary, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    'Français',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // Logo
                Center(
                  child: Image.asset(
                    'assets/images/2.jpg',
                    height: 100,
                  ),
                ),

                const SizedBox(height: 30),

                // Title
                Center(
                  child: Text(
                    'Code de vérification',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Subtitle
                Center(
                  child: Text(
                    'Saisissez le code à 4 chiffres envoyé à\n${widget.contact}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // OTP Fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(4, (index) => _buildOTPField(index)),
                ),

                const SizedBox(height: 30),

                // Resend Code
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Vous n\'avez pas reçu de code ?',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _resendCode,
                        child: Text(
                          _secondsRemaining > 0
                              ? 'Renvoyer dans ${_secondsRemaining}s'
                              : 'Renvoyer le code',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _secondsRemaining > 0
                                ? AppColors.textGrey
                                : AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Verify Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _checkOTPCompletion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Vérifier',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textWhite,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}