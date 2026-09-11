import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/confirmation_bottom_sheet.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/priority_chip.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/widgets/timeline_item.dart';
import '../domain/job.dart';
import '../domain/job_repository.dart';
import 'jobs_provider.dart';

class JobDetailScreen extends ConsumerStatefulWidget {
  final String jobId;
  const JobDetailScreen({super.key, required this.jobId});

  @override
  ConsumerState<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends ConsumerState<JobDetailScreen> {
  final _noteController = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : null,
      ));
  }

  Future<void> _startJob() async {
    setState(() => _busy = true);
    try {
      await ref.read(jobsControllerProvider.notifier).startJob(widget.jobId);
      _showSnack('Job started');
    } catch (e) {
      _showSnack(
          e is JobValidationException ? e.message : 'Could not start job',
          isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _completeJob(Job job) async {
    String? validationError;
    while (true) {
      if (!mounted) return;
      final note = await showCompletionBottomSheet(
        context,
        title: 'Complete Job',
        description: 'Confirm the work is finished for ${job.id}.',
        validationError: validationError,
      );
      if (note == null) return; // cancelled
      setState(() => _busy = true);
      try {
        await ref
            .read(jobsControllerProvider.notifier)
            .completeJob(job.id, completionNote: note);
        if (mounted) {
          setState(() => _busy = false);
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              icon: const Icon(Icons.check_circle_rounded,
                  color: AppColors.success, size: 40),
              title: const Text('Job Completed Successfully'),
              content: Text('${job.id} has been marked as completed.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Done'),
                ),
              ],
            ),
          );
        }
        return;
      } on JobValidationException catch (e) {
        setState(() => _busy = false);
        validationError = e.message;
        continue;
      } catch (e) {
        setState(() => _busy = false);
        _showSnack('Could not complete job', isError: true);
        return;
      }
    }
  }

  Future<void> _addNote(String jobId) async {
    final text = _noteController.text.trim();
    if (text.isEmpty) return;
    try {
      await ref.read(jobsControllerProvider.notifier).addNote(jobId, text);
      if (!mounted) return;
      _noteController.clear();
      FocusScope.of(context).unfocus();
    } catch (e) {
      _showSnack('Could not add note', isError: true);
    }
  }

  Future<void> _pickImage(String jobId, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: source, imageQuality: 80);
      if (file == null) return; // user cancelled selection
      await ref
          .read(jobsControllerProvider.notifier)
          .addAttachment(jobId, file.path);
      _showSnack('Photo attached');
    } catch (e) {
      _showSnack('Could not access camera or gallery on this device',
          isError: true);
    }
  }

  void _showAttachmentOptions(String jobId) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose Image'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(jobId, ImageSource.gallery);
              },
            ),
            if (!kIsWeb)
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(jobId, ImageSource.camera);
                },
              ),
          ],
        ),
      ),
    );
  }

  IconData _activityIcon(String description) {
    final d = description.toLowerCase();
    if (d.contains('started') || d.contains('arrived')) {
      return Icons.play_circle_outline_rounded;
    }
    if (d.contains('completed')) return Icons.check_circle_outline_rounded;
    if (d.contains('photo') || d.contains('attached')) {
      return Icons.photo_camera_outlined;
    }
    if (d.contains('note')) return Icons.edit_note_rounded;
    if (d.contains('checklist')) return Icons.checklist_rounded;
    return Icons.circle_notifications_outlined;
  }

  Color _activityAccent(String description) {
    final d = description.toLowerCase();
    if (d.contains('completed')) return AppColors.success;
    if (d.contains('started') || d.contains('arrived')) return AppColors.accentBlue;
    if (d.contains('photo') || d.contains('attached')) return AppColors.warning;
    if (d.contains('note') || d.contains('checklist')) return AppColors.indigo;
    return AppColors.pending;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final jobsState = ref.watch(jobsControllerProvider);

    if (jobsState.loadState == JobsLoadState.loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Job Details')),
        body: const LoadingState(),
      );
    }

    if (jobsState.loadState == JobsLoadState.error) {
      return Scaffold(
        appBar: AppBar(title: const Text('Job Details')),
        body: ErrorState(
          message: jobsState.errorMessage ?? 'Unable to load job details.',
          onRetry: () => ref.read(jobsControllerProvider.notifier).loadJobs(),
        ),
      );
    }

    final job = jobsState.jobs
        .cast<Job?>()
        .firstWhere((j) => j?.id == widget.jobId, orElse: () => null);

    if (job == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Job Details')),
        body: const EmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Job not found',
          message: 'This job may have been removed or the link is invalid.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(job.id)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xxl),
          children: [
            Row(
              children: [
                PriorityChip(priority: job.priority),
                const SizedBox(width: 8),
                StatusChip(status: job.status),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(job.title, style: theme.textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.lg),
            _InfoCard(job: job),
            const SizedBox(height: AppSpacing.lg),
            _Section(
              title: 'Service Description',
              child: Text(job.description, style: theme.textTheme.bodyMedium),
            ),
            const SizedBox(height: AppSpacing.lg),
            _Section(
              title: 'Service Checklist',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (job.checklist.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Row(
                        children: [
                          Text(
                            '${job.checklist.where((c) => c.isDone).length}/${job.checklist.length}',
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.pill),
                              child: LinearProgressIndicator(
                                value: job.checklist.isEmpty
                                    ? 0
                                    : job.checklist
                                            .where((c) => c.isDone)
                                            .length /
                                        job.checklist.length,
                                minHeight: 6,
                                backgroundColor: theme.dividerColor,
                                valueColor:
                                    const AlwaysStoppedAnimation<Color>(
                                        AppColors.accentBlue),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ...job.checklist
                      .map((item) => CheckboxListTile(
                           value: item.isDone,
                           onChanged: job.status == JobStatus.completed
                               ? null
                               : (checked) => ref
                                   .read(jobsControllerProvider.notifier)
                                   .updateChecklistItem(
                                       job.id, item.id, checked ?? false),
                           contentPadding: EdgeInsets.zero,
                           controlAffinity: ListTileControlAffinity.leading,
                           title: Text(item.label,
                               style: theme.textTheme.bodyMedium),
                           subtitle: item.isRequired && !item.isDone
                               ? Text('Required',
                                   style: theme.textTheme.bodySmall?.copyWith(
                                       color: AppColors.warning, fontSize: 11))
                               : null,
                         ))
                     .toList(),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _Section(
              title: 'Job Notes',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...job.notes.map((n) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: theme.cardTheme.color,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            border: Border.all(color: theme.dividerColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(n.text, style: theme.textTheme.bodyMedium),
                              const SizedBox(height: 4),
                              Text(
                                  DateFormat('MMM d, h:mm a')
                                      .format(n.createdAt),
                                  style: theme.textTheme.bodySmall),
                            ],
                          ),
                        ),
                      )),
                  if (job.status != JobStatus.completed)
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _noteController,
                            decoration:
                                const InputDecoration(hintText: 'Add a note…'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: () => _addNote(job.id),
                          icon: const Icon(Icons.send_rounded),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _Section(
              title: 'Attachments',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (job.attachments.isEmpty)
                    Text('No attachments yet.',
                        style: theme.textTheme.bodySmall)
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: job.attachments
                          .map((a) => Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.secondary
                                      .withValues(alpha: 0.08),
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.sm),
                                  border: Border.all(color: theme.dividerColor),
                                ),
                                child: const Icon(Icons.image_outlined),
                              ))
                          .toList(),
                    ),
                  const SizedBox(height: AppSpacing.sm),
                  if (job.status != JobStatus.completed)
                    OutlinedButton.icon(
                      onPressed: () => _showAttachmentOptions(job.id),
                      icon: const Icon(Icons.add_photo_alternate_outlined),
                      label: const Text('Choose Image'),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _Section(
              title: 'Activity Timeline',
              child: job.activity.isEmpty
                  ? Text('No activity yet.', style: theme.textTheme.bodySmall)
                  : Column(
                      children: [
                        for (var i = 0; i < job.activity.length; i++)
                          TimelineItem(
                            icon: _activityIcon(job.activity[i].description),
                            accent: _activityAccent(
                                job.activity[i].description),
                            title: job.activity[i].description,
                            time: DateFormat('h:mm a')
                                .format(job.activity[i].timestamp),
                            isLast: i == job.activity.length - 1,
                          ),
                      ],
                    ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (job.status == JobStatus.pending)
              ElevatedButton(
                onPressed: _busy ? null : _startJob,
                child: _busy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_arrow_rounded),
                          SizedBox(width: 8),
                          Text('Start Job'),
                        ],
                      ),
              ),
            if (job.status == JobStatus.inProgress)
              ElevatedButton(
                onPressed: _busy ? null : () => _completeJob(job),
                child: _busy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline_rounded),
                          SizedBox(width: 8),
                          Text('Complete Job'),
                        ],
                      ),
              ),
            if (job.status == JobStatus.completed)
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: AppColors.success),
                    SizedBox(width: 8),
                    Text('This job has been completed.'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Job job;
  const _InfoCard({required this.job});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(label: 'Client', value: job.clientName),
          _InfoRow(label: 'Contact', value: job.contactName),
          _InfoRow(label: 'Phone', value: job.contactPhone),
          _InfoRow(label: 'Location', value: job.address),
          _InfoRow(
            label: 'Schedule',
            value:
                '${DateFormat('MMMM d').format(job.scheduledDate)}\n${job.scheduledTime}',
          ),
          _InfoRow(
              label: 'Estimated Duration',
              value: job.estimatedDuration,
              isLast: true),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;
  const _InfoRow(
      {required this.label, required this.value, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: theme.textTheme.bodySmall),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 0.6)),
        const SizedBox(height: AppSpacing.sm),
        child,
      ],
    );
  }
}
