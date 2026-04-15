import 'package:online_banking_system/core/session/session_manager.dart';
import 'package:online_banking_system/shared/models/banking_models.dart';

import '../domain/auth_repository.dart';
import 'auth_api.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApi api;

  AuthRepositoryImpl(this.api);

  @override
  Future<User> login(String email, String password) async {
    final data = await api.login(email: email, password: password);
    final user = User.fromApi(Map<String, dynamic>.from(data['user'] as Map));

    await SessionManager.instance.setSession(
      accessToken: data['access_token'] as String,
      refreshToken: data['refresh_token'] as String,
      currentUser: user,
    );

    return user;
  }

  @override
  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    String? phone,
  }) {
    return api.register(
      fullName: fullName,
      email: email,
      password: password,
      phone: phone,
    );
  }

  @override
  Future<void> verifyOtp(String email, String code) {
    return api.verifyOtp(code: code, email: email);
  }

  @override
  Future<void> forgotPassword(String email) {
    return api.forgotPassword(email: email);
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) {
    return api.resetPassword(
      email: email,
      code: code,
      newPassword: newPassword,
    );
  }

  @override
  Future<void> logout() async {
    final refreshToken = SessionManager.instance.refreshToken;
    if (refreshToken != null && refreshToken.trim().isNotEmpty) {
      await api.logout(refreshToken: refreshToken);
    }
    await SessionManager.instance.clear();
  }
}
