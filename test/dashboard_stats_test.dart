import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fieldops/features/jobs/domain/job.dart';
import 'package:fieldops/features/jobs/presentation/jobs_filter_provider.dart';
import 'package:fieldops/features/jobs/presentation/jobs_provider.dart';

Future<void> _pumpMicrotasks() =>
    Future.delayed(const Duration(milliseconds: 700));

/// Triggers the lazy [JobsController] initial load and lets the mock
/// repository's async fetch settle before the test asserts on state.
Future<void> _primeJobs(ProviderContainer container) async {
  container.read(jobsControllerProvider);
  await _pumpMicrotasks();
  await _pumpMicrotasks();
}

void main() {
  group('Dashboard statistics react to job completion', () {
    test(
        'completing a today job increases completed count and decreases pending',
        () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await _primeJobs(container);

      final statsBefore = container.read(dashboardStatsProvider);
      final todaysJobs = container.read(todaysScheduleProvider);
      final pendingToday =
          todaysJobs.firstWhere((j) => j.status == JobStatus.pending);

      final controller = container.read(jobsControllerProvider.notifier);
      await controller.startJob(pendingToday.id);

      var job = container
          .read(jobsControllerProvider)
          .jobs
          .firstWhere((j) => j.id == pendingToday.id);
      for (final item in job.checklist) {
        await controller.updateChecklistItem(job.id, item.id, true);
      }
      await controller.completeJob(job.id,
          completionNote: 'Completed for test');

      final statsAfter = container.read(dashboardStatsProvider);

      expect(statsAfter.completed, statsBefore.completed + 1);
      expect(statsAfter.pending, statsBefore.pending - 1);
    });
  });

  group('Job filtering and search', () {
    test('filtering by "Completed" only returns completed jobs', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await _primeJobs(container);

      container.read(jobFilterProvider.notifier).state = JobFilter.completed;
      final filtered = container.read(filteredJobsProvider);

      expect(filtered, isNotEmpty);
      expect(filtered.every((j) => j.status == JobStatus.completed), isTrue);
    });

    test('searching narrows results across all filters', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await _primeJobs(container);

      container.read(jobSearchQueryProvider.notifier).state = 'Nexus';
      final filtered = container.read(filteredJobsProvider);

      expect(filtered, isNotEmpty);
      expect(filtered.every((j) => j.clientName.contains('Nexus')), isTrue);
    });
  });
}
