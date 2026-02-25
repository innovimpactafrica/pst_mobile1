class DaySchedule {
  final bool isOpen;
  final String? startTime;
  final String? endTime;

  const DaySchedule({required this.isOpen, this.startTime, this.endTime});

  DaySchedule copyWith({bool? isOpen, String? startTime, String? endTime}) {
    return DaySchedule(
      isOpen: isOpen ?? this.isOpen,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}
