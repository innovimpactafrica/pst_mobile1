import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:private_school/core/utils/app_colors.dart';

class TripFilterModal extends StatefulWidget {
  final Function(TripFilters) onApplyFilters;
  final TripFilters? currentFilters;

  const TripFilterModal({
    super.key,
    required this.onApplyFilters,
    this.currentFilters,
  });

  @override
  State<TripFilterModal> createState() => _TripFilterModalState();
}

class _TripFilterModalState extends State<TripFilterModal> {
  TimeOfDay? _departureTime;
  TimeOfDay? _returnTime;
  String? _destination;
  final TextEditingController _destinationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.currentFilters != null) {
      _departureTime = widget.currentFilters!.departureTime;
      _returnTime = widget.currentFilters!.returnTime;
      _destination = widget.currentFilters!.destination;
      _destinationController.text = _destination ?? '';
    }
  }

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          _buildHeader(),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTimeFilter(
                    label: 'departure_time'.tr(),
                    time: _departureTime,
                    onTap: () => _selectTime(true),
                    onClear: () => setState(() => _departureTime = null),
                  ),
                  const SizedBox(height: 16),
                  _buildTimeFilter(
                    label: 'return_time'.tr(),
                    time: _returnTime,
                    onTap: () => _selectTime(false),
                    onClear: () => setState(() => _returnTime = null),
                  ),
                  const SizedBox(height: 16),
                  _buildDestinationFilter(),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _resetFilters,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: AppColors.error),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'reset'.tr(),
                            style: GoogleFonts.inter(
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _applyFilters,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'apply'.tr(),
                            style: GoogleFonts.inter(
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.grey300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E5E5))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'filter_trips'.tr(),
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.close, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeFilter({
    required String label,
    required TimeOfDay? time,
    required VoidCallback onTap,
    required VoidCallback onClear,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    time != null
                        ? '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'
                        : 'select_time'.tr(),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: time != null
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                if (time != null)
                  GestureDetector(
                    onTap: onClear,
                    child: const Icon(
                      Icons.clear,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDestinationFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'destination'.tr(),
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _destinationController,
          decoration: InputDecoration(
            hintText: 'destination_example'.tr(),
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            prefixIcon: const Icon(
              Icons.location_on_outlined,
              color: AppColors.textSecondary,
              size: 20,
            ),
            suffixIcon: _destinationController.text.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      setState(() {
                        _destinationController.clear();
                        _destination = null;
                      });
                    },
                    child: const Icon(
                      Icons.clear,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  )
                : null,
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          onChanged: (value) {
            setState(() {
              _destination = value.isEmpty ? null : value;
            });
          },
        ),
      ],
    );
  }

  Future<void> _selectTime(bool isDeparture) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime:
          (isDeparture ? _departureTime : _returnTime) ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.success,
              onPrimary: AppColors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isDeparture) {
          _departureTime = picked;
        } else {
          _returnTime = picked;
        }
      });
    }
  }

  void _resetFilters() {
    setState(() {
      _departureTime = null;
      _returnTime = null;
      _destination = null;
      _destinationController.clear();
    });
  }

  void _applyFilters() {
    final filters = TripFilters(
      departureTime: _departureTime,
      returnTime: _returnTime,
      destination: _destination,
    );
    widget.onApplyFilters(filters);
    Navigator.pop(context);
  }
}

class TripFilters {
  final TimeOfDay? departureTime;
  final TimeOfDay? returnTime;
  final String? destination;

  TripFilters({this.departureTime, this.returnTime, this.destination});

  bool get hasFilters =>
      departureTime != null || returnTime != null || destination != null;
}
