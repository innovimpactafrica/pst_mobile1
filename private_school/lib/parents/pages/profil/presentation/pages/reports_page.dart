import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../utils/app_colors.dart';
import '../../../acceuil/widgets/report_problem_modal.dart';


class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  int _selectedTab = 0;

  // TODO: Cette liste devrait venir d'un BLoC/Repository
  // Pour l'instant, données mockées pour le UI
  final List<Map<String, dynamic>> _allReports = [
    {
      'title': 'Signalement A',
      'description': 'Lorem ipsum is simply dumm...',
      'status': 'Résolu',
      'statusColor': AppColors.successGreen,
      'category': 'Incident',
      'imageUrl': 'assets/images/signalementA.png',
    },
    {
      'title': 'Signalement A',
      'description': 'Lorem ipsum is simply dumm...',
      'status': 'En cours',
      'statusColor': AppColors.warningOrange,
      'category': 'Litiges',
      'imageUrl': 'assets/images/report2.jpg',
    },
    {
      'title': 'Signalement sécurité',
      'description': 'Lorem ipsum is simply dumm...',
      'status': 'Rejeté',
      'statusColor': AppColors.errorRed,
      'category': 'Sécurité',
      'imageUrl': 'assets/images/signalementsecurite.png',
    },
  ];

  List<Map<String, dynamic>> get _filteredReports {
    if (_selectedTab == 0) {
      return _allReports;
    }

    const categories = ['Incident', 'Litiges', 'Sécurité'];
    final selectedCategory = categories[_selectedTab - 1];

    return _allReports
        .where((report) => report['category'] == selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Signalements',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          _buildSearchBar(),
          const SizedBox(height: 16),
          _buildTabs(),
          const SizedBox(height: 16),
          _buildReportsList(),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderGrey),
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Rechercher',
            hintStyle: GoogleFonts.inter(
              color: AppColors.textGrey,
              fontSize: 14,
            ),
            border: InputBorder.none,
            icon: Icon(
              Icons.search,
              color: AppColors.textGrey,
              size: 20,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildTab('Tous', 0),
          const SizedBox(width: 8),
          _buildTab('Incident', 1),
          const SizedBox(width: 8),
          _buildTab('Litiges', 2),
          const SizedBox(width: 8),
          _buildTab('Sécurité', 3),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryPurple : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primaryPurple : AppColors.borderGrey,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.textDark,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReportsList() {
    return Expanded(
      child: _filteredReports.isEmpty
          ? Center(
        child: Text(
          'Aucun signalement',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textGrey,
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _filteredReports.length,
        itemBuilder: (context, index) {
          final report = _filteredReports[index];
          return _buildReportCard(
            title: report['title'],
            description: report['description'],
            status: report['status'],
            statusColor: report['statusColor'],
            imageUrl: report['imageUrl'],
          );
        },
      ),
    );
  }

  Widget _buildReportCard({
    required String title,
    required String description,
    required String status,
    required Color statusColor,
    required String imageUrl,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildReportImage(imageUrl),
          const SizedBox(width: 12),
          Expanded(
            child: _buildReportInfo(title, description),
          ),
          const SizedBox(width: 8),
          _buildStatusBadge(status, statusColor),
        ],
      ),
    );
  }

  Widget _buildReportImage(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 50,
        height: 50,
        color: AppColors.imagePlaceholder,
        child: Image.asset(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(
            Icons.image,
            color: AppColors.textGrey,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildReportInfo(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.textGrey,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status, Color statusColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
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
          const SizedBox(width: 6),
          Text(
            status,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: () {
        showReportProblemModal(context);
      },
      backgroundColor: AppColors.primaryGreen,
      elevation: 4,
      child: SvgPicture.asset(
        'assets/icons/13.svg',
        width: 24,
        height: 24,
        color: Colors.white,
      ),
    );
  }
}