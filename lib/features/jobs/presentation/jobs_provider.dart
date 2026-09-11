import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/repository_providers.dart';
import '../domain/job.dart';

enum JobsLoadState { loading, loaded, error }

class JobsState {
  final JobsLoadState loadState;
  final List<Job> jobs;
  final String? errorMessage;

  const JobsState({
    this.loadState = JobsLoadState.loading,
    this.jobs = const [],
    this.errorMessage,
  });

  JobsState copyWith(
      {JobsLoadState? loadState, List<Job>? jobs, String? errorMessage}) {
    return JobsState(
      loadState: loadState ?? this.loadState,
      jobs: jobs ?? this.jobs,
      errorMessage: errorMessage,
    );
  }
}

/// Single source of truth for job data. All screens (dashboard, jobs
/// list, job details, activity) read from this controller so status
/// changes are reflected everywhere immediately.
class JobsController extends StateNotifier<JobsState> {
  final Ref ref;
  JobsController(this.ref) : super(const JobsState()) {
    loadJobs();
  }

  Future<void> loadJobs() async {
    state = state.copyWith(loadState: JobsLoadState.loading);
    try {
      final repo = ref.read(jobRepositoryProvider);
      final jobs = await repo.getJobs();
      state = JobsState(loadState: JobsLoadState.loaded, jobs: jobs);
    } catch (e) {
      state =
          JobsState(loadState: JobsLoadState.error, errorMessage: e.toString());
    }
  }

  Job? jobById(String id) {
    try {
      return state.jobs.firstWhere((j) => j.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> startJob(String id) async {
    final repo = ref.read(jobRepositoryProvider);
    final updated = await repo.startJob(id);
    _replaceJob(updated);
  }

  Future<void> completeJob(String id, {required String completionNote}) async {
    final repo = ref.read(jobRepositoryProvider);
    final updated = await repo.completeJob(id, completionNote: completionNote);
    _replaceJob(updated);
  }

  Future<void> addNote(String id, String note) async {
    final repo = ref.read(jobRepositoryProvider);
    final updated = await repo.addJobNote(id, note);
    _replaceJob(updated);
  }

  Future<void> updateChecklistItem(
      String id, String checklistItemId, bool isDone) async {
    final repo = ref.read(jobRepositoryProvider);
    final updated = await repo.updateChecklist(id, checklistItemId, isDone);
    _replaceJob(updated);
  }

  Future<void> addAttachment(String id, String path) async {
    final repo = ref.read(jobRepositoryProvider);
    final updated = await repo.addAttachment(id, path);
    _replaceJob(updated);
  }

  void _replaceJob(Job updated) {
    final jobs =
        state.jobs.map((j) => j.id == updated.id ? updated : j).toList();
    state = state.copyWith(jobs: jobs);
  }
}

final jobsControllerProvider = StateNotifierProvider<JobsController, JobsState>(
    (ref) => JobsController(ref));

/// Dashboard KPI numbers derived from live job state.
class DashboardStats {
  final int todaysJobs;
  final int completed;
  final int inProgress;
  final int pending;
  final int jobsThisWeek;
  final double completionRate;

  const DashboardStats({
    required this.todaysJobs,
    required this.completed,
    required this.inProgress,
    required this.pending,
    required this.jobsThisWeek,
    required this.completionRate,
  });
}

final dashboardStatsProvider = Provider<DashboardStats>((ref) {
  final jobs = ref.watch(jobsControllerProvider).jobs;
  final now = DateTime.now();
  bool isToday(DateTime d) =>
      d.year == now.year && d.month == now.month && d.day == now.day;
  bool isThisWeek(DateTime d) => now.difference(d).inDays.abs() <= 7;

  final todays = jobs.where((j) => isToday(j.scheduledDate)).toList();
  final completed = todays.where((j) => j.status == JobStatus.completed).length;
  final inProgress =
      todays.where((j) => j.status == JobStatus.inProgress).length;
  final pending = todays.where((j) => j.status == JobStatus.pending).length;

  final weekly = jobs.where((j) => isThisWeek(j.scheduledDate)).toList();
  final weeklyCompleted =
      weekly.where((j) => j.status == JobStatus.completed).length;
  final completionRate =
      weekly.isEmpty ? 0.0 : (weeklyCompleted / weekly.length) * 100;

  return DashboardStats(
    todaysJobs: todays.length,
    completed: completed,
    inProgress: inProgress,
    pending: pending,
    jobsThisWeek: weekly.length,
    completionRate: completionRate,
  );
});

final todaysScheduleProvider = Provider<List<Job>>((ref) {
  final jobs = ref.watch(jobsControllerProvider).jobs;
  final now = DateTime.now();
  final todays = jobs
      .where((j) =>
          j.scheduledDate.year == now.year &&
          j.scheduledDate.month == now.month &&
          j.scheduledDate.day == now.day)
      .toList();
  todays.sort((a, b) =>
      a.status == b.status ? 0 : (a.status == JobStatus.completed ? 1 : -1));
  return todays;
});
