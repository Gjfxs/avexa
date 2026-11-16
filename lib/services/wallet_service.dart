
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/portfolio_asset.dart';
import '../models/wallet_transaction.dart';

class WalletService {
  WalletService._();

  static final instance = WalletService._();

  // Moralis pozostaje wyłącznie dla istniejącej obsługi transakcji.
  static const _apiKey = String.fromEnvironment('MORALIS_API_KEY');
  static const _baseUrl = 'https://solana-gateway.moralis.io';

  static const _rpcUrl = 'https://api.mainnet-beta.solana.com';

  static const _tokenProgram =
      'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA';

  static const _token2022Program =
      'TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb';

  static const _wrappedSolMint =
      'So11111111111111111111111111111111111111112';

  Map<String, String> get _headers => {
        'X-API-Key': _apiKey,
        'Accept': 'application/json',
      };

  // ============================================================
  // PORTFOLIO - PUBLIC SOLANA RPC + DEXSCREENER
  // ============================================================

  Future<List<PortfolioAsset>> getSolanaPortfolio(
    String walletAddress,
  ) async {
    final assets = <PortfolioAsset>[];

    // 1. Native SOL balance.
    final solResult = await _rpcCall(
      'getBalance',
      [
        walletAddress,
        {'commitment': 'confirmed'},
      ],
    );

    final lamports = _toDouble(solResult['value']);
    final solAmount = lamports / 1000000000;

    if (solAmount > 0) {
      assets.add(
        PortfolioAsset(
          symbol: 'SOL',
          name: 'Solana',
          amount: solAmount,
          valueUsd: 0,
          priceUsd: 0,
          network: 'solana',
          walletAddress: walletAddress,
          isNative: true,
        ),
      );
    }

    // 2. SPL Token + Token-2022 balances.
    final tokenBalances = <String, Map<String, dynamic>>{};

    for (final programId in [
      _tokenProgram,
      _token2022Program,
    ]) {
      final result = await _rpcCall(
        'getTokenAccountsByOwner',
        [
          walletAddress,
          {'programId': programId},
          {
            'encoding': 'jsonParsed',
            'commitment': 'confirmed',
          },
        ],
      );

      final accounts = result['value'];

      if (accounts is! List) continue;

      for (final account in accounts) {
        if (account is! Map) continue;

        final accountData = account['account'];
        if (accountData is! Map) continue;

        final data = accountData['data'];
        if (data is! Map) continue;

        final parsed = data['parsed'];
        if (parsed is! Map) continue;

        final info = parsed['info'];
        if (info is! Map) continue;

        final mint = info['mint']?.toString();
        final tokenAmount = info['tokenAmount'];

        if (mint == null || tokenAmount is! Map) continue;

        final decimals = int.tryParse(
              tokenAmount['decimals']?.toString() ?? '',
            ) ??
            0;

        final rawAmount = _toDouble(tokenAmount['amount']);

        final amount = tokenAmount['uiAmountString'] != null
            ? _toDouble(tokenAmount['uiAmountString'])
            : rawAmount / pow(10, decimals);

        if (amount <= 0) continue;

        final existing = tokenBalances[mint];

        if (existing == null) {
          tokenBalances[mint] = {
            'amount': amount,
            'decimals': decimals,
          };
        } else {
          existing['amount'] =
              _toDouble(existing['amount']) + amount;
        }
      }
    }

    // 3. Prepare token assets.
    for (final entry in tokenBalances.entries) {
      assets.add(
        PortfolioAsset(
          symbol: 'TOKEN',
          name: 'Solana Token',
          amount: _toDouble(entry.value['amount']),
          valueUsd: 0,
          priceUsd: 0,
          network: 'solana',
          tokenAddress: entry.key,
          walletAddress: walletAddress,
          decimals: entry.value['decimals'] as int,
        ),
      );
    }

    // 4. Get prices for SOL and all tokens.
    final mints = <String>{
      _wrappedSolMint,
      ...tokenBalances.keys,
    };

    final prices = await _getTokenPrices(mints.toList());

    final solPrice = prices[_wrappedSolMint] ?? 0;

    // 5. Calculate USD values.
    final pricedAssets = assets.map((asset) {
      final mint = asset.isNative
          ? _wrappedSolMint
          : asset.tokenAddress;

      final double price = mint == null ? 0.0 : (prices[mint] ?? 0.0);

      return asset.copyWith(
        symbol: asset.isNative ? 'SOL' : asset.symbol,
        name: asset.isNative ? 'Solana' : asset.name,
        priceUsd: price,
        valueUsd: asset.amount * price,
      );
    }).toList();

    debugPrint(
      'PORTFOLIO: ${pricedAssets.length} assets, '
      'SOL price: $solPrice USD',
    );

    return pricedAssets;
  }


