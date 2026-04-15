import 'dart:convert';

import 'package:online_banking_system/shared/models/banking_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  SessionManager._();

  static final SessionManager instance = SessionManager._();
  static const _accessTokenKey = 'session.access_token';
  static const _refreshTokenKey = 'session.refresh_token';
  static const _currentUserKey = 'session.current_user';
  static const _onboardingSeenKey = 'app.onboarding_seen';

  String? _accessToken;
  String? _refreshToken;
  User? _currentUser;
  bool _hasSeenOnboarding = false;
  SharedPreferences? _preferences;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  User? get currentUser => _currentUser;
  bool get hasSeenOnboarding => _hasSeenOnboarding;
  bool get isAuthenticated =>
      _accessToken != null && _accessToken!.trim().isNotEmpty;

  Future<SharedPreferences> _getPreferences() async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  Future<void> restoreSession() async {
    final preferences = await _getPreferences();
    _accessToken = preferences.getString(_accessTokenKey);
    _refreshToken = preferences.getString(_refreshTokenKey);
    _hasSeenOnboarding = preferences.getBool(_onboardingSeenKey) ?? false;

    final userJson = preferences.getString(_currentUserKey);
    if (userJson == null || userJson.trim().isEmpty) {
      _currentUser = null;
      return;
    }

    try {
      _currentUser = User.fromJson(
        jsonDecode(userJson) as Map<String, dynamic>,
      );
    } catch (_) {
      _currentUser = null;
      await preferences.remove(_currentUserKey);
    }
  }

  Future<void> setSession({
    required String accessToken,
    required String refreshToken,
    User? currentUser,
  }) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _currentUser = currentUser;
    return _persist();
  }

  Future<void> updateTokens({
    required String accessToken,
    required String refreshToken,
  }) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    return _persist();
  }

  Future<void> setCurrentUser(User? user) {
    _currentUser = user;
    return _persist();
  }

  Future<void> setOnboardingSeen(bool value) async {
    _hasSeenOnboarding = value;
    final preferences = await _getPreferences();
    await preferences.setBool(_onboardingSeenKey, value);
  }

  Future<void> clear() async {
    _accessToken = null;
    _refreshToken = null;
    _currentUser = null;
    final preferences = await _getPreferences();
    await Future.wait([
      preferences.remove(_accessTokenKey),
      preferences.remove(_refreshTokenKey),
      preferences.remove(_currentUserKey),
    ]);
  }

  Future<void> _persist() async {
    final preferences = await _getPreferences();
    await Future.wait([
      if (_accessToken == null || _accessToken!.trim().isEmpty)
        preferences.remove(_accessTokenKey)
      else
        preferences.setString(_accessTokenKey, _accessToken!),
      if (_refreshToken == null || _refreshToken!.trim().isEmpty)
        preferences.remove(_refreshTokenKey)
      else
        preferences.setString(_refreshTokenKey, _refreshToken!),
      if (_currentUser == null)
        preferences.remove(_currentUserKey)
      else
        preferences.setString(
          _currentUserKey,
          jsonEncode(_currentUser!.toJson()),
        ),
    ]);
  }
}
