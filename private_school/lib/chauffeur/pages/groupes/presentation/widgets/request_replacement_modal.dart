import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../domain/bloc/group_bloc.dart';
import '../../domain/bloc/group_event.dart';
import '../../domain/bloc/group_state.dart';
import '../../data/repositories/group_repository.dart';
import '../../data/models/group_model.dart';
import 'package:private_school/chauffeur/utils/app_colors.dart';

/// Modal pour DEMANDER un remplacement (utilisateur qui veut être remplacé)
class RequestReplacementModal extends StatefulWidget {
  final Planning planning;

  const RequestReplacementModal({super.key, required this.planning});

  @override
  State<RequestReplacementModal> createState() =>
      _RequestReplacementModalState();
}

class _RequestReplacementModalState extends State<RequestReplacementModal> {
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _requestReplacement(BuildContext context) {
    if (_reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
          Text('Veuillez entrer un motif', style: GoogleFonts.inter()),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    context.read<GroupBloc>().add(
      RequestReplacementEvent(
        planningId: widget.planning.id,
        reason: _reasonController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GroupBloc(repository: GroupRepository()),
      child: BlocConsumer<GroupBloc, GroupState>(
        listener: (context, state) {
          if (state is ReplacementRequested) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Demande de remplacement envoyée',
                    style: GoogleFonts.inter()),
                backgroundColor: AppColors.primaryGreen,
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
                        color: AppColors.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.calendar_today,
                              color: AppColors.primaryGreen,
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
                                DateFormat('EEEE dd MMMM', 'fr_FR')
                                    .format(widget.planning.date),
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
                    TextField(
                      controller: _reasonController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Description',
                        hintStyle: GoogleFonts.inter(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.primaryGreen),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 🆕 UN SEUL BOUTON: ENVOYER
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state is GroupLoading
                            ? null
                            : () => _requestReplacement(context),
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
                          'Envoyer',
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
          );
        },
      ),
    );
  }
}