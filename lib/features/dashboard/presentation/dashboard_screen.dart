import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/metric_card.dart';
import '../../../core/widgets/priority_chip.dart';
import '../../../core/widgets/profile_avatar.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/status_chip.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../jobs/domain/job.dart';
import '../../jobs/presentation/jobs_provider.dart';
import '../../notifications/presentation/notifications_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final jobsState = ref.watch(jobsControllerProvider);
    final stats = ref.watch(dashboardStatsProvider);
    final schedule = ref.watch(todaysScheduleProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider);
    final user = ref.watch(authControllerProvider).user;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(jobsControllerProvider.notifier).loadJobs(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.md, AppSpacing.md, 88),
            children: [
              Row(
                children: [
                  ProfileAvatar(name: user?.name ?? 'Alex Morgan'),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_greeting(user?.name ?? 'Alex'),
                            style: theme.textTheme.titleLarge),
                        Text(user?.title ?? 'Senior Field Technician',
                            style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    tooltip: 'Create work order',
                    onPressed: () => context.push('/jobs/new'),
                    icon: const Icon(Icons.add_task_rounded),
                  ),
                  const SizedBox(width: 4),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        tooltip: 'Notifications',
                        icon: const Icon(Icons.notifications_none_rounded),
                        onPressed: () => context.push('/notifications'),
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                                minWidth: 16, minHeight: 16),
                            child: Text(
                              '$unreadCount',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              if (jobsState.loadState == JobsLoadState.loading)
                const LoadingState(),
              if (jobsState.loadState == JobsLoadState.error)
                ErrorState(
                  message: jobsState.errorMessage ?? 'Unable to load jobs.',
                  onRetry: () =>
                      ref.read(jobsControllerProvider.notifier).loadJobs(),
                ),
              if (jobsState.loadState == JobsLoadState.loaded) ...[
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: AppSpacing.sm,
                  crossAxisSpacing: AppSpacing.sm,
                  childAspectRatio: 1.2,
                  children: [
                    MetricCard(
                      label: "Today's Jobs",
                      value: '${stats.todaysJobs}',
                      icon: Icons.today_rounded,
                      accent: AppColors.accentBlue,
                    ),
                    MetricCard(
                      label: 'Completed',
                      value: '${stats.completed}',
                      icon: Icons.check_circle_outline_rounded,
                      accent: AppColors.success,
                    ),
                    MetricCard(
                      label: 'In Progress',
                      value: '${stats.inProgress}',
                      icon: Icons.autorenew_rounded,
                      accent: AppColors.inProgress,
                    ),
                    MetricCard(
                      label: 'Pending',
                      value: '${stats.pending}',
                      icon: Icons.pending_outlined,
                      accent: AppColors.pending,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Performance', style: theme.textTheme.titleMedium),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          _PerfStat(
                              label: 'Jobs This Week',
                              value: '${stats.jobsThisWeek}'),
                          _PerfStat(
                              label: 'Completion Rate',
                              value:
                                  '${stats.completionRate.toStringAsFixed(0)}%'),
                          const _PerfStat(
                              label: 'Avg. Service', value: '1h 42m'),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        child: LinearProgressIndicator(
                          value: (stats.completionRate / 100).clamp(0, 1),
                          minHeight: 8,
                          backgroundColor: theme.dividerColor,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.accentBlue),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                SectionHeader(
                  title: "Today's Schedule",
                  actionLabel: 'View All Jobs',
                  onAction: () => context.go('/jobs'),
                ),
                const SizedBox(height: AppSpacing.sm),
                if (schedule.isEmpty)
                  const EmptyState(
                    icon: Icons.event_available_rounded,
                    title: 'No jobs scheduled today',
                    message:
                        'Enjoy the downtime, or check upcoming jobs in the Jobs tab.',
                  )
                else
                  ...schedule.map((job) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _ScheduleCard(job: job),
                      )),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _greeting(String name) {
    final firstName = name.split(' ').first;
    final hour = DateTime.now().hour;
    final part = hour < 12 ? 'Morning' : (hour < 17 ? 'Afternoon' : 'Evening');
    return 'Good $part, $firstName';
  }
}

class _PerfStat extends StatelessWidget {
  final String label;
  final String value;
  const _PerfStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: theme.textTheme.titleLarge),
          Text(label,
              style: theme.textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final Job job;
  const _ScheduleCard({required this.job});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md),
      onTap: () => context.push('/jobs/${job.id}'),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(job.scheduledTime, style: theme.textTheme.bodySmall),
                const Spacer(),
                PriorityChip(priority: job.priority),
              ],
            ),
            const SizedBox(height: 6),
            Text(job.title, style: theme.textTheme.titleSmall),
            const SizedBox(height: 2),
            Text('${job.clientName} · ${job.address}',
                style: theme.textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            StatusChip(status: job.status),
          ],
        ),
      ),
    );
  }
}
