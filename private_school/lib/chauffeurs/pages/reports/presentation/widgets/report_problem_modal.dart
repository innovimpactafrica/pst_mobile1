// Modal for reporting problems - CORRECTED VERSION WITH EDIT SUPPORT
// Path: lib/chauffeurs/pages/reports/presentation/widgets/report_problem_modal.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:private_school/chauffeurs/pages/reports/data/models/report_model.dart';
import 'package:private_school/core/utils/app_colors.dart';
import 'package:private_school/core/utils/app_constants.dart';
import '../../domain/bloc/report_bloc.dart';
import '../../domain/bloc/report_event.dart';
import '../../domain/bloc/report_state.dart';

class ReportProblemModal extends StatefulWidget {
  final ReportModel? reportToEdit;
  const ReportProblemModal({super.key, this.reportToEdit});

  @override
  State<ReportProblemModal> createState() => _ReportProblemModalState();
}

class _ReportProblemModalState extends State<ReportProblemModal> {
  late TextEditingController _descriptionController;
  String? _selectedProblemType;
  final List<File> _selectedFiles = [];
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploading = false;
  bool get isEditMode => widget.reportToEdit != null;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.reportToEdit?.description ?? '',
    );

    if (widget.reportToEdit != null) {
      // Chercher le type correspondant
      final existingType = _problemTypes.firstWhere(
        (element) =>
            element['api'] == widget.reportToEdit!.type ||
            element['value'] == widget.reportToEdit!.category,
        orElse: () => _problemTypes.last,
      );
      _selectedProblemType = existingType['value'];
    }
  }

  final List<Map<String, String>> _problemTypes = [
    {'value': 'Problème technique', 'api': 'incident'},
    {'value': 'Problème de trajet', 'api': 'incident'},
    {'value': 'Problème de paiement', 'api': 'litige'},
    {'value': 'Problème de passager', 'api': 'litige'},
    {'value': 'Problème de sécurité', 'api': 'securite'},
    {'value': 'Autre', 'api': 'incident'},
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      showModalBottomSheet(
        context: context,
        backgroundColor: AppColors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingL),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt,
                    color: AppColors.primary,
                  ),
                  title: Text(
                    'take_photo'.tr(),
                    style: GoogleFonts.inter(
                      fontSize: AppConstants.fontSizeM,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickImageFromCamera();
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library,
                    color: AppColors.primary,
                  ),
                  title: Text(
                    'choose_from_gallery'.tr(),
                    style: GoogleFonts.inter(
                      fontSize: AppConstants.fontSizeM,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickImageFromGallery();
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.insert_drive_file,
                    color: AppColors.primary,
                  ),
                  title: Text(
                    'choose_file_label'.tr(),
                    style: GoogleFonts.inter(
                      fontSize: AppConstants.fontSizeM,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickDocument();
                  },
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      _showErrorSnackBar('file_selection_error'.tr());
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedFiles.add(File(image.path));
        });
      }
    } catch (e) {
      _showErrorSnackBar('camera_error'.tr());
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedFiles.add(File(image.path));
        });
      }
    } catch (e) {
      _showErrorSnackBar('image_selection_error'.tr());
    }
  }

  Future<void> _pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileSize = await file.length();

        if (fileSize > 10 * 1024 * 1024) {
          _showErrorSnackBar('file_too_large'.tr());
          return;
        }

        setState(() {
          _selectedFiles.add(file);
        });
      }
    } catch (e) {
      _showErrorSnackBar('document_selection_error'.tr());
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _submitReport() async {
    // Validation
    if (_selectedProblemType == null) {
      _showErrorSnackBar('please_select_problem_type'.tr());
      return;
    }
    if (_descriptionController.text.trim().isEmpty) {
      _showErrorSnackBar('please_describe_problem'.tr());
      return;
    }

    // Les fichiers sont obligatoires UNIQUEMENT en mode création
    if (!isEditMode && _selectedFiles.isEmpty) {
      _showErrorSnackBar('please_add_document'.tr());
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final problemConfig = _problemTypes.firstWhere(
        (type) => type['value'] == _selectedProblemType,
        orElse: () => {'value': 'Autre', 'api': 'incident'},
      );

      if (isEditMode) {
        // Mode modification - avec fichiers optionnels
        context.read<ReportBloc>().add(
              UpdateReportEvent(
                id: widget.reportToEdit!.id,
                type: problemConfig['api']!,
                category: _selectedProblemType!,
                description: _descriptionController.text.trim(),
                files: _selectedFiles.isNotEmpty ? _selectedFiles : null,
              ),
            );
      } else {
        // Mode création
        context.read<ReportBloc>().add(
              CreateReportEvent(
                type: problemConfig['api']!,
                category: _selectedProblemType!,
                description: _descriptionController.text.trim(),
                files: _selectedFiles,
              ),
            );
      }
    } catch (e) {
      _showErrorSnackBar('report_preparation_error'.tr());
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReportBloc, ReportState>(
      listener: (context, state) {
        if (state is ReportCreated || state is ReportUpdated) {
          setState(() {
            _isUploading = false;
          });
          Navigator.pop(context);
          _showSuccessSnackBar(
            isEditMode
                ? 'report_updated_successfully'.tr()
                : 'report_created_successfully'.tr(),
          );
        } else if (state is ReportError) {
          setState(() {
            _isUploading = false;
          });
          _showErrorSnackBar(state.message);
        }
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildProblemTypeDropdown(),
                const SizedBox(height: 24),
                _buildDescriptionField(),
                const SizedBox(height: 24),
                _buildDocumentsSection(), // ✅ TOUJOURS afficher, pas seulement en mode création
                const SizedBox(height: 32),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          isEditMode ? 'edit_report'.tr() : 'report_problem'.tr(),
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildProblemTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'problem_type'.tr(),
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFD1D5DB),
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedProblemType,
              hint: Text(
                'select'.tr(),
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: AppConstants.fontSizeM,
                ),
              ),
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.textPrimary,
              ),
              items: _problemTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type['value'],
                  child: Text(
                    type['value']!,
                    style: GoogleFonts.inter(
                      fontSize: AppConstants.fontSizeM,
                      color: AppColors.textPrimary,
                    ),
                  ),
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

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'description'.tr(),
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _descriptionController,
          maxLines: 5,
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeM,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'description_example'.tr(),
            hintStyle: GoogleFonts.inter(
              color: AppColors.textSecondary.withValues(alpha: 0.5),
              fontSize: AppConstants.fontSizeM,
            ),
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFD1D5DB),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFD1D5DB),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2,
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
        Row(
          children: [
            Text(
              'documents'.tr(),
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            // ✅ AIDE en mode édition
            if (isEditMode) ...[
              const SizedBox(width: 8),
              Text(
                'optional_replace'.tr(),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),

        if (_selectedFiles.isNotEmpty) ...[
          ..._selectedFiles.asMap().entries.map((entry) {
            final index = entry.key;
            final file = entry.value;
            return _buildFileItem(file, index);
          }),
          const SizedBox(height: 12),
        ],

        InkWell(
          onTap: _isUploading ? null : _pickFile,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFD1D5DB),
                width: 1,
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
                  'choose_file'.tr(),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'formats'.tr(),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: _isUploading ? null : _pickFile,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    'browse_file'.tr(),
                    style: GoogleFonts.inter(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: AppConstants.fontSizeM,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFileItem(File file, int index) {
    final fileName = file.path.split('/').last;
    final fileExtension = fileName.split('.').last.toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              _getFileIcon(fileExtension),
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _formatFileSize(file.lengthSync()),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _removeFile(index),
            icon: const Icon(Icons.close, size: 18),
            color: AppColors.error,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'png':
      case 'jpg':
      case 'jpeg':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isUploading ? null : _submitReport,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isUploading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: AppColors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                isEditMode ? 'edit'.tr() : 'send'.tr(),
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
      ),
    );
  }
}