/// ChargeNET role names as returned by the API.
enum UserRole {
  admin('Admin'),
  technician('Technician'),
  driver('Driver'),
  unknown('Unknown');

  const UserRole(this.apiName);

  final String apiName;

  static UserRole fromApi(String? value) {
    if (value == null) return UserRole.unknown;
    return UserRole.values.firstWhere(
      (r) => r.apiName.toLowerCase() == value.toLowerCase(),
      orElse: () => UserRole.unknown,
    );
  }

  bool get canAccessDesktop =>
      this == UserRole.admin || this == UserRole.technician;

  bool get canAccessMobile =>
      this == UserRole.driver ||
      this == UserRole.admin ||
      this == UserRole.technician;
}
