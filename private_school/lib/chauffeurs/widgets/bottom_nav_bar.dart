import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:private_school/core/utils/app_colors.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.successDark,
          unselectedItemColor: AppColors.textGrey,
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: 'home'.tr(),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.route),
              label: 'my_trips'.tr(),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.credit_card),
              label: 'subscription'.tr(),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person),
              label: 'profile'.tr(),
            ),
          ],
        ),
      ),
    );
  }
}
