import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../data/models/child_model.dart';
import '../../domain/bloc/child_bloc.dart';
import '../../domain/bloc/child_event.dart';

class ChildScheduleModal extends StatefulWidget {
  final ChildModel child;

  const ChildScheduleModal({super.key, required this.child});

  @override
  State<ChildScheduleModal> createState() => _ChildScheduleModalState();
}

class _ChildScheduleModalState extends State<ChildScheduleModal> {
  late Map<String, DaySchedule> _schedule;
  final List<String> _days = [
    'Lun.',
    'Mar',
    'Mer.',
    'Jeu',
    'Ven.',
    'Sam.',
    'Dim.',
  ];

  @override
  void initState() {
    super.initState();

    final Map<String, DaySchedule> childSchedule = widget.child.schedule ?? {};
    _schedule = {};

    final Map<String, String> dayMapping = {
      'Lundi': 'Lun.',
      'Mardi': 'Mar',
      'Mercredi': 'Mer.',
      'Jeudi': 'Jeu',
      'Vendredi': 'Ven.',
      'Samedi': 'Sam.',
      'Dimanche': 'Dim.',
    };

    childSchedule.forEach((day, schedule) {
      final normalizedDay = dayMapping[day] ?? day;
      _schedule[normalizedDay] = schedule;
    });

    if (_schedule.isEmpty) {
      _schedule = _getDefaultSchedule();
    } else {
      _getDefaultSchedule().forEach((day, defaultSchedule) {
        if (!_schedule.containsKey(day)) {
          _schedule[day] = defaultSchedule;
        }
      });
    }

    debugPrint(' [ScheduleModal] Initialized schedule: $_schedule');
  }

  Map<String, DaySchedule> _getDefaultSchedule() {
    return {
      'Lun.': DaySchedule(isOpen: true, startTime: '09:00', endTime: '18:00'),
      'Mar': DaySchedule(isOpen: true, startTime: '09:00', endTime: '18:00'),
      'Mer.': DaySchedule(isOpen: true, startTime: '09:00', endTime: '18:00'),
      'Jeu': DaySchedule(isOpen: true, startTime: '09:00', endTime: '18:00'),
      'Ven.': DaySchedule(isOpen: true, startTime: '09:00', endTime: '18:00'),
      'Sam.': DaySchedule(isOpen: false),
      'Dim.': DaySchedule(isOpen: false),
    };
  }

  void _toggleDay(String day) {
    setState(() {
      final current = _schedule[day];
      if (current == null) {
        _schedule[day] = DaySchedule(
          isOpen: true,
          startTime: '09:00',
          endTime: '18:00',
        );
      } else {
        _schedule[day] = current.copyWith(isOpen: !current.isOpen);
      }
    });
  }

  Future<void> _selectTime(String day, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.success),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        final timeString =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';

        final current = _schedule[day];

        if (current == null) {
          _schedule[day] = DaySchedule(
            isOpen: true,
            startTime: isStart ? timeString : '09:00',
            endTime: !isStart ? timeString : '18:00',
          );
        } else {
          _schedule[day] = current.copyWith(
            startTime: isStart ? timeString : current.startTime,
            endTime: !isStart ? timeString : current.endTime,
          );
        }
      });
    }
  }

  void _handleSave() {
    debugPrint(
      ' [ScheduleModal] Saving schedule for child: ${widget.child.id}',
    );
    debugPrint(' [ScheduleModal] Schedule (ONLY abbreviated days): $_schedule');

    context.read<ChildBloc>().add(
      UpdateChildScheduleEvent(childId: widget.child.id, schedule: _schedule),
    );

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTableHeader(),
                  const SizedBox(height: 8),
                  ..._days.map((day) => _buildDayRow(day)),
                  const SizedBox(height: 24),
                  _buildSaveButton(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'schedule_for'.tr(args: [widget.child.fullName]),
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.close, color: Colors.grey.shade600, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(
              'day'.tr(),
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                'availability'.tr(),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'departure'.tr(),
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'return'.tr(),
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayRow(String day) {
    final schedule = _schedule[day] ?? DaySchedule(isOpen: false);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade200, width: 0.5),
      ),
      child: Row(
        children: [
          // COLONNE JOUR
          SizedBox(
            width: 48,
            child: Text(
              day,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),

          // COLONNE DISPONIBILITÉ
          Expanded(
            flex: 3,
            child: Row(
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: Checkbox(
                    value: schedule.isOpen,
                    onChanged: (_) => _toggleDay(day),
                    activeColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3),
                    ),
                    side: BorderSide(color: Colors.grey.shade400, width: 1.5),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  schedule.isOpen ? 'open'.tr() : 'closed'.tr(),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),

          // COLONNE DÉPART
          Expanded(
            flex: 2,
            child: _buildTimeDisplay(
              time: schedule.startTime,
              isEnabled: schedule.isOpen,
              onTap: schedule.isOpen ? () => _selectTime(day, true) : null,
            ),
          ),

          Expanded(
            flex: 2,
            child: _buildTimeDisplay(
              time: schedule.endTime,
              isEnabled: schedule.isOpen,
              onTap: schedule.isOpen ? () => _selectTime(day, false) : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeDisplay({
    String? time,
    required bool isEnabled,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey.shade300, width: 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.access_time,
              size: 14,
              color: isEnabled ? const Color(0xFFFF6B6B) : Colors.grey.shade300,
            ),
            const SizedBox(width: 4),
            Text(
              time ?? '00:00',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isEnabled
                    ? (time != null ? Colors.black87 : Colors.grey.shade400)
                    : Colors.grey.shade300,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _handleSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.success,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
        child: Text(
          'update'.tr(),
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
