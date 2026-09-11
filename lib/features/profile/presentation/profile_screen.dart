import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/theme_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/profile_avatar.dart';
import '../../auth/domain/app_user.dart';
import '../../auth/presentation/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authControllerProvider).user;
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xxl),
          children: [
            Row(
              children: [
                ProfileAvatar(name: user?.name ?? 'Alex Morgan', size: 60),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.name ?? 'Alex Morgan',
                          style: theme.textTheme.titleLarge),
                      Text(user?.title ?? 'Senior Field Technician',
                          style: theme.textTheme.bodyMedium),
                      Text(user?.employeeId ?? 'EMP-2048',
                          style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Row(
                children: [
                  _StatItem(value: '142', label: 'Jobs Completed'),
                  _StatItem(value: '96%', label: 'Completion Rate'),
                  _StatItem(value: '4.8', label: 'Customer Rating'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('SETTINGS', style: theme.textTheme.labelSmall),
            const SizedBox(height: AppSpacing.sm),
            _SettingsTile(
              icon: Icons.badge_outlined,
              title: 'Personal Information',
              onTap: () => _showPersonalInfo(context, user),
            ),
            _SettingsTile(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              onTap: () => _showNotificationPrefs(context),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: theme.dividerColor),
              ),
              child: SwitchListTile(
                secondary: const Icon(Icons.dark_mode_outlined),
                title: const Text('Dark Mode'),
                value: isDark,
                onChanged: (value) =>
                    ref.read(themeModeProvider.notifier).toggle(value),
              ),
            ),
            _SettingsTile(
              icon: Icons.security_outlined,
              title: 'Security',
              onTap: () => _showSecurity(context),
            ),
            _SettingsTile(
              icon: Icons.help_outline_rounded,
              title: 'Help & Support',
              onTap: () => _showSupport(context),
            ),
            _SettingsTile(
              icon: Icons.info_outline_rounded,
              title: 'About FieldOps',
              onTap: () => showAboutDialog(
                context: context,
                applicationName: 'FieldOps',
                applicationVersion: '1.0.0',
                applicationLegalese: 'Field Service & Client Management',
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton.icon(
              onPressed: () async {
                await ref.read(authControllerProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              },
              icon: const Icon(Icons.logout_rounded, color: AppColors.error),
              label: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPersonalInfo(BuildContext context, AppUser? user) {
    final u = user ??
        const AppUser(
          id: 'EMP-2048',
          name: 'Alex Morgan',
          title: 'Senior Field Technician',
          employeeId: 'EMP-2048',
          email: 'field.agent@fieldops.com',
        );
    _showInfoDialog(context, title: 'Personal Information', rows: [
      _InfoRow('Full Name', u.name),
      _InfoRow('Employee ID', u.employeeId),
      _InfoRow('Job Title', u.title),
      _InfoRow('Email', u.email),
      _InfoRow('Phone', '+92 300 1234567'),
      _InfoRow('Region', 'Karachi, Pakistan'),
    ]);
  }

  void _showNotificationPrefs(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _NotificationPrefsDialog(),
    );
  }

  void _showSecurity(BuildContext context) {
    _showInfoDialog(context, title: 'Security', rows: [
      _InfoRow('Password', '••••••••••'),
      _InfoRow('Last Changed', 'Aug 15, 2026'),
      _InfoRow('Two-Factor Auth', 'Disabled'),
      _InfoRow('Last Login', 'Today, 8:42 AM'),
      _InfoRow('Account Status', 'Active'),
    ]);
  }

  void _showSupport(BuildContext context) {
    _showInfoDialog(context, title: 'Help & Support', rows: [
      _InfoRow('Email', 'support@fieldops.com'),
      _InfoRow('Phone', '+92 21 111 222 333'),
      _InfoRow('Hours', 'Mon–Fri, 9 AM – 6 PM PKT'),
      _InfoRow('Status Page', 'status.fieldops.com'),
    ]);
  }

  void _showInfoDialog(
    BuildContext context, {
    required String title,
    required List<_InfoRow> rows,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final row in rows) ...[
                  _InfoRowWidget(row: row),
                  if (row != rows.last)
                    Divider(height: 1, color: theme.dividerColor),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class _InfoRow {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);
}

class _InfoRowWidget extends StatelessWidget {
  final _InfoRow row;
  const _InfoRowWidget({required this.row});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(row.label, style: theme.textTheme.bodySmall),
          ),
          Expanded(
            flex: 3,
            child: Text(
              row.value,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationPrefsDialog extends StatefulWidget {
  const _NotificationPrefsDialog();

  @override
  State<_NotificationPrefsDialog> createState() =>
      _NotificationPrefsDialogState();
}

class _NotificationPrefsDialogState extends State<_NotificationPrefsDialog> {
  bool _jobAssignments = true;
  bool _scheduleChanges = true;
  bool _reminders = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Notifications'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggle('Job Assignments', _jobAssignments, (v) {
            setState(() => _jobAssignments = v);
            _saved(context);
          }),
          _toggle('Schedule Changes', _scheduleChanges, (v) {
            setState(() => _scheduleChanges = v);
            _saved(context);
          }),
          _toggle('Reminders', _reminders, (v) {
            setState(() => _reminders = v);
            _saved(context);
          }),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Done'),
        ),
      ],
    );
  }

  Widget _toggle(String label, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      value: value,
      onChanged: onChanged,
    );
  }

  void _saved(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Preference saved')));
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(value, style: theme.textTheme.titleLarge),
          const SizedBox(height: 2),
          Text(label,
              style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _SettingsTile(
      {required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: theme.dividerColor),
      ),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}