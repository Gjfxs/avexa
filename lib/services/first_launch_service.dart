import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FirstLaunchService {
  FirstLaunchService._();

  static final FirstLaunchService instance =
      FirstLaunchService._();

  static const String _languageSelectedKey =
      'avexa_language_selected';

  String? get _userId =>
      Supabase.instance.client.auth.currentUser?.id;

  String? _accountKey(String suffix) {
    final userId = _userId;

    if (userId == null) return null;

    return 'avexa_${userId}_$suffix';
  }

  Future<bool> hasSelectedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_languageSelectedKey) ?? false;
  }

  Future<void> markLanguageSelected() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_languageSelectedKey, true);
  }

  Future<bool> hasCompletedOnboarding() async {
    final key = _accountKey('onboarding_completed');
    if (key == null) return false;

    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }

  Future<void> markOnboardingCompleted() async {
    final key = _accountKey('onboarding_completed');
    if (key == null) {
      throw StateError(
        'Cannot save onboarding without a signed-in user.',
      );
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, true);
  }

  Future<bool> hasCompletedSubscriptionStep() async {
    final key = _accountKey('subscription_step_completed');
    if (key == null) return false;

    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }

  Future<void> markSubscriptionStepCompleted() async {
    final key = _accountKey('subscription_step_completed');
    if (key == null) {
      throw StateError(
        'Cannot save subscription selection without a signed-in user.',
      );
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, true);
  }
}