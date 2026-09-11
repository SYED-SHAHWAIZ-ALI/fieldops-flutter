import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/timeline_item.dart';
import '../../jobs/presentation/jobs_provider.dart';

class _FeedEntry {
  final String description;
  final String jobId;
  final String clientName;
  final DateTime timestamp;
  final IconData icon;
  final Color accent;

  _FeedEntry({
    required this.description,
    required this.jobId,
    required this.clientName,
    required this.timestamp,
    required this.icon,
    required this.accent,
  });
}

 IconData _iconFor(String description) {
  final d = description.toLowerCase();
  if (d.contains('started')) return Icons.play_circle_outline_rounded;
  if (d.contains('completed')) return Icons.check_circle_outline_rounded;
  if (d.contains('photo') || d.contains('attached')) {
    return Icons.photo_camera_outlined;
  }
  if (d.contains('note')) return Icons.edit_note_rounded;
  if (d.contains('arrived')) return Icons.person_pin_circle_outlined;
  if (d.contains('checklist')) return Icons.checklist_rounded;
  return Icons.circle_notifications_outlined;
}

Color _accentFor(String description) {
  final d = description.toLowerCase();
  if (d.contains('completed')) return AppColors.success;
  if (d.contains('started') || d.contains('arrived')) return AppColors.accentBlue;
  if (d.contains('photo') || d.contains('attached')) return AppColors.warning;
  if (d.contains('note') || d.contains('checklist')) return AppColors.indigo;
  return AppColors.pending;
}

class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobs = ref.watch(jobsControllerProvider).jobs;

    final entries = <_FeedEntry>[];
    for (final job in jobs) {
      for (final a in job.activity) {
        entries.add(_FeedEntry(
          description: a.description,
          jobId: job.id,
          clientName: job.clientName,
          timestamp: a.timestamp,
          icon: _iconFor(a.description),
          accent: _accentFor(a.description),
        ));
      }
    }
    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final now = DateTime.now();
    bool isSameDay(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;

    final today = entries.where((e) => isSameDay(e.timestamp, now)).toList();
    final yesterday = entries
        .where((e) =>
            isSameDay(e.timestamp, now.subtract(const Duration(days: 1))))
        .toList();
    final earlier = entries
        .where((e) =>
            !isSameDay(e.timestamp, now) &&
            !isSameDay(e.timestamp, now.subtract(const Duration(days: 1))))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity'),
        actions: [
          if (entries.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: Center(
                child: Text('${entries.length} events',
                    style: Theme.of(context).textTheme.bodySmall),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: entries.isEmpty
            ? const EmptyState(
                icon: Icons.history_rounded,
                title: 'No activity yet',
                message: 'Job updates, notes, and photos will appear here.',
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm,
                    AppSpacing.md, AppSpacing.xxl),
                children: [
                  if (today.isNotEmpty) _Group(title: 'Today', entries: today),
                  if (yesterday.isNotEmpty)
                    _Group(title: 'Yesterday', entries: yesterday),
                  if (earlier.isNotEmpty)
                    _Group(title: 'Earlier', entries: earlier),
                ],
              ),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  final String title;
  final List<_FeedEntry> entries;
  const _Group({required this.title, required this.entries});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(title.toUpperCase(), style: theme.textTheme.labelSmall),
          ),
          for (var i = 0; i < entries.length; i++)
            TimelineItem(
              icon: entries[i].icon,
              accent: entries[i].accent,
              title: entries[i].description,
              subtitle: '${entries[i].jobId} · ${entries[i].clientName}',
              time: DateFormat('h:mm a').format(entries[i].timestamp),
              isLast: i == entries.length - 1,
            ),
        ],
      ),
    );
  }
}