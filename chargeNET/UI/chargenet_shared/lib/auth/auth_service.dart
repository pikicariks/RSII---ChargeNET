import '../api/api_client.dart';
import '../api/endpoints.dart';
import '../models/auth_response.dart';

/// Pure Dart auth API calls — no widget state.
class AuthService {
  const AuthService(this._client);

  final ApiClient _client;

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) {
    return _client.post(
      ApiEndpoints.authLogin,
      data: {'email': email, 'password': password},
      parser: (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<AuthResponse> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phoneNumber,
  }) {
    return _client.post(
      ApiEndpoints.authRegister,
      data: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        if (phoneNumber != null && phoneNumber.isNotEmpty)
          'phoneNumber': phoneNumber,
      },
      parser: (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
    );
  }
}
