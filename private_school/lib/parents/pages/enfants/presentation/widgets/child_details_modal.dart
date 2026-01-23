import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../utils/app_colors.dart';
import '../../../utils/modal_helper.dart';
import '../../data/models/child_model.dart';
import '../../domain/bloc/child_bloc.dart';
import '../../domain/bloc/child_event.dart';
import 'edit_child_modal.dart';
import 'child_schedule_modal.dart';

class ChildDetailsModal extends StatelessWidget {
  final ChildModel child;

  const ChildDetailsModal({
    super.key,
    required this.child,
  });

  void _showEditModal(BuildContext context) {
    Navigator.pop(context); // Fermer le modal actuel
    Future.delayed(const Duration(milliseconds: 300), () {
      ModalHelper.showSlideModal(
        context: context,
        child: EditChildModal(child: child),
      );
    });
  }

  void _showScheduleModal(BuildContext context) {
    Navigator.pop(context); // Fermer le modal actuel
    Future.delayed(const Duration(milliseconds: 300), () {
      ModalHelper.showSlideModal(
        context: context,
        child: ChildScheduleModal(child: child),
      );
    });
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Supprimer l\'enfant',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer ${child.fullName} ?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Annuler',
              style: GoogleFonts.inter(color: Colors.grey.shade600),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<ChildBloc>().add(DeleteChildEvent(child.id));
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            child: Text(
              'Supprimer',
              style: GoogleFonts.inter(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
                  _buildAvatar(),
                  const SizedBox(height: 32),
                  _buildInfoRow('Prénom', child.firstName),
                  const SizedBox(height: 20),
                  _buildInfoRow('Nom', child.lastName),
                  const SizedBox(height: 20),
                  _buildInfoRow('Adresse', child.fullAddress),
                  const SizedBox(height: 20),
                  _buildInfoRow('École', child.school),
                  const SizedBox(height: 32),
                  _buildModifyButton(context),
                  const SizedBox(height: 12),
                  _buildScheduleButton(context),
                  const SizedBox(height: 32),
                  _buildDeleteButton(context),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Détails de l\'enfant',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.close,
              color: Colors.grey.shade600,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          child.initials,
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryGreen,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModifyButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () => _showEditModal(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          'Modifier',
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: () => _showScheduleModal(context),
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue.withOpacity(0.15), // bleu clair
          foregroundColor: AppColors.primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          side: BorderSide.none, // supprime le contour
        ),
        child: Text(
          'Configurer les horaires',
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryBlue,
          ),
        ),
      ),
    );
  }


  Widget _buildDeleteButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: GestureDetector(
        onTap: () => _confirmDelete(context),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white, // background blanc
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.grey.shade400, // contour gris
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              'Supprimer',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.red, // texte rouge
              ),
            ),
          ),
        ),
      ),
    );
  }

}