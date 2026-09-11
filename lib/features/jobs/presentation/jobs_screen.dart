import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/empty_state.dart';
import 'jobs_filter_provider.dart';
import 'jobs_provider.dart';
import 'widgets/job_card.dart';

class JobsScreen extends ConsumerStatefulWidget {
  const JobsScreen({super.key});

  @override
  ConsumerState<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends ConsumerState<JobsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final jobsState = ref.watch(jobsControllerProvider);
    final filteredJobs = ref.watch(filteredJobsProvider);
    final activeFilter = ref.watch(jobFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jobs'),
        actions: [
          IconButton(
            tooltip: 'Create work order',
            onPressed: () => context.push('/jobs/new'),
            icon: const Icon(Icons.add_task_rounded),
          ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/jobs/new'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Job'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                0,
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {});
                  ref.read(jobSearchQueryProvider.notifier).state = value;
                },
                decoration: InputDecoration(
                  hintText: 'Search jobs, clients, locations…',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(jobSearchQueryProvider.notifier).state =
                                '';
                            setState(() {});
                          },
                        ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                itemCount: JobFilter.values.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = JobFilter.values[index];
                  final selected = filter == activeFilter;
                  return ChoiceChip(
                    label: Text(filter.label),
                    selected: selected,
                    onSelected: (_) =>
                        ref.read(jobFilterProvider.notifier).state = filter,
                    selectedColor:
                        theme.colorScheme.secondary.withValues(alpha: 0.15),
                    labelStyle: TextStyle(
                      color: selected ? theme.colorScheme.secondary : null,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (jobsState.loadState == JobsLoadState.loading) {
                    return const LoadingState();
                  }
                  if (jobsState.loadState == JobsLoadState.error) {
                    return ErrorState(
                      message: jobsState.errorMessage ?? 'Unable to load jobs.',
                      onRetry: () =>
                          ref.read(jobsControllerProvider.notifier).loadJobs(),
                    );
                  }
                  if (filteredJobs.isEmpty) {
                    return const EmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'No matching jobs',
                      message: 'Try a different search term or filter.',
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () =>
                        ref.read(jobsControllerProvider.notifier).loadJobs(),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        0,
                        AppSpacing.md,
                        104,
                      ),
                      itemCount: filteredJobs.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final job = filteredJobs[index];
                        return JobCard(
                          job: job,
                          onTap: () => context.push('/jobs/${job.id}'),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
