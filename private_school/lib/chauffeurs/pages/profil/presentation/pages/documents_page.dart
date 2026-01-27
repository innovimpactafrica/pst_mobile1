import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../widgets/primary_button.dart';

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key});

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  File? _licenseFile;
  File? _idCardFile;
  int? _licenseSizeKB;
  int? _idCardSizeKB;

  Future<void> _pickDocument(String type) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      int sizeKB = (await file.length()) ~/ 1024;

      setState(() {
        if (type == 'license') {
          _licenseFile = file;
          _licenseSizeKB = sizeKB;
        } else {
          _idCardFile = file;
          _idCardSizeKB = sizeKB;
        }
      });
    }
  }

  void _uploadDocuments() {
    // Implement upload logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Documents téléchargés avec succès'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E3192),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const Text(
                    'Documents',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Driver License
                      _buildDocumentCard(
                        title: 'Permis de conduire',
                        file: _licenseFile,
                        sizeKB: _licenseSizeKB,
                        onTap: () => _pickDocument('license'),
                      ),
                      const SizedBox(height: 20),
                      // ID Card/Passport
                      _buildDocumentCard(
                        title: 'CNI/Passeport',
                        file: _idCardFile,
                        sizeKB: _idCardSizeKB,
                        onTap: () => _pickDocument('idCard'),
                      ),
                      const SizedBox(height: 40),
                      // Upload Button
                      PrimaryButton(
                        text: 'Mettre à jour',
                        onPressed: (_licenseFile != null || _idCardFile != null)
                            ? _uploadDocuments
                            : () {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentCard({
    required String title,
    File? file,
    int? sizeKB,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          if (file == null) ...[
            Icon(
              Icons.upload_file,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              'Choisissez un fichier',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Formats: JPEG, PNG, PDF et MPK jusqu\'à 10 Mo',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onTap,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                backgroundColor: Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Parcourir le fichier',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1F2937),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.description,
                      color: Color(0xFF2E3192),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          file.path.split('/').last,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1F2937),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${sizeKB}Ko',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        if (title == 'Permis de conduire') {
                          _licenseFile = null;
                          _licenseSizeKB = null;
                        } else {
                          _idCardFile = null;
                          _idCardSizeKB = null;
                        }
                      });
                    },
                    icon: const Icon(
                      Icons.close,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onTap,
              child: const Text(
                'Changer le fichier',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF2E3192),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}