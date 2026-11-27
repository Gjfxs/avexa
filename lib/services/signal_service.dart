import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

class SignalService {
  SignalService._();

  static final SupabaseClient _supabase =
      SupabaseService.client;

  // ============================================================
  // GET ACTIVE SIGNALS
  // ============================================================

  static Future<List<Map<String, dynamic>>> getActiveSignals({
    String? timeframe,
  }) async {
    dynamic query = _supabase
        .from('signals')
        .select()
        .inFilter(
          'status',
          ['ACTIVE', 'TP1_HIT', 'TP2_HIT'],
        );

    if (timeframe != null) {
      query = query.eq('timeframe', timeframe);
    }

    final response = await query.order(
      'created_at',
      ascending: false,
    );

    return (response as List)
        .map(
          (item) => Map<String, dynamic>.from(item),
        )
        .toList();
  }

  // ============================================================
  // GET SIGNAL HISTORY
  // ============================================================

  static Future<List<Map<String, dynamic>>> getSignalHistory({
    int limit = 50,
  }) async {
    final response = await _supabase
        .from('signals')
        .select()
        .order(
          'created_at',
          ascending: false,
        )
        .limit(limit);

    return (response as List)
        .map(
          (item) => Map<String, dynamic>.from(item),
        )
        .toList();
  }

  // ============================================================
  // GET SINGLE SIGNAL
  // ============================================================

  static Future<Map<String, dynamic>?> getSignal(
    String signalId,
  ) async {
    final response = await _supabase
        .from('signals')
        .select()
        .eq('id', signalId)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return Map<String, dynamic>.from(response);
  }

  // ============================================================
  // GET LIVE MARKET DATA
  // ============================================================

  static Future<Map<String, dynamic>?> getMarketData(
    String tokenAddress,
  ) async {
    if (tokenAddress.trim().isEmpty) {
      return null;
    }

    try {
      final response = await _supabase.functions.invoke(
        'get-token-market-data',
        body: {
          'token_address': tokenAddress.trim(),
        },
      );

      if (response.data == null) {
        return null;
      }

      if (response.data is Map) {
        return Map<String, dynamic>.from(
          response.data as Map,
        );
      }

      return null;
    } catch (error) {
      print(
        'GET MARKET DATA ERROR: $error',
      );

      return null;
    }
  }

  // ============================================================
  // CHECK SIGNAL ACCESS
  // ============================================================

  static Future<Map<String, dynamic>> checkSignalAccess(
    String signalId,
  ) async {
    final response = await _supabase.rpc(
      'get_signal_access',
      params: {
        'p_signal_id': signalId,
      },
    );

    return Map<String, dynamic>.from(response);
  }

  // ============================================================
  // GET LIVE MARKET DATA
  // ============================================================

  static Future<Map<String, dynamic>> getTokenMarketData(
    String tokenAddress,
  ) async {
    final response = await _supabase.functions.invoke(
      'get-token-market-data',
      body: {
        'token_address': tokenAddress,
      },
    );

    if (response.data == null) {
      throw Exception('No market data returned.');
    }

    final data = Map<String, dynamic>.from(
      response.data as Map,
    );

    if (data['success'] == false) {
      throw Exception(
        data['error']?.toString() ??
            'Unable to load market data.',
      );
    }

    return data;
  }
  // ============================================================
  // GET ACTIVE FUTURES PRO SIGNALS
  // ============================================================

  static Future<List<Map<String, dynamic>>> getActiveFuturesSignals({
    int limit = 5,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();

    final response = await _supabase
        .from('signals')
        .select()
        .eq('market', 'FUTURES')
        .inFilter(
          'status',
          ['ACTIVE', 'TP1_HIT', 'TP2_HIT'],
        )
        .gt('expires_at', now)
        .order('created_at', ascending: false)
        .limit(limit);

    return (response as List)
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

}