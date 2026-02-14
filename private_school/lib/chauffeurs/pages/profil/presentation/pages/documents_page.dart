import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_constants.dart';
import '../../data/models/driver_profile_model.dart';
import '../../../profil/domain/bloc/driver_profile_bloc.dart';
import '../../../profil/domain/bloc/driver_profile_event.dart';
import '../../../profil/domain/bloc/driver_profile_state.dart';
import '../widgets/primary_button.dart';

/// Documents page for drivers
/// Manages driver's legal documents upload via PUT /api/drivers/{id}
class DocumentsPage extends StatefulWidget {
  final DriverProfileModel profile;

  const DocumentsPage({super.key, required this.profile});

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  File? _licenseFile;
  File? _idCardFile;
  int? _licenseSizeKB;
  int? _idCardSizeKB;

  @override
  void initState() {
    super.initState();
    debugPrint('📄 [DocumentsPage] Initialized');
    debugPrint('📄 [DocumentsPage] Driver ID: ${widget.profile.driver.id}');
    debugPrint('📄 [DocumentsPage] License Document: ${widget.profile.driver.licenseDocument}');
    debugPrint('📄 [DocumentsPage] ID Document: ${widget.profile.driver.idDocument}');
    debugPrint('📄 [DocumentsPage] Vehicle Photo: ${widget.profile.driver.vehiclePhoto}');
  }

  Future<void> _pickDocument(String type) async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: AppConstants.allowedDocumentExtensions,
      );

      if (result != null) {
        final File file = File(result.files.single.path!);
        final int sizeKB = (await file.length()) ~/ 1024;

        if (sizeKB > AppConstants.maxFileSizeKB) {
          if (mounted) _showSnackBar(AppConstants.errorFileTooBig, isError: true);
          return;
        }

        setState(() {
          if (type == 'license') {
            _licenseFile = file;
            _licenseSizeKB = sizeKB;
          } else if (type == 'idCard') {
            _idCardFile = file;
            _idCardSizeKB = sizeKB;
          }
        });

        debugPrint('📄 [DocumentsPage] File selected: ${file.path.split('/').last} ($sizeKB Ko)');

        if (mounted) _showSnackBar(AppConstants.successFileSelected, isError: false);
      }
    } catch (e) {
      debugPrint('❌ [DocumentsPage] Error: $e');
      if (mounted) _showSnackBar('${AppConstants.errorPickFile}: $e', isError: true);
    }
  }

  void _uploadDocuments() {
    if (_licenseFile == null && _idCardFile == null) {
      _showSnackBar(AppConstants.errorNoFile, isError: true);
      return;
    }
    _performUpload();
  }

  Future<void> _performUpload() async {
    try {
      debugPrint('📤 [DocumentsPage] Starting upload...');
      final FormData formData = FormData();

      if (_licenseFile != null) {
        final String fileName = _licenseFile!.path.split('/').last;
        formData.files.add(
          MapEntry(
            'license_document',
            await MultipartFile.fromFile(_licenseFile!.path, filename: fileName),
          ),
        );
        debugPrint('📄 [DocumentsPage] License added: $fileName');
      }

      if (_idCardFile != null) {
        final String fileName = _idCardFile!.path.split('/').last;
        formData.files.add(
          MapEntry(
            'id_document',
            await MultipartFile.fromFile(_idCardFile!.path, filename: fileName),
          ),
        );
        debugPrint('📄 [DocumentsPage] ID card added: $fileName');
      }

      final String driverId = widget.profile.driver.id.toString();
      debugPrint('👤 [DocumentsPage] Driver ID: $driverId');

      if (mounted) {
        context.read<DriverProfileBloc>().add(
          UpdateDriverByIdEvent(driverId: driverId, formData: formData),
        );
      }
    } catch (e) {
      debugPrint('❌ [DocumentsPage] Upload error: $e');
      if (mounted) _showSnackBar('${AppConstants.errorUpload}: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isError ? Icons.error : Icons.check_circle, color: Colors.white),
            const SizedBox(width: AppConstants.spacingL),
            Expanded(
              child: Text(message, style: const TextStyle(fontWeight: FontWeight.w500)),
            ),
          ],
        ),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusM)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

