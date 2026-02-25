import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_constants.dart';
import '../../../../../core/utils/image_url_helper.dart';
import '../../data/models/report_model.dart';

class ReportCardWidget extends StatelessWidget {
  final ReportModel report;
  final VoidCallback onTap;

  const ReportCardWidget({
    super.key,
    required this.report,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusL),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
        padding: const EdgeInsets.all(AppConstants.spacingM),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          boxShadow: [
            BoxShadow(
              color: AppColors.blackOpacity05,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image thumbnail
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                image: report.imageUrl != null && report.imageUrl!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(
                          ImageUrlHelper.getFullImageUrl(report.imageUrl!),
                        ),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: report.imageUrl == null || report.imageUrl!.isEmpty
                    ? AppColors.backgroundLight
                    : null,
              ),
              child: report.imageUrl == null || report.imageUrl!.isEmpty
                  ? Icon(
                      _getIconForType(report.type),
                      color: _getColorForType(report.type),
                      size: 28,
                    )
                  : null,
            ),

            const SizedBox(width: AppConstants.spacingM),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.category,
                    style: GoogleFonts.inter(
                      fontSize: AppConstants.fontSizeM,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    report.description,
                    style: GoogleFonts.inter(
                      fontSize: AppConstants.fontSizeS,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: AppConstants.spacingS),

            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusBackgroundColor(report.status),
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _getStatusColor(report.status),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _getStatusLabel(report.status),
                    style: GoogleFonts.inter(
                      fontSize: AppConstants.fontSizeS - 1,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(report.status),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'incident':
        return Icons.warning_amber_rounded;
      case 'litige':
        return Icons.gavel_rounded;
      case 'securite':
      case 'sécurité':
        return Icons.shield_outlined;
      default:
        return Icons.error_outline;
    }
  }

  Color _getColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'incident':
        return AppColors.warning;
      case 'litige':
        return AppColors.primary;
      case 'securite':
      case 'sécurité':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'résolu':
      case 'resolved':
        return 'resolved'.tr();
      case 'en cours':
      case 'in_progress':
      case 'pending':
        return 'in_progress'.tr();
      case 'rejeté':
      case 'rejected':
        return 'rejected'.tr();
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'résolu':
      case 'resolved':
        return AppColors.success;
      case 'en cours':
      case 'in_progress':
      case 'pending':
        return AppColors.warning;
      case 'rejeté':
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getStatusBackgroundColor(String status) {
    return _getStatusColor(status).withValues(alpha: 0.1);
  }
}
