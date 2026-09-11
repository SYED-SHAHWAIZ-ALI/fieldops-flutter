import 'package:flutter_test/flutter_test.dart';
import 'package:fieldops/features/jobs/data/mock_job_repository.dart';
import 'package:fieldops/features/jobs/domain/job.dart';
import 'package:fieldops/features/jobs/domain/job_repository.dart';

void main() {
  group('MockJobRepository status transitions', () {
    late MockJobRepository repository;

    setUp(() {
      repository = MockJobRepository();
    });

    test('creating a work order generates a pending job with audit metadata',
        () async {
      final before = await repository.getJobs();
      final created = await repository.createJob(
        CreateJobInput(
          title: 'AC Compressor Inspection',
          description: 'Inspect compressor condition and cooling performance.',
          clientId: 'CLI-001',
          clientName: 'Apex Industries',
          contactName: 'Ahmed Raza',
          contactPhone: '+92 300 1234567',
          address: 'Gulshan-e-Iqbal, Karachi',
          scheduledDate: DateTime.now(),
          scheduledTime: '11:00 AM',
          estimatedDuration: '2 hours',
          priority: JobPriority.high,
          assignedTechnician: 'Alex Morgan',
        ),
      );

      final after = await repository.getJobs();
      expect(after.length, before.length + 1);
      expect(created.id, startsWith('JOB-'));
      expect(created.status, JobStatus.pending);
      expect(created.clientName, 'Apex Industries');
      expect(created.checklist, isNotEmpty);
      expect(created.activity.last.description, 'Work order created');
    });

    test('a pending job can be started and becomes in progress', () async {
      final jobs = await repository.getJobs();
      final pendingJob = jobs.firstWhere((j) => j.status == JobStatus.pending);

      final started = await repository.startJob(pendingJob.id);

      expect(started.status, JobStatus.inProgress);
      expect(started.activity.last.description, 'Job started');
    });

    test('starting a job that is not pending throws a validation exception',
        () async {
      final jobs = await repository.getJobs();
      final completedJob =
          jobs.firstWhere((j) => j.status == JobStatus.completed);

      expect(
        () => repository.startJob(completedJob.id),
        throwsA(isA<JobValidationException>()),
      );
    });

    test('completing a job requires a completion note', () async {
      final jobs = await repository.getJobs();
      final pendingJob = jobs.firstWhere((j) => j.status == JobStatus.pending);
      final started = await repository.startJob(pendingJob.id);

      expect(
        () => repository.completeJob(started.id, completionNote: ''),
        throwsA(isA<JobValidationException>()),
      );
    });

    test('completing a job requires all required checklist items to be done',
        () async {
      final jobs = await repository.getJobs();
      final pendingJob = jobs.firstWhere((j) => j.status == JobStatus.pending);
      final started = await repository.startJob(pendingJob.id);

      expect(
        () =>
            repository.completeJob(started.id, completionNote: 'Work finished'),
        throwsA(isA<JobValidationException>()),
      );
    });

    test('a fully-checked job completes successfully with a note', () async {
      final jobs = await repository.getJobs();
      final pendingJob = jobs.firstWhere((j) => j.status == JobStatus.pending);
      var job = await repository.startJob(pendingJob.id);

      for (final item in job.checklist) {
        job = await repository.updateChecklist(job.id, item.id, true);
      }

      final completed = await repository.completeJob(job.id,
          completionNote: 'All checks passed');

      expect(completed.status, JobStatus.completed);
      expect(completed.notes.last.text, 'All checks passed');
      expect(completed.activity.last.description, 'Job completed');
    });

    test('job lookup by id returns null for an unknown id', () async {
      final result = await repository.getJobById('JOB-9999');
      expect(result, isNull);
    });
  });

  group('MockJobRepository search', () {
    late MockJobRepository repository;

    setUp(() {
      repository = MockJobRepository();
    });

    test('search matches by client name case-insensitively', () async {
      final results = await repository.searchJobs('apex');
      expect(results, isNotEmpty);
      expect(results.every((j) => j.clientName.toLowerCase().contains('apex')),
          isTrue);
    });

    test('search matches by job id', () async {
      final results = await repository.searchJobs('JOB-1024');
      expect(results.length, 1);
      expect(results.first.id, 'JOB-1024');
    });

    test('an empty query returns all jobs', () async {
      final all = await repository.getJobs();
      final results = await repository.searchJobs('');
      expect(results.length, all.length);
    });
  });
}
