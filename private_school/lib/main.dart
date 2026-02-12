// Main App Entry Point - WITH MESSAGING BLOCS
// Path: lib/main.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:private_school/chauffeurs/pages/abonnement/data/services/subscription_service.dart';
import 'package:private_school/chauffeurs/pages/authentification/data/repositories/driver_auth_repository.dart';
import 'package:private_school/chauffeurs/pages/authentification/domain/bloc/driver_auth_bloc.dart';
import 'package:private_school/chauffeurs/pages/authentification/presentation/pages/forgot_password_page.dart';
import 'package:private_school/chauffeurs/pages/authentification/presentation/pages/reset_password_page.dart';
import 'package:private_school/chauffeurs/pages/authentification/presentation/pages/verify_otp_page.dart';
import 'package:private_school/chauffeurs/pages/dashboard/data/repositories/dashboard_repository.dart';
import 'package:private_school/chauffeurs/pages/dashboard/domain/bloc/dashboard_bloc.dart';
import 'package:private_school/chauffeurs/pages/dashboard/domain/bloc/notification_event.dart';
import 'package:private_school/chauffeurs/pages/dashboard/presentation/pages/dashboard_page.dart';
import 'package:private_school/chauffeurs/pages/profil/domain/bloc/driver_profile_event.dart';
import 'package:private_school/chauffeurs/pages/trajets/data/repositories/trip_repository.dart' as driver_trip;
import 'package:private_school/chauffeurs/pages/trajets/domain/bloc/trip_bloc.dart';
//import 'package:private_school/chauffeurs/pages/trajets/domain/bloc/trip_event.dart';
import 'package:private_school/core/network/api_client.dart';
import 'package:private_school/pages/role_selection_page.dart';

// Parent imports
import 'package:private_school/parents/pages/acceuil/presentation/pages/home.dart';
import 'package:private_school/parents/pages/authentification/presentation/pages/connexion.dart';
import 'package:private_school/parents/pages/authentification/presentation/pages/creer_mdp.dart';
import 'package:private_school/parents/pages/authentification/presentation/pages/mdp_oublie.dart';
import 'package:private_school/parents/pages/authentification/presentation/pages/parent_inscription.dart';
import 'package:private_school/parents/pages/authentification/presentation/pages/verification.dart';
import 'package:private_school/parents/pages/demarrage/bienvenu.dart';
import 'package:private_school/parents/pages/demarrage/splash.dart';
import 'package:private_school/parents/pages/enfants/domain/bloc/child_bloc.dart';
import 'package:private_school/parents/pages/authentification/domain/bloc/auth_bloc.dart';

// Driver imports
import 'package:private_school/chauffeurs/pages/authentification/presentation/pages/connexion.dart' as driver_auth;
import 'package:private_school/chauffeurs/pages/authentification/presentation/pages/inscription.dart' as driver_auth;

import 'package:private_school/chauffeurs/pages/abonnement/domain/bloc/subscription_bloc.dart';
import 'package:private_school/chauffeurs/pages/abonnement/data/repositories/subscription_repository.dart';

import 'package:private_school/chauffeurs/pages/profil/domain/bloc/driver_profile_bloc.dart';
import 'package:private_school/chauffeurs/pages/profil/data/repositories/driver_profile_repository.dart';
import 'package:private_school/parents/pages/school/domain/bloc/school_bloc.dart';

import 'chauffeurs/pages/dashboard/domain/bloc/notification_bloc.dart';
import 'chauffeurs/pages/dashboard/data/repositories/notification_repository.dart';

// Report BLoCs
import 'package:private_school/chauffeurs/pages/reports/domain/bloc/report_bloc.dart' as driver_reports;
import 'package:private_school/parents/pages/reports/domain/bloc/report_bloc.dart' as parent_reports;

// MESSAGING BLOCS - PARENT
import 'package:private_school/parents/pages/acceuil/domain/bloc/conversation_bloc.dart';
import 'package:private_school/parents/pages/acceuil/domain/bloc/message_bloc.dart';
import 'package:private_school/parents/pages/acceuil/data/repositories/messaging_repository.dart';

