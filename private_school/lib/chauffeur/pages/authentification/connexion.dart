import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:private_school/chauffeur/pages/authentification/inscription.dart';
import '../../utils/HexColor.dart';
import 'mdp_oublie.dart'; // ✅ à adapter selon ton chemin réel
import '../acceuil/home.dart'; // ✅ à adapter selon ton chemin réel

class Connexion extends StatefulWidget {
  const Connexion({super.key});

  @override
  State<Connexion> createState() => _ConnexionState();
}

class _ConnexionState extends State<Connexion> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // ======== Barre du haut (Langue) ========
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
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
                  ],
                ),

                const SizedBox(height: 30),

                // ======== Logo ========
                Image.asset(
                  'assets/images/2.jpg',
                  width: 120,
                  height: 120,
                ),

                const SizedBox(height: 25),

                // ======== Titre & Description ========
                Text(
                  "Connexion",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: HexColor("#2F2884"),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Connectez-vous pour explorer toutes les\nfonctionnalités de l’application.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: HexColor("#4B5563"),
                  ),
                ),

                const SizedBox(height: 30),

                // ======== Champ Email ========
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Identification",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: HexColor("#343741"),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: "Ex: bdiop@gmail.com",
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
                  ),
                ),

                const SizedBox(height: 20),

                // ======== Champ Mot de passe ========
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Mot de passe",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: HexColor("#343741"),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: "********",
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
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: HexColor("#ACB5BB"),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // ======== Bouton Se connecter ========
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HexColor("#2F2884"),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const HomePage()),
                      );
                    },
                    child: const Text(
                      "Se connecter",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ======== Mot de passe oublié ? ========
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MdpOubliePage(),
                      ),
                    );
                  },
                  child: Text(
                    "Mot de passe oublié ?",
                    style: TextStyle(
                      color: HexColor("#2F2884"),
                      fontWeight: FontWeight.w600,
                    
                    ),
                  ),
                ),

                const SizedBox(height: 50),

                // ======== Lien inscription ========
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Vous n'avez pas de compte ",
                      style: TextStyle(color: HexColor("#CBD5E1")),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, "/inscription");Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const InscriptionPage()),
);

                      },
                      child: Text(
                        "S’inscrire",
                        style: TextStyle(
                          color: HexColor("#38AA36"),
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
      ),
    );
  }
}
