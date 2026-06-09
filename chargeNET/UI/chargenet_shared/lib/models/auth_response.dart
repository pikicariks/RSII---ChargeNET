import '../auth/user_role.dart';

/// Response from POST /api/auth/login and /api/auth/register.
class AuthResponse {
  const AuthResponse({
    required this.token,
    required this.userId,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
  });

  final String token;
  final int userId;
  final String email;
  final String firstName;
  final String lastName;
  final UserRole role;

  String get fullName => '$firstName $lastName'.trim();

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String? ?? '',
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      email: json['email'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      role: UserRole.fromApi(json['role'] as String?),
    );
  }

  Map<String, dynamic> toJson() => {
        'token': token,
        'userId': userId,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'role': role.apiName,
      };
}
