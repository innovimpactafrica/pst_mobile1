import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:private_school/parents/utils/HexColor.dart';

class InscriptionPage extends StatefulWidget {
  const InscriptionPage({super.key});

  @override
  State<InscriptionPage> createState() => _InscriptionPageState();
}

class _InscriptionPageState extends State<InscriptionPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void nextPage() {
    if (_currentPage < 2) {
      setState(() => _currentPage++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset('assets/icons/12.svg', height: 80),
            const SizedBox(height: 20),
            const Text(
              "Demande d’inscription envoyée avec succès",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/connexion');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2623D5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  "OK",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: SvgPicture.asset('assets/icons/back.svg'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/4.svg',
                        color: HexColor('#2F2884'),
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        "Français",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF374151)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // --- LOGO + TITRE ---
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  Image.asset('assets/images/2.jpg', height: 80),
                  const SizedBox(height: 10),
                  Text(
                    "Inscrivez-vous en un clic",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: HexColor('#2F2884'),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Créer un compte maintenant et profitez pleinement de l’application.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // --- TITRE + PROGRESSION ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _currentPage == 0
                        ? "Informations personnelles"
                        : _currentPage == 1
                            ? "Informations véhicule"
                            : "Pièces jointes",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: HexColor('#2F2884')),
                  ),
                  Text(
                    "${_currentPage + 1}/3",
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: (_currentPage + 1) / 3,
                  backgroundColor: Colors.grey[200],
                  color: HexColor('#2F2884'),
                  minHeight: 6,
                ),
              ),
            ),

            // --- CONTENU DYNAMIQUE ---
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Étape 1 : Informations personnelles
  Widget _buildStep1() {
    return _buildForm([
      _buildLabeledField("Prénom et nom", "Ex: Birima Diop"),
      _buildLabeledField("Numéro de téléphone", "Ex: 77 123 45 67"),
      _buildLabeledField("Adresse email", "Ex: bdiop@gmail.com"),
    ]);
  }

  // Étape 2 : Informations véhicule
  Widget _buildStep2() {
    return _buildForm([
      _buildLabeledField("Marque du véhicule", "Ex: Ford"),
      _buildLabeledField("Couleur du véhicule", "Ex: Rouge"),
      _buildLabeledField("Immatriculation du véhicule", "Ex: AA-2535-01"),
    ]);
  }

  // Étape 3 : Pièces jointes
  Widget _buildStep3() {
    return _buildForm([
      _buildUploadField("Permis de conduire"),
      _buildUploadField("CNI / Passport"),
      _buildUploadField("Photo du véhicule"),
    ], nextLabel: "Soumettre");
  }

  // Formulaire générique
  Widget _buildForm(List<Widget> fields, {String nextLabel = "Continuer"}) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...fields,
          const SizedBox(height: 30),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: HexColor('#2F2884'),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)),
              ),
              child: Text(nextLabel,
                  style: const TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: GestureDetector(
              onTap: () => Navigator.pushReplacementNamed(context, '/connexion'),
              child: RichText(
                text: TextSpan(
                  text: "Vous avez déjà un compte ?  ",
                  style: const TextStyle(color: Colors.black54),
                  children: [
                    TextSpan(
                      text: "Se Connecter",
                      style: TextStyle(
                        color: HexColor('#38AA36'),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Champ de texte avec label
  Widget _buildLabeledField(String label, String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 6),
          TextField(
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF2F2884))),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  // Champ upload
Widget _buildUploadField(String label) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: HexColor('#646B78'),
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFCBD5E1)),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset('assets/icons/11.svg', height: 40),
              const SizedBox(height: 8),
              const Text(
                "Choisissez un fichier",
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
              ),
              const SizedBox(height: 4),
              Text(
                "Formats: JPEG, PNG, PDF, MP4 (max 10 Mo)",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: HexColor('#A9ACB4'),
                  fontSize: 8,
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: 140,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: HexColor('#CBD0DC')),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      backgroundColor: Colors.white,
                      foregroundColor: HexColor('#54575C'),
                    ).copyWith(
                      overlayColor:
                          MaterialStateProperty.all(HexColor('#F1F2F6')),
                    ),
                    child: const Text(
                      "Parcourir le fichier",
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
}

