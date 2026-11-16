class WalletTransaction {
  final String action;
  final String token;
  final String tokenName;
  final double amountUsd;
  final double tokenAmount;
  final DateTime? timestamp;
  final String? transactionHash;

  const WalletTransaction({
    required this.action,
    required this.token,
    required this.tokenName,
    required this.amountUsd,
    required this.tokenAmount,
    this.timestamp,
    this.transactionHash,
  });

  bool get isBuy => action.toUpperCase() == 'BOUGHT';
  bool get isSell => action.toUpperCase() == 'SOLD';
}