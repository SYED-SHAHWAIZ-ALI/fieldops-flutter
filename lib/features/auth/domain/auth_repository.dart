import 'app_user.dart';

/// Auth repository contract. A future `ApiAuthRepository` implementing
/// this interface can call the FastAPI backend without any change to
/// the presentation layer.
abstract class AuthRepository {
  Future<AppUser> login({required String email, required String password});
  Future<void> logout();
  Future<AppUser?> getCurrentUser();
}

class InvalidCredentialsException implements Exception {
  final String message;
  InvalidCredentialsException([this.message = 'Invalid email or password.']);

  @override
  String toString() => message;
}
