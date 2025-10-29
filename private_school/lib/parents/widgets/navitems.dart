// main_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // ✅ Nécessaire pour SvgPicture

import '../utils/HexColor.dart';

class MainScreen extends StatefulWidget {
  final bool off;

  const MainScreen({super.key, this.off = false});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildCurrentPage(),
      backgroundColor: HexColor('#F5F7FA'),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildCurrentPage() {
    final List<Widget> pages = [
      
    ];

    return pages[_selectedIndex];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
    final navItems = [
      _buildNavItem(context, 0, 'home', 'Accueil'),
      _buildNavItem(context, 1, 'calendar', 'Rendez-vous'),
      _buildNavItem(context, 2, 'ordonnance', 'Ordonnances'),
      _buildNavItem(context, 3, 'user', 'Mon compte'),
    ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(35),
          topRight: Radius.circular(35),
        ),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
          ),
        ],
      ),
      height: 80,
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: navItems,
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    String iconName,
    String label,
  ) {
    final isSelected = index == selectedIndex;
    final iconPath = isSelected
        ? 'assets/icons/${iconName}_selected.svg'
        : 'assets/icons/$iconName.svg';

    return InkWell(
      onTap: () {
        if (!isSelected) {
          onItemTapped(index);
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(iconPath, width: 22.0, height: 22.0),
          const SizedBox(height: 4.0),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.0,
              color: isSelected
                  ? HexColor('#FF5C02')
                  : const Color.fromARGB(255, 113, 113, 113),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
