import '../domain/app_notification.dart';
import '../domain/notification_repository.dart';

class MockNotificationRepository implements NotificationRepository {
  late final List<AppNotification> _notifications = _seed();

  @override
  Future<List<AppNotification>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 350));
    final sorted = [..._notifications]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return List.unmodifiable(sorted);
  }

  @override
  Future<void> markAsRead(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
  }

  @override
  Future<void> markAllAsRead() async {
    await Future.delayed(const Duration(milliseconds: 200));
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
  }

  List<AppNotification> _seed() {
    final now = DateTime.now();
    return [
      AppNotification(
        id: 'n1',
        type: NotificationType.newJob,
        title: 'New Job Assigned',
        message: 'JOB-1032 assigned for 2:30 PM',
        timestamp: now.subtract(const Duration(minutes: 20)),
      ),
      AppNotification(
        id: 'n2',
        type: NotificationType.scheduleChange,
        title: 'Schedule Updated',
        message: 'JOB-1028 moved to 4:00 PM',
        timestamp: now.subtract(const Duration(hours: 2)),
      ),
      AppNotification(
        id: 'n3',
        type: NotificationType.reminder,
        title: 'Job Reminder',
        message: 'Your next job begins in 30 minutes',
        timestamp: now.subtract(const Duration(hours: 3)),
      ),
      AppNotification(
        id: 'n4',
        type: NotificationType.newJob,
        title: 'New Job Assigned',
        message: 'JOB-1033 assigned for tomorrow, 9:00 AM',
        timestamp: now.subtract(const Duration(days: 1, hours: 1)),
        isRead: true,
      ),
      AppNotification(
        id: 'n5',
        type: NotificationType.scheduleChange,
        title: 'Schedule Updated',
        message: 'JOB-1030 rescheduled to next Monday',
        timestamp: now.subtract(const Duration(days: 2)),
        isRead: true,
      ),
    ];
  }
}
