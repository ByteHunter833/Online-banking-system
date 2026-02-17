// 1. Провайдер для Dio
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_banking_system/core/dio_client.dart';
import 'package:online_banking_system/screens/features/auth/data/auth_api.dart';
import 'package:online_banking_system/screens/features/auth/data/auth_repository_impl.dart';

final dioProvider = Provider<Dio>((ref) {
  return DioClient.create();
});

// 2. Провайдер для AuthApi
final authApiProvider = Provider<AuthApi>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthApi(dio);
});

// 3. Провайдер для AuthRepository
final authRepositoryProvider = Provider<AuthRepositoryImpl>((ref) {
  final api = ref.watch(authApiProvider);
  return AuthRepositoryImpl(api);
});
