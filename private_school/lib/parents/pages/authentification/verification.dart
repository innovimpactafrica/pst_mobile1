import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:private_school/core/utils/app_colors.dart';
import 'package:private_school/core/utils/app_constants.dart';
import 'creer_mdp.dart';

class Verification extends StatefulWidget {
  const Verification({super.key});

  @override
  State<Verification> createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  int _secondsRemaining = 23;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
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
        setState(() => _secondsRemaining--);
      }
    });
  }

  void _checkOTPCompletion() {
    if (_controllers.every((c) => c.text.isNotEmpty)) {
      // SnackBar stylisée
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(AppConstants.spacingM),
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusL)),
          content: Row(
            children: [
              SvgPicture.asset('assets/icons/9.svg', width: 24, height: 24),
              const SizedBox(width: AppConstants.spacingS),
              const Text(
                "Vérification terminée",
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );

      Future.delayed(const Duration(seconds: 1, milliseconds: 500), () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PasswordCreationPage()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingXXL),
          child: Column(
            children: [
              Image.asset(AppConstants.logoPath, height: 100),
              const SizedBox(height: AppConstants.spacingL),
              const Text(
                "Code de vérification",
                style: TextStyle(
                  fontSize: AppConstants.fontSizeXXL,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppConstants.spacingS),
              const Text(
                "Saisissez le code à 4 chiffres envoyé par Email à votre@email.com",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: AppConstants.fontSizeM, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 40),
              
              // Cases OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) => _buildOTPField(index)),
              ),
              
              const SizedBox(height: 30),
              _buildResendSection(),
              const Spacer(),
              _buildVerifyButton(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        _buildLanguageSelector(),
      ],
    );
  }

  Widget _buildOTPField(int index) {
    return SizedBox(
      width: 60,
      height: 60,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        decoration: InputDecoration(
          counterText: "",
          filled: true,
          fillColor: _controllers[index].text.isNotEmpty ? AppColors.successLight : AppColors.backgroundLight,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
            borderSide: const BorderSide(color: AppColors.successDark, width: 2),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 3) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          _checkOTPCompletion();
          setState(() {}); 
        },
      ),
    );
  }

  Widget _buildResendSection() {
    return Column(
      children: [
        const Text("Vous n’avez pas reçu de code ?", style: TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _secondsRemaining == 0 ? _startCountdown : null,
          child: Text(
            _secondsRemaining > 0 ? "Renvoyer dans (${_secondsRemaining}s)" : "Renvoyer le code",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _secondsRemaining > 0 ? AppColors.textGrey : AppColors.successDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _checkOTPCompletion,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusXXL)),
        ),
        child: const Text(
          "Vérifier",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.white),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/icons/4.svg',
            colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
            width: 18,
          ),
          const SizedBox(width: 6),
          const Text("Français", style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}