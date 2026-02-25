import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:private_school/chauffeurs/pages/authentification/domain/bloc/driver_auth_bloc.dart';
import 'package:private_school/chauffeurs/pages/authentification/domain/bloc/driver_auth_event.dart';
import 'package:private_school/core/storage/secure_storage.dart';
import 'bienvenu.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final isLoggedIn = await SecureStorage().isLoggedIn();

    if (isLoggedIn) {
      context.read<DriverAuthBloc>().add(CheckDriverAuthStatusEvent());
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomePage()),
      );
    }
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
            Positioned(
              top: -40,
              left: -60,
              child: Transform.rotate(
                angle: -0.35,
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

            Positioned(
              bottom: -40,
              right: -60,
              child: Transform.rotate(
                angle: -0.35,
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