  Future<double> getSolanaPortfolioValue(String walletAddress) async {
    // Native SOL balance.
    final solResult = await _rpcCall(
      'getBalance',
      [
        walletAddress,
        {'commitment': 'confirmed'},
      ],
    );

    final solAmount = _toDouble(solResult['value']) / 1000000000;

    // SPL Token + Token-2022 balances.
    final tokenBalances = <String, double>{};

    for (final programId in [
      _tokenProgram,
      _token2022Program,
    ]) {
      final result = await _rpcCall(
        'getTokenAccountsByOwner',
        [
          walletAddress,
          {'programId': programId},
          {
            'encoding': 'jsonParsed',
            'commitment': 'confirmed',
          },
        ],
      );

      final accounts = result['value'];
      if (accounts is! List) continue;

      for (final account in accounts) {
        if (account is! Map) continue;

        final accountData = account['account'];
        if (accountData is! Map) continue;

        final data = accountData['data'];
        if (data is! Map) continue;

        final parsed = data['parsed'];
        if (parsed is! Map) continue;

        final info = parsed['info'];
        if (info is! Map) continue;

        final mint = info['mint']?.toString();
        final tokenAmount = info['tokenAmount'];

        if (mint == null || tokenAmount is! Map) continue;

        final decimals = int.tryParse(
              tokenAmount['decimals']?.toString() ?? '',
            ) ??
            0;

        final rawAmount = _toDouble(tokenAmount['amount']);

        final amount = tokenAmount['uiAmountString'] != null
            ? _toDouble(tokenAmount['uiAmountString'])
            : rawAmount / pow(10, decimals);

        if (amount <= 0) continue;

        tokenBalances[mint] =
            (tokenBalances[mint] ?? 0) + amount;
      }
    }

    // Fetch prices for all unique tokens and wrapped SOL.
    final mints = <String>{
      _wrappedSolMint,
      ...tokenBalances.keys,
    };

    final prices = await _getTokenPrices(mints.toList());

    // Calculate the wallet's total USD value.
    double total = solAmount * (prices[_wrappedSolMint] ?? 0);

    for (final entry in tokenBalances.entries) {
      final price = prices[entry.key] ?? 0;
      total += entry.value * price;
    }

    debugPrint(
      'PORTFOLIO VALUE: $walletAddress = \$${total.toStringAsFixed(2)}',
    );

    return total;
  }


  // ============================================================
  // SOLANA RPC
  // ============================================================

