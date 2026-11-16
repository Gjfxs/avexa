
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';


Future<void> testWalletRLS({
  required String foreignWalletId,
}) async {
  final client = SupabaseService.client;

  final user = client.auth.currentUser;

  if (user == null) {
    throw Exception('User is not logged in');
  }

  print('========== WALLET RLS TEST ==========');
  print('Logged user ID: ${user.id}');
  print('Foreign wallet ID: $foreignWalletId');

  // TEST 1: SELECT
  final selectResult = await client
      .from('tracked_wallets')
      .select('id, name, user_id')
      .eq('id', foreignWalletId);

  print('RLS SELECT RESULT: $selectResult');

  // TEST 2: UPDATE
  // Celowo ustawiamy warunek na nieistniejące UUID.
  // Żaden rekord nie zostanie zmodyfikowany.
  final updateResult = await client
      .from('tracked_wallets')
      .update({'name': 'RLS_TEST_SHOULD_NOT_CHANGE'})
      .eq('id', foreignWalletId)
      .eq('id', '00000000-0000-0000-0000-000000000000')
      .select('id');

  print('RLS UPDATE RESULT: $updateResult');

  // TEST 3: DELETE
  // Ten sam dodatkowy warunek bezpieczeństwa.
  // Żaden rekord nie zostanie usunięty.
  final deleteResult = await client
      .from('tracked_wallets')
      .delete()
      .eq('id', foreignWalletId)
      .eq('id', '00000000-0000-0000-0000-000000000000')
      .select('id');

  print('RLS DELETE RESULT: $deleteResult');

  print('========== END RLS TEST ==========');
}

class WalletTrackerService {
  WalletTrackerService._();

  static final SupabaseClient _supabase =
      SupabaseService.client;

  // ============================================================
  // GET WALLET DATA
  // ============================================================

  static Future<Map<String, dynamic>> getWalletData() async {
    final session = _supabase.auth.currentSession;

    if (session == null) {
      throw Exception('User is not logged in');
    }

    final accessToken = session.accessToken;

    print('WALLET API: user = ${session.user.email}');
    print(
      'WALLET API: access token exists = ${accessToken.isNotEmpty}',
    );

    final response = await _supabase.functions.invoke(
      'wallet-api',
      method: HttpMethod.get,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    print('WALLET API STATUS: ${response.status}');
    print('WALLET API DATA: ${response.data}');

    if (response.status != 200) {
      throw Exception(
        'Wallet API error: ${response.status} - ${response.data}',
      );
    }

    final data = response.data;

    if (data is! Map) {
      throw Exception('Invalid Wallet API response');
    }

    return Map<String, dynamic>.from(data);
  }

  // ============================================================
  // ADD WALLET
  // ============================================================

  static Future<Map<String, dynamic>> addWallet({
    required String name,
    required String address,
    String network = 'Solana',
  }) async {
    final response = await _supabase.functions.invoke(
      'wallet-api',
      method: HttpMethod.post,
      body: {
        'action': 'add',
        'name': name,
        'address': address,
        'network': network,
      },
    );

    print('ADD WALLET STATUS: ${response.status}');
    print('ADD WALLET DATA: ${response.data}');

    if (response.status != 200) {
      throw Exception(
        'Add wallet error: ${response.status} - ${response.data}',
      );
    }

    return Map<String, dynamic>.from(response.data);
  }

  // ============================================================
  // UPDATE WALLET
  // ============================================================

  static Future<Map<String, dynamic>> updateWallet({
    required String walletId,
    String? name,
    bool? alertsEnabled,
    bool? buyAlerts,
    bool? sellAlerts,
    bool? largeTransactionAlerts,
    double? largeTransactionThreshold,
  }) async {
    final body = <String, dynamic>{
      'action': 'update',
      'wallet_id': walletId,
    };

    if (name != null) {
      body['name'] = name;
    }

    if (alertsEnabled != null) {
      body['alerts_enabled'] = alertsEnabled;
    }

    if (buyAlerts != null) {
      body['buy_alerts'] = buyAlerts;
    }

    if (sellAlerts != null) {
      body['sell_alerts'] = sellAlerts;
    }

    if (largeTransactionAlerts != null) {
      body['large_transaction_alerts'] =
          largeTransactionAlerts;
    }

    if (largeTransactionThreshold != null) {
      body['large_transaction_threshold'] =
          largeTransactionThreshold;
    }

    final response = await _supabase.functions.invoke(
      'wallet-api',
      method: HttpMethod.post,
      body: body,
    );

    print('UPDATE WALLET STATUS: ${response.status}');
    print('UPDATE WALLET DATA: ${response.data}');

    if (response.status != 200) {
      throw Exception(
        'Update wallet error: ${response.status} - ${response.data}',
      );
    }

    return Map<String, dynamic>.from(response.data);
  }

  // ============================================================
  // DELETE WALLET
  // ============================================================

  static Future<Map<String, dynamic>> deleteWallet({
    required String walletId,
  }) async {
    final response = await _supabase.functions.invoke(
      'wallet-api',
      method: HttpMethod.post,
      body: {
        'action': 'delete',
        'wallet_id': walletId,
      },
    );

    print('DELETE WALLET STATUS: ${response.status}');
    print('DELETE WALLET DATA: ${response.data}');

    if (response.status != 200) {
      throw Exception(
        'Delete wallet error: ${response.status} - ${response.data}',
      );
    }

    return Map<String, dynamic>.from(response.data);
  }

  // ============================================================
  // SYNC ONE WALLET
  // ============================================================

  static Future<Map<String, dynamic>> syncWallet({
    required String walletId,
  }) async {
    final session = _supabase.auth.currentSession;

    if (session == null) {
      throw Exception('User is not logged in');
    }

    if (walletId.trim().isEmpty) {
      throw Exception('Brak identyfikatora portfela');
    }

    final response = await _supabase.functions.invoke(
      'wallet-sync',
      method: HttpMethod.post,
      headers: {
        'Authorization': 'Bearer ${session.accessToken}',
      },
      body: {
        'wallet_id': walletId,
      },
    );

    print('SINGLE WALLET SYNC STATUS: ${response.status}');
    print('SINGLE WALLET SYNC DATA: ${response.data}');

    final data = response.data;

    if (response.status == 200 &&
        data is Map &&
        data['success'] == true) {
      return Map<String, dynamic>.from(data);
    }

    final message = data is Map
        ? data['error']?.toString() ??
            'Synchronizacja portfela nie powiodła się'
        : 'Nieoczekiwana odpowiedź z wallet-sync';

    throw Exception(message);
  }

  // ============================================================
  // SYNC ALL WALLETS
  // ============================================================

  static Future<Map<String, dynamic>> syncWallets() async {
    final session = _supabase.auth.currentSession;

    if (session == null) {
      throw Exception('User is not logged in');
    }

    final response = await _supabase.functions.invoke(
      'wallet-sync',
      method: HttpMethod.post,
      headers: {
        'Authorization': 'Bearer ${session.accessToken}',
      },
      body: <String, dynamic>{},
    );

    print('ALL WALLETS SYNC STATUS: ${response.status}');
    print('ALL WALLETS SYNC DATA: ${response.data}');

    final data = response.data;

    if (response.status == 200 &&
        data is Map &&
        data['success'] == true) {
      return Map<String, dynamic>.from(data);
    }

    final message = data is Map
        ? data['error']?.toString() ??
            'Synchronizacja nie powiodła się'
        : 'Nieoczekiwana odpowiedź z wallet-sync';

    throw Exception(message);
  }
}