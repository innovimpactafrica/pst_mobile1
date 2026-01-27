import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../domain/bloc/group_bloc.dart';
import '../../domain/bloc/group_event.dart';
import '../../domain/bloc/group_state.dart';
import '../../data/repositories/group_repository.dart';
import '../../data/models/group_model.dart';
import 'package:private_school/core/utils/app_colors.dart';

/// Modal pour RÉPONDRE à une demande de remplacement (autres membres)
class RespondReplacementModal extends StatelessWidget {
  final Planning planning;

  const RespondReplacementModal({super.key, required this.planning});

  void _respondToReplacement(BuildContext context, bool accept) {
    context.read<GroupBloc>().add(
      RespondToReplacementEvent(planningId: planning.id, accept: accept),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GroupBloc(repository: GroupRepository()),
      child: BlocConsumer<GroupBloc, GroupState>(
        listener: (context, state) {
          if (state is ReplacementResponseSent) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.accepted
                      ? 'Remplacement accepté'
                      : 'Remplacement refusé',
                  style: GoogleFonts.inter(),
                ),
                backgroundColor: state.accepted
                    ? AppColors.success
                    : Colors.orange,
              ),
            );
          }
        },
        builder: (context, state) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Demande de remplacement',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
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
                    const SizedBox(height: 20),

                    // DATE DU TRAJET
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.calendar_today,
                              color: AppColors.success,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Date du trajet',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                DateFormat(
                                  'EEEE dd MMMM',
                                  'fr_FR',
                                ).format(planning.date),
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // MOTIF
                    Text(
                      'Motif',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Afficher le motif (en lecture seule)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        planning.replacementReason ?? 'Aucun motif spécifié',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 🆕 DEUX BOUTONS: REFUSER / ACCEPTER
                    Row(
                      children: [
                        // BOUTON REFUSER
                        Expanded(
                          child: OutlinedButton(
                            onPressed: state is GroupLoading
                                ? null
                                : () => _respondToReplacement(context, false),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(color: Colors.red.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Refuser',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.red.shade600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // BOUTON ACCEPTER
                        Expanded(
                          child: ElevatedButton(
                            onPressed: state is GroupLoading
                                ? null
                                : () => _respondToReplacement(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
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
                                    'Accepter',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
