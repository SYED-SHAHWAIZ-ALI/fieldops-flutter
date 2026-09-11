import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/empty_state.dart';
import 'clients_provider.dart';
import 'widgets/client_card.dart';

class ClientsScreen extends ConsumerStatefulWidget {
  const ClientsScreen({super.key});

  @override
  ConsumerState<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends ConsumerState<ClientsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientsAsync = ref.watch(filteredClientsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Clients')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
              child: TextField(
                controller: _searchController,
                onChanged: (v) =>
                    ref.read(clientSearchQueryProvider.notifier).state = v,
                decoration: const InputDecoration(
                  hintText: 'Search clients or locations…',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
            ),
            Expanded(
              child: clientsAsync.when(
                loading: () => const LoadingState(),
                error: (e, _) => ErrorState(
                  message: 'Unable to load clients.',
                  onRetry: () => ref.invalidate(clientsListProvider),
                ),
                data: (clients) {
                  if (clients.isEmpty) {
                    return const EmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'No matching clients',
                      message: 'Try a different search term.',
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md, 0, AppSpacing.md, AppSpacing.xxl),
                    itemCount: clients.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final client = clients[index];
                      final liveStats =
                          ref.watch(clientLiveJobStatsProvider(client.id));
                      return ClientCard(
                        client: client,
                        activeJobs: liveStats.active,
                        onTap: () => context.push('/clients/${client.id}'),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
