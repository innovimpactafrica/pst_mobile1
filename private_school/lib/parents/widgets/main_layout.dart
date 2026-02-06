import 'package:flutter/material.dart';
import '../../core/utils/app_colors.dart';
import '../pages/acceuil/presentation/pages/home.dart';
import '../pages/enfants/presentation/pages/enfants_page.dart';
import '../pages/enfants/presentation/widgets/add_child_modal.dart';
import '../pages/groupes/presentation/pages/groupes_page.dart';
import '../pages/profil/presentation/pages/profil_page.dart';
import '../pages/trajets/presentation/pages/trajets_page.dart';
import 'bottom_nav_bar.dart';

/// Main layout with bottom navigation
/// Manages navigation between main app sections
class MainLayout extends StatefulWidget {
  final int initialIndex;

  const MainLayout({super.key, this.initialIndex = 0});

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
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            children: const [
              HomePage(), // Index 0
              EnfantsPage(), // Index 1
              TrajetsPage(), // Index 2
              GroupesPage(), // Index 3
              ProfilPage(), // Index 4
            ],
          ),

          // Add button (only on children page)
          if (_currentIndex == 1) _buildFloatingAddButton(),

          BottomNavBar(
            currentIndex: _currentIndex,
            onTap: _onNavTap,
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingAddButton() {
    return Positioned(
      bottom: 90,
      right: 20,
      child: FloatingActionButton(
        backgroundColor: AppColors.success,
        elevation: 6,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const AddChildModal(),
          );
        },
        child: const Icon(
          Icons.add,
          color: AppColors.textWhite,
          size: 28,
        ),
      ),
    );
  }
}