// Main screen for driver interface with bottom navigation
// Path: lib/chauffeurs/widgets/main_screen.dart

import 'package:flutter/material.dart';
import 'package:private_school/chauffeurs/pages/dashboard/presentation/pages/dashboard_page.dart';
import 'package:private_school/core/utils/app_colors.dart';
import 'package:private_school/parents/pages/profil/presentation/pages/profil_page.dart';
import 'package:private_school/parents/pages/trajets/presentation/pages/trajets_page.dart';


class MainScreen extends StatefulWidget {
  final bool off;
  final int initialIndex;

  const MainScreen({super.key, this.off = false, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;
  late PageController _pageController;

  final List<Widget> pages = const [
    DashboardPage(),
    TrajetsPage(),
    //TransactionsPage(),
    ProfilPage(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: pages,
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }
}

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              0,
              Icons.dashboard_outlined,
              Icons.dashboard,
              'Accueil',
            ),
            _buildNavItem(
              1,
              Icons.directions_car_outlined,
              Icons.directions_car,
              'Trajets',
            ),
            _buildNavItem(
              2,
              Icons.account_balance_wallet_outlined,
              Icons.account_balance_wallet,
              'Transactions',
            ),
            _buildNavItem(3, Icons.person_outline, Icons.person, 'Profil'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.secondary : AppColors.textGrey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.secondary : AppColors.textGrey,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
