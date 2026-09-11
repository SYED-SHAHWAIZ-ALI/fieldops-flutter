import '../../../core/constants/app_constants.dart';
import '../domain/app_user.dart';
import '../domain/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  AppUser? _currentUser;

  static const _demoUser = AppUser(
    id: 'EMP-2048',
    name: 'Alex Morgan',
    title: 'Senior Field Technician',
    employeeId: 'EMP-2048',
    email: AppConstants.demoEmail,
  );

  @override
  Future<AppUser> login(
      {required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 900));

    if (email.trim().toLowerCase() != AppConstants.demoEmail.toLowerCase() ||
        password != AppConstants.demoPassword) {
      throw InvalidCredentialsException();
    }

    _currentUser = _demoUser;
    return _demoUser;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
  }

  @override
  Future<AppUser?> getCurrentUser() async => _currentUser;
}
