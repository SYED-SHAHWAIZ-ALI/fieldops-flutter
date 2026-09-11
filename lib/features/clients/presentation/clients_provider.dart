import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/repository_providers.dart';
import '../../jobs/domain/job.dart';
import '../../jobs/presentation/jobs_provider.dart';
import '../domain/client.dart';

final clientsListProvider = FutureProvider<List<Client>>((ref) async {
  final repo = ref.read(clientRepositoryProvider);
  return repo.getClients();
});

final clientSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredClientsProvider = Provider<AsyncValue<List<Client>>>((ref) {
  final asyncClients = ref.watch(clientsListProvider);
  final query = ref.watch(clientSearchQueryProvider).trim().toLowerCase();

  return asyncClients.whenData((clients) {
    if (query.isEmpty) {
      return clients;
    }
    return clients
        .where((c) =>
            c.companyName.toLowerCase().contains(query) ||
            c.contactName.toLowerCase().contains(query) ||
            c.address.toLowerCase().contains(query))
        .toList();
  });
});

final clientByIdProvider =
    FutureProvider.family<Client?, String>((ref, id) async {
  final repo = ref.read(clientRepositoryProvider);
  return repo.getClientById(id);
});

class ClientLiveJobStats {
  final int active;
  final int completedInDemo;

  const ClientLiveJobStats({
    required this.active,
    required this.completedInDemo,
  });
}

/// Live work-order counts derived from the shared JobsController.
/// Historical completed totals remain on the Client model.
final clientLiveJobStatsProvider =
    Provider.family<ClientLiveJobStats, String>((ref, clientId) {
  final jobs = ref
      .watch(jobsControllerProvider)
      .jobs
      .where((job) => job.clientId == clientId)
      .toList();
  return ClientLiveJobStats(
    active: jobs.where((job) => job.status != JobStatus.completed).length,
    completedInDemo:
        jobs.where((job) => job.status == JobStatus.completed).length,
  );
});
