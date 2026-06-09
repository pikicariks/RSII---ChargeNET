import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_response.dart';

/// Persists JWT and user session across app restarts.
abstract class TokenStorage {
  Future<String?> readToken();
  Future<AuthResponse?> readSession();
  Future<void> writeSession(AuthResponse session);
  Future<void> clear();
}

const _sessionKey = 'chargenet_auth_session';

/// Mobile (iOS/Android) — encrypted keychain / keystore.
class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  final FlutterSecureStorage _storage;

  @override
  Future<String?> readToken() async {
    final session = await readSession();
    return session?.token;
  }

  @override
  Future<AuthResponse?> readSession() async {
    final raw = await _storage.read(key: _sessionKey);
    if (raw == null || raw.isEmpty) return null;
    return AuthResponse.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  @override
  Future<void> writeSession(AuthResponse session) async {
    await _storage.write(
      key: _sessionKey,
      value: jsonEncode(session.toJson()),
    );
  }

  @override
  Future<void> clear() => _storage.delete(key: _sessionKey);
}

/// Desktop / web fallback — acceptable for seminar builds.
class SharedPreferencesTokenStorage implements TokenStorage {
  SharedPreferencesTokenStorage(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<String?> readToken() async {
    final session = await readSession();
    return session?.token;
  }

  @override
  Future<AuthResponse?> readSession() async {
    final raw = _prefs.getString(_sessionKey);
    if (raw == null || raw.isEmpty) return null;
    return AuthResponse.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  @override
  Future<void> writeSession(AuthResponse session) async {
    await _prefs.setString(_sessionKey, jsonEncode(session.toJson()));
  }

  @override
  Future<void> clear() => _prefs.remove(_sessionKey);
}

/// In-memory storage for unit tests.
class MemoryTokenStorage implements TokenStorage {
  AuthResponse? _session;

  @override
  Future<void> clear() async => _session = null;

  @override
  Future<AuthResponse?> readSession() async => _session;

  @override
  Future<String?> readToken() async => _session?.token;

  @override
  Future<void> writeSession(AuthResponse session) async {
    _session = session;
  }
}

/// Picks secure storage on mobile, shared preferences elsewhere.
Future<TokenStorage> createTokenStorage() async {
  if (kIsWeb) {
    final prefs = await SharedPreferences.getInstance();
    return SharedPreferencesTokenStorage(prefs);
  }

  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
    case TargetPlatform.iOS:
      return SecureTokenStorage();
    default:
      final prefs = await SharedPreferences.getInstance();
      return SharedPreferencesTokenStorage(prefs);
  }
}
