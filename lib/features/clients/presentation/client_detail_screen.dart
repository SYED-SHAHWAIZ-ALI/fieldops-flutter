import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/status_chip.dart';
import '../../jobs/presentation/jobs_provider.dart';
import 'clients_provider.dart';

class ClientDetailScreen extends ConsumerWidget {
  final String clientId;
  const ClientDetailScreen({super.key, required this.clientId});

  void _feedback(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final clientAsync = ref.watch(clientByIdProvider(clientId));
    final jobs = ref
        .watch(jobsControllerProvider)
        .jobs
        .where((j) => j.clientId == clientId)
        .toList();
    final liveStats = ref.watch(clientLiveJobStatsProvider(clientId));

    return Scaffold(
      appBar: AppBar(title: const Text('Client Details')),
      body: SafeArea(
        child: clientAsync.when(
          loading: () => const LoadingState(),
          error: (e, _) => const ErrorState(message: 'Unable to load client.'),
          data: (client) {
            if (client == null) {
              return const EmptyState(
                icon: Icons.error_outline_rounded,
                title: 'Client not found',
                message: 'This client may have been removed.',
              );
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xxl),
              children: [
                Text(client.companyName, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text(client.contactName, style: theme.textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    _ActionTile(
                      icon: Icons.call_outlined,
                      label: 'Call',
                      accent: AppColors.success,
                      onTap: () =>
                          _feedback(context, 'Calling ${client.contactName}'),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _ActionTile(
                      icon: Icons.message_outlined,
                      label: 'Message',
                      accent: AppColors.accentBlue,
                      onTap: () => _feedback(
                          context, 'Opening message to ${client.contactName}'),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _ActionTile(
                      icon: Icons.directions_outlined,
                      label: 'Directions',
                      accent: AppColors.warning,
                      onTap: () => _feedback(
                          context, 'Opening directions to ${client.address}'),
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
                      _Row(label: 'Phone', value: client.phone),
                      _Row(label: 'Email', value: client.email),
                      _Row(label: 'Address', value: client.address),
                      _Row(
                          label: 'Active Work Orders',
                          value: '${liveStats.active}'),
                      _Row(
                        label: 'Completed in Demo',
                        value: '${liveStats.completedInDemo}',
                      ),
                      _Row(
                        label: 'Historical Completed',
                        value: '${client.completedJobs}',
                        isLast: true,
                      ),
                    ],
                  ),
                ),
                if (client.notes.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Text('NOTES', style: theme.textTheme.labelSmall),
                  const SizedBox(height: AppSpacing.sm),
                  Text(client.notes, style: theme.textTheme.bodyMedium),
                ],
                const SizedBox(height: AppSpacing.lg),
                Text('JOB HISTORY', style: theme.textTheme.labelSmall),
                const SizedBox(height: AppSpacing.sm),
                if (jobs.isEmpty)
                  Text('No jobs on record yet.',
                      style: theme.textTheme.bodySmall)
                else
                  ...jobs.map((job) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          onTap: () => context.push('/jobs/${job.id}'),
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: theme.cardTheme.color,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(color: theme.dividerColor),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(job.title,
                                          style: theme.textTheme.titleSmall),
                                      Text(job.id,
                                          style: theme.textTheme.bodySmall),
                                    ],
                                  ),
                                ),
                                StatusChip(status: job.status),
                              ],
                            ),
                          ),
                        ),
                      )),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accent;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1.1,
        child: Material(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.md),
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: accent, size: 20),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;
  const _Row({required this.label, required this.value, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.sm),
      child: Row(
        children: [
          SizedBox(
              width: 120, child: Text(label, style: theme.textTheme.bodySmall)),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
