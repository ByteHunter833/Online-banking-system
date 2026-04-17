import 'package:dio/dio.dart';

class AuthApi {
  final Dio dio;

  AuthApi(this.dio);

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    String? deviceId,
    String? deviceName,
    String? totpCode,
    String? recoveryCode,
  }) async {
    final response = await dio.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
        if (deviceId != null && deviceId.trim().isNotEmpty)
          'device_id': deviceId.trim(),
        if (deviceName != null && deviceName.trim().isNotEmpty)
          'device_name': deviceName.trim(),
        if (totpCode != null && totpCode.trim().isNotEmpty)
          'totp_code': totpCode.trim(),
        if (recoveryCode != null && recoveryCode.trim().isNotEmpty)
          'recovery_code': recoveryCode.trim(),
      },
    );

    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    String? phone,
  }) async {
    await dio.post(
      '/auth/register',
      data: {
        'full_name': fullName,
        'email': email,
        'password': password,
        if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
      },
    );
  }

  Future<void> verifyOtp({required String email, required String code}) async {
    await dio.post(
      '/auth/verify-email',
      data: {'email': email, 'otp_code': code},
    );
  }

  Future<void> forgotPassword({required String email}) async {
    await dio.post('/auth/forgot-password', data: {'email': email});
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await dio.post(
      '/auth/reset-password',
      data: {'email': email, 'otp_code': code, 'new_password': newPassword},
    );
  }

  Future<void> logout({required String refreshToken}) async {
    await dio.post('/auth/logout', data: {'refresh_token': refreshToken});
  }
}