// ✅ HOME BLOC - PARENT (AJOUTÉ)
import 'package:private_school/parents/pages/acceuil/domain/bloc/home_bloc.dart';
import 'package:private_school/parents/pages/acceuil/domain/bloc/home_event.dart';
import 'package:private_school/parents/pages/trajets/data/repositories/trip_repository.dart' as parent_trip;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize French locale for date formatting
  await initializeDateFormatting('fr_FR', null);
  
  // Initialize EasyLocalization
  await EasyLocalization.ensureInitialized();
  
  // Initialize API Client
  await ApiClient().init();
  debugPrint('API Client initialized');

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('fr'), // Français
        Locale('en'), // Anglais
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('fr'),
      child: MultiBlocProvider(
        providers: [
          // ==================== PARENT BLOCS ====================
          BlocProvider<ChildBloc>(create: (context) => ChildBloc()),
          BlocProvider<AuthBloc>(create: (context) => AuthBloc()),
          BlocProvider(create: (_) => parent_reports.ReportBloc()),
          BlocProvider(create: (context) => SchoolBloc()),
          
          // ✅ HOME BLOC - PARENT (AJOUTÉ)
          BlocProvider<HomeBloc>(
            create: (context) => HomeBloc(
              repository: parent_trip.TripRepository(),
            )..add(LoadDriversEvent()),
          ),
          
          // ✅ MESSAGING BLOCS - PARENT
          BlocProvider<ConversationBloc>(
            create: (context) => ConversationBloc(
              repository: MessagingRepository(),
            ),
          ),
          BlocProvider<MessageBloc>(
            create: (context) => MessageBloc(
              repository: MessagingRepository(),
            ),
          ),

          // ==================== DRIVER BLOCS ====================
          BlocProvider<DriverAuthBloc>(
            create: (context) =>
                DriverAuthBloc(repository: DriverAuthRepository()),
          ),
          BlocProvider(
            create: (context) => DashboardBloc(repository: DashboardRepository()),
          ),
          BlocProvider<SubscriptionBloc>(
            create: (context) => SubscriptionBloc(
              repository: SubscriptionRepository(SubscriptionService()),
            ),
          ),
          BlocProvider(
            create: (context) => TripBloc(repository: driver_trip.TripRepository()),
          ),
          BlocProvider<DriverProfileBloc>(
            create: (context) => DriverProfileBloc(
              repository: DriverProfileRepository(),
            )..add(LoadDriverProfileEvent()),
          ),
          BlocProvider(
            create: (_) => NotificationBloc(
              repository: NotificationRepository(),
            )..add(const LoadNotificationsEvent()),
          ),
          BlocProvider(create: (_) => driver_reports.ReportBloc()),
        ],
        child: const MyApp(),
      ),
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
      
      // Configuration de la localisation avec EasyLocalization
      localizationsDelegates: [
        ...context.localizationDelegates,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      
      initialRoute: '/',
      routes: {
        // ==================== STARTUP ROUTES ====================
        '/': (context) => const Splash(),
        '/bienvenu': (context) => const WelcomePage(),
        '/role-selection': (context) => const RoleSelectionPage(),

        // ==================== PARENT ROUTES ====================
        '/parent/connexion': (context) => const Connexion(),
        '/parent/inscription': (context) => const ParentInscription(),
        '/parent/creer-mdp': (context) => const PasswordCreationPage(),
        '/parent/verification': (context) => const Verification(),
        '/parent/mdp-oublie': (context) => const MdpOubliePage(),
        '/parent/dashboard': (context) => const HomePage(),

        // ==================== DRIVER ROUTES ====================
        
        // Driver Authentication
        '/driver/connexion': (context) => const driver_auth.Connexion(),
        '/driver/inscription': (context) => const driver_auth.InscriptionPage(),
        '/driver/dashboard': (context) => const DashboardPage(),
        
        // Driver Forgot Password System
        '/driver/forgot-password': (context) => const ForgotPasswordPage(),
        '/driver/verify-otp': (context) => const VerifyOtpForgotPage(contact: ''),
        '/driver/reset-password': (context) => const ResetPasswordPage(userId: 0, code: ''),

        // ==================== LEGACY ROUTES ====================
        // Backward compatibility - redirect to parent
        '/connexion': (context) => const Connexion(),
        '/inscription': (context) => const ParentInscription(),
        '/cree': (context) => const PasswordCreationPage(),
        '/verification': (context) => const Verification(),
        '/password': (context) => const MdpOubliePage(),
        '/dashboard': (context) => const HomePage(),
      },
    );
  }
}