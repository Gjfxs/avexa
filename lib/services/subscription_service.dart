
import 'supabase_service.dart';
import 'package:flutter/foundation.dart';

class SubscriptionService {
  SubscriptionService._();

  static final _supabase = SupabaseService.client;

  // ============================================================
  // CHECK IF USER IS PRO
  // ============================================================

  static Future<bool> isPro() async {
    try {
      final user = _supabase.auth.currentUser;

      if (user == null) {
        debugPrint('SUBSCRIPTION CHECK: NO USER');
        return false;
      }

      final now = DateTime.now().toUtc().toIso8601String();

      final response = await _supabase
          .from('user_subscriptions')
          .select('id, status, expires_at, revocation_date')
          .eq('user_id', user.id)
          .eq('status', 'active')
          .gt('expires_at', now)
          .isFilter('revocation_date', null)
          .limit(1);

      debugPrint('SUBSCRIPTION DEBUG USER: ${user.id}');
      debugPrint('SUBSCRIPTION DEBUG NOW: $now');
      debugPrint('SUBSCRIPTION DEBUG RESPONSE: $response');

      final isPro = response.isNotEmpty;

      debugPrint('SUBSCRIPTION CHECK: PRO = $isPro');

      return isPro;
    } catch (error) {
      debugPrint('SUBSCRIPTION CHECK ERROR: $error');
      return false;
    }
  }

  // ============================================================
  // USE FREE SIGNAL
  // ============================================================

  static Future<bool> consumeFreeSignal() async {
    final response = await _supabase.rpc(
      'consume_free_signal',
    );

    return response == true;
  }

  // ============================================================
  // CHECK IF FREE SIGNAL WAS USED TODAY
  // ============================================================

  static Future<bool> hasUsedFreeSignalToday() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      return false;
    }

    final response = await _supabase
        .from('signal_daily_usage')
        .select('id')
        .eq('user_id', user.id)
        .eq(
          'usage_date',
          DateTime.now()
              .toIso8601String()
              .substring(0, 10),
        )
        .maybeSingle();

    return response != null;
  }
}
