import 'package:flutter/services.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth/local_auth.dart';

class BiometricAuthService {
  final LocalAuthentication _authentication = LocalAuthentication();

  Future<bool> canAuthenticate() async {
    try {
      final canCheck = await _authentication.canCheckBiometrics;
      final isSupported = await _authentication.isDeviceSupported();
      return canCheck || isSupported;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      return await _authentication.authenticate(
        localizedReason: 'Authenticate to unlock your banking session',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
    } on PlatformException catch (error) {
      if (error.code == auth_error.notAvailable ||
          error.code == auth_error.notEnrolled ||
          error.code == auth_error.passcodeNotSet) {
        return false;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
