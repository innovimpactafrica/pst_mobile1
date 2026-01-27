import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:private_school/core/utils/app_colors.dart';
import '../../authentification/domain/bloc/driver_auth_bloc.dart';
import '../../authentification/domain/bloc/driver_auth_event.dart';
import '../../authentification/domain/bloc/driver_auth_state.dart';
import 'creer_mdp.dart';

class Verification extends StatefulWidget {
  final String phone;

  const Verification({super.key, required this.phone});

  @override
  State<Verification> createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );

  int _secondsRemaining = 23;
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
    _secondsRemaining = 23;
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

      context.read<DriverAuthBloc>().add(
        DriverVerifyOTPEvent(phone: widget.phone, otp: otp),
      );
    }
  }

  void _resendCode() {
    if (_secondsRemaining == 0) {
      _startCountdown();
      context.read<DriverAuthBloc>().add(
        DriverForgotPasswordEvent(phone: widget.phone),
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nouveau code envoyé')));
    }
  }

  Widget _buildOTPField(int index) {
    bool isSelected = _controllers[index].selection.baseOffset >= 0;

    return SizedBox(
      width: 48,
      height: 48,
      child: TextField(
        controller: _controllers[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: TextStyle(fontSize: 18, color: AppColors.textPrimary),
        decoration: InputDecoration(
          counterText: "",
          filled: true,
          fillColor: isSelected ? AppColors.successLight : AppColors.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: isSelected ? AppColors.successDark : AppColors.background,
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
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );
        } else if (state is DriverOTPVerified) {
          if (!mounted) return;
          Navigator.of(context).pop();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
              backgroundColor: Colors.white,
              content: Row(
                children: [
                  SvgPicture.asset('assets/icons/9.svg', width: 24, height: 24),
                  const SizedBox(width: 12),
                  const Text(
                    "Vérification terminée",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );

          // ✅ Fixed: Check mounted before using context after async gap
          Future.delayed(const Duration(seconds: 1, milliseconds: 500), () {
            if (!mounted) return;

            final otp = _controllers.map((c) => c.text).join();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => PasswordCreationPage(phone: widget.phone, otp: otp),
              ),
            );
          });
        } else if (state is DriverAuthError) {
          if (!mounted) return;
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
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: SvgPicture.asset('assets/icons/back.svg'),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/4.svg',
                    colorFilter: ColorFilter.mode(
                      AppColors.secondary,
                      BlendMode.srcIn,
                    ),
                    width: 20,
                    height: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "Français",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/2.jpg',
                    width: 100,
                    height: 100,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    "Code de vérification",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    "Saisissez le code à 4 chiffres envoyé par\nSMS au ${widget.phone}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(4, (index) => _buildOTPField(index)),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      Text(
                        "Vous n'avez pas reçu de code ?",
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: _resendCode,
                        child: Text(
                          _secondsRemaining > 0
                              ? "Renvoyer dans (${_secondsRemaining}s)"
                              : "Renvoyer le code",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _secondsRemaining > 0
                                ? AppColors.textGrey
                                : AppColors.successDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _checkOTPCompletion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Vérifier",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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