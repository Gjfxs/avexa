import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

class LocalAuthService {
  static final LocalAuthentication _auth =
      LocalAuthentication();

  static Future<bool> isAvailable() async {
    try {
      final canCheckBiometrics =
          await _auth.canCheckBiometrics;

      final isDeviceSupported =
          await _auth.isDeviceSupported();

      return canCheckBiometrics ||
          isDeviceSupported;
    } catch (e) {
      debugPrint(
        'LOCAL AUTH AVAILABILITY ERROR: $e',
      );

      return false;
    }
  }

  /// Systemowe uwierzytelnienie iPhone'a.
  ///
  /// biometricOnly: false oznacza:
  /// Face ID → jeżeli się nie powiedzie → kod iPhone'a.
  static Future<bool> authenticate() async {
    try {
      final available = await isAvailable();

      if (!available) {
        return false;
      }

      return await _auth.authenticate(
        localizedReason:
            'Unlock AnalyX with Face ID or your iPhone passcode',
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
    } catch (e) {
      debugPrint(
        'LOCAL AUTH ERROR: $e',
      );

      return false;
    }
  }

  /// Tylko biometryczne uwierzytelnienie.
  ///
  /// Na ten moment nie używamy tego do App Lock.
  static Future<bool> authenticateBiometric() async {
    try {
      final canCheck =
          await _auth.canCheckBiometrics;

      final supported =
          await _auth.isDeviceSupported();

      if (!canCheck && !supported) {
        return false;
      }

      return await _auth.authenticate(
        localizedReason:
            'Use Face ID to unlock AnalyX',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } catch (e) {
      debugPrint(
        'BIOMETRIC AUTH ERROR: $e',
      );

      return false;
    }
  }
}