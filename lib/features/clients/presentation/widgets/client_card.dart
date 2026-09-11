import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/client.dart';

class ClientCard extends StatelessWidget {
  final Client client;
  final VoidCallback onTap;
  final int? activeJobs;

  const ClientCard({
    super.key,
    required this.client,
    required this.onTap,
    this.activeJobs,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(Icons.business_rounded,
                  color: theme.colorScheme.secondary),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(client.companyName, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Text('${client.contactName} · ${client.address}',
                      style: theme.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _Badge(
                          label:
                              '${activeJobs ?? client.activeJobs} active now'),
                      const SizedBox(width: 6),
                      _Badge(label: '${client.completedJobs} completed'),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  const _Badge({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: theme.dividerColor.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(999),
      ),
      child:
          Text(label, style: theme.textTheme.bodySmall?.copyWith(fontSize: 11)),
    );
  }
}
