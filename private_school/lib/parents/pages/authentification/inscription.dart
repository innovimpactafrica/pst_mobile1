import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:private_school/core/utils/app_colors.dart';
import 'package:private_school/core/utils/app_constants.dart';
import '../../authentification/domain/bloc/auth_bloc.dart';
import '../../authentification/domain/bloc/auth_event.dart';
import '../../authentification/domain/bloc/auth_state.dart';

class InscriptionPage extends StatefulWidget {
  const InscriptionPage({super.key});

  @override
  State<InscriptionPage> createState() => _InscriptionPageState();
}

class _InscriptionPageState extends State<InscriptionPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Contrôleurs
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _carBrandController = TextEditingController();
  final TextEditingController _carColorController = TextEditingController();
  final TextEditingController _carPlateController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _carBrandController.dispose();
    _carColorController.dispose();
    _carPlateController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void nextPage() {
    if (_currentPage < 2) {
      if (_currentPage == 0 && _isStep1Invalid()) return;
      
      setState(() => _currentPage++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _submitRegistration();
    }
  }

  bool _isStep1Invalid() {
    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs personnels')),
      );
      return true;
    }
    return false;
  }

  void _submitRegistration() {
    final nameParts = _nameController.text.trim().split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts[0] : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    context.read<AuthBloc>().add(
          RegisterEvent(
            firstName: firstName,
            lastName: lastName,
            phone: _phoneController.text.trim(),
            email: _emailController.text.trim(),
          ),
        );
  }

  void _showSuccessDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusXL)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset('assets/icons/12.svg', height: 80),
            const SizedBox(height: AppConstants.spacingM),
            const Text(
              "Demande d’inscription envoyée avec succès",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: AppConstants.fontSizeM, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppConstants.spacingXXL),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/connexion');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusXXL),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text("OK", style: TextStyle(color: AppColors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        } else if (state is RegisterSuccess) {
          Navigator.of(context).pop();
          _showSuccessDialog();
        } else if (state is AuthError) {
          if (Navigator.canPop(context)) Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildTopContent(),
              _buildProgressIndicator(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [_buildStep1(), _buildStep2(), _buildStep3()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingM, vertical: AppConstants.spacingS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/4.svg',
                colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
                width: 20,
              ),
              const SizedBox(width: 6),
              const Text(
                "Français",
                style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopContent() {
    return Column(
      children: [
        Image.asset(AppConstants.logoPath, height: 80),
        const SizedBox(height: AppConstants.spacingS),
        const Text(
          "Inscrivez-vous en un clic",
          style: TextStyle(
            fontSize: AppConstants.fontSizeXXL,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 8),
          child: Text(
            "Créez un compte maintenant et profitez pleinement de l’application.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: AppConstants.fontSizeS),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    String title = _currentPage == 0 
        ? "Informations personnelles" 
        : _currentPage == 1 ? "Informations véhicule" : "Pièces jointes";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingXXL),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
              Text("${_currentPage + 1}/3", style: const TextStyle(color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (_currentPage + 1) / 3,
            backgroundColor: AppColors.grey200,
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return _buildFormPage([
      _buildTextField("Prénom et nom", "Ex: Birima Diop", _nameController, Icons.person_outline),
      _buildTextField("Numéro de téléphone", "Ex: 77 123 45 67", _phoneController, Icons.phone_android),
      _buildTextField("Adresse email", "Ex: bdiop@gmail.com", _emailController, Icons.email_outlined),
    ]);
  }

  Widget _buildStep2() {
    return _buildFormPage([
      _buildTextField("Marque du véhicule", "Ex: Ford", _carBrandController, Icons.directions_car_filled_outlined),
      _buildTextField("Couleur du véhicule", "Ex: Rouge", _carColorController, Icons.color_lens_outlined),
      _buildTextField("Immatriculation", "Ex: AA-2535-01", _carPlateController, Icons.badge_outlined),
    ]);
  }

  Widget _buildStep3() {
    return _buildFormPage([
      _buildUploadBox("Permis de conduire"),
      _buildUploadBox("CNI / Passport"),
      _buildUploadBox("Photo du véhicule"),
    ], buttonLabel: "Soumettre l'inscription");
  }

  Widget _buildFormPage(List<Widget> children, {String buttonLabel = "Continuer"}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingXXL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...children,
          const SizedBox(height: AppConstants.spacingXXL),
          ElevatedButton(
            onPressed: nextPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusXXL)),
            ),
            child: Text(buttonLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: AppConstants.spacingM),
          _buildLoginLink(),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, color: AppColors.textGrey, size: 20),
              filled: true,
              fillColor: AppColors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadBox(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(AppConstants.radiusL),
              color: AppColors.backgroundLight,
            ),
            child: Column(
              children: [
                SvgPicture.asset('assets/icons/11.svg', height: 30),
                const SizedBox(height: 8),
                const Text("Cliquez pour choisir un fichier", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                const Text("JPEG, PNG ou PDF (Max 10Mo)", style: TextStyle(fontSize: 10, color: AppColors.textGrey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Déjà un compte ? ", style: TextStyle(color: AppColors.textSecondary)),
        GestureDetector(
          onTap: () => Navigator.pushReplacementNamed(context, '/connexion'),
          child: const Text("Se Connecter", style: TextStyle(color: AppColors.successDark, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}