# API Integration Guide for FinanceFlow Banking App

This guide walks you through integrating your FastAPI backend with the FinanceFlow Flutter app.

## 📋 Overview

The app is structured with:

- **Frontend**: Flutter with Riverpod for state management
- **Backend**: FastAPI (to be implemented)
- **Models**: Defined in `lib/models/banking_models.dart`
- **Mock Data**: `lib/data/mock_data_service.dart` (for testing)

## 🔗 API Endpoints Required

### Authentication Endpoints

```
POST   /api/v1/auth/register
POST   /api/v1/auth/login
POST   /api/v1/auth/logout
POST   /api/v1/auth/refresh-token
POST   /api/v1/auth/verify-otp
POST   /api/v1/auth/send-otp
POST   /api/v1/auth/forgot-password
POST   /api/v1/auth/reset-password
```

### User Endpoints

```
GET    /api/v1/users/me
PUT    /api/v1/users/me
PUT    /api/v1/users/change-password
```

### Account Endpoints

```
GET    /api/v1/accounts
GET    /api/v1/accounts/{id}
POST   /api/v1/accounts
```

### Card Endpoints

```
GET    /api/v1/cards
GET    /api/v1/cards/{id}
POST   /api/v1/cards
PUT    /api/v1/cards/{id}/freeze
PUT    /api/v1/cards/{id}/unfreeze
```

### Transaction Endpoints

```
GET    /api/v1/transactions
GET    /api/v1/transactions/{id}
POST   /api/v1/transfers
GET    /api/v1/transfers/{id}
GET    /api/v1/transactions/history
```

### Recipient Endpoints

```
GET    /api/v1/recipients
POST   /api/v1/recipients
DELETE /api/v1/recipients/{id}
PUT    /api/v1/recipients/{id}/favorite
```

### Notification Endpoints

```
GET    /api/v1/notifications
PUT    /api/v1/notifications/{id}/read
PUT    /api/v1/notifications/mark-all-read
DELETE /api/v1/notifications/{id}
```

## 🏗️ Step-by-Step Integration

### Step 1: Update DioClient Configuration

File: `lib/core/dio_client.dart`

```dart
import 'package:dio/dio.dart';

class DioClient {
  static Dio create({String? token}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'http://your-backend-api.com/api/v1',
        // baseUrl: 'http://10.0.2.2:8000/api/v1', // For Android emulator
        // baseUrl: 'http://localhost:8000/api/v1', // For iOS simulator
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    // Add request interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('REQUEST: ${options.method} ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('RESPONSE: ${response.statusCode}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          print('ERROR: ${e.message}');
          return handler.next(e);
        },
      ),
    );

    // Add logging
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: true,
        error: true,
        logPrint: (obj) => print('DIO: $obj'),
      ),
    );

    return dio;
  }
}
```

### Step 2: Create Repository Classes

Create `lib/data/repositories/auth_repository.dart`:

```dart
import 'package:dio/dio.dart';
import 'package:online_banking_system/core/dio_client.dart';
import 'package:online_banking_system/models/banking_models.dart';

class AuthRepository {
  final Dio dio;

  AuthRepository({required this.dio});

  Future<String> login(String email, String password) async {
    try {
      final response = await dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      // Store token in secure storage
      final token = response.data['access_token'];
      return token;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<User> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '/auth/register',
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'password': password,
        },
      );

      return User.fromJson(response.data['user']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<User> getCurrentUser() async {
    try {
      final response = await dio.get('/users/me');
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    if (error.response?.statusCode == 401) {
      return 'Unauthorized. Please login again.';
    } else if (error.response?.statusCode == 400) {
      return error.response?.data['detail'] ?? 'Bad request';
    } else if (error.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout';
    }
    return 'An error occurred';
  }
}
```

Create `lib/data/repositories/account_repository.dart`:

```dart
import 'package:dio/dio.dart';
import 'package:online_banking_system/models/banking_models.dart';

class AccountRepository {
  final Dio dio;

  AccountRepository({required this.dio});

  Future<List<Account>> getAccounts() async {
    try {
      final response = await dio.get('/accounts');
      return (response.data['accounts'] as List)
          .map((account) => Account.fromJson(account))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Account> getAccount(String id) async {
    try {
      final response = await dio.get('/accounts/$id');
      return Account.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    return error.response?.data['detail'] ?? 'Failed to fetch accounts';
  }
}
```

Similarly create repositories for:

- `transaction_repository.dart`
- `card_repository.dart`
- `recipient_repository.dart`
- `notification_repository.dart`

### Step 3: Update Providers

