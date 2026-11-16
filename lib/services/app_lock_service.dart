import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppLockService {
  AppLockService._();

  static final AppLockService instance = AppLockService._();

  static const String _appLockEnabledKey =
      'analyx_app_lock_enabled';

  static const FlutterSecureStorage _storage =
      FlutterSecureStorage();

  Future<bool> isEnabled() async {
    final value = await _storage.read(
      key: _appLockEnabledKey,
    );

    return value == 'true';
  }

  Future<void> setEnabled(bool enabled) async {
    await _storage.write(
      key: _appLockEnabledKey,
      value: enabled.toString(),
    );
  }
}