@override
Widget build(BuildContext context) {
  return BlocListener<DriverProfileBloc, DriverProfileState>(
    listener: (context, state) {
      if (state is DriverProfileUpdated) {
        debugPrint('✅ [DocumentsPage] Success');
        _showSnackBar(AppConstants.successUpload, isError: false);

        setState(() {
          _licenseFile = null;
          _idCardFile = null;
          _licenseSizeKB = null;
          _idCardSizeKB = null;
        });
      } else if (state is DriverProfileError) {
        debugPrint('❌ [DocumentsPage] Error: ${state.message}');
        _showSnackBar(state.message, isError: true);
      }
    },
    child: Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppConstants.radiusXL),
                    topRight: Radius.circular(AppConstants.radiusXL),
                  ),
                ),
                child: BlocBuilder<DriverProfileBloc, DriverProfileState>(
                  builder: (context, state) {
                    final bool isUpdating = state is DriverProfileUpdating;
                    
                   
                    final currentProfile = (state is DriverProfileUpdated) 
                        ? state.profile 
                        : (state is DriverProfileLoaded) ? state.profile : widget.profile;
                    final driverInfo = currentProfile.driver;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(AppConstants.spacingXXL),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (driverInfo.licenseDocument != null || driverInfo.idDocument != null)
                            _buildInfoMessage(),

                          _buildDocumentCard(
                            title: AppConstants.labelLicense,
                            icon: Icons.card_membership,
                            existingDocumentUrl: driverInfo.licenseDocument,
                            newFile: _licenseFile,
                            newSizeKB: _licenseSizeKB,
                            onTap: () => _pickDocument('license'),
                            onRemove: () => setState(() {
                              _licenseFile = null;
                              _licenseSizeKB = null;
                            }),
                          ),

                          const SizedBox(height: AppConstants.spacingXXL),

                          _buildDocumentCard(
                            title: AppConstants.labelIdCard,
                            icon: Icons.badge,
                            existingDocumentUrl: driverInfo.idDocument,
                            newFile: _idCardFile,
                            newSizeKB: _idCardSizeKB,
                            onTap: () => _pickDocument('idCard'),
                            onRemove: () => setState(() {
                              _idCardFile = null;
                              _idCardSizeKB = null;
                            }),
                          ),

                          const SizedBox(height: 40),

                          PrimaryButton(
                            text: AppConstants.labelUpdate,
                            isLoading: isUpdating,
                            onPressed: (_licenseFile != null || _idCardFile != null)
                                ? () => _uploadDocuments()
                                : null,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: AppConstants.iconSizeM),
          ),
          const Text(
            AppConstants.labelDocuments,
            style: TextStyle(
              fontSize: AppConstants.fontSizeXL,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoMessage() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      margin: const EdgeInsets.only(bottom: AppConstants.spacingXXL),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue[700]),
          const SizedBox(width: AppConstants.spacingL),
          Expanded(
            child: Text(
              AppConstants.labelInfoMessage,
              style: TextStyle(fontSize: AppConstants.fontSizeM, color: Colors.blue[900]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard({
    required String title,
    required IconData icon,
    String? existingDocumentUrl,
    File? newFile,
    int? newSizeKB,
    required VoidCallback onTap,
    required VoidCallback onRemove,
  }) {
    final bool hasNewFile = newFile != null;
    final bool hasExistingDoc = existingDocumentUrl != null && existingDocumentUrl.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingXXL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: AppColors.borderLight, width: 2),
        boxShadow: const [BoxShadow(color: Color(0x0C000000), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: AppConstants.iconSizeM),
              const SizedBox(width: AppConstants.radiusM),
              Expanded(
                child: Text(title, style: const TextStyle(fontSize: AppConstants.fontSizeL, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              ),
              if (hasExistingDoc && !hasNewFile)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.radiusM, vertical: AppConstants.spacingXS),
                  decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(AppConstants.radiusS)),
                  child: const Text(AppConstants.labelValidated, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.success)),
                ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingM),
          if (hasNewFile) ...[
            _buildNewFilePreview(newFile, newSizeKB, onRemove),
            const SizedBox(height: AppConstants.spacingL),
            _buildChangeButton(onTap, AppConstants.labelChangeFile),
          ] else if (hasExistingDoc) ...[
            _buildExistingDocumentPreview(existingDocumentUrl),
            const SizedBox(height: AppConstants.spacingL),
            _buildChangeButton(onTap, AppConstants.labelReplaceFile),
          ] else ...[
            _buildEmptyState(onTap),
          ],
        ],
      ),
    );
  }

  Widget _buildNewFilePreview(File? file, int? sizeKB, VoidCallback onRemove) {
    if (file == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(AppConstants.radiusL), border: Border.all(color: AppColors.primary, width: 2)),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppConstants.radiusM)),
            child: const Icon(Icons.description, color: AppColors.primary),
          ),
          const SizedBox(width: AppConstants.spacingL),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(file.path.split('/').last, style: const TextStyle(fontSize: AppConstants.fontSizeM, fontWeight: FontWeight.w500, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: AppConstants.spacingXS),
                Text(_formatFileSize(sizeKB ?? 0), style: const TextStyle(fontSize: AppConstants.fontSizeS, color: AppColors.textSecondary)),
              ],
            ),
          ),
          IconButton(onPressed: onRemove, icon: const Icon(Icons.close, color: AppColors.textSecondary)),
        ],
      ),
    );
  }


