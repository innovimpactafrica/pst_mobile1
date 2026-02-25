import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import '../../../../../core/utils/app_colors.dart';

class TripFiltersModal extends StatefulWidget {
  final Function(Map<String, dynamic>) onApplyFilters;

  const TripFiltersModal({super.key, required this.onApplyFilters});

  @override
  State<TripFiltersModal> createState() => _TripFiltersModalState();
}

class _TripFiltersModalState extends State<TripFiltersModal> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedSchool;
  String _selectedStatus = 'Tous';

  final List<String> _statusOptions = [
    'Tous',
    'En attente',
    'En cours',
    'Terminé',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'advanced_filters'.tr(),
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date
                  _buildSectionTitle('trip_date'.tr()),
                  const SizedBox(height: 12),
                  _buildDatePicker(),

                  const SizedBox(height: 24),

                  // Heure
                  _buildSectionTitle('departure_time'.tr()),
                  const SizedBox(height: 12),
                  _buildTimePicker(),

                  const SizedBox(height: 24),

                  // Statut
                  _buildSectionTitle('status'.tr()),
                  const SizedBox(height: 12),
                  _buildStatusChips(),

                  const SizedBox(height: 24),

                  // École
                  _buildSectionTitle('school'.tr()),
                  const SizedBox(height: 12),
                  _buildSchoolField(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Buttons
          // Buttons
          Container(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              20 + MediaQuery.of(context).padding.bottom,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _resetFilters,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'reset'.tr(),
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'apply'.tr(),
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) {
          setState(() => _selectedDate = date);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today,
              size: 20,
              color: AppColors.primary,
            ),
            const SizedBox(width: 12),
            Text(
              _selectedDate != null
                  ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                  : 'select_date'.tr(),
              style: GoogleFonts.inter(
                fontSize: 14,
                color: _selectedDate != null
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            if (_selectedDate != null)
              GestureDetector(
                onTap: () => setState(() => _selectedDate = null),
                child: const Icon(Icons.close, size: 18),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return GestureDetector(
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: _selectedTime ?? TimeOfDay.now(),
        );
        if (time != null) {
          setState(() => _selectedTime = time);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, size: 20, color: AppColors.primary),
            const SizedBox(width: 12),
            Text(
              _selectedTime != null
                  ? _selectedTime!.format(context)
                  : 'select_time'.tr(),
              style: GoogleFonts.inter(
                fontSize: 14,
                color: _selectedTime != null
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            if (_selectedTime != null)
              GestureDetector(
                onTap: () => setState(() => _selectedTime = null),
                child: const Icon(Icons.close, size: 18),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _statusOptions.map((status) {
        final isSelected = _selectedStatus == status;
        return GestureDetector(
          onTap: () => setState(() => _selectedStatus = status),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? AppColors.white : AppColors.textPrimary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSchoolField() {
    return TextField(
      onChanged: (value) => _selectedSchool = value,
      decoration: InputDecoration(
        hintText: 'school_name'.tr(),
        prefixIcon: const Icon(
          Icons.school,
          size: 20,
          color: AppColors.primary,
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedDate = null;
      _selectedTime = null;
      _selectedSchool = null;
      _selectedStatus = 'Tous';
    });
  }

  void _applyFilters() {
    widget.onApplyFilters({
      'date': _selectedDate,
      'time': _selectedTime,
      'school': _selectedSchool,
      'status': _selectedStatus,
    });
    Navigator.pop(context);
  }
}