  Future<Map<String, dynamic>> _rpcCall(
    String method,
    List<dynamic> params,
  ) async {
    final response = await http
        .post(
          Uri.parse(_rpcUrl),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'jsonrpc': '2.0',
            'id': 1,
            'method': method,
            'params': params,
          }),
        )
        .timeout(const Duration(seconds: 25));

    if (response.statusCode != 200) {
      throw Exception(
        'Solana RPC error (${response.statusCode})',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map) {
      throw Exception('Invalid Solana RPC response');
    }

    if (decoded['error'] != null) {
      throw Exception(
        'Solana RPC: ${decoded['error']}',
      );
    }

    final result = decoded['result'];

    if (result is! Map) {
      throw Exception('Missing Solana RPC result');
    }

    return Map<String, dynamic>.from(result);
  }

  // ============================================================
  // TOKEN PRICES - DEXSCREENER
  // ============================================================

  Future<Map<String, double>> _getTokenPrices(
    List<String> mints,
  ) async {
    final prices = <String, double>{};

    // DexScreener accepts up to 30 token addresses per request.
    for (var i = 0; i < mints.length; i += 30) {
      final end = min(i + 30, mints.length);
      final batch = mints.sublist(i, end);

      final url = Uri.parse(
        'https://api.dexscreener.com/tokens/v1/solana/'
        '${batch.join(',')}',
      );

      final response = await http
          .get(url)
          .timeout(const Duration(seconds: 25));

      if (response.statusCode != 200) {
        debugPrint(
          'DEXSCREENER ERROR: ${response.statusCode}',
        );
        continue;
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! List) continue;

      for (final pair in decoded) {
        if (pair is! Map) continue;

        final baseToken = pair['baseToken'];
        final quoteToken = pair['quoteToken'];

        if (baseToken is! Map || quoteToken is! Map) {
          continue;
        }

        final baseAddress =
            baseToken['address']?.toString();

        final quoteAddress =
            quoteToken['address']?.toString();

        final basePrice = _toDouble(pair['priceUsd']);
        final nativePrice = _toDouble(pair['priceNative']);

        final liquidity = pair['liquidity'];
        final liquidityUsd = liquidity is Map
            ? _toDouble(liquidity['usd'])
            : 0.0;

        if (basePrice <= 0) continue;

        void savePrice(String? mint, double price) {
          if (mint == null || price <= 0) return;

          final current = prices[mint];

          // Prefer the price from the pair with greater liquidity.
          // The liquidity comparison is handled below by keeping
          // the first usable price unless a better pair is found.
          if (current == null || current <= 0) {
            prices[mint] = price;
          }
        }

        if (batch.contains(baseAddress)) {
          savePrice(baseAddress, basePrice);
        }

        if (batch.contains(quoteAddress) && nativePrice > 0) {
          savePrice(
            quoteAddress,
            basePrice / nativePrice,
          );
        }

        // Prevent unused-variable warnings and keep the value
        // available for future liquidity-based price selection.
        if (liquidityUsd < 0) {
          debugPrint('Invalid liquidity value');
        }
      }

      // Avoid sending multiple batches too quickly.
      if (end < mints.length) {
        await Future.delayed(
          const Duration(milliseconds: 500),
        );
      }
    }

    return prices;
  }

  // ============================================================
  // TRANSACTIONS - EXISTING MORALIS IMPLEMENTATION
  // ============================================================

  Future<List<WalletTransaction>> getSolanaTransactions(
    String walletAddress, {
    int limit = 20,
  }) async {
    final url = Uri.parse(
      '$_baseUrl/account/mainnet/$walletAddress/swaps'
      '?limit=$limit',
    );

    final response = await http.get(
      url,
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load wallet transactions '
        '(${response.statusCode})',
      );
    }

    final decoded = jsonDecode(response.body);

    final List<dynamic> swaps;

    if (decoded is List) {
      swaps = decoded;
    } else if (decoded is Map && decoded['result'] is List) {
      swaps = decoded['result'];
    } else {
      return [];
    }

    return swaps
        .map<WalletTransaction?>(
          (swap) => _parseSwap(swap),
        )
        .whereType<WalletTransaction>()
        .toList();
  }

  WalletTransaction? _parseSwap(dynamic swap) {
    if (swap is! Map) {
      return null;
    }

    final map = Map<String, dynamic>.from(swap);

    final transactionHash =
        map['transactionHash']?.toString() ??
            map['transaction_hash']?.toString() ??
            map['signature']?.toString();

    final timestampValue =
        map['blockTimestamp'] ??
            map['block_timestamp'] ??
            map['timestamp'];

    DateTime? timestamp;

    if (timestampValue != null) {
      timestamp = DateTime.tryParse(
        timestampValue.toString(),
      );
    }

    final bought = map['bought'];
    final sold = map['sold'];

    if (bought is Map) {
      return WalletTransaction(
        action: 'BOUGHT',
        token: bought['symbol']?.toString() ?? 'UNKNOWN',
        tokenName: bought['name']?.toString() ?? '',
        amountUsd: _toDouble(
          bought['usdAmount'] ??
              bought['usd_amount'] ??
              bought['usdValue'],
        ),
        tokenAmount: _toDouble(bought['amount']),
        timestamp: timestamp,
        transactionHash: transactionHash,
      );
    }

    if (sold is Map) {
      return WalletTransaction(
        action: 'SOLD',
        token: sold['symbol']?.toString() ?? 'UNKNOWN',
        tokenName: sold['name']?.toString() ?? '',
        amountUsd: _toDouble(
          sold['usdAmount'] ??
              sold['usd_amount'] ??
              sold['usdValue'],
        ),
        tokenAmount: _toDouble(sold['amount']),
        timestamp: timestamp,
        transactionHash: transactionHash,
      );
    }

    final type =
        map['transactionType']?.toString().toLowerCase() ??
            map['type']?.toString().toLowerCase();

    if (type == 'buy' || type == 'bought') {
      return WalletTransaction(
        action: 'BOUGHT',
        token: map['symbol']?.toString() ?? 'UNKNOWN',
        tokenName: map['name']?.toString() ?? '',
        amountUsd: _toDouble(
          map['usdAmount'] ??
              map['usd_amount'] ??
              map['usdValue'],
        ),
        tokenAmount: _toDouble(map['amount']),
        timestamp: timestamp,
        transactionHash: transactionHash,
      );
    }

    if (type == 'sell' || type == 'sold') {
      return WalletTransaction(
        action: 'SOLD',
        token: map['symbol']?.toString() ?? 'UNKNOWN',
        tokenName: map['name']?.toString() ?? '',
        amountUsd: _toDouble(
          map['usdAmount'] ??
              map['usd_amount'] ??
              map['usdValue'],
        ),
        tokenAmount: _toDouble(map['amount']),
        timestamp: timestamp,
        transactionHash: transactionHash,
      );
    }

    return null;
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }
}
