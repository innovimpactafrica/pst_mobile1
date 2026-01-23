import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/bloc/group_bloc.dart';
import '../../domain/bloc/group_event.dart';
import '../../domain/bloc/group_state.dart';
import '../../data/repositories/group_repository.dart';
import '../../data/models/group_model.dart';
import 'package:private_school/parents/utils/app_colors.dart';

class JoinGroupModal extends StatelessWidget {
  final GroupModel group;

  const JoinGroupModal({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GroupBloc(repository: GroupRepository()),
      child: BlocConsumer<GroupBloc, GroupState>(
        listener: (context, state) {
          if (state is GroupJoined) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Groupe rejoint !', style: GoogleFonts.inter()),
                backgroundColor: AppColors.primaryGreen,
              ),
            );
          }
        },
        builder: (context, state) {
          return Padding(
              padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
          decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
          ),
          ),
          child: SafeArea(
          child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          // HEADER
          Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
          Text(
          'Rejoindre un groupe',
          style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
          ),
          ),
          IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          ),
          ],
          ),

          const SizedBox(height: 32),

          // AVATAR GRAND
          Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
          color: AppColors.primaryGreen.withOpacity(0.1),
          shape: BoxShape.circle,
          ),
          child: Center(
          child: Text(
          group.initial,
          style: GoogleFonts.inter(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryGreen,
          ),
          ),
          ),
          ),

          const SizedBox(height: 20),

          // NOM DU GROUPE
          Text(
          group.name,
          style: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
          ),
          ),

          const SizedBox(height: 8),

          // INFO CRÉATEUR
          Text(
          'Créé par ${group.createdBy}, ${_formatDate(group.createdAt)}',
          style: GoogleFonts.inter(
          fontSize: 13,
          color: Colors.grey.shade600,
          ),
          ),

          // DESCRIPTION
          if (group.description != null) ...[
          const SizedBox(height: 20),
          Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
          group.description!,
          style: GoogleFonts.inter(
          fontSize: 13,
          color: Colors.grey.shade700,
          height: 1.5,
          ),
          textAlign: TextAlign.center,
          ),
          ),
          ],

          const SizedBox(height: 24),

          // AVATARS DES MEMBRES (SUPERPOSÉS)
          SizedBox(
          height: 40,
          child: Stack(
          alignment: Alignment.center,
          children: [
          if (group.members.isNotEmpty)
          Positioned(
          left: MediaQuery.of(context).size.width / 2 - 60,
          child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
          color: AppColors.primaryGreen.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          ),
          child: Center(
          child: Text(
          group.members[0].displayInitials,
          style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
          ),
          ),
          ),
          ),
          ),
          if (group.members.length > 1)
          Positioned(
          left: MediaQuery.of(context).size.width / 2 - 40,
          child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
          color: Colors.orange.shade200,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          ),
          child: Center(
          child: Text(
          group.members[1].displayInitials,
          style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
          ),
          ),
          ),
          ),
          ),
          if (group.membersCount > 2)
          Positioned(
          left: MediaQuery.of(context).size.width / 2 - 20,
          child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
          color: AppColors.primaryGreen.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          ),
          child: Center(
          child: Text(
          '+${group.membersCount - 2}',
          style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
          ),
          ),
          ),
          ),
          ),
          ],
          ),
          ),

          const SizedBox(height: 24),

          // BOUTON REJOINDRE
          SizedBox(
          width: double.infinity,
          child: ElevatedButton(
          onPressed: state is GroupLoading
          ? null
              : () {
          context.read<GroupBloc>().add(JoinGroupEvent(group.id));
          },
          style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          ),
          child: state is GroupLoading
          ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
          ),
          )
              : Text(
          'Rejoindre le groupe',
          style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          ),
          ),
          ),
          ),
          ],
          ),
          ),
          ),
          ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return "aujourd'hui";
    } else if (difference.inDays < 7) {
      return 'il y a ${difference.inDays}j';
    } else if (difference.inDays < 30) {
      return 'il y a ${(difference.inDays / 7).floor()} sem';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}