import '../domain/auth_repository.dart';
import 'auth_api.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApi api;

  AuthRepositoryImpl(this.api);

  @override
  Future<void> register(String email, String password) {
    return api.register(email: email, password: password);
  }

  @override
  Future<void> verifyOtp(String code, String email) {
    return api.verifyOtp(code: code, email: email);
  }
}
