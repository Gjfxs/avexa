
import 'dart:convert';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/connected_account.dart';

class ConnectionService {
  ConnectionService._() {
    _authSubscription =
        _supabase.auth.onAuthStateChange.listen((data) {
      final nextUserId = data.session?.user.id;

      if (nextUserId != _loadedUserId) {
        _loadVersion++;

        _walletAccounts.clear();
        _legacyAccounts.clear();
        _walletRowIds.clear();

        _loadedUserId = null;
      }
    });
  }

  static final instance = ConnectionService._();

  final SupabaseClient _supabase = Supabase.instance.client;

  late final StreamSubscription<AuthState> _authSubscription;

  final List<ConnectedAccount> _walletAccounts = [];
  final List<ConnectedAccount> _legacyAccounts = [];

  final Map<String, String> _walletRowIds = {};

  String? _loadedUserId;
  int _loadVersion = 0;

  List<ConnectedAccount> get accounts =>
      List.unmodifiable([..._walletAccounts, ..._legacyAccounts]);

  List<ConnectedAccount> get walletAccounts =>
      List.unmodifiable(_walletAccounts);

  List<ConnectedAccount> get legacyAccounts =>
      List.unmodifiable(_legacyAccounts);

  String _userStorageKey(String userId) =>
      'connected_accounts_$userId';

  ConnectedAccount? getConnectedAccount() {
    if (_walletAccounts.isNotEmpty) return _walletAccounts.first;
    if (_legacyAccounts.isNotEmpty) return _legacyAccounts.first;
    return null;
  }

  bool isConnected(String provider) {
    return _legacyAccounts.any(
      (account) => account.provider == provider,
    );
  }

  bool isWalletConnected({
    required String network,
    required String address,
  }) {
    return _walletAccounts.any((account) {
      return account.network!.toLowerCase() ==
              network.toLowerCase() &&
          _normalizeAddress(network, account.walletAddress!) ==
              _normalizeAddress(network, address);
    });
  }

  // --------------------------------------------------
  // LOAD CURRENT USER DATA
  // --------------------------------------------------

  Future<void> load() async {
    final userId = _supabase.auth.currentUser?.id;
    final version = ++_loadVersion;

    _walletAccounts.clear();
    _legacyAccounts.clear();
    _walletRowIds.clear();
    _loadedUserId = userId;

    if (userId == null) return;

    try {
      final rows = await _supabase
          .from('portfolio_wallets')
          .select()
          .eq('user_id', userId);

      if (!_isCurrentSession(userId, version)) return;

      for (final row in rows) {
        final network = row['network']?.toString() ?? '';
        final address = row['address']?.toString() ?? '';
        final rowId = row['id']?.toString();

        if (network.isEmpty || address.isEmpty || rowId == null) {
          continue;
        }

        final account = ConnectedAccount(
          provider: network,
          connected: true,
          walletAddress: address,
          customName: row['custom_name']?.toString(),
          connectedAt: row['created_at'] == null
              ? null
              : DateTime.tryParse(row['created_at'].toString()),
          network: network,
        );

        _walletAccounts.add(account);
        _walletRowIds[account.connectionId] = rowId;
      }

      await _loadLegacyAccounts(userId, version);
    } catch (_) {
      if (_isCurrentSession(userId, version)) {
        _walletAccounts.clear();
        _walletRowIds.clear();
        _legacyAccounts.clear();
      }
      rethrow;
    }
  }

  // --------------------------------------------------
  // CONNECT WALLET
  // --------------------------------------------------

