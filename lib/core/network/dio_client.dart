import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:online_banking_system/core/session/session_manager.dart';

class DioClient {
  static const String defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );
  static Future<Map<String, dynamic>>? _refreshFuture;

  static Dio create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: defaultBaseUrl,
        headers: {'Content-Type': 'application/json'},
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = SessionManager.instance.accessToken;
          if (token != null && token.trim().isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          handler.next(options);
        },
        onError: (error, handler) async {
          final statusCode = error.response?.statusCode;
          final request = error.requestOptions;
          final refreshToken = SessionManager.instance.refreshToken;
          final isRefreshRequest = request.path.endsWith('/auth/refresh');
          final alreadyRetried = request.extra['retried_after_refresh'] == true;

          if (statusCode == 401 &&
              !isRefreshRequest &&
              !alreadyRetried &&
              refreshToken != null &&
              refreshToken.trim().isNotEmpty) {
            try {
              final refreshed = await _refreshTokens(refreshToken);
              final accessToken = refreshed['access_token'] as String;
              final nextRefreshToken =
                  (refreshed['refresh_token'] as String?) ?? refreshToken;

              await SessionManager.instance.updateTokens(
                accessToken: accessToken,
                refreshToken: nextRefreshToken,
              );

              final response = await dio.fetch<dynamic>(
                request.copyWith(
                  headers: <String, dynamic>{
                    ...request.headers,
                    'Authorization': 'Bearer $accessToken',
                  },
                  extra: <String, dynamic>{
                    ...request.extra,
                    'retried_after_refresh': true,
                  },
                ),
              );

              handler.resolve(response);
              return;
            } catch (_) {
              await SessionManager.instance.clear();
            }
          }

          handler.next(error);
        },
      ),
    );

    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: true,
        error: true,
        logPrint: (obj) => debugPrint('DIO LOG: $obj'),
      ),
    );

    return dio;
  }

  static Future<Map<String, dynamic>> _refreshTokens(String refreshToken) {
    final existing = _refreshFuture;
    if (existing != null) {
      return existing;
    }

    final completer = Completer<Map<String, dynamic>>();
    _refreshFuture = completer.future;

    () async {
      try {
        final refreshDio = Dio(
          BaseOptions(
            baseUrl: defaultBaseUrl,
            headers: {'Content-Type': 'application/json'},
            connectTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 20),
          ),
        );

        final response = await refreshDio.post(
          '/auth/refresh',
          data: {'refresh_token': refreshToken},
        );
        completer.complete(Map<String, dynamic>.from(response.data as Map));
      } catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      } finally {
        _refreshFuture = null;
      }
    }();

    return completer.future;
  }
}
