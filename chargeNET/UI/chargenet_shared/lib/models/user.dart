import '../api/json_utils.dart';

class ChargeNetUser {
  const ChargeNetUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.roleId,
    required this.roleName,
    this.phoneNumber,
    this.cityId,
    this.cityName,
    this.address,
    this.isDeleted = false,
    required this.createdAt,
  });

  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final int roleId;
  final String roleName;
  final String? phoneNumber;
  final int? cityId;
  final String? cityName;
  final String? address;
  final bool isDeleted;
  final DateTime createdAt;

  String get fullName => '$firstName $lastName'.trim();

  factory ChargeNetUser.fromJson(Map<String, dynamic> json) {
    return ChargeNetUser(
      id: (json['id'] as num?)?.toInt() ?? 0,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      roleId: (json['roleId'] as num?)?.toInt() ?? 0,
      roleName: json['roleName'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String?,
      cityId: (json['cityId'] as num?)?.toInt(),
      cityName: json['cityName'] as String?,
      address: json['address'] as String?,
      isDeleted: json['isDeleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  static List<ChargeNetUser> listFromJson(dynamic json) =>
      parseJsonList(json, ChargeNetUser.fromJson);
}
