import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:online_banking_system/shared/models/banking_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  SessionManager._();

  static final SessionManager instance = SessionManager._();
  static const _accessTokenKey = 'session.access_token';
  static const _refreshTokenKey = 'session.refresh_token';
  static const _currentUserKey = 'session.current_user';
  static const _unlockPinKey = 'session.unlock_pin';
  static const _onboardingSeenKey = 'app.onboarding_seen';
  static const _deviceIdKey = 'app.device_id';

  String? _accessToken;
  String? _refreshToken;
  String? _unlockPin;
  String? _deviceId;
  User? _currentUser;
  bool _hasSeenOnboarding = false;
  SharedPreferences? _preferences;
  final _sessionExpiredController = StreamController<void>.broadcast();

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  User? get currentUser => _currentUser;
  bool get hasSeenOnboarding => _hasSeenOnboarding;
  bool get hasUnlockPin =>
      _unlockPin != null && RegExp(r'^\d{4}$').hasMatch(_unlockPin!);
  Stream<void> get sessionExpiredStream => _sessionExpiredController.stream;
  bool get isAuthenticated =>
      _accessToken != null && _accessToken!.trim().isNotEmpty;

  Future<SharedPreferences> _getPreferences() async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  Future<void> restoreSession() async {
    final preferences = await _getPreferences();
    _accessToken = preferences.getString(_accessTokenKey);
    _refreshToken = preferences.getString(_refreshTokenKey);
    _unlockPin = preferences.getString(_unlockPinKey);
    _deviceId = preferences.getString(_deviceIdKey);
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
    _unlockPin = null;
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

  Future<void> setUnlockPin(String pin) {
    if (!RegExp(r'^\d{4}$').hasMatch(pin)) {
      throw ArgumentError('PIN must contain exactly 4 digits');
    }

    _unlockPin = pin;
    return _persist();
  }

  bool verifyUnlockPin(String pin) {
    return hasUnlockPin && _unlockPin == pin;
  }

  Future<({String id, String name})> getDeviceInfo() async {
    final id = await getDeviceId();
    return (id: id, name: _resolveDeviceName());
  }

  Future<String> getDeviceId() async {
    if (_deviceId != null && _deviceId!.trim().isNotEmpty) {
      return _deviceId!;
    }

    final preferences = await _getPreferences();
    final stored = preferences.getString(_deviceIdKey);
    if (stored != null && stored.trim().isNotEmpty) {
      _deviceId = stored;
      return stored;
    }

    final generated = _generateDeviceId();
    _deviceId = generated;
    await preferences.setString(_deviceIdKey, generated);
    return generated;
  }

  Future<void> setOnboardingSeen(bool value) async {
    _hasSeenOnboarding = value;
    final preferences = await _getPreferences();
    await preferences.setBool(_onboardingSeenKey, value);
  }

  Future<void> expireSession() async {
    await clear();
    _sessionExpiredController.add(null);
  }

  Future<void> clear() async {
    _accessToken = null;
    _refreshToken = null;
    _unlockPin = null;
    _currentUser = null;
    final preferences = await _getPreferences();
    await Future.wait([
      preferences.remove(_accessTokenKey),
      preferences.remove(_refreshTokenKey),
      preferences.remove(_unlockPinKey),
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
      if (_unlockPin == null || _unlockPin!.trim().isEmpty)
        preferences.remove(_unlockPinKey)
      else
        preferences.setString(_unlockPinKey, _unlockPin!),
      if (_currentUser == null)
        preferences.remove(_currentUserKey)
      else
        preferences.setString(
          _currentUserKey,
          jsonEncode(_currentUser!.toJson()),
        ),
    ]);
  }

  String _generateDeviceId() {
    final random = math.Random.secure();
    final suffix = List.generate(
      6,
      (_) => random.nextInt(1 << 16).toRadixString(16).padLeft(4, '0'),
    ).join();
    return 'financeflow-${DateTime.now().millisecondsSinceEpoch}-$suffix';
  }

  String _resolveDeviceName() {
    if (kIsWeb) {
      return 'Web browser';
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'Android device',
      TargetPlatform.iOS => 'iPhone or iPad',
      TargetPlatform.macOS => 'Mac',
      TargetPlatform.windows => 'Windows device',
      TargetPlatform.linux => 'Linux device',
      TargetPlatform.fuchsia => 'Fuchsia device',
    };
  }
}
