// Main layout with bottom navigation - UPDATED
// Path: lib/chauffeurs/widgets/main_layout.dart

import 'package:flutter/material.dart';
import 'package:private_school/chauffeurs/pages/dashboard/presentation/pages/dashboard_page.dart';
import 'package:private_school/chauffeurs/pages/profil/presentation/pages/profile_main_page.dart';

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
 @override
Widget build(BuildContext context) {
  return Scaffold( // <--- On retire le MultiBlocProvider d'ici !
    body: PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      onPageChanged: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      children: const [
        DashboardPage(),
        TrajetsPage(),
        AbonnementPage(),
        ProfileMainPage(), // Cette page utilisera maintenant le Bloc global
      ],
    ),
    bottomNavigationBar: BottomNavBar(
      currentIndex: _currentIndex,
      onTap: _onNavTap,
    ),
  );
}
}