import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/utils/app_colors.dart';

class BottomNavBar extends StatelessWidget {
final int currentIndex;
final Function(int) onTap;

const BottomNavBar({
super.key,
required this.currentIndex,
required this.onTap,
});

@override
@override
Widget build(BuildContext context) {
  final bottomPadding = MediaQuery.of(context).padding.bottom;
  
  return Positioned(
    left: 0,
    right: 0,
    bottom: 0,
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      // ✅ Hauteur fixe + padding système Android
      padding: EdgeInsets.only(bottom: bottomPadding),
      height: 70 + bottomPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(icon: Icons.home_rounded, label: 'home'.tr(), index: 0),
          _buildNavItem(icon: Icons.people_rounded, label: 'children'.tr(), index: 1),
          _buildNavItem(icon: Icons.route_rounded, label: 'my_trips'.tr(), index: 2),
          _buildNavItem(icon: Icons.groups_rounded, label: 'groups'.tr(), index: 3),
          _buildNavItem(icon: Icons.person_rounded, label: 'profile'.tr(), index: 4),
        ],
      ),
    ),
  );
}

Widget _buildNavItem({
required IconData icon,
required String label,
required int index,
}) {
final bool isSelected = currentIndex == index;
return GestureDetector(
onTap: () => onTap(index),
behavior: HitTestBehavior.opaque,
child: SizedBox(
width: 70,
child: Column(
mainAxisSize: MainAxisSize.min,
mainAxisAlignment: MainAxisAlignment.center,
children: [
Icon(
icon,
color: isSelected ? AppColors.success : Colors.grey,
size: 24,
),
const SizedBox(height: 4),
Text(
label,
style: GoogleFonts.inter(
fontSize: 10,
fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
color: isSelected ? AppColors.success : Colors.grey,
),
),
],
),
),
);
}
}