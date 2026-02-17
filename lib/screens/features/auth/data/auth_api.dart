import 'package:dio/dio.dart';

class AuthApi {
  final Dio dio;

  AuthApi(this.dio);
  Future<void> register({
    required String email,
    required String password,
  }) async {
    await dio.post(
      '/auth/register',
      data: {'email': email, 'password': password},
    );
  }

  Future<void> verifyOtp({required String email, required String code}) async {
    await dio.post(
      '/auth/verify-otp',
      data: {'email': email, 'otp_code': code},
    );
  }
}
