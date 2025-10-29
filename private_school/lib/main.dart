import 'package:flutter/material.dart';
import 'package:private_school/chauffeur/pages/acceuil/home.dart';
import 'package:private_school/chauffeur/pages/authentification/connexion.dart';
import 'package:private_school/chauffeur/pages/authentification/creer_mdp.dart';
import 'package:private_school/chauffeur/pages/authentification/inscription.dart';
import 'package:private_school/chauffeur/pages/authentification/mdp_oublie.dart';
import 'package:private_school/chauffeur/pages/authentification/verification.dart';
import 'package:private_school/chauffeur/pages/demarrage/bienvenu.dart';
import 'package:private_school/chauffeur/pages/demarrage/splash.dart';
// Import de la page de mot de passe



// Import de ta nouvelle page splash

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Patrimoine App',
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // Point d'entrée
      routes: {
        '/': (context) => Splash(), // Page suivante (à créer)
        '/bienvenu': (context) => WelcomePage(),
        '/connexion': (context) => Connexion(), // Page d'accueil
          '/inscription': (context) => InscriptionPage(),// Page d'inscription
        '/cree': (context) => PasswordCreationPage(), // Page de connexion
        '/verification': (context) => Verification(), // Page de vérification
        '/password': (context) => MdpOubliePage(), // Page de création de mot de passe
        '/dashboard': (context) => HomePage(), // Page du tableau de bord
      
      },
    );
  }
}