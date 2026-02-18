import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_constants.dart';
import '../../data/models/incident_model.dart';
//import '../../data/services/incident_service.dart';
import '../../domain/bloc/incident_bloc.dart';
import '../../domain/bloc/incident_event.dart';
import '../../domain/bloc/incident_state.dart';
import '../../../authentification/domain/bloc/auth_bloc.dart';
import '../../../authentification/domain/bloc/auth_state.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  int _selectedTab = 0;
  int _currentPage = 1;
  final int _itemsPerPage = 5;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<IncidentBloc>().add(LoadIncidentsEvent());
  }

  List<IncidentModel> _getFilteredIncidents(List<IncidentModel> allIncidents, String? currentUserId) {
    var filtered = currentUserId != null
        ? allIncidents.where((i) => i.userId == currentUserId).toList()
        : allIncidents;
    
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((i) =>
        i.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        i.description.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    if (_selectedTab != 0) {
      const categories = ['Incident', 'Litiges', 'Sécurité'];
      final selectedCategory = categories[_selectedTab - 1];
      filtered = filtered.where((i) => i.category == selectedCategory).toList();
    }
    
    return filtered;
  }

  List<IncidentModel> _getPaginatedIncidents(List<IncidentModel> filtered) {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    
    if (startIndex >= filtered.length) return [];
    
    return filtered.sublist(
      startIndex,
      endIndex > filtered.length ? filtered.length : endIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.success,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textWhite, size: 20),
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
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final currentUserId = authState is AuthAuthenticated ? authState.user?.id : null;
          
          return BlocBuilder<IncidentBloc, IncidentState>(
            builder: (context, incidentState) {
              if (incidentState is IncidentLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (incidentState is IncidentError) {
                return Center(child: Text('Erreur: ${incidentState.message}'));
              }
              
              if (incidentState is IncidentsLoaded) {
                final filteredIncidents = _getFilteredIncidents(incidentState.incidents, currentUserId);
                final paginatedIncidents = _getPaginatedIncidents(filteredIncidents);
                final totalPages = (filteredIncidents.length / _itemsPerPage).ceil();
                
                return Column(
                  children: [
                    const SizedBox(height: AppConstants.spacingXL),
                    _buildSearchBar(),
                    const SizedBox(height: AppConstants.spacingXL),
                    _buildTabs(),
                    const SizedBox(height: AppConstants.spacingXL),
                    _buildReportsList(paginatedIncidents, totalPages),
                  ],
                );
              }
              
              return const Center(child: Text('Aucun incident'));
            },
          );
        },
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingXL + 4),
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
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
              _currentPage = 1;
            });
          },
          decoration: InputDecoration(
            hintText: 'Rechercher',
            hintStyle: GoogleFonts.inter(color: AppColors.textGrey, fontSize: AppConstants.fontSizeM),
            border: InputBorder.none,
            icon: const Icon(Icons.search, color: AppColors.textGrey, size: 20),
            contentPadding: const EdgeInsets.symmetric(vertical: AppConstants.spacingL),
          ),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingXL + 4),
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
            _currentPage = 1;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingM + 2),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.white,
            borderRadius: BorderRadius.circular(AppConstants.radiusXL + 4),
            border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
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

  Widget _buildReportsList(List<IncidentModel> incidents, int totalPages) {
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: incidents.isEmpty
                ? Center(
                    child: Text(
                      'Aucun signalement',
                      style: GoogleFonts.inter(fontSize: AppConstants.fontSizeM, color: AppColors.textGrey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingXL + 4),
                    itemCount: incidents.length,
                    itemBuilder: (context, index) {
                      final incident = incidents[index];
                      return _buildReportCard(
                        title: incident.title,
                        description: incident.description,
                        status: incident.status,
                        statusColor: Color(incident.statusColorValue),
                        imageUrl: incident.imageUrl ?? 'assets/images/signalementA.png',
                      );
                    },
                  ),
          ),
          if (totalPages > 1) _buildPagination(totalPages),
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
          BoxShadow(color: AppColors.blackOpacity05, blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.spacingS),
            child: Container(
              width: 50,
              height: 50,
              color: AppColors.imagePlaceholder,
              child: Image.asset(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.image, color: AppColors.textGrey, size: 24),
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spacingL),
          Expanded(
            child: Column(
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
                  style: GoogleFonts.inter(fontSize: AppConstants.fontSizeS, color: AppColors.textGrey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppConstants.spacingS),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingM + 2, vertical: 5),
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
                  decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
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
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(int totalPages) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingXL + 4, vertical: AppConstants.spacingL),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Page $_currentPage sur $totalPages',
            style: GoogleFonts.inter(fontSize: AppConstants.fontSizeS, color: AppColors.textSecondary),
          ),
          Row(
            children: [
              _buildPageButton(
                icon: Icons.chevron_left,
                onPressed: _currentPage > 1 ? () => setState(() => _currentPage--) : null,
              ),
              const SizedBox(width: AppConstants.spacingS),
              ..._buildPageNumbers(totalPages),
              const SizedBox(width: AppConstants.spacingS),
              _buildPageButton(
                icon: Icons.chevron_right,
                onPressed: _currentPage < totalPages ? () => setState(() => _currentPage++) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers(int totalPages) {
    List<Widget> pages = [];
    for (int i = 1; i <= totalPages; i++) {
      if (i == 1 || i == totalPages || (i >= _currentPage - 1 && i <= _currentPage + 1)) {
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
                border: Border.all(color: _currentPage == i ? AppColors.primary : AppColors.grey300),
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
            child: Text('...', style: GoogleFonts.inter(fontSize: AppConstants.fontSizeS, color: AppColors.textSecondary)),
          ),
        );
      }
    }
    return pages;
  }

  Widget _buildPageButton({required IconData icon, required VoidCallback? onPressed}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: onPressed != null ? AppColors.white : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: onPressed != null ? AppColors.grey300 : AppColors.grey200),
      ),
      child: IconButton(
        icon: Icon(icon, size: 16, color: onPressed != null ? AppColors.textPrimary : AppColors.textSecondary),
        padding: EdgeInsets.zero,
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: () {},
      backgroundColor: AppColors.success,
      elevation: 4,
      child: SvgPicture.asset(
        'assets/icons/13.svg',
        width: 24,
        height: 24,
        colorFilter: const ColorFilter.mode(AppColors.textWhite, BlendMode.srcIn),
      ),
    );
  }
}
