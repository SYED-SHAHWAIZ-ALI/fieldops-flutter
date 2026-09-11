import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../features/jobs/domain/job.dart';

class StatusChip extends StatelessWidget {
  final JobStatus status;
  const StatusChip({super.key, required this.status});

  Color get _color {
    switch (status) {
      case JobStatus.pending:
        return AppColors.pending;
      case JobStatus.inProgress:
        return AppColors.inProgress;
      case JobStatus.completed:
        return AppColors.success;
    }
  }

  String get _label {
    switch (status) {
      case JobStatus.pending:
        return 'PENDING';
      case JobStatus.inProgress:
        return 'IN PROGRESS';
      case JobStatus.completed:
        return 'COMPLETED';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _label,
        style: TextStyle(
          color: _color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
