// Reusable Floating Action Button for reporting problems
// Path: lib/chauffeurs/widgets/report_problem_fab.dart

import 'package:flutter/material.dart';
import 'package:private_school/core/utils/app_colors.dart';
import 'report_problem_modal.dart';

class ReportProblemFAB extends StatelessWidget {
  const ReportProblemFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 90, // Above bottom navigation bar
      right: 20,
      child: FloatingActionButton(
        backgroundColor: AppColors.primary,
        elevation: 6,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const ReportProblemModal(),
          );
        },
        child: const Icon(
          Icons.add,
          color: AppColors.white,
          size: 28,
        ),
      ),
    );
  }
}