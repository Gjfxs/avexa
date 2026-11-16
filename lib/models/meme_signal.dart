class MemeSignal {
  final String id;
  final String symbol;
  final String market;
  final String tier;
  final String timeframe;
  final String direction;

  final double entryPrice;
  final double stopLoss;
  final double takeProfit1;
  final double? takeProfit2;
  final double? takeProfit3;

  final int confidence;
  final String riskLevel;
  final double? riskReward;

  final String? reason;
  final String? tokenAddress;
  final String? pairAddress;
  final String? imageUrl;

  final DateTime createdAt;
  final DateTime? expiresAt;

  MemeSignal({
    required this.id,
    required this.symbol,
    required this.market,
    required this.tier,
    required this.timeframe,
    required this.direction,
    required this.entryPrice,
    required this.stopLoss,
    required this.takeProfit1,
    this.takeProfit2,
    this.takeProfit3,
    required this.confidence,
    required this.riskLevel,
    this.riskReward,
    this.reason,
    this.tokenAddress,
    this.pairAddress,
    this.imageUrl,
    required this.createdAt,
    this.expiresAt,
  });

  factory MemeSignal.fromMap(
    Map<String, dynamic> map,
  ) {
    return MemeSignal(
      id: map['id']?.toString() ?? '',
      symbol: map['symbol']?.toString() ?? 'UNKNOWN',
      market: map['market']?.toString() ?? 'MEME',
      tier: map['tier']?.toString() ?? 'FREE',
      timeframe: map['timeframe']?.toString() ?? '1h',
      direction: map['direction']?.toString() ?? 'LONG',

      entryPrice:
          double.tryParse(
                map['entry_price']?.toString() ?? '',
              ) ??
              0,

      stopLoss:
          double.tryParse(
                map['stop_loss']?.toString() ?? '',
              ) ??
              0,

      takeProfit1:
          double.tryParse(
                map['take_profit_1']?.toString() ?? '',
              ) ??
              0,

      takeProfit2:
          double.tryParse(
            map['take_profit_2']?.toString() ?? '',
          ),

      takeProfit3:
          double.tryParse(
            map['take_profit_3']?.toString() ?? '',
          ),

      confidence:
          int.tryParse(
                map['confidence']?.toString() ?? '',
              ) ??
              0,

      riskLevel:
          map['risk_level']?.toString() ?? 'HIGH',

      riskReward:
          double.tryParse(
            map['risk_reward']?.toString() ?? '',
          ),

      reason: map['reason']?.toString(),

      tokenAddress:
          map['token_address']?.toString(),

      pairAddress:
          map['pair_address']?.toString(),

      imageUrl:
          map['image_url']?.toString(),

      createdAt:
          DateTime.tryParse(
                map['created_at']?.toString() ?? '',
              ) ??
              DateTime.now(),

      expiresAt:
          DateTime.tryParse(
            map['expires_at']?.toString() ?? '',
          ),
    );
  }

  bool get isExpired {
    if (expiresAt == null) {
      return false;
    }

    return DateTime.now().isAfter(expiresAt!);
  }

  String get shortTokenAddress {
    if (tokenAddress == null ||
        tokenAddress!.length < 12) {
      return tokenAddress ?? 'N/A';
    }

    return '${tokenAddress!.substring(0, 6)}...'
        '${tokenAddress!.substring(tokenAddress!.length - 6)}';
  }
}