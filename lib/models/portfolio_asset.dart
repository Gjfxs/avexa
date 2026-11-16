
class PortfolioAsset {
  /// Token ticker, e.g. SOL, ETH, USDC.
  final String symbol;

  /// Full token name.
  final String name;

  /// Amount held in the wallet.
  final double amount;

  /// Total market value in USD.
  final double valueUsd;

  /// Current price of one token in USD.
  final double priceUsd;

  /// Token logo URL, if available.
  final String? logo;

  /// Blockchain network: solana, ethereum, base,
  /// arbitrum or polygon.
  final String? network;

  /// Public token contract address or Solana mint.
  /// Native assets may not have a token address.
  final String? tokenAddress;

  /// Public wallet address from which this asset was read.
  final String? walletAddress;

  /// Token decimal precision.
  final int? decimals;

  /// Whether this is the native asset of the network.
  final bool isNative;

  const PortfolioAsset({
    required this.symbol,
    required this.name,
    required this.amount,
    required this.valueUsd,
    this.priceUsd = 0,
    this.logo,
    this.network,
    this.tokenAddress,
    this.walletAddress,
    this.decimals,
    this.isNative = false,
  });

  PortfolioAsset copyWith({
    String? symbol,
    String? name,
    double? amount,
    double? valueUsd,
    double? priceUsd,
    String? logo,
    String? network,
    String? tokenAddress,
    String? walletAddress,
    int? decimals,
    bool? isNative,
  }) {
    return PortfolioAsset(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      valueUsd: valueUsd ?? this.valueUsd,
      priceUsd: priceUsd ?? this.priceUsd,
      logo: logo ?? this.logo,
      network: network ?? this.network,
      tokenAddress: tokenAddress ?? this.tokenAddress,
      walletAddress: walletAddress ?? this.walletAddress,
      decimals: decimals ?? this.decimals,
      isNative: isNative ?? this.isNative,
    );
  }
}
