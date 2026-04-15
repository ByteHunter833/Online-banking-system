import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:online_banking_system/features/auth/domain/auth_repository.dart';
import 'package:online_banking_system/features/auth/presentation/providers/auth_provider.dart';
import 'package:online_banking_system/features/auth/presentation/state/auth_state.dart';
import 'package:online_banking_system/shared/models/banking_models.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository repository;

  AuthNotifier(this.repository) : super(const AuthState());

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    String? phone,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await repository.register(
        fullName: fullName,
        email: email,
        password: password,
        phone: phone,
      );
      state = state.copyWith(isLoading: false, error: null);
    } on DioException catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: _extractErrorMessage(error, fallback: 'Registration failed'),
      );
      rethrow;
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
      rethrow;
    }
  }

  Future<void> verifyOtp(String email, String code) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await repository.verifyOtp(email, code);
      state = state.copyWith(
        isLoading: false,
        isOtpVerified: true,
        error: null,
      );
    } on DioException catch (error) {
      state = state.copyWith(
        isLoading: false,
        isOtpVerified: false,
        error: _extractErrorMessage(error, fallback: 'OTP verification failed'),
      );
      rethrow;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        isOtpVerified: false,
        error: error.toString(),
      );
      rethrow;
    }
  }

  Future<User> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await repository.login(email, password);
      state = state.copyWith(isLoading: false, error: null);
      return user;
    } on DioException catch (error) {
      final message = _extractErrorMessage(error, fallback: 'Login failed');
      state = state.copyWith(isLoading: false, error: message);
      rethrow;
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
      rethrow;
    }
  }

  Future<void> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await repository.forgotPassword(email);
      state = state.copyWith(isLoading: false, error: null);
    } on DioException catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: _extractErrorMessage(error, fallback: 'Password reset failed'),
      );
      rethrow;
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
      rethrow;
    }
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await repository.resetPassword(
        email: email,
        code: code,
        newPassword: newPassword,
      );
      state = state.copyWith(isLoading: false, error: null);
    } on DioException catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: _extractErrorMessage(error, fallback: 'Password reset failed'),
      );
      rethrow;
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
      rethrow;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await repository.logout();
      state = state.copyWith(isLoading: false, error: null);
    } on DioException catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: _extractErrorMessage(error, fallback: 'Logout failed'),
      );
      rethrow;
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
      rethrow;
    }
  }

  String _extractErrorMessage(DioException error, {required String fallback}) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }

      final detail = data['detail'];
      if (detail is List && detail.isNotEmpty) {
        final first = detail.first;
        if (first is Map<String, dynamic>) {
          final msg = first['msg'];
          if (msg is String && msg.trim().isNotEmpty) {
            return msg;
          }
        }
      }
    }

    return error.message ?? fallback;
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});
