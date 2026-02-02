import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:private_school/core/utils/app_colors.dart';
import 'package:private_school/core/utils/app_constants.dart';
import 'package:private_school/core/utils/image_url_helper.dart';
import '../../data/models/report_model.dart';
import '../../domain/bloc/report_bloc.dart';
import '../../domain/bloc/report_event.dart';
import '../../domain/bloc/report_state.dart';
import '../widgets/report_problem_modal.dart';

class ReportDetailPage extends StatelessWidget {
  final ReportModel report;

  const ReportDetailPage({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReportBloc, ReportState>(
      listener: (context, state) {
        if (state is ReportDeleted) {
          // Retour à la liste après suppression
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Signalement supprimé avec succès'),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state is ReportError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        } else if (state is ReportUpdated) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Signalement modifié avec succès'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppConstants.radiusXXL),
                      topRight: Radius.circular(AppConstants.radiusXXL),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppConstants.spacingXL),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatusBadge(),
                        const SizedBox(height: AppConstants.spacingXL),
                        _buildInfoSection(),
                        const SizedBox(height: AppConstants.spacingXL),
                        _buildDocumentsSection(),
                        const SizedBox(height: AppConstants.spacingXL),
                        _buildActionButtons(context),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingXL + 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spacingL),
          Expanded(
            child: Text(
              'Détails du signalement',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: _getStatusBackgroundColor(report.status),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getStatusColor(report.status),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _getStatusLabel(report.status),
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeM,
              fontWeight: FontWeight.w600,
              color: _getStatusColor(report.status),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingL),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            icon: Icons.category_outlined,
            label: 'Catégorie',
            value: report.category,
          ),
          const Divider(height: AppConstants.spacingL),
          _buildInfoRow(
            icon: Icons.description_outlined,
            label: 'Description',
            value: report.description,
          ),
          const Divider(height: AppConstants.spacingL),
          _buildInfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Date de création',
            value: _formatDate(report.createdAt),
          ),
          if (report.resolvedAt != null) ...[
            const Divider(height: AppConstants.spacingL),
            _buildInfoRow(
              icon: Icons.check_circle_outline,
              label: 'Date de résolution',
              value: _formatDate(report.resolvedAt!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primary,
        ),
        const SizedBox(width: AppConstants.spacingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeS,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeM,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentsSection() {
    if (report.imageUrl == null || report.imageUrl!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Documents',
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeL,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppConstants.spacingM),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          child: Image.network(
            ImageUrlHelper.getFullImageUrl(report.imageUrl!),
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                ),
                child: Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    size: 48,
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Bouton Modifier
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => ReportProblemModal(
                  reportToEdit: report,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
              ),
              elevation: 0,
            ),
            icon: const Icon(Icons.edit_outlined, color: AppColors.white),
            label: Text(
              'Modifier le signalement',
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeM,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppConstants.spacingM),

        // Bouton Supprimer
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: () => _showDeleteConfirmation(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.error, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
              ),
            ),
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            label: Text(
              'Supprimer le signalement',
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeM,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        title: Text(
          'Confirmer la suppression',
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeL,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer ce signalement ? Cette action est irréversible.',
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeM,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Annuler',
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeM,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
       context.read<ReportBloc>().add(
  DeleteReportEvent(
    id: report.id,
    userId: report.userId,
  ),
);

            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
            ),
            child: Text(
              'Supprimer',
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeM,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'résolu':
      case 'resolved':
        return 'Résolu';
      case 'en cours':
      case 'in_progress':
      case 'pending':
        return 'En cours';
      case 'rejeté':
      case 'rejected':
        return 'Rejeté';
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