import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AuthResponse parses camelCase JSON from API', () {
    final response = AuthResponse.fromJson({
      'token': 'jwt-abc',
      'userId': 42,
      'email': 'driver@test.com',
      'firstName': 'Test',
      'lastName': 'Driver',
      'role': 'Driver',
    });

    expect(response.token, 'jwt-abc');
    expect(response.userId, 42);
    expect(response.role, UserRole.driver);
    expect(response.fullName, 'Test Driver');
  });

  test('AuthResponse round-trips through token storage JSON', () async {
    final storage = MemoryTokenStorage();
    const original = AuthResponse(
      token: 'jwt',
      userId: 1,
      email: 'a@b.com',
      firstName: 'A',
      lastName: 'B',
      role: UserRole.admin,
    );

    await storage.writeSession(original);
    final restored = await storage.readSession();

    expect(restored?.email, 'a@b.com');
    expect(restored?.role, UserRole.admin);
    expect(restored?.token, 'jwt');
  });
}
