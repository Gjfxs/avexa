
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/connected_account.dart';

class ConnectionService {
  ConnectionService._();

  static final instance = ConnectionService._();

  final List<ConnectedAccount> _accounts = [];

  static const _storageKey = 'connected_accounts';

  List<ConnectedAccount> get accounts =>
      List.unmodifiable(_accounts);

  List<ConnectedAccount> get walletAccounts =>
      List.unmodifiable(
        _accounts.where((account) => account.isWalletAddress),
      );

  List<ConnectedAccount> get legacyAccounts =>
      List.unmodifiable(
        _accounts.where((account) => !account.isWalletAddress),
      );

  ConnectedAccount? getConnectedAccount() {
    if (_accounts.isEmpty) return null;
    return _accounts.first;
  }

  bool isConnected(String provider) {
    return _accounts.any(
      (account) => account.provider == provider,
    );
  }

  bool isWalletConnected({
    required String network,
    required String address,
  }) {
    return _accounts.any((account) {
      if (!account.isWalletAddress) return false;

      return account.network!.toLowerCase() ==
              network.toLowerCase() &&
          _normalizeAddress(network, account.walletAddress!) ==
              _normalizeAddress(network, address);
    });
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final storedAccounts =
        prefs.getStringList(_storageKey) ?? [];

    _accounts.clear();

    for (final rawAccount in storedAccounts) {
      try {
        final data =
            jsonDecode(rawAccount) as Map<String, dynamic>;

        final provider = data['provider']?.toString() ?? '';
        final walletAddress =
            data['walletAddress']?.toString();

        final storedNetwork = data['network']?.toString();

        final network = storedNetwork?.isNotEmpty == true
            ? storedNetwork!.toLowerCase()
            : _inferLegacyNetwork(provider, walletAddress);

        _accounts.add(
          ConnectedAccount(
            provider: provider,
            connected: data['connected'] == true,
            walletAddress: walletAddress,
            apiKey: data['apiKey']?.toString(),
            customName: data['customName']?.toString(),
            connectedAt: data['connectedAt'] != null
                ? DateTime.tryParse(
                    data['connectedAt'].toString(),
                  )
                : null,
            lastSync: data['lastSync'] != null
                ? DateTime.tryParse(
                    data['lastSync'].toString(),
                  )
                : null,
            network: network,
          ),
        );
      } catch (_) {
        // Pomijamy uszkodzony wpis.
      }
    }
  }

  Future<void> connectWallet({
    required String network,
    required String address,
    String? customName,
  }) async {
    final normalizedNetwork = network.trim().toLowerCase();
    final normalizedAddress = address.trim();

    if (normalizedNetwork.isEmpty || normalizedAddress.isEmpty) {
      throw ArgumentError('Network and address are required.');
    }

    final existingIndex = _accounts.indexWhere((account) {
      if (!account.isWalletAddress) return false;

      return account.network!.toLowerCase() ==
              normalizedNetwork &&
          _normalizeAddress(
                normalizedNetwork,
                account.walletAddress!,
              ) ==
              _normalizeAddress(
                normalizedNetwork,
                normalizedAddress,
              );
    });

    final account = ConnectedAccount(
      provider: normalizedNetwork,
      connected: true,
      walletAddress: normalizedAddress,
      customName: customName?.trim(),
      connectedAt: DateTime.now(),
      lastSync: null,
      network: normalizedNetwork,
    );

    if (existingIndex >= 0) {
      _accounts[existingIndex] = account;
    } else {
      _accounts.add(account);
    }

    await _save();
  }

  Future<void> disconnectWallet({
    required String network,
    required String address,
  }) async {
    final normalizedNetwork = network.trim().toLowerCase();

    _accounts.removeWhere((account) {
      if (!account.isWalletAddress) return false;

      return account.network!.toLowerCase() ==
              normalizedNetwork &&
          _normalizeAddress(
                normalizedNetwork,
                account.walletAddress!,
              ) ==
              _normalizeAddress(
                normalizedNetwork,
                address,
              );
    });

    await _save();
  }

  Future<void> renameWallet({
    required String network,
    required String address,
    required String customName,
  }) async {
    final normalizedNetwork = network.trim().toLowerCase();

    final index = _accounts.indexWhere((account) {
      if (!account.isWalletAddress) return false;

      return account.network!.toLowerCase() ==
              normalizedNetwork &&
          _normalizeAddress(
                normalizedNetwork,
                account.walletAddress!,
              ) ==
              _normalizeAddress(
                normalizedNetwork,
                address,
              );
    });

    if (index == -1) return;

    _accounts[index] = _accounts[index].copyWith(
      customName: customName.trim(),
    );

    await _save();
  }

  // Zachowane metody starszego systemu.
  Future<void> connect(
    String provider, {
    String? walletAddress,
    String? apiKey,
    String? customName,
  }) async {
    _accounts.removeWhere(
      (account) => account.provider == provider,
    );

    _accounts.add(
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

    await _save();
  }

  Future<void> disconnect(String provider) async {
    _accounts.removeWhere(
      (account) => account.provider == provider,
    );

    await _save();
  }

  Future<void> rename(
    String provider,
    String customName,
  ) async {
    final index = _accounts.indexWhere(
      (account) => account.provider == provider,
    );

    if (index == -1) return;

    _accounts[index] = _accounts[index].copyWith(
      customName: customName.trim(),
    );

    await _save();
  }

  Future<void> clearAll() async {
    _accounts.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();

    if (_accounts.isEmpty) {
      await prefs.remove(_storageKey);
      return;
    }

    final encodedAccounts = _accounts.map((account) {
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

    await prefs.setStringList(
      _storageKey,
      encodedAccounts,
    );
  }

  String? _inferLegacyNetwork(
    String provider,
    String? walletAddress,
  ) {
    if (walletAddress == null || walletAddress.isEmpty) {
      return null;
    }

    switch (provider.toLowerCase()) {
      case 'phantom':
        return 'solana';
      case 'metamask':
        return 'ethereum';
      default:
        return null;
    }
  }

  String _normalizeAddress(String network, String address) {
    if (network.toLowerCase() == 'solana') {
      return address.trim();
    }

    return address.trim().toLowerCase();
  }
}
