import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/repository_providers.dart';
import '../domain/app_notification.dart';

class NotificationsController
    extends StateNotifier<AsyncValue<List<AppNotification>>> {
  final Ref ref;
  NotificationsController(this.ref) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(notificationRepositoryProvider);
      final items = await repo.getNotifications();
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markAsRead(String id) async {
    final repo = ref.read(notificationRepositoryProvider);
    await repo.markAsRead(id);
    state.whenData((items) {
      state = AsyncValue.data([
        for (final n in items)
          if (n.id == id) n.copyWith(isRead: true) else n
      ]);
    });
  }

  Future<void> markAllAsRead() async {
    final repo = ref.read(notificationRepositoryProvider);
    await repo.markAllAsRead();
    state.whenData((items) {
      state =
          AsyncValue.data([for (final n in items) n.copyWith(isRead: true)]);
    });
  }
}

final notificationsControllerProvider = StateNotifierProvider<
    NotificationsController,
    AsyncValue<List<AppNotification>>>((ref) => NotificationsController(ref));

final unreadNotificationCountProvider = Provider<int>((ref) {
  final async = ref.watch(notificationsControllerProvider);
  return async.maybeWhen(
    data: (items) => items.where((n) => !n.isRead).length,
    orElse: () => 0,
  );
});
