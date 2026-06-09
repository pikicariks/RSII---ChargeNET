import '../models/auth_response.dart';

/// Immutable auth state held by [AuthNotifier].
class AuthState {
  const AuthState({
    this.session,
    this.isLoading = false,
    this.isRestoring = true,
    this.error,
  });

  final AuthResponse? session;
  final bool isLoading;
  final bool isRestoring;
  final String? error;

  bool get isAuthenticated => session != null;

  AuthState copyWith({
    AuthResponse? session,
    bool? isLoading,
    bool? isRestoring,
    String? error,
    bool clearSession = false,
    bool clearError = false,
  }) {
    return AuthState(
      session: clearSession ? null : (session ?? this.session),
      isLoading: isLoading ?? this.isLoading,
      isRestoring: isRestoring ?? this.isRestoring,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
