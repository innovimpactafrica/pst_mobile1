import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../pages/home.dart';           // adapte selon ta structure
import '../pages/rendez_vous.dart';   // exemple
import '../pages/ordonnances.dart';   // exemple
import '../pages/mon_compte.dart';    // exemple
import '../utils/HexColor.dart';

class MainScreen extends StatefulWidget {
  final bool off;

  const MainScreen({super.key, this.off = false});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> pages = [
    HomePage(),        // page Accueil
    RendezVousPage(),  // page Rendez-vous
    OrdonnancesPage(), // page Ordonnances
    MonComptePage(),   // page Mon compte
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_selectedIndex],
      backgroundColor: HexColor('#F5F7FA'),
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
  }
}

// ... CustomBottomNavigationBar reste le même
