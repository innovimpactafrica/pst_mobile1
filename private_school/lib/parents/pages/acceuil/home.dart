// Home page for parents - Fixed import
// Path: lib/parents/pages/acceuil/home.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:private_school/parents/pages/acceuil/domain/bloc/home_bloc.dart';
import 'package:private_school/parents/pages/acceuil/domain/bloc/home_event.dart';
import 'package:private_school/parents/pages/acceuil/domain/bloc/home_state.dart';

import '../../widgets/main_layout.dart';
import '../trajets/presentation/pages/trip_detail_page.dart';
import 'discussion.dart';
import 'package:private_school/core/utils/app_colors.dart';
import 'package:private_school/parents/pages/acceuil/widgets/report_problem_modal.dart';
import 'package:private_school/parents/pages/trajets/data/models/trip_model.dart';
import 'package:private_school/parents/pages/trajets/data/repositories/trip_repository.dart';
import 'package:private_school/parents/pages/trajets/presentation/widgets/trip_card_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          HomeBloc(repository: TripRepository())..add(LoadDriversEvent()),
      child: const HomePageContent(),
    );
  }
}

class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  int _selectedIndex = 0;

  void _openDiscussions(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const DiscussionsPage()),
    );
  }

  void _openReportProblem(BuildContext context) {
    // Use the modal directly with showModalBottomSheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ReportProblemModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.success,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: Stack(
                    children: [
                      _buildMapBackground(context),
                      Column(
                        children: [
                          _buildSearchBar(),
                          const Spacer(),
                          BlocBuilder<HomeBloc, HomeState>(
                            builder: (context, state) {
                              if (state is HomeLoading) {
                                return const SizedBox(
                                  height: 280,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              } else if (state is HomeLoaded) {
                                return _buildTripCardsSection(state.trips);
                              } else if (state is HomeError) {
                                return SizedBox(
                                  height: 280,
                                  child: Center(
                                    child: Text(
                                      state.message,
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox(height: 280);
                            },
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            _buildBottomNavigationBar(),
            _buildFloatingActionButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMapBackground(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.grey.shade200),
      child: Stack(
        children: [
          Center(
            child: Icon(
              Icons.map_outlined,
              size: 80,
              color: Colors.grey.shade300,
            ),
          ),
          Positioned(
            top: 150,
            left: MediaQuery.of(context).size.width * 0.4,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 3),
              ),
              child: Icon(
                Icons.location_on,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Rechercher un trajet",
                  hintStyle: GoogleFonts.inter(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey.shade500,
                    size: 22,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(Icons.tune, color: Colors.grey.shade600, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(color: AppColors.success),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white,
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/1.png',
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.person,
                        size: 32,
                        color: AppColors.success,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Bonjour,",
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Mariama Ly",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => _openDiscussions(context),
                child: _buildNotifIconSvg('assets/icons/notif.svg', 1),
              ),
              const SizedBox(width: 12),
              _buildNotifIconSvg('assets/icons/Settings.svg', 0),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotifIconSvg(String svgPath, int notifCount) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: SvgPicture.asset(
              svgPath,
              width: 30,
              height: 30,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        if (notifCount > 0)
          Positioned(
            right: 2,
            top: 2,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                notifCount.toString(),
                style: const TextStyle(
                  fontSize: 8,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTripCardsSection(List<TripModel> trips) {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: trips.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(right: index < trips.length - 1 ? 12 : 0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              child: TripCardWidget(
                trip: trips[index],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TripDetailPage(trip: trips[index]),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        height: 70,
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(icon: Icons.home_rounded, label: 'Accueil', index: 0),
            _buildNavItem(
              icon: Icons.people_rounded,
              label: 'Enfants',
              index: 1,
            ),
            _buildNavItem(
              icon: Icons.route_rounded,
              label: 'Mes trajets',
              index: 2,
            ),
            _buildNavItem(
              icon: Icons.groups_rounded,
              label: 'Groupes',
              index: 3,
            ),
            _buildNavItem(
              icon: Icons.person_rounded,
              label: 'Profil',
              index: 4,
            ),
          ],
        ),
      ),
    );
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const MainLayout(initialIndex: 1),
        ),
      );
    }
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onBottomNavTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.success : Colors.grey.shade500,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.success : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return Positioned(
      right: 20,
      bottom: 90,
      child: FloatingActionButton(
        onPressed: () => _openReportProblem(context),
        backgroundColor: AppColors.success,
        elevation: 4,
        child: SvgPicture.asset(
          'assets/icons/13.svg',
          width: 28,
          height: 28,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashHeight = 3;
    const dashSpace = 3;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}