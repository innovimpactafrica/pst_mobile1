import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:private_school/chauffeur/pages/acceuil/home.dart';
import 'package:private_school/chauffeur/pages/authentification/connexion.dart';
import 'package:private_school/chauffeur/pages/authentification/creer_mdp.dart';
import 'package:private_school/chauffeur/pages/authentification/inscription.dart';
import 'package:private_school/chauffeur/pages/authentification/mdp_oublie.dart';
import 'package:private_school/chauffeur/pages/authentification/verification.dart';
import 'package:private_school/chauffeur/pages/demarrage/bienvenu.dart';
import 'package:private_school/chauffeur/pages/demarrage/splash.dart';
import 'package:private_school/chauffeur/pages/enfants/domain/bloc/child_bloc.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser les données de localisation pour le français
  await initializeDateFormatting('fr_FR', null);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<ChildBloc>(
          create: (context) => ChildBloc(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Patrimoine App',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => Splash(),
        '/bienvenu': (context) => WelcomePage(),
        '/connexion': (context) => Connexion(),
        '/inscription': (context) => InscriptionPage(),
        '/cree': (context) => PasswordCreationPage(),
        '/verification': (context) => Verification(),
        '/password': (context) => MdpOubliePage(),
        '/dashboard': (context) => HomePage(),
      },
    );
  }
}
