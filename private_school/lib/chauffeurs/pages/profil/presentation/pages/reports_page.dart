import 'package:flutter/material.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String _selectedFilter = 'Tous';

  final List<Map<String, dynamic>> _reports = [
    {
      'id': '1',
      'title': 'Signalement A',
      'description': 'Lorem ipsum is simply dumm..',
      'status': 'resolved',
      'type': 'general',
      'image': null,
    },
    {
      'id': '2',
      'title': 'Signalement A',
      'description': 'Lorem ipsum is simply dumm..',
      'status': 'in_progress',
      'type': 'incident',
      'image': null,
    },
    {
      'id': '3',
      'title': 'Signalement sécurité',
      'description': 'Lorem ipsum is simply dumm..',
      'status': 'rejected',
      'type': 'security',
      'image': null,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E3192),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create report page
        },
        backgroundColor: const Color(0xFF2E3192),
        child: const Icon(Icons.lightbulb_outline, color: Colors.white),
      ),
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
                    'Signalements',
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
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Rechercher',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey[400],
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF9FAFB),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                      ),
                    ),
                    // Filter Chips
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('Tous', _selectedFilter == 'Tous'),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              'Incident',
                              _selectedFilter == 'Incident',
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              'Litiges',
                              _selectedFilter == 'Litiges',
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              'Sécurité',
                              _selectedFilter == 'Sécurité',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Reports List
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _reports.length,
                        itemBuilder: (context, index) {
                          return _buildReportCard(_reports[index]);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF10B981) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF10B981)
                : const Color(0xFFE5E7EB),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    Color statusColor;
    String statusText;

    switch (report['status']) {
      case 'resolved':
        statusColor = const Color(0xFF10B981);
        statusText = 'Résolu';
        break;
      case 'in_progress':
        statusColor = const Color(0xFFF59E0B);
        statusText = 'En cours';
        break;
      case 'rejected':
        statusColor = const Color(0xFFEF4444);
        statusText = 'Rejeté';
        break;
      default:
        statusColor = const Color(0xFF6B7280);
        statusText = 'En attente';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Report Image
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
              image: report['image'] != null
                  ? DecorationImage(
                      image: NetworkImage(report['image']),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: report['image'] == null
                ? Icon(Icons.image_outlined, color: Colors.grey[500])
                : null,
          ),
          const SizedBox(width: 12),
          // Report Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      report['title'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  report['description'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
