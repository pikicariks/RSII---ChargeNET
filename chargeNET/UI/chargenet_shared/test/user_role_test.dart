import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('UserRole maps API names and access rules', () {
    expect(UserRole.fromApi('Admin'), UserRole.admin);
    expect(UserRole.fromApi('driver'), UserRole.driver);
    expect(UserRole.admin.canAccessDesktop, isTrue);
    expect(UserRole.driver.canAccessDesktop, isFalse);
    expect(UserRole.driver.canAccessMobile, isTrue);
  });
}
