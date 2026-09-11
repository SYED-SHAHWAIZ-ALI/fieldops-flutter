enum JobStatus { pending, inProgress, completed }

enum JobPriority { low, medium, high, urgent }

class ChecklistItem {
  final String id;
  final String label;
  final bool isRequired;
  final bool isDone;

  const ChecklistItem({
    required this.id,
    required this.label,
    this.isRequired = true,
    this.isDone = false,
  });

  ChecklistItem copyWith({bool? isDone}) => ChecklistItem(
        id: id,
        label: label,
        isRequired: isRequired,
        isDone: isDone ?? this.isDone,
      );
}

class JobNote {
  final String id;
  final String text;
  final DateTime createdAt;

  const JobNote(
      {required this.id, required this.text, required this.createdAt});
}

class JobAttachment {
  final String id;
  final String path;
  final DateTime addedAt;

  const JobAttachment(
      {required this.id, required this.path, required this.addedAt});
}

class JobActivityEntry {
  final String id;
  final String description;
  final DateTime timestamp;

  const JobActivityEntry({
    required this.id,
    required this.description,
    required this.timestamp,
  });
}

class Job {
  final String id;
  final String title;
  final String description;
  final String clientId;
  final String clientName;
  final String contactName;
  final String contactPhone;
  final String address;
  final DateTime scheduledDate;
  final String scheduledTime;
  final String estimatedDuration;
  final JobPriority priority;
  final JobStatus status;
  final List<ChecklistItem> checklist;
  final List<JobNote> notes;
  final List<JobAttachment> attachments;
  final List<JobActivityEntry> activity;
  final String assignedTechnician;

  const Job({
    required this.id,
    required this.title,
    required this.description,
    required this.clientId,
    required this.clientName,
    required this.contactName,
    required this.contactPhone,
    required this.address,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.estimatedDuration,
    required this.priority,
    required this.status,
    this.checklist = const [],
    this.notes = const [],
    this.attachments = const [],
    this.activity = const [],
    required this.assignedTechnician,
  });

  Job copyWith({
    JobStatus? status,
    List<ChecklistItem>? checklist,
    List<JobNote>? notes,
    List<JobAttachment>? attachments,
    List<JobActivityEntry>? activity,
  }) {
    return Job(
      id: id,
      title: title,
      description: description,
      clientId: clientId,
      clientName: clientName,
      contactName: contactName,
      contactPhone: contactPhone,
      address: address,
      scheduledDate: scheduledDate,
      scheduledTime: scheduledTime,
      estimatedDuration: estimatedDuration,
      priority: priority,
      status: status ?? this.status,
      checklist: checklist ?? this.checklist,
      notes: notes ?? this.notes,
      attachments: attachments ?? this.attachments,
      activity: activity ?? this.activity,
      assignedTechnician: assignedTechnician,
    );
  }
}
