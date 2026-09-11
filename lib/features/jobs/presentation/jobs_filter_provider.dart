import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/job.dart';
import 'jobs_provider.dart';

enum JobFilter { all, today, pending, inProgress, completed }

extension JobFilterLabel on JobFilter {
  String get label {
    switch (this) {
      case JobFilter.all:
        return 'All';
      case JobFilter.today:
        return 'Today';
      case JobFilter.pending:
        return 'Pending';
      case JobFilter.inProgress:
        return 'In Progress';
      case JobFilter.completed:
        return 'Completed';
    }
  }
}

final jobSearchQueryProvider = StateProvider<String>((ref) => '');
final jobFilterProvider = StateProvider<JobFilter>((ref) => JobFilter.all);

final filteredJobsProvider = Provider<List<Job>>((ref) {
  final jobs = ref.watch(jobsControllerProvider).jobs;
  final query = ref.watch(jobSearchQueryProvider).trim().toLowerCase();
  final filter = ref.watch(jobFilterProvider);
  final now = DateTime.now();

  var result = jobs.where((j) {
    switch (filter) {
      case JobFilter.all:
        return true;
      case JobFilter.today:
        return j.scheduledDate.year == now.year &&
            j.scheduledDate.month == now.month &&
            j.scheduledDate.day == now.day;
      case JobFilter.pending:
        return j.status == JobStatus.pending;
      case JobFilter.inProgress:
        return j.status == JobStatus.inProgress;
      case JobFilter.completed:
        return j.status == JobStatus.completed;
    }
  }).toList();

  if (query.isNotEmpty) {
    result = result.where((j) {
      return j.title.toLowerCase().contains(query) ||
          j.clientName.toLowerCase().contains(query) ||
          j.id.toLowerCase().contains(query) ||
          j.address.toLowerCase().contains(query);
    }).toList();
  }

  result.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
  return result;
});
