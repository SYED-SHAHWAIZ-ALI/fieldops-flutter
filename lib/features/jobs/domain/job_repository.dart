import 'job.dart';

/// Job repository contract. A future `ApiJobRepository` calling the
/// FastAPI backend can implement this same interface with no changes
/// required in the jobs/dashboard presentation layer.
abstract class JobRepository {
  Future<List<Job>> getJobs();
  Future<Job?> getJobById(String id);
  Future<List<Job>> searchJobs(String query);
  Future<Job> startJob(String id);
  Future<Job> completeJob(String id, {required String completionNote});
  Future<Job> addJobNote(String id, String note);
  Future<Job> updateChecklist(String id, String checklistItemId, bool isDone);
  Future<Job> addAttachment(String id, String path);
}

class JobNotFoundException implements Exception {
  final String id;
  JobNotFoundException(this.id);

  @override
  String toString() => 'Job $id was not found.';
}

class JobValidationException implements Exception {
  final String message;
  JobValidationException(this.message);

  @override
  String toString() => message;
}
