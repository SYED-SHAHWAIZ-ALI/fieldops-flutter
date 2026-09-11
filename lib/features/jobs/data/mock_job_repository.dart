import '../domain/job.dart';
import '../domain/job_repository.dart';

class MockJobRepository implements JobRepository {
  late final List<Job> _jobs = _seedJobs();

  @override
  Future<List<Job>> getJobs() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.unmodifiable(_jobs);
  }

  @override
  Future<Job?> getJobById(String id) async {
    await Future.delayed(const Duration(milliseconds: 250));
    try {
      return _jobs.firstWhere((j) => j.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Job>> searchJobs(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return List.unmodifiable(_jobs);
    return _jobs.where((j) {
      return j.title.toLowerCase().contains(q) ||
          j.clientName.toLowerCase().contains(q) ||
          j.id.toLowerCase().contains(q) ||
          j.address.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Future<Job> startJob(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _jobs.indexWhere((j) => j.id == id);
    if (index == -1) throw JobNotFoundException(id);
    final job = _jobs[index];
    if (job.status != JobStatus.pending) {
      throw JobValidationException('Only pending jobs can be started.');
    }
    final updated = job.copyWith(
      status: JobStatus.inProgress,
      activity: [
        ...job.activity,
        JobActivityEntry(
          id: 'act-${DateTime.now().millisecondsSinceEpoch}',
          description: 'Job started',
          timestamp: DateTime.now(),
        ),
      ],
    );
    _jobs[index] = updated;
    return updated;
  }

  @override
  Future<Job> completeJob(String id, {required String completionNote}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _jobs.indexWhere((j) => j.id == id);
    if (index == -1) throw JobNotFoundException(id);
    final job = _jobs[index];

    if (job.status != JobStatus.inProgress) {
      throw JobValidationException('Only in-progress jobs can be completed.');
    }
    if (completionNote.trim().isEmpty) {
      throw JobValidationException('A completion note is required.');
    }
    final unfinishedRequired =
        job.checklist.where((c) => c.isRequired && !c.isDone).toList();
    if (unfinishedRequired.isNotEmpty) {
      throw JobValidationException(
        'Complete all required checklist items before finishing this job.',
      );
    }

    final now = DateTime.now();
    final updated = job.copyWith(
      status: JobStatus.completed,
      notes: [
        ...job.notes,
        JobNote(
            id: 'note-${now.millisecondsSinceEpoch}',
            text: completionNote,
            createdAt: now),
      ],
      activity: [
        ...job.activity,
        JobActivityEntry(
          id: 'act-${now.millisecondsSinceEpoch}',
          description: 'Job completed',
          timestamp: now,
        ),
      ],
    );
    _jobs[index] = updated;
    return updated;
  }

  @override
  Future<Job> addJobNote(String id, String note) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final index = _jobs.indexWhere((j) => j.id == id);
    if (index == -1) throw JobNotFoundException(id);
    if (note.trim().isEmpty) {
      throw JobValidationException('Note cannot be empty.');
    }
    final job = _jobs[index];
    final now = DateTime.now();
    final updated = job.copyWith(
      notes: [
        ...job.notes,
        JobNote(
            id: 'note-${now.millisecondsSinceEpoch}',
            text: note.trim(),
            createdAt: now),
      ],
      activity: [
        ...job.activity,
        JobActivityEntry(
          id: 'act-${now.millisecondsSinceEpoch}',
          description: 'Inspection notes added',
          timestamp: now,
        ),
      ],
    );
    _jobs[index] = updated;
    return updated;
  }

  @override
  Future<Job> updateChecklist(
      String id, String checklistItemId, bool isDone) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _jobs.indexWhere((j) => j.id == id);
    if (index == -1) throw JobNotFoundException(id);
    final job = _jobs[index];
    final updatedChecklist = job.checklist
        .map((c) => c.id == checklistItemId ? c.copyWith(isDone: isDone) : c)
        .toList();
    final updated = job.copyWith(checklist: updatedChecklist);
    _jobs[index] = updated;
    return updated;
  }

  @override
  Future<Job> addAttachment(String id, String path) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _jobs.indexWhere((j) => j.id == id);
    if (index == -1) throw JobNotFoundException(id);
    final job = _jobs[index];
    final now = DateTime.now();
    final updated = job.copyWith(
      attachments: [
        ...job.attachments,
        JobAttachment(
            id: 'att-${now.millisecondsSinceEpoch}', path: path, addedAt: now),
      ],
      activity: [
        ...job.activity,
        JobActivityEntry(
          id: 'act-${now.millisecondsSinceEpoch}',
          description: 'Photo attached',
          timestamp: now,
        ),
      ],
    );
    _jobs[index] = updated;
    return updated;
  }

  List<Job> _seedJobs() {
    final today = DateTime.now();
    DateTime d(int offsetDays) =>
        DateTime(today.year, today.month, today.day + offsetDays);

    List<ChecklistItem> hvacChecklist() => const [
          ChecklistItem(id: 'c1', label: 'Inspect filters'),
          ChecklistItem(id: 'c2', label: 'Check refrigerant pressure'),
          ChecklistItem(id: 'c3', label: 'Inspect compressor'),
          ChecklistItem(id: 'c4', label: 'Inspect electrical connections'),
          ChecklistItem(id: 'c5', label: 'Test thermostat'),
          ChecklistItem(id: 'c6', label: 'Record outlet temperature'),
        ];

    List<ChecklistItem> genericChecklist() => const [
          ChecklistItem(id: 'g1', label: 'Visual safety inspection'),
          ChecklistItem(id: 'g2', label: 'Functional test'),
          ChecklistItem(id: 'g3', label: 'Record readings'),
          ChecklistItem(id: 'g4', label: 'Customer sign-off'),
        ];

    return [
      Job(
        id: 'JOB-1024',
        title: 'HVAC Preventive Maintenance',
        description:
            'Perform scheduled HVAC maintenance including compressor inspection, filter inspection, electrical connections, refrigerant pressure and temperature checks.',
        clientId: 'CLI-001',
        clientName: 'Apex Industries',
        contactName: 'Ahmed Raza',
        contactPhone: '+92 300 1234567',
        address: 'Gulshan-e-Iqbal, Karachi',
        scheduledDate: d(0),
        scheduledTime: '10:00 AM',
        estimatedDuration: '2 hours',
        priority: JobPriority.high,
        status: JobStatus.inProgress,
        checklist: hvacChecklist(),
        activity: [
          JobActivityEntry(
              id: 'a1',
              description: 'Technician arrived',
              timestamp: d(0).add(const Duration(hours: 9, minutes: 55))),
          JobActivityEntry(
              id: 'a2',
              description: 'Job started',
              timestamp: d(0).add(const Duration(hours: 10, minutes: 2))),
        ],
        assignedTechnician: 'Alex Morgan',
      ),
      Job(
        id: 'JOB-1025',
        title: 'Generator Inspection',
        description:
            'Routine inspection of standby generator, load bank test and fuel system check.',
        clientId: 'CLI-002',
        clientName: 'Metro Trading Co.',
        contactName: 'Bilal Sheikh',
        contactPhone: '+92 321 9988776',
        address: 'Shahrah-e-Faisal, Karachi',
        scheduledDate: d(0),
        scheduledTime: '1:00 PM',
        estimatedDuration: '1.5 hours',
        priority: JobPriority.medium,
        status: JobStatus.pending,
        checklist: genericChecklist(),
        assignedTechnician: 'Alex Morgan',
      ),
      Job(
        id: 'JOB-1026',
        title: 'Network Equipment Repair',
        description:
            'Diagnose and repair intermittent switch failure affecting floor 3 network.',
        clientId: 'CLI-003',
        clientName: 'Nexus Solutions',
        contactName: 'Farah Khan',
        contactPhone: '+92 333 4455667',
        address: 'Clifton, Karachi',
        scheduledDate: d(0),
        scheduledTime: '3:30 PM',
        estimatedDuration: '1 hour',
        priority: JobPriority.urgent,
        status: JobStatus.pending,
        checklist: genericChecklist(),
        assignedTechnician: 'Alex Morgan',
      ),
      Job(
        id: 'JOB-1027',
        title: 'Fire Safety Inspection',
        description:
            'Annual fire suppression and alarm system compliance inspection.',
        clientId: 'CLI-004',
        clientName: 'Prime Healthcare',
        contactName: 'Dr. Sana Iqbal',
        contactPhone: '+92 300 7712345',
        address: 'DHA, Karachi',
        scheduledDate: d(0),
        scheduledTime: '5:00 PM',
        estimatedDuration: '2.5 hours',
        priority: JobPriority.high,
        status: JobStatus.pending,
        checklist: genericChecklist(),
        assignedTechnician: 'Alex Morgan',
      ),
      Job(
        id: 'JOB-1028',
        title: 'Elevator Preventive Service',
        description:
            'Scheduled preventive maintenance for passenger elevator, cable and brake inspection.',
        clientId: 'CLI-005',
        clientName: 'Vertex Logistics',
        contactName: 'Imran Qureshi',
        contactPhone: '+92 345 1122334',
        address: 'Korangi, Karachi',
        scheduledDate: d(0),
        scheduledTime: '4:00 PM',
        estimatedDuration: '2 hours',
        priority: JobPriority.medium,
        status: JobStatus.completed,
        checklist:
            genericChecklist().map((c) => c.copyWith(isDone: true)).toList(),
        notes: [
          JobNote(
            id: 'n1',
            text: 'All systems nominal. No corrective action required.',
            createdAt: d(-1),
          ),
        ],
        activity: [
          JobActivityEntry(
              id: 'a3', description: 'Job started', timestamp: d(-1)),
          JobActivityEntry(
              id: 'a4', description: 'Job completed', timestamp: d(-1)),
        ],
        assignedTechnician: 'Alex Morgan',
      ),
      Job(
        id: 'JOB-1029',
        title: 'Electrical Panel Audit',
        description:
            'Thermal imaging audit of main electrical distribution panel.',
        clientId: 'CLI-006',
        clientName: 'NorthStar Retail',
        contactName: 'Hassan Ali',
        contactPhone: '+92 302 6677889',
        address: 'PECHS, Karachi',
        scheduledDate: d(1),
        scheduledTime: '9:30 AM',
        estimatedDuration: '1.5 hours',
        priority: JobPriority.low,
        status: JobStatus.pending,
        checklist: genericChecklist(),
        assignedTechnician: 'Alex Morgan',
      ),
      Job(
        id: 'JOB-1030',
        title: 'CCTV System Servicing',
        description:
            'Lens cleaning, alignment, and recorder storage health check for site-wide CCTV.',
        clientId: 'CLI-007',
        clientName: 'PakTech Solutions',
        contactName: 'Zainab Malik',
        contactPhone: '+92 311 2233445',
        address: 'SITE Area, Karachi',
        scheduledDate: d(1),
        scheduledTime: '11:00 AM',
        estimatedDuration: '2 hours',
        priority: JobPriority.medium,
        status: JobStatus.pending,
        checklist: genericChecklist(),
        assignedTechnician: 'Alex Morgan',
      ),
      Job(
        id: 'JOB-1031',
        title: 'Water Pump Maintenance',
        description:
            'Bearing lubrication and seal inspection on main booster pump.',
        clientId: 'CLI-008',
        clientName: 'Orion Manufacturing',
        contactName: 'Kamran Siddiqui',
        contactPhone: '+92 321 8899001',
        address: 'North Nazimabad, Karachi',
        scheduledDate: d(-1),
        scheduledTime: '2:00 PM',
        estimatedDuration: '1 hour',
        priority: JobPriority.low,
        status: JobStatus.completed,
        checklist:
            genericChecklist().map((c) => c.copyWith(isDone: true)).toList(),
        notes: [
          JobNote(
              id: 'n2',
              text: 'Bearing replaced. Pump running smoothly.',
              createdAt: d(-1)),
        ],
        activity: [
          JobActivityEntry(
              id: 'a5', description: 'Job completed', timestamp: d(-1)),
        ],
        assignedTechnician: 'Alex Morgan',
      ),
      Job(
        id: 'JOB-1032',
        title: 'Access Control Installation',
        description:
            'Install and configure two biometric access control units at warehouse entry points.',
        clientId: 'CLI-003',
        clientName: 'Nexus Solutions',
        contactName: 'Farah Khan',
        contactPhone: '+92 333 4455667',
        address: 'Clifton, Karachi',
        scheduledDate: d(1),
        scheduledTime: '2:30 PM',
        estimatedDuration: '3 hours',
        priority: JobPriority.medium,
        status: JobStatus.pending,
        checklist: genericChecklist(),
        assignedTechnician: 'Alex Morgan',
      ),
      Job(
        id: 'JOB-1033',
        title: 'Backup Power Load Test',
        description:
            'Full load bank test of UPS and diesel generator failover sequence.',
        clientId: 'CLI-004',
        clientName: 'Prime Healthcare',
        contactName: 'Dr. Sana Iqbal',
        contactPhone: '+92 300 7712345',
        address: 'DHA, Karachi',
        scheduledDate: d(2),
        scheduledTime: '9:00 AM',
        estimatedDuration: '2 hours',
        priority: JobPriority.high,
        status: JobStatus.pending,
        checklist: genericChecklist(),
        assignedTechnician: 'Alex Morgan',
      ),
      Job(
        id: 'JOB-1034',
        title: 'Refrigeration Unit Repair',
        description: 'Diagnose compressor fault on walk-in cold storage unit.',
        clientId: 'CLI-006',
        clientName: 'NorthStar Retail',
        contactName: 'Hassan Ali',
        contactPhone: '+92 302 6677889',
        address: 'PECHS, Karachi',
        scheduledDate: d(-2),
        scheduledTime: '10:30 AM',
        estimatedDuration: '2 hours',
        priority: JobPriority.urgent,
        status: JobStatus.completed,
        checklist:
            genericChecklist().map((c) => c.copyWith(isDone: true)).toList(),
        notes: [
          JobNote(
              id: 'n3',
              text: 'Compressor capacitor replaced.',
              createdAt: d(-2)),
        ],
        activity: [
          JobActivityEntry(
              id: 'a6', description: 'Job completed', timestamp: d(-2)),
        ],
        assignedTechnician: 'Alex Morgan',
      ),
    ];
  }
}
