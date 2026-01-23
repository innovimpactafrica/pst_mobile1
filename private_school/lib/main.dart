import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:private_school/parents/pages/acceuil/home.dart';
import 'package:private_school/parents/pages/authentification/connexion.dart';
import 'package:private_school/parents/pages/authentification/creer_mdp.dart';
import 'package:private_school/parents/pages/authentification/inscription.dart';
import 'package:private_school/parents/pages/authentification/mdp_oublie.dart';
import 'package:private_school/parents/pages/authentification/verification.dart';
import 'package:private_school/parents/pages/demarrage/bienvenu.dart';
import 'package:private_school/parents/pages/demarrage/splash.dart';
import 'package:private_school/parents/pages/enfants/domain/bloc/child_bloc.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:private_school/parents/authentification/domain/bloc/auth_bloc.dart';
import 'package:private_school/core/network/api_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser les données de localisation pour le français
  await initializeDateFormatting('fr_FR', null);
  // ✅ AJOUTER CETTE LIGNE - Initialiser l'API Client
  await ApiClient().init();
  print('✅ API Client initialized');

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<ChildBloc>(
          create: (context) => ChildBloc(),
        ),
        // ✅ AJOUTER CE BLOC
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(),
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
          '/': (context) => const Splash(),
          '/bienvenu': (context) => const WelcomePage(),
          '/connexion': (context) => const Connexion(),
          '/inscription': (context) => const InscriptionPage(),
          '/cree': (context) => const PasswordCreationPage(),
          '/verification': (context) => const Verification(),
          '/password': (context) => const MdpOubliePage(),
          '/dashboard': (context) => const HomePage(),
        },
    );
  }
}
