import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../features/jobs/domain/job.dart';

class PriorityChip extends StatelessWidget {
  final JobPriority priority;
  const PriorityChip({super.key, required this.priority});

  Color get _color {
    switch (priority) {
      case JobPriority.low:
        return AppColors.priorityLow;
      case JobPriority.medium:
        return AppColors.priorityMedium;
      case JobPriority.high:
        return AppColors.priorityHigh;
      case JobPriority.urgent:
        return AppColors.priorityUrgent;
    }
  }

  String get _label {
    switch (priority) {
      case JobPriority.low:
        return 'LOW';
      case JobPriority.medium:
        return 'MEDIUM';
      case JobPriority.high:
        return 'HIGH';
      case JobPriority.urgent:
        return 'URGENT';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: _color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
          ),
          Text(
            _label,
            style: TextStyle(
              color: _color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
