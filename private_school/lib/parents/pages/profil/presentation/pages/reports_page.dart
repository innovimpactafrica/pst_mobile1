import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_constants.dart';

/// Reports page for drivers
/// Displays and filters driver reports
class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  int _selectedTab = 0;
  int _currentPage = 1;
  final int _itemsPerPage = 5;

  // Mock data - should come from BLoC/Repository
  final List<Map<String, dynamic>> _allReports = [
    {
      'title': 'Signalement A',
      'description': 'Lorem ipsum is simply dumm...',
      'status': 'Résolu',
      'statusColor': AppColors.success,
      'category': 'Incident',
      'imageUrl': 'assets/images/signalementA.png',
    },
    {
      'title': 'Signalement A',
      'description': 'Lorem ipsum is simply dumm...',
      'status': 'En cours',
      'statusColor': AppColors.warning,
      'category': 'Litiges',
      'imageUrl': 'assets/images/report2.jpg',
    },
    {
      'title': 'Signalement sécurité',
      'description': 'Lorem ipsum is simply dumm...',
      'status': 'Rejeté',
      'statusColor': AppColors.error,
      'category': 'Sécurité',
      'imageUrl': 'assets/images/signalementsecurite.png',
    },
  ];

  List<Map<String, dynamic>> get _filteredReports {
    List<Map<String, dynamic>> filtered;
    
    if (_selectedTab == 0) {
      filtered = _allReports;
    } else {
      const categories = ['Incident', 'Litiges', 'Sécurité'];
      final selectedCategory = categories[_selectedTab - 1];
      filtered = _allReports
          .where((report) => report['category'] == selectedCategory)
          .toList();
    }
    
    // Pagination
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    
    if (startIndex >= filtered.length) {
      return [];
    }
    
    return filtered.sublist(
      startIndex,
      endIndex > filtered.length ? filtered.length : endIndex,
    );
  }
  
  int get _totalPages {
    final filtered = _selectedTab == 0
        ? _allReports
        : _allReports.where((report) {
            const categories = ['Incident', 'Litiges', 'Sécurité'];
            return report['category'] == categories[_selectedTab - 1];
          }).toList();
    return (filtered.length / _itemsPerPage).ceil();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.success,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.textWhite,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Signalements',
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeXL,
            fontWeight: FontWeight.w600,
            color: AppColors.textWhite,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: AppConstants.spacingXL),
          _buildSearchBar(),
          const SizedBox(height: AppConstants.spacingXL),
          _buildTabs(),
          const SizedBox(height: AppConstants.spacingXL),
          _buildReportsList(),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingXL + 4,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingXL,
          vertical: AppConstants.spacingXS,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusXL + 4),
          border: Border.all(color: AppColors.border),
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Rechercher',
            hintStyle: GoogleFonts.inter(
              color: AppColors.textGrey,
              fontSize: AppConstants.fontSizeM,
            ),
            border: InputBorder.none,
            icon: const Icon(Icons.search, color: AppColors.textGrey, size: 20),
            contentPadding: const EdgeInsets.symmetric(
              vertical: AppConstants.spacingL,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingXL + 4,
      ),
      child: Row(
        children: [
          _buildTab('Tous', 0),
          const SizedBox(width: AppConstants.spacingS),
          _buildTab('Incident', 1),
          const SizedBox(width: AppConstants.spacingS),
          _buildTab('Litiges', 2),
          const SizedBox(width: AppConstants.spacingS),
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
            _currentPage = 1; // Reset to first page when changing tab
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppConstants.spacingM + 2,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.white,
            borderRadius: BorderRadius.circular(AppConstants.radiusXL + 4),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeS + 1,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? AppColors.textWhite : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReportsList() {
    final totalItems = _selectedTab == 0
        ? _allReports.length
        : _allReports.where((report) {
            const categories = ['Incident', 'Litiges', 'Sécurité'];
            return report['category'] == categories[_selectedTab - 1];
          }).length;
    
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: _filteredReports.isEmpty
                ? Center(
                    child: Text(
                      'Aucun signalement',
                      style: GoogleFonts.inter(
                        fontSize: AppConstants.fontSizeM,
                        color: AppColors.textGrey,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingXL + 4,
                    ),
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
          ),
          if (_totalPages > 1) _buildPagination(totalItems),
        ],
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
      margin: const EdgeInsets.only(bottom: AppConstants.spacingL),
      padding: const EdgeInsets.all(AppConstants.spacingL),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.spacingL),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackOpacity05,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildReportImage(imageUrl),
          const SizedBox(width: AppConstants.spacingL),
          Expanded(child: _buildReportInfo(title, description)),
          const SizedBox(width: AppConstants.spacingS),
          _buildStatusBadge(status, statusColor),
        ],
      ),
    );
  }

  Widget _buildReportImage(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.spacingS),
      child: Container(
        width: 50,
        height: 50,
        color: AppColors.imagePlaceholder,
        child: Image.asset(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.image, color: AppColors.textGrey, size: 24),
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
            fontSize: AppConstants.fontSizeM,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppConstants.spacingXS),
        Text(
          description,
          style: GoogleFonts.inter(
            fontSize: AppConstants.fontSizeS,
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingM + 2,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
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
              fontSize: AppConstants.fontSizeXS + 1,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(int totalItems) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingXL + 4,
        vertical: AppConstants.spacingL,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Page $_currentPage sur $_totalPages',
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeS,
              color: AppColors.textSecondary,
            ),
          ),
          Row(
            children: [
              _buildPageButton(
                icon: Icons.chevron_left,
                onPressed: _currentPage > 1
                    ? () => setState(() => _currentPage--)
                    : null,
              ),
              const SizedBox(width: AppConstants.spacingS),
              ..._buildPageNumbers(),
              const SizedBox(width: AppConstants.spacingS),
              _buildPageButton(
                icon: Icons.chevron_right,
                onPressed: _currentPage < _totalPages
                    ? () => setState(() => _currentPage++)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers() {
    List<Widget> pages = [];
    
    for (int i = 1; i <= _totalPages; i++) {
      if (i == 1 ||
          i == _totalPages ||
          (i >= _currentPage - 1 && i <= _currentPage + 1)) {
        pages.add(
          GestureDetector(
            onTap: () => setState(() => _currentPage = i),
            child: Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: _currentPage == i ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _currentPage == i ? AppColors.primary : AppColors.grey300,
                ),
              ),
              child: Center(
                child: Text(
                  '$i',
                  style: GoogleFonts.inter(
                    fontSize: AppConstants.fontSizeS,
                    fontWeight: _currentPage == i ? FontWeight.w600 : FontWeight.w400,
                    color: _currentPage == i ? AppColors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        );
      } else if (i == _currentPage - 2 || i == _currentPage + 2) {
        pages.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '...',
              style: GoogleFonts.inter(
                fontSize: AppConstants.fontSizeS,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        );
      }
    }
    
    return pages;
  }

  Widget _buildPageButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: onPressed != null ? AppColors.white : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: onPressed != null ? AppColors.grey300 : AppColors.grey200,
        ),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          size: 16,
          color: onPressed != null ? AppColors.textPrimary : AppColors.textSecondary,
        ),
        padding: EdgeInsets.zero,
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: () {
        _showReportProblemModal(context);
      },
      backgroundColor: AppColors.success,
      elevation: 4,
      child: SvgPicture.asset(
        'assets/icons/13.svg',
        width: 24,
        height: 24,
        colorFilter: const ColorFilter.mode(
          AppColors.textWhite,
          BlendMode.srcIn,
        ),
      ),
    );
  }

  void _showReportProblemModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppConstants.radiusXL + 8),
            topRight: Radius.circular(AppConstants.radiusXL + 8),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingXXL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacingXL),

              // Title
              Text(
                'Signaler un problème',
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeXXL,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppConstants.spacingXL),

              // Category dropdown
              Text(
                'Catégorie',
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeM,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppConstants.spacingS),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingXL,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                ),
                child: DropdownButton<String>(
                  value: 'Incident',
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: ['Incident', 'Litiges', 'Sécurité']
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {},
                ),
              ),
              const SizedBox(height: AppConstants.spacingXL),

              // Description
              Text(
                'Description',
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeM,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppConstants.spacingS),
              TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Décrivez le problème...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusL),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusL),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusL),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacingXXL),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Signalement envoyé'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusL),
                    ),
                  ),
                  child: Text(
                    'Envoyer',
                    style: GoogleFonts.inter(
                      fontSize: AppConstants.fontSizeL,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textWhite,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
