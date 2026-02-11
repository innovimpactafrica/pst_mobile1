import 'package:flutter/material.dart';
import '../../../../../core/utils/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';


class PlanToggle extends StatelessWidget {
  final bool isAnnual;
  final Function(bool) onToggle;

  const PlanToggle({super.key, required this.isAnnual, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'choose_your_plan'.tr(),

          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildOption(
                 label: 'monthly'.tr(),

                  isSelected: !isAnnual,
                  onTap: () => onToggle(false),
                ),
              ),
              Expanded(
                child: _buildOption(
                 label: 'annual'.tr(),

                  isSelected: isAnnual,
                  onTap: () => onToggle(true),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOption({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.blackOpacity10,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
