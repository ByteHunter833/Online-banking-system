import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_banking_system/core/dio_client.dart';
import 'package:online_banking_system/screens/features/auth/data/auth_api.dart';
import 'package:online_banking_system/screens/features/auth/data/auth_repository_impl.dart';
import '../../domain/auth_repository.dart';
import '../state/auth_state.dart';

final dioProvider = Provider((ref) {
  return DioClient.create();
});

final authApiProvider = Provider((ref) {
  return AuthApi(ref.read(dioProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.read(authApiProvider));
});

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

class AuthNotifier extends Notifier<AuthState> {
  AuthRepository get repository => ref.read(authRepositoryProvider);

  @override
  AuthState build() => const AuthState();

  Future<void> register(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await repository.register(email, password);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> verifyOtp(String code, String email) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await repository.verifyOtp(code, email);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