  Future<void> connectWallet({
    required String network,
    required String address,
    String? customName,
  }) async {
    final user = _requireUser();
    final userId = user.id;

    final normalizedNetwork = network.trim().toLowerCase();
    final normalizedAddress = address.trim();
    final name = customName?.trim();

    if (!_isSupportedNetwork(normalizedNetwork)) {
      throw ArgumentError('Unsupported network: $normalizedNetwork');
    }

    if (normalizedAddress.isEmpty) {
      throw ArgumentError('Wallet address is required.');
    }

    await _ensureLoadedForUser(userId);

    final existing = _walletAccounts.where((account) {
      return account.network!.toLowerCase() == normalizedNetwork &&
          _normalizeAddress(
                normalizedNetwork,
                account.walletAddress!,
              ) ==
              _normalizeAddress(
                normalizedNetwork,
                normalizedAddress,
              );
    });

    final existingAccount = existing.isEmpty ? null : existing.first;

    if (existingAccount != null) {
      final rowId = _walletRowIds[existingAccount.connectionId];

      if (rowId == null) {
        throw StateError('Could not identify the existing wallet.');
      }

      await _supabase
          .from('portfolio_wallets')
          .update({
            'custom_name': name == null || name.isEmpty ? null : name,
          })
          .eq('id', rowId)
          .eq('user_id', userId);
    } else {
      await _supabase.from('portfolio_wallets').insert({
        'user_id': userId,
        'network': normalizedNetwork,
        'address': normalizedAddress,
        'custom_name': name == null || name.isEmpty ? null : name,
      });
    }

    _ensureSameUser(userId);
    await load();
  }

  // --------------------------------------------------
  // DISCONNECT WALLET
  // --------------------------------------------------

  Future<void> disconnectWallet({
    required String network,
    required String address,
  }) async {
    final user = _requireUser();
    final userId = user.id;
    final normalizedNetwork = network.trim().toLowerCase();
    final normalizedAddress = address.trim();

    await _ensureLoadedForUser(userId);

    final matches = _walletAccounts.where((account) {
      return account.network!.toLowerCase() == normalizedNetwork &&
          _normalizeAddress(
                normalizedNetwork,
                account.walletAddress!,
              ) ==
              _normalizeAddress(
                normalizedNetwork,
                normalizedAddress,
              );
    });

    if (matches.isEmpty) return;

    final rowId = _walletRowIds[matches.first.connectionId];

    if (rowId == null) {
      throw StateError('Could not identify the wallet to delete.');
    }

    await _supabase
        .from('portfolio_wallets')
        .delete()
        .eq('id', rowId)
        .eq('user_id', userId);

    _ensureSameUser(userId);
    await load();
  }

  // --------------------------------------------------
  // RENAME WALLET
  // --------------------------------------------------

  Future<void> renameWallet({
    required String network,
    required String address,
    required String customName,
  }) async {
    final user = _requireUser();
    final userId = user.id;
    final normalizedNetwork = network.trim().toLowerCase();
    final normalizedAddress = address.trim();

    await _ensureLoadedForUser(userId);

    final matches = _walletAccounts.where((account) {
      return account.network!.toLowerCase() == normalizedNetwork &&
          _normalizeAddress(
                normalizedNetwork,
                account.walletAddress!,
              ) ==
              _normalizeAddress(
                normalizedNetwork,
                normalizedAddress,
              );
    });

    if (matches.isEmpty) return;

    final rowId = _walletRowIds[matches.first.connectionId];

    if (rowId == null) {
      throw StateError('Could not identify the wallet to rename.');
    }

    final name = customName.trim();

    await _supabase
        .from('portfolio_wallets')
        .update({
          'custom_name': name.isEmpty ? null : name,
        })
        .eq('id', rowId)
        .eq('user_id', userId);

    _ensureSameUser(userId);
    await load();
  }

  // --------------------------------------------------
  // LEGACY CONNECTIONS
  // Exchange/API connections remain local and are
  // separated by authenticated user ID.
  // --------------------------------------------------

  Future<void> connect(
    String provider, {
    String? walletAddress,
    String? apiKey,
    String? customName,
  }) async {
    final user = _requireUser();

    await _ensureLoadedForUser(user.id);

    _legacyAccounts.removeWhere(
      (account) => account.provider == provider,
    );

    _legacyAccounts.add(
      ConnectedAccount(
        provider: provider,
        connected: true,
        walletAddress: walletAddress,
        apiKey: apiKey,
        customName: customName,
        connectedAt: DateTime.now(),
        lastSync: null,
      ),
    );

    await _saveLegacyAccounts(user.id);
  }

  Future<void> disconnect(String provider) async {
    final user = _requireUser();

    await _ensureLoadedForUser(user.id);

    _legacyAccounts.removeWhere(
      (account) => account.provider == provider,
    );

    await _saveLegacyAccounts(user.id);
  }

