
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OnboardingService {
  OnboardingService._();

  static final OnboardingService instance =
      OnboardingService._();

  static const FlutterSecureStorage _storage =
      FlutterSecureStorage();

  // New device-level onboarding flag.
  static const String _completedKey =
      'avexa_onboarding_completed';

  // Legacy account-level key, kept for migration.
  String? get _legacyCompletedKey {
    final userId =
        Supabase.instance.client.auth.currentUser?.id;

    if (userId == null) return null;

    return 'avexa_onboarding_completed_$userId';
  }

  Future<bool> isCompleted() async {
    // First check the new device-level flag.
    final completed =
        await _storage.read(key: _completedKey);

    if (completed == 'true') {
      return true;
    }

    // Migrate the old account-level flag when a user
    // is already signed in.
    final legacyKey = _legacyCompletedKey;

    if (legacyKey != null) {
      final legacyCompleted =
          await _storage.read(key: legacyKey);

      if (legacyCompleted == 'true') {
        await _storage.write(
          key: _completedKey,
          value: 'true',
        );

        return true;
      }
    }

    return false;
  }

  Future<void> markCompleted() async {
    // Onboarding can now be completed before login.
    await _storage.write(
      key: _completedKey,
      value: 'true',
    );

    // Keep the old account-level flag as well when
    // a user happens to be signed in.
    final legacyKey = _legacyCompletedKey;

    if (legacyKey != null) {
      await _storage.write(
        key: legacyKey,
        value: 'true',
      );
    }
  }
}