File: `lib/providers/app_providers.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_banking_system/core/dio_client.dart';
import 'package:online_banking_system/data/repositories/account_repository.dart';
import 'package:online_banking_system/models/banking_models.dart';
import 'package:online_banking_system/data/repositories/auth_repository.dart';

// Dio Provider
final dioProvider = Provider((ref) => DioClient.create());

// Repository Providers
final authRepositoryProvider = Provider((ref) {
  return AuthRepository(dio: ref.watch(dioProvider));
});

final accountRepositoryProvider = Provider((ref) {
  return AccountRepository(dio: ref.watch(dioProvider));
});

// Auth Providers
final userProvider = FutureProvider<User>((ref) async {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.getCurrentUser();
});

// Account Providers
final accountsProvider = FutureProvider<List<Account>>((ref) async {
  final accountRepo = ref.watch(accountRepositoryProvider);
  return accountRepo.getAccounts();
});

final primaryAccountProvider = FutureProvider<Account>((ref) async {
  final accounts = await ref.watch(accountsProvider.future);
  return accounts.firstWhere((acc) => acc.isPrimary);
});

// Add more providers for cards, transactions, etc.
```

### Step 4: Update Screens to Use Real Data

Example: Update `HomeScreen`

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final userAsync = ref.watch(userProvider);
  final primaryAccountAsync = ref.watch(primaryAccountProvider);
  final transactionsAsync = ref.watch(transactionsProvider);

  return Scaffold(
    // ... existing code ...
    body: userAsync.when(
      data: (user) {
        return SingleChildScrollView(
          child: Column(
            children: [
              // Display user greeting
              Text('${AppStrings.hello}, ${user.firstName}!'),

              // ... rest of the UI ...
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: EmptyState(
          icon: Icons.error_outline,
          title: 'Error',
          message: error.toString(),
          onRetry: () => ref.refresh(userProvider),
        ),
      ),
    ),
  );
}
```

### Step 5: Implement Error Handling

Create `lib/core/exceptions.dart`:

```dart
class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException({required this.message, this.statusCode});

  @override
  String toString() => 'AppException: $message';
}

class NetworkException extends AppException {
  NetworkException({required String message})
      : super(message: 'Network Error: $message');
}

class ServerException extends AppException {
  ServerException({required String message, int? statusCode})
      : super(message: message, statusCode: statusCode);
}

class ValidationException extends AppException {
  ValidationException({required String message})
      : super(message: 'Validation Error: $message');
}
```

### Step 6: Add Token Management

Create `lib/core/token_manager.dart`:

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenManager {
  static const _tokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  final _storage = const FlutterSecureStorage();

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: _tokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}
```

## 🔐 Security Best Practices

1. **Use HTTPS**: Always use HTTPS in production
2. **Secure Storage**: Store tokens in platform-specific secure storage
3. **Token Refresh**: Implement token refresh mechanism
4. **Input Validation**: Validate all user inputs
5. **Error Messages**: Don't expose sensitive information in errors
6. **Certificate Pinning**: Consider for high-security apps

## 📝 Testing Integration

Add to `pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.0
```

Create `test/repositories/account_repository_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:online_banking_system/data/repositories/account_repository.dart';

void main() {
  group('AccountRepository', () {
    late MockDio mockDio;
    late AccountRepository repository;

    setUp(() {
      mockDio = MockDio();
      repository = AccountRepository(dio: mockDio);
    });

    test('getAccounts returns list of accounts', () async {
      // Arrange
      when(mockDio.get('/accounts')).thenAnswer(
        (_) async => Response(
          data: {
            'accounts': [
              {'id': '1', 'account_type': 'current'},
            ]
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/accounts'),
        ),
      );

      // Act
      final accounts = await repository.getAccounts();

      // Assert
      expect(accounts.length, 1);
      expect(accounts[0].accountType, 'current');
    });
  });
}
```

## 🚀 Deployment

1. Update `baseUrl` in `DioClient` for production
2. Enable code obfuscation
3. Test on distribution certificates
4. Use environment-specific configuration
5. Implement proper error logging (Sentry)

## 📞 Troubleshooting

### Connection Issues

- Check API endpoint URL
- Verify network connectivity
- Check firewall rules
- Enable CORS on backend

### Token Issues

- Ensure token is being saved
- Check token expiration handling
- Verify refresh token endpoint

### Data Mapping Issues

- Verify API response matches model
- Check field naming (snake_case vs camelCase)
- Log API responses for debugging

## 📚 References

- Dio Documentation: https://github.com/flutterchina/dio
- Riverpod Documentation: https://riverpod.dev
- Flutter Secure Storage: https://pub.dev/packages/flutter_secure_storage
