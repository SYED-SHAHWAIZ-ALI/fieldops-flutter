import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/empty_state.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../clients/domain/client.dart';
import '../../clients/presentation/clients_provider.dart';
import '../domain/job.dart';
import '../domain/job_repository.dart';
import 'jobs_provider.dart';

class CreateJobScreen extends ConsumerStatefulWidget {
  const CreateJobScreen({super.key});

  @override
  ConsumerState<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends ConsumerState<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _clientId;
  JobPriority _priority = JobPriority.medium;
  String _duration = '2 hours';
  DateTime _scheduledDate = DateTime.now();
  TimeOfDay _scheduledTime = const TimeOfDay(hour: 9, minute: 0);
  bool _saving = false;

  static const _durations = [
    '30 min',
    '1 hour',
    '1h 30m',
    '2 hours',
    '3 hours',
    '4 hours',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year, now.month, now.day);
    final selected = await showDatePicker(
      context: context,
      initialDate:
          _scheduledDate.isBefore(firstDate) ? firstDate : _scheduledDate,
      firstDate: firstDate,
      lastDate: firstDate.add(const Duration(days: 365)),
    );
    if (selected != null && mounted) {
      setState(() => _scheduledDate = selected);
    }
  }

  Future<void> _pickTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _scheduledTime,
    );
    if (selected != null && mounted) {
      setState(() => _scheduledTime = selected);
    }
  }

  Future<void> _submit(List<Client> clients) async {
    if (_saving) {
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final clientId = _clientId;
    if (clientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a client for this work order.')),
      );
      return;
    }

    final client = clients.firstWhere((item) => item.id == clientId);
    setState(() => _saving = true);

    try {
      final input = CreateJobInput(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        clientId: client.id,
        clientName: client.companyName,
        contactName: client.contactName,
        contactPhone: client.phone,
        address: client.address,
        scheduledDate: _scheduledDate,
        scheduledTime: MaterialLocalizations.of(context)
            .formatTimeOfDay(_scheduledTime, alwaysUse24HourFormat: false),
        estimatedDuration: _duration,
        priority: _priority,
        assignedTechnician:
            ref.read(authControllerProvider).user?.name ?? 'Alex Morgan',
      );

      final created =
          await ref.read(jobsControllerProvider.notifier).createJob(input);
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${created.id} created successfully.')),
      );
      context.pushReplacement('/jobs/${created.id}');
    } on JobValidationException catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: AppColors.error),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not create the work order. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clientsAsync = ref.watch(clientsListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('New Work Order')),
      body: SafeArea(
        child: clientsAsync.when(
          loading: () => const LoadingState(),
          error: (error, stack) => ErrorState(
            message: 'Unable to load clients for this work order.',
            onRetry: () => ref.invalidate(clientsListProvider),
          ),
          data: (clients) {
            if (clients.isEmpty) {
              return const EmptyState(
                icon: Icons.groups_outlined,
                title: 'No clients available',
                message: 'Add a client before creating a work order.',
              );
            }

            return Form(
              key: _formKey,
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.xxl,
                ),
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color:
                          theme.colorScheme.secondary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color:
                            theme.colorScheme.secondary.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.assignment_add,
                          color: theme.colorScheme.secondary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Create a field work order',
                                style: theme.textTheme.titleSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'A standard service checklist and audit timeline are added automatically.',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('WORK ORDER', style: theme.textTheme.labelSmall),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _titleController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Job title',
                      hintText: 'e.g. AC Compressor Inspection',
                      prefixIcon: Icon(Icons.work_outline_rounded),
                    ),
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.length < 3) {
                        return 'Enter a clear job title.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Client',
                      prefixIcon: Icon(Icons.business_outlined),
                    ),
                    items: clients
                        .map(
                          (client) => DropdownMenuItem(
                            value: client.id,
                            child: Text(
                              client.companyName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _clientId = value),
                    validator: (value) =>
                        value == null ? 'Select a client.' : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('SCHEDULE', style: theme.textTheme.labelSmall),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: _PickerField(
                          icon: Icons.calendar_today_outlined,
                          label: 'Date',
                          value:
                              DateFormat('EEE, MMM d').format(_scheduledDate),
                          onTap: _pickDate,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _PickerField(
                          icon: Icons.schedule_outlined,
                          label: 'Time',
                          value: MaterialLocalizations.of(context)
                              .formatTimeOfDay(_scheduledTime),
                          onTap: _pickTime,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<JobPriority>(
                          initialValue: _priority,
                          decoration: const InputDecoration(
                            labelText: 'Priority',
                            prefixIcon: Icon(Icons.flag_outlined),
                          ),
                          items: JobPriority.values
                              .map(
                                (priority) => DropdownMenuItem(
                                  value: priority,
                                  child: Text(_priorityLabel(priority)),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _priority = value);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _duration,
                          decoration: const InputDecoration(
                            labelText: 'Est. duration',
                            prefixIcon: Icon(Icons.timer_outlined),
                          ),
                          items: _durations
                              .map(
                                (duration) => DropdownMenuItem(
                                  value: duration,
                                  child: Text(duration),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _duration = value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('SERVICE DETAILS', style: theme.textTheme.labelSmall),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _descriptionController,
                    minLines: 4,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      labelText: 'Service description',
                      hintText:
                          'Describe the inspection, maintenance, repair, or service required.',
                      alignLabelWithHint: true,
                    ),
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.length < 10) {
                        return 'Add a short service description.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ElevatedButton.icon(
                    onPressed: _saving ? null : () => _submit(clients),
                    icon: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.add_task_rounded),
                    label: Text(_saving ? 'Creating…' : 'Create Work Order'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _priorityLabel(JobPriority priority) {
    switch (priority) {
      case JobPriority.low:
        return 'Low';
      case JobPriority.medium:
        return 'Medium';
      case JobPriority.high:
        return 'High';
      case JobPriority.urgent:
        return 'Urgent';
    }
  }
}

class _PickerField extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _PickerField({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.cardTheme.color,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          constraints: const BoxConstraints(minHeight: 58),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.secondary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(label, style: theme.textTheme.bodySmall),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