  Future<void> rename(
    String provider,
    String customName,
  ) async {
    final user = _requireUser();

    await _ensureLoadedForUser(user.id);

    final index = _legacyAccounts.indexWhere(
      (account) => account.provider == provider,
    );

    if (index == -1) return;

    _legacyAccounts[index] = _legacyAccounts[index].copyWith(
      customName: customName.trim(),
    );

    await _saveLegacyAccounts(user.id);
  }

  // --------------------------------------------------
  // CLEAR DATA
  // clearAll deletes current user's remote wallets.
  // clearLocalState only clears local memory/storage.
  // --------------------------------------------------

  Future<void> clearAll() async {
    final user = _requireUser();
    final userId = user.id;

    await _supabase
        .from('portfolio_wallets')
        .delete()
        .eq('user_id', userId);

    await clearLocalState(userId: userId);
  }

  Future<void> clearLocalState({String? userId}) async {
    final targetUserId = userId ?? _supabase.auth.currentUser?.id;

    _loadVersion++;

    _walletAccounts.clear();
    _legacyAccounts.clear();
    _walletRowIds.clear();
    _loadedUserId = null;

    if (targetUserId != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userStorageKey(targetUserId));
    }
  }

  // --------------------------------------------------
  // LEGACY LOCAL STORAGE
  // --------------------------------------------------

  Future<void> _loadLegacyAccounts(
    String userId,
    int version,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    if (!_isCurrentSession(userId, version)) return;

    final stored = prefs.getStringList(_userStorageKey(userId)) ?? [];

    for (final raw in stored) {
      try {
        final data = jsonDecode(raw) as Map<String, dynamic>;

        _legacyAccounts.add(
          ConnectedAccount(
            provider: data['provider']?.toString() ?? '',
            connected: data['connected'] == true,
            walletAddress: data['walletAddress']?.toString(),
            apiKey: data['apiKey']?.toString(),
            customName: data['customName']?.toString(),
            connectedAt: data['connectedAt'] == null
                ? null
                : DateTime.tryParse(data['connectedAt'].toString()),
            lastSync: data['lastSync'] == null
                ? null
                : DateTime.tryParse(data['lastSync'].toString()),
            network: data['network']?.toString(),
          ),
        );
      } catch (_) {
        // Ignore malformed legacy entries.
      }
    }
  }

  Future<void> _saveLegacyAccounts(String userId) async {
    _ensureSameUser(userId);

    final prefs = await SharedPreferences.getInstance();

    _ensureSameUser(userId);

    final stored = _legacyAccounts.map((account) {
      return jsonEncode({
        'provider': account.provider,
        'connected': account.connected,
        'walletAddress': account.walletAddress,
        'apiKey': account.apiKey,
        'customName': account.customName,
        'connectedAt': account.connectedAt?.toIso8601String(),
        'lastSync': account.lastSync?.toIso8601String(),
        'network': account.network,
      });
    }).toList();

    await prefs.setStringList(_userStorageKey(userId), stored);
  }

  // --------------------------------------------------
  // HELPERS
  // --------------------------------------------------

  User _requireUser() {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw StateError('You must be logged in to manage connections.');
    }

    return user;
  }

  void _ensureSameUser(String userId) {
    if (_supabase.auth.currentUser?.id != userId) {
      throw StateError('User session changed. Please try again.');
    }
  }

  bool _isCurrentSession(String userId, int version) {
    return _supabase.auth.currentUser?.id == userId &&
        _loadVersion == version;
  }

  Future<void> _ensureLoadedForUser(String userId) async {
    if (_loadedUserId != userId) {
      await load();
    }

    _ensureSameUser(userId);

    if (_loadedUserId != userId) {
      throw StateError('Could not load data for the current user.');
    }
  }

  bool _isSupportedNetwork(String network) {
    return const {
      'solana',
      'ethereum',
      'base',
      'arbitrum',
      'polygon',
    }.contains(network);
  }

  String _normalizeAddress(String network, String address) {
    if (network.toLowerCase() == 'solana') {
      return address.trim();
    }

    return address.trim().toLowerCase();
  }
}
