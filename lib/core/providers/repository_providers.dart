import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/mock_auth_repository.dart';
import '../../features/auth/domain/auth_repository.dart';
import '../../features/clients/data/mock_client_repository.dart';
import '../../features/clients/domain/client_repository.dart';
import '../../features/jobs/data/mock_job_repository.dart';
import '../../features/jobs/domain/job_repository.dart';
import '../../features/notifications/data/mock_notification_repository.dart';
import '../../features/notifications/domain/notification_repository.dart';

/// Swap these providers for Api* implementations once the FastAPI
/// backend is available. Nothing outside this file needs to change.
final authRepositoryProvider =
    Provider<AuthRepository>((ref) => MockAuthRepository());

final jobRepositoryProvider =
    Provider<JobRepository>((ref) => MockJobRepository());

final clientRepositoryProvider =
    Provider<ClientRepository>((ref) => MockClientRepository());

final notificationRepositoryProvider =
    Provider<NotificationRepository>((ref) => MockNotificationRepository());
