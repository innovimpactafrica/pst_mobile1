import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:private_school/core/utils/app_colors.dart';
import 'package:private_school/core/utils/app_constants.dart';
import '../../domain/bloc/report_bloc.dart';
import '../../domain/bloc/report_event.dart';
import '../../domain/bloc/report_state.dart';
import '../widgets/report_card_widget.dart';
import '../widgets/report_problem_modal.dart';
import 'report_detail_page.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';

  final List<String> _filters = ['all', 'incident', 'disputes', 'security'];

  @override
  void initState() {
    super.initState();
    context.read<ReportBloc>().add(LoadReportsEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.success,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppConstants.radiusXXL),
                    topRight: Radius.circular(AppConstants.radiusXXL),
                  ),
                ),
                child: Column(
                  children: [
                    _buildSearchBar(),
                    _buildFilterChips(),
                    Expanded(child: _buildReportsList()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingXL + 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spacingL),
          Expanded(
            child: Text(
              'reports',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ).tr(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingXL),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          context.read<ReportBloc>().add(SearchReportsEvent(value));
        },
        decoration: InputDecoration(
          hintText: 'search'.tr(),
          hintStyle: GoogleFonts.inter(
            color: AppColors.textSecondary.withValues(alpha: 0.5),
            fontSize: AppConstants.fontSizeM,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusXL),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingL,
            vertical: AppConstants.spacingM,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingXL),
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: AppConstants.spacingM),
            child: FilterChip(
              showCheckmark: false,
              label: Text(
                filter.tr(),
                style: GoogleFonts.inter(
                  fontSize: AppConstants.fontSizeM,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.white : AppColors.textPrimary,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
                context.read<ReportBloc>().add(FilterReportsEvent(filter));
              },
              backgroundColor: AppColors.white,
              selectedColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusXL),
                side: BorderSide.none,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingL,
                vertical: AppConstants.spacingS,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReportsList() {
    return BlocListener<ReportBloc, ReportState>(
      listener: (context, state) {
        if (state is ReportDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('report_deleted_successfully'.tr()),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is ReportError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: BlocBuilder<ReportBloc, ReportState>(
        builder: (context, state) {
          if (state is ReportLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.success),
            );
          }

          if (state is ReportError) {
            return _buildErrorState(state.message);
          }

          if (state is ReportsLoaded) {
            if (state.filteredReports.isEmpty) {
              return _buildEmptyState();
            }

            return Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    color: AppColors.success,
                    onRefresh: () async {
                      context.read<ReportBloc>().add(RefreshReportsEvent());
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(AppConstants.spacingXL),
                      itemCount: state.filteredReports.length,
                      itemBuilder: (context, index) {
                        return ReportCardWidget(
                          report: state.filteredReports[index],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReportDetailPage(
                                  report: state.filteredReports[index],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                if (state.totalPages > 1) _buildPaginationTabs(state),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildPaginationTabs(ReportsLoaded state) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(state.totalPages, (index) {
          final pageNumber = index + 1;
          final isCurrentPage = pageNumber == state.currentPage;

          return GestureDetector(
            onTap: isCurrentPage || state.isLoadingMore
                ? null
                : () {
                    context.read<ReportBloc>().add(LoadPageEvent(pageNumber));
                  },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isCurrentPage ? AppColors.primary : AppColors.white,
                border: Border.all(
                  color: isCurrentPage ? AppColors.primary : AppColors.grey400,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$pageNumber',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isCurrentPage
                      ? AppColors.white
                      : AppColors.textPrimary,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open_outlined,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppConstants.spacingL),
          Text(
            'no_reports'.tr(),
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeL,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppConstants.spacingS),
          Text(
            'your_reports_will_appear_here'.tr(),
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeM,
              color: AppColors.textSecondary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: AppConstants.spacingL),
          Text(
            'loading_error'.tr(),
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeL,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.spacingS),
          Text(
            message,
            style: GoogleFonts.inter(
              fontSize: AppConstants.fontSizeM,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingXL),
          ElevatedButton(
            onPressed: () {
              context.read<ReportBloc>().add(LoadReportsEvent());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingXXL,
                vertical: AppConstants.spacingM,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
              ),
            ),
            child: Text(
              'retry'.tr(),
              style: GoogleFonts.inter(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => const ReportProblemModal(),
        );
      },
      backgroundColor: AppColors.success,
      child: SvgPicture.asset(
        'assets/icons/13.svg',
        colorFilter: const ColorFilter.mode(AppColors.white, BlendMode.srcIn),
        width: 28,
        height: 28,
      ),
    );
  }
}
