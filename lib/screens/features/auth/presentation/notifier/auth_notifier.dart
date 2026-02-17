import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:online_banking_system/screens/features/auth/domain/auth_repository.dart';
import 'package:online_banking_system/screens/features/auth/presentation/providers/auth_provider.dart';
import 'package:online_banking_system/screens/features/auth/presentation/state/auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository repository;

  AuthNotifier(this.repository) : super(AuthState());

  Future<void> register(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await repository.register(email, password);
      state = state.copyWith(isLoading: false);
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Registration failed';
      state = state.copyWith(isLoading: false, error: errorMessage);
      rethrow;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> verifyOtp(String email, String code) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await repository.verifyOtp(email, code);
      state = state.copyWith(isLoading: false);
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['message'] ?? 'OTP verification failed';
      state = state.copyWith(isLoading: false, error: errorMessage);
      rethrow;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Здесь добавьте метод login в repository
      // await repository.login(email, password);
      state = state.copyWith(isLoading: false);
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Login failed';
      state = state.copyWith(isLoading: false, error: errorMessage);
      rethrow;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }
}

// Провайдер для AuthNotifier
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});
