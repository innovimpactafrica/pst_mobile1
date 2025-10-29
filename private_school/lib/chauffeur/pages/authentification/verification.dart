import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../utils/HexColor.dart';
import 'creer_mdp.dart';

class Verification extends StatefulWidget {
  const Verification({super.key});

  @override
  State<Verification> createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());

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
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

 void _checkOTPCompletion() {
  if (_controllers.every((c) => c.text.isNotEmpty)) {
    // Affichage du message en bas avec icône
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(
            bottom: 20, left: 16, right: 16), // place en bas
        backgroundColor: Colors.white,
        content: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/9.svg', // icône check
              width: 24,
              height: 24,
            ),
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

    // Après 1.5 secondes, naviguer vers la page de création de mot de passe
    Future.delayed(const Duration(seconds: 1, milliseconds: 500), () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PasswordCreationPage()),
      );
    });
  }
}


  Widget _buildOTPField(int index) {
    bool isSelected =
        _controllers[index].selection.baseOffset >= 0; // si le curseur est actif

    return SizedBox(
      width: 48,
      height: 48,
      child: TextField(
        controller: _controllers[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: TextStyle(
          fontSize: 18,
          color: HexColor("#212121"),
        ),
        decoration: InputDecoration(
          counterText: "",
          filled: true,
          fillColor: isSelected ? HexColor("#DFF8E2") : HexColor("#F1F2F6"),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: isSelected ? HexColor("#38AA36") : HexColor("#F1F2F6"),
              width: 2,
            ),
          ),
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (_) {
          _checkOTPCompletion();
          setState(() {}); // met à jour la bordure
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo
              Center(
                child: Image.asset(
                  'assets/images/2.jpg', // <-- ton logo
                  width: 100,
                  height: 100,
                ),
              ),
              const SizedBox(height: 16),
              // Titre
              Center(
                child: Text(
                  "Code de vérification",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: HexColor("#2F2884"),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  "Saisissez le code à 4 chiffres envoyé par\nEmail à votre@email.com",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: HexColor("#4B5563"),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Cases OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) => _buildOTPField(index)),
              ),
              const SizedBox(height: 20),
              // Renvoyer le code
              Center(
                child: Column(
                  children: [
                    Text(
                      "Vous n’avez pas reçu de code ?",
                      style: TextStyle(
                        fontSize: 15,
                        color: HexColor("#212121"),
                      ),
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: _secondsRemaining == 0
                          ? () {
                              _startCountdown();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Nouveau code envoyé")),
                              );
                            }
                          : null,
                      child: Text(
                        _secondsRemaining > 0
                            ? "Renvoyer dans (${_secondsRemaining}s)"
                            : "Renvoyer le code",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _secondsRemaining > 0
                              ? HexColor("#B0B0B0")
                              : HexColor("#38AA36"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Bouton Vérifier
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _checkOTPCompletion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HexColor("#2F2884"),
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
    );
  }
}
