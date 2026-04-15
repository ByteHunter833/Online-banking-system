import 'package:online_banking_system/shared/models/banking_models.dart';

abstract class AuthRepository {
  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    String? phone,
  });

  Future<User> login(String email, String password);
  Future<void> verifyOtp(String email, String code);
  Future<void> forgotPassword(String email);
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });
  Future<void> logout();
}