Widget _buildExistingDocumentPreview(dynamic documentUrl) {
  
  if (documentUrl == null || documentUrl is! String || documentUrl.isEmpty) {
    debugPrint('⚠️ [DocumentsPage] URL invalide ou format Map détecté: $documentUrl');
    return const SizedBox.shrink(); 
  }

  final String fullUrl = documentUrl.startsWith('http') 
      ? documentUrl 
      : "http://86.106.181.31:3000$documentUrl";

  return GestureDetector(
    onTap: () async {
      final Uri uri = Uri.parse(fullUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showSnackBar('Impossible d’ouvrir le document', isError: true);
      }
    },
    child: Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: AppColors.successLight, 
        borderRadius: BorderRadius.circular(AppConstants.radiusL), 
        border: Border.all(color: AppColors.success, width: 2),
      ),
      child: Row(
        children: [
          _buildThumbnail(fullUrl),
          const SizedBox(width: AppConstants.spacingL),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  AppConstants.labelCurrentDocument, 
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeM, 
                    fontWeight: FontWeight.w600, 
                    color: AppColors.textPrimary
                  ),
                ),
                const SizedBox(height: AppConstants.spacingXS),
                Text(
                  documentUrl.split('/').last, 
                  style: const TextStyle(
                    fontSize: AppConstants.fontSizeS, 
                    color: AppColors.textSecondary
                  ), 
                  maxLines: 1, 
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildThumbnail(String url) {
  return Container(
    width: 48,
    height: 48,
    decoration: BoxDecoration(
      color: AppColors.success.withValues(alpha:0.1), 
      borderRadius: BorderRadius.circular(AppConstants.radiusM),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.radiusM),
      child: Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.insert_drive_file, 
          color: AppColors.success
        ),
      ),
    ),
  );
}

  Widget _buildEmptyState(VoidCallback onTap) {
    return Column(
      children: [
        const Icon(Icons.upload_file, size: 48, color: AppColors.borderLight),
        const SizedBox(height: AppConstants.spacingL),
        const Text(AppConstants.labelChooseFile, style: TextStyle(fontSize: AppConstants.fontSizeM, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        const SizedBox(height: AppConstants.spacingXS),
        const Text(AppConstants.labelFormats, style: TextStyle(fontSize: AppConstants.fontSizeS, color: AppColors.textTertiary), textAlign: TextAlign.center),
        const SizedBox(height: AppConstants.spacingM),
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingXXL, vertical: AppConstants.spacingL),
            backgroundColor: AppColors.backgroundLight,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusM)),
          ),
          child: const Text(AppConstants.labelBrowse, style: TextStyle(fontSize: AppConstants.fontSizeM, color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }

  Widget _buildChangeButton(VoidCallback onTap, String text) {
    return Center(
      child: TextButton(
        onPressed: onTap,
        child: Text(text, style: const TextStyle(fontSize: AppConstants.fontSizeM, color: AppColors.primary, fontWeight: FontWeight.w500)),
      ),
    );
  }

  String _formatFileSize(int sizeKB) {
    if (sizeKB < 1024) return '$sizeKB Ko';
    return '${(sizeKB / 1024).toStringAsFixed(1)} Mo';
  }
}
