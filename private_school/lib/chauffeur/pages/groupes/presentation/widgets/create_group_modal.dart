import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/bloc/group_bloc.dart';
import '../../domain/bloc/group_event.dart';
import '../../domain/bloc/group_state.dart';
import '../../data/repositories/group_repository.dart';
import 'package:private_school/chauffeur/utils/app_colors.dart';

class CreateGroupModal extends StatefulWidget {
  const CreateGroupModal({super.key});

  @override
  State<CreateGroupModal> createState() => _CreateGroupModalState();
}

class _CreateGroupModalState extends State<CreateGroupModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _membersController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _membersController.dispose();
    super.dispose();
  }

  void _createGroup(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      // Séparer les emails par virgule ou espace
      final memberEmails = _membersController.text
          .split(RegExp(r'[,\s]+'))
          .where((e) => e.isNotEmpty)
          .toList();

      context.read<GroupBloc>().add(
        CreateGroupEvent(
          name: _nameController.text.trim(),
          memberEmails: memberEmails,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GroupBloc(repository: GroupRepository()),
      child: BlocConsumer<GroupBloc, GroupState>(
        listener: (context, state) {
          if (state is GroupCreated) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Groupe créé avec succès',
                  style: GoogleFonts.inter(),
                ),
                backgroundColor: AppColors.primaryGreen,
              ),
            );
          }
          if (state is GroupError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: GoogleFonts.inter(),
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is GroupLoading;

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
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // HEADER
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Créer un groupe de covoiturage',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // NOM DU GROUPE
                      Text(
                        'Nom du groupe',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'Ex : sencov',
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
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Veuillez entrer un nom de groupe';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // MEMBRES
                      Text(
                        'Membres',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _membersController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'email ou numéro de téléphone',
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

                      const SizedBox(height: 32),

                      // BOUTON CRÉER
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : () => _createGroup(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : Text(
                            'Créer',
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
}