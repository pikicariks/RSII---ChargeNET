import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../api/api_exception.dart';
import '../api/chargenet_api.dart';
import '../auth/auth_service.dart';
import '../auth/auth_state.dart';
import '../auth/token_storage.dart';
import '../config/app_config.dart';

final tokenStorageProvider = FutureProvider<TokenStorage>((ref) async {
  return createTokenStorage();
});

final apiClientProvider = FutureProvider<ApiClient>((ref) async {
  final storage = await ref.watch(tokenStorageProvider.future);

  return ApiClient(
    baseUrl: AppConfig.apiBaseUrl,
    tokenStorage: storage,
    onUnauthorized: () {
      ref.read(authProvider.notifier).logout(sessionExpired: true);
    },
  );
});

final authServiceProvider = FutureProvider<AuthService>((ref) async {
  final client = await ref.watch(apiClientProvider.future);
  return AuthService(client);
});

final chargeNetApiProvider = FutureProvider<ChargeNetApi>((ref) async {
  final client = await ref.watch(apiClientProvider.future);
  return ChargeNetApi(client);
});

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    Future.microtask(_restoreSession);
    return const AuthState();
  }

  Future<TokenStorage> get _storage async =>
      await ref.read(tokenStorageProvider.future);

  Future<AuthService> get _authService async =>
      await ref.read(authServiceProvider.future);

  Future<void> _restoreSession() async {
    try {
      final storage = await _storage;
      final session = await storage.readSession();
      state = state.copyWith(
        session: session,
        isRestoring: false,
        clearSession: session == null,
      );
    } catch (_) {
      state = state.copyWith(isRestoring: false, clearSession: true);
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(apiClientProvider.future);
      final response = await (await _authService).login(
        email: email.trim(),
        password: password,
      );
      await (await _storage).writeSession(response);
      state = state.copyWith(
        session: response,
        isLoading: false,
        isRestoring: false,
        clearError: true,
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Login failed. Please try again.',
      );
      return false;
    }
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(apiClientProvider.future);
      final response = await (await _authService).register(
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        email: email.trim(),
        password: password,
        phoneNumber: phoneNumber?.trim(),
      );
      await (await _storage).writeSession(response);
      state = state.copyWith(
        session: response,
        isLoading: false,
        isRestoring: false,
        clearError: true,
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Registration failed. Please try again.',
      );
      return false;
    }
  }

  Future<void> logout({bool sessionExpired = false}) async {
    try {
      await (await _storage).clear();
    } catch (_) {
      // Best-effort clear.
    }
    state = AuthState(
      isRestoring: false,
      error: sessionExpired
          ? 'Your session has expired. Please sign in again.'
          : null,
    );
  }
}
