import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/repository_providers.dart';
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
    if (query.isEmpty) return clients;
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
