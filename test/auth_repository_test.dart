import 'package:flutter_test/flutter_test.dart';
import 'package:fieldops/features/auth/data/mock_auth_repository.dart';
import 'package:fieldops/features/auth/domain/auth_repository.dart';

void main() {
  group('MockAuthRepository', () {
    late MockAuthRepository repository;

    setUp(() {
      repository = MockAuthRepository();
    });

    test('login succeeds with correct demo credentials', () async {
      final user = await repository.login(
        email: 'field.agent@fieldops.com',
        password: 'demo123',
      );
      expect(user.name, 'Alex Morgan');
    });

    test('login throws InvalidCredentialsException with wrong password',
        () async {
      expect(
        () => repository.login(
            email: 'field.agent@fieldops.com', password: 'wrong'),
        throwsA(isA<InvalidCredentialsException>()),
      );
    });

    test('login throws InvalidCredentialsException with unknown email',
        () async {
      expect(
        () =>
            repository.login(email: 'nobody@fieldops.com', password: 'demo123'),
        throwsA(isA<InvalidCredentialsException>()),
      );
    });

    test('getCurrentUser is null until a successful login', () async {
      expect(await repository.getCurrentUser(), isNull);
      await repository.login(
          email: 'field.agent@fieldops.com', password: 'demo123');
      expect(await repository.getCurrentUser(), isNotNull);
    });

    test('logout clears the current session', () async {
      await repository.login(
          email: 'field.agent@fieldops.com', password: 'demo123');
      await repository.logout();
      expect(await repository.getCurrentUser(), isNull);
    });
  });
}
