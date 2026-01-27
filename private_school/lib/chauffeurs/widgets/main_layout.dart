// Main layout for driver interface with bottom navigation
// Path: lib/chauffeurs/widgets/main_layout.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:private_school/chauffeurs/pages/dashboard/data/repositories/dashboard_repository.dart';
import 'package:private_school/chauffeurs/pages/dashboard/domain/bloc/dashboard_bloc.dart';
import 'package:private_school/chauffeurs/pages/dashboard/presentation/pages/dashboard_page.dart';
import 'package:private_school/parents/pages/profil/presentation/pages/profil_page.dart';
import 'package:private_school/parents/pages/trajets/presentation/pages/trajets_page.dart';
import '../pages/abonnement/presentation/pages/abonnement_page.dart';
import 'bottom_nav_bar.dart';

class MainLayout extends StatefulWidget {
  final int initialIndex;

  const MainLayout({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late int _currentIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          // Index 0 - Dashboard
          BlocProvider(
            create: (context) => DashboardBloc(
              repository: DashboardRepository(),
            ),
            child: const DashboardPage(),
          ),
          // Index 1 - Trajets
          const TrajetsPage(),
          // Index 2 - Abonnement
          const AbonnementPage(),
          // Index 3 - Profil
          const ProfilPage(),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}