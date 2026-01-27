import 'package:flutter/material.dart';
import 'package:private_school/core/utils/app_constants.dart';


/// Stats card widget for dashboard
/// Location: lib/features/dashboard/presentation/widgets/stats_card.dart
class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingS),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppConstants.radiusS),
            ),
            child: Icon(
              icon,
              color: color,
              size: AppConstants.iconSizeL,
            ),
          ),
          const SizedBox(height: AppConstants.spacingS),
          Text(
            value,
            style: TextStyle(
              fontSize: AppConstants.fontSizeXXL,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: AppConstants.fontSizeS,
              color: color.withValues(alpha: 0.7),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}