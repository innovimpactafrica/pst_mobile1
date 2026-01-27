import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:private_school/chauffeurs/pages/dashboard/data/repositories/dashboard_repository.dart';
import 'package:private_school/chauffeurs/pages/dashboard/domain/bloc/dashboard_bloc.dart';
import 'package:private_school/chauffeurs/pages/dashboard/presentation/pages/dashboard_page.dart';
import 'package:private_school/chauffeurs/pages/trajets/data/repositories/trip_repository.dart';
import 'package:private_school/chauffeurs/pages/trajets/domain/bloc/trip_bloc.dart';
import 'package:private_school/chauffeurs/pages/trajets/presentation/pages/trip_page.dart';
import 'package:private_school/core/network/api_client.dart';
import 'package:private_school/pages/role_selection_page.dart';

// Parent imports
import 'package:private_school/parents/pages/acceuil/home.dart';
import 'package:private_school/parents/pages/authentification/connexion.dart';
import 'package:private_school/parents/pages/authentification/creer_mdp.dart';
import 'package:private_school/parents/pages/authentification/inscription.dart';
import 'package:private_school/parents/pages/authentification/mdp_oublie.dart';
import 'package:private_school/parents/pages/authentification/verification.dart';
import 'package:private_school/parents/pages/demarrage/bienvenu.dart';
import 'package:private_school/parents/pages/demarrage/splash.dart';
import 'package:private_school/parents/pages/enfants/domain/bloc/child_bloc.dart';
import 'package:private_school/parents/authentification/domain/bloc/auth_bloc.dart';

// Driver imports
import 'package:private_school/chauffeurs/pages/authentification/connexion.dart' as driver_auth;
import 'package:private_school/chauffeurs/pages/authentification/inscription.dart' as driver_auth;
import 'package:private_school/chauffeurs/pages/authentification/mdp_oublie.dart' as driver_auth;
//import 'package:private_school/chauffeurs/pages/authentification/verification.dart' as driver_auth;
//import 'package:private_school/chauffeurs/pages/authentification/creer_mdp.dart' as driver_auth;
import 'package:private_school/chauffeurs/authentification/domain/bloc/driver_auth_bloc.dart';
import 'package:private_school/chauffeurs/authentification/data/repositories/driver_auth_repository.dart';

import 'package:private_school/chauffeurs/pages/abonnement/domain/bloc/subscription_bloc.dart';
import 'package:private_school/chauffeurs/pages/abonnement/data/repositories/subscription_repository.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize French locale for date formatting
  await initializeDateFormatting('fr_FR', null);

  // Initialize API Client
  await ApiClient().init();
  debugPrint('✅ API Client initialized');

  runApp(
    MultiBlocProvider(
      providers: [
        // Parent BLoCs
        BlocProvider<ChildBloc>(
          create: (context) => ChildBloc(),
        ),
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(),
        ),

        // Driver BLoCs
        BlocProvider<DriverAuthBloc>(
          create: (context) => DriverAuthBloc(
            repository: DriverAuthRepository(),
          ),
        ),
        BlocProvider(
  create: (context) => DashboardBloc(
    repository: DashboardRepository(),
  ),
  child: const DashboardPage(),
),
        BlocProvider<SubscriptionBloc>(
      create: (context) => SubscriptionBloc(
        repository: SubscriptionRepository(),
      ),
    ),
   
BlocProvider(
  create: (context) => TripBloc(
    repository: TripRepository(),
  ),
  child: const TripPage(),
)
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
      title: 'Private School Transport',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        // Startup routes
        '/': (context) => const Splash(),
        '/bienvenu': (context) => const WelcomePage(),

        // Parent routes
        '/parent/connexion': (context) => const Connexion(),
        '/parent/inscription': (context) => const InscriptionPage(),
        '/parent/creer-mdp': (context) => const PasswordCreationPage(),
        '/parent/verification': (context) => const Verification(),
        '/parent/mdp-oublie': (context) => const MdpOubliePage(),
        '/parent/dashboard': (context) => const HomePage(),

        // Driver routes
        '/driver/connexion': (context) => const driver_auth.Connexion(),
        '/driver/inscription': (context) => const driver_auth.InscriptionPage(),
        '/driver/mdp-oublie': (context) => const driver_auth.MdpOubliePage(),
        '/driver/dashboard': (context) => const DashboardPage(),

        // Legacy routes (backward compatibility - redirect to parent)
        '/connexion': (context) => const Connexion(),
        '/inscription': (context) => const InscriptionPage(),
        '/cree': (context) => const PasswordCreationPage(),
        '/verification': (context) => const Verification(),
        '/password': (context) => const MdpOubliePage(),
        '/dashboard': (context) => const HomePage(),
        '/role-selection': (context) => const RoleSelectionPage(), // ✅ NOUVEAU
      },
    );
  }
}