import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'bienvenu.dart';
import '../../utils/HexColor.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomePage()),
      );

    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        color: Colors.white,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ==== Coin haut gauche (forme diagonale nette) ====
            Positioned(
              top: -40,
              left: -60,
              child: Transform.rotate(
                angle: -0.35, // rotation nette pour la diagonale
                child: SvgPicture.asset(
                  'assets/icons/2.svg',
                  width: 150,
                  height: 150,
                ),
              ),
            ),
            Positioned(
              top: 40,
              left: -10,
              child: Transform.rotate(
                angle: -0.35,
                child: SvgPicture.asset(
                  'assets/icons/3.svg',
                  width: 120,
                  height: 120,
                ),
              ),
            ),

            // ==== Coin bas droit (symétrique de la diagonale) ====
            Positioned(
              bottom: -40,
              right: -60,
              child: Transform.rotate(
                angle: -0.35, // même angle pour garder la diagonale
                child: SvgPicture.asset(
                  'assets/icons/2.svg',
                  width: 150,
                  height: 150,
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              right: -10,
              child: Transform.rotate(
                angle: -0.35,
                child: SvgPicture.asset(
                  'assets/icons/3.svg',
                  width: 120,
                  height: 120,
                ),
              ),
            ),

            // ==== Logo central ====
            Center(
              child: Image.asset(
                'assets/images/2.jpg',
                width: 165,
                height: 199,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
