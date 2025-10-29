import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../utils/HexColor.dart';
import '../authentification/connexion.dart'; // 🔹 ta page de connexion (ajuste le chemin si besoin)

class PasswordCreationPage extends StatefulWidget {
  const PasswordCreationPage({super.key});

  @override
  State<PasswordCreationPage> createState() => _PasswordCreationPageState();
}

class _PasswordCreationPageState extends State<PasswordCreationPage> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // ----- Fenêtre modale de succès -----
  void _showSuccessModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✅ Icône de validation
              SvgPicture.asset(
                'assets/icons/12.svg',
                width: 80,
                height: 80,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),
              // ✅ Texte principal
               Text(
                "Votre mot de passe a été crée avec succès. Veuillez vous connecter maintenant",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: HexColor('#030319'),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // ✅ Bouton OK
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Ferme la modale
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const Connexion()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HexColor("#2F2884"),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "OK",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                  color: HexColor("#2F2884"),
                  width: 20,
                  height: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  "Français",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: HexColor("#374151"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // ----- Contenu principal -----
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ✅ Logo centré
            Center(
              child: Image.asset(
                'assets/images/2.jpg',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 18),

            // ✅ Titre centré
            Text(
              "Créez votre mot de passe",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: HexColor("#1A1C1E"),
              ),
            ),
            const SizedBox(height: 10),

            // ✅ Description centrée
            Text(
              "Choisissez un nouveau mot de passe sécurisé pour\nprotéger votre compte.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: HexColor("#6C7278"),
              ),
            ),
            const SizedBox(height: 30),

            // 🔹 Label champ 1
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Nouveau mot de passe",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: HexColor("#333333"),
                ),
              ),
            ),
            const SizedBox(height: 6),

            // 🔹 Champ mot de passe
            TextField(
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                hintText: "********",
                hintStyle: TextStyle(color: HexColor("#9CA3AF")),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: HexColor("#CBD5E1")),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: HexColor("#CBD5E1")),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: HexColor("#D4B036")),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: HexColor("#ACB5BB"),
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 🔹 Label champ 2
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Confirmer mot de passe",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: HexColor("#333333"),
                ),
              ),
            ),
            const SizedBox(height: 6),

            // 🔹 Champ confirmation
            TextField(
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                hintText: "********",
                hintStyle: TextStyle(color: HexColor("#9CA3AF")),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: HexColor("#CBD5E1")),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: HexColor("#CBD5E1")),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: HexColor("#DEE8EE")),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: HexColor("#ACB5BB"),
                  ),
                  onPressed: () => setState(() =>
                      _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
              ),
            ),
            const Spacer(),

            // ✅ Bouton "Confirmer"
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: HexColor("#2F2884"),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                onPressed: _showSuccessModal,
                child: const Text(
                  "Confirmer",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}