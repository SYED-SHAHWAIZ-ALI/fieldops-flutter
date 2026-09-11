import '../domain/client.dart';
import '../domain/client_repository.dart';

class MockClientRepository implements ClientRepository {
  final List<Client> _clients = const [
    Client(
      id: 'CLI-001',
      companyName: 'Apex Industries',
      contactName: 'Ahmed Raza',
      phone: '+92 300 1234567',
      email: 'ahmed.raza@apexindustries.pk',
      address: 'Gulshan-e-Iqbal, Karachi',
      activeJobs: 1,
      completedJobs: 12,
      notes:
          'Prefers morning service windows. HVAC contract renews in December.',
    ),
    Client(
      id: 'CLI-002',
      companyName: 'Metro Trading Co.',
      contactName: 'Bilal Sheikh',
      phone: '+92 321 9988776',
      email: 'bilal.sheikh@metrotrading.pk',
      address: 'Shahrah-e-Faisal, Karachi',
      activeJobs: 1,
      completedJobs: 8,
      notes: 'Generator under warranty until next year.',
    ),
    Client(
      id: 'CLI-003',
      companyName: 'Nexus Solutions',
      contactName: 'Farah Khan',
      phone: '+92 333 4455667',
      email: 'farah.khan@nexussolutions.pk',
      address: 'Clifton, Karachi',
      activeJobs: 2,
      completedJobs: 15,
      notes: 'Key account. Escalate network issues as urgent.',
    ),
    Client(
      id: 'CLI-004',
      companyName: 'Prime Healthcare',
      contactName: 'Dr. Sana Iqbal',
      phone: '+92 300 7712345',
      email: 'sana.iqbal@primehealthcare.pk',
      address: 'DHA, Karachi',
      activeJobs: 2,
      completedJobs: 20,
      notes: 'Fire safety compliance is audited annually by regulator.',
    ),
    Client(
      id: 'CLI-005',
      companyName: 'Vertex Logistics',
      contactName: 'Imran Qureshi',
      phone: '+92 345 1122334',
      email: 'imran.qureshi@vertexlogistics.pk',
      address: 'Korangi, Karachi',
      activeJobs: 0,
      completedJobs: 6,
      notes: 'Elevator maintenance on a quarterly schedule.',
    ),
    Client(
      id: 'CLI-006',
      companyName: 'NorthStar Retail',
      contactName: 'Hassan Ali',
      phone: '+92 302 6677889',
      email: 'hassan.ali@northstarretail.pk',
      address: 'PECHS, Karachi',
      activeJobs: 1,
      completedJobs: 9,
      notes: 'Cold storage is business-critical; prioritize urgent requests.',
    ),
    Client(
      id: 'CLI-007',
      companyName: 'PakTech Solutions',
      contactName: 'Zainab Malik',
      phone: '+92 311 2233445',
      email: 'zainab.malik@paktechsolutions.pk',
      address: 'SITE Area, Karachi',
      activeJobs: 1,
      completedJobs: 5,
      notes: 'New client onboarded this quarter.',
    ),
    Client(
      id: 'CLI-008',
      companyName: 'Orion Manufacturing',
      contactName: 'Kamran Siddiqui',
      phone: '+92 321 8899001',
      email: 'kamran.siddiqui@orionmfg.pk',
      address: 'North Nazimabad, Karachi',
      activeJobs: 0,
      completedJobs: 11,
      notes: 'Plant runs 24/7; coordinate maintenance windows in advance.',
    ),
  ];

  @override
  Future<List<Client>> getClients() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.unmodifiable(_clients);
  }

  @override
  Future<Client?> getClientById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _clients.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Client>> searchClients(String query) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return List.unmodifiable(_clients);
    return _clients
        .where((c) =>
            c.companyName.toLowerCase().contains(q) ||
            c.contactName.toLowerCase().contains(q) ||
            c.address.toLowerCase().contains(q))
        .toList();
  }
}
