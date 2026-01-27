// Modal widget for reporting problems - API compliant
// Path: lib/chauffeurs/widgets/report_problem_modal.dart

import 'package:flutter/material.dart';
import 'package:private_school/core/utils/app_colors.dart';
import 'package:private_school/core/network/api_client.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ReportProblemModal extends StatefulWidget {
  const ReportProblemModal({super.key});

  @override
  State<ReportProblemModal> createState() => _ReportProblemModalState();
}

class _ReportProblemModalState extends State<ReportProblemModal> {
  String? _selectedProblemType;
  final TextEditingController _descriptionController = TextEditingController();
  File? _attachedFile;
  bool _isSubmitting = false;
  final ApiClient _apiClient = ApiClient();

  final List<String> _problemTypes = [
    'Problème technique',
    'Problème de trajet',
    'Problème de paiement',
    'Problème de passager',
    'Autre',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final file = File(image.path);
        final fileSize = await file.length();
        
        // Check file size (10 MB limit)
        if (fileSize > 10 * 1024 * 1024) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Le fichier est trop volumineux (max 10 MB)'),
              backgroundColor: AppColors.warning,
            ),
          );
          return;
        }

        setState(() {
          _attachedFile = file;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la sélection du fichier: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _submit() async {
    // Validation
    if (_selectedProblemType == null || _descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs obligatoires'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Call API: POST /api/incidents
      final response = await _apiClient.post(
        '/api/incidents',
        data: {
          'type': _selectedProblemType,
          'description': _descriptionController.text.trim(),
          // Add more fields as required by your API
          // 'attachment': _attachedFile != null ? base64Image : null,
        },
      );

      if (!mounted) return;

      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Votre incident a été signalé avec succès'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      String errorMessage = e.toString();
      
      // Clean error message
      if (errorMessage.contains('Exception:')) {
        errorMessage = errorMessage.replaceAll('Exception:', '').trim();
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $errorMessage'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildProblemTypeSection(),
              const SizedBox(height: 20),
              _buildDescriptionSection(),
              const SizedBox(height: 20),
              _buildDocumentsSection(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Signaler un problème',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildProblemTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Type de problème',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.textSecondary.withValues(alpha: 0.2),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedProblemType,
              hint: const Text(
                'Sélectionner',
                style: TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down),
              items: _problemTypes.map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedProblemType = newValue;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _descriptionController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Ex. lorem ipsum',
            hintStyle: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.textSecondary.withValues(alpha: 0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.textSecondary.withValues(alpha: 0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Documents (optionnel)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        
        if (_attachedFile != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.successBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _attachedFile!.path.split('/').last,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _attachedFile = null;
                    });
                  },
                  icon: const Icon(
                    Icons.close,
                    size: 18,
                    color: AppColors.error,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.textSecondary.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 40,
                  color: AppColors.primary.withValues(alpha: 0.6),
                ),
                const SizedBox(height: 12),
                Text(
                  'Choisissez un fichier',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Formats : .PNG, .JPEG. Taille : 10 MB',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: _pickFile,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Parcourir',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: AppColors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Text(
                'Envoyer',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
      ),
    );
  }
}