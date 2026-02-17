abstract class AuthRepository {
  Future<void> register(String email, String password);
  Future<void> verifyOtp(String email, String code);
}
