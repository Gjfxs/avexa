class PortfolioTransaction {
  final String coin;
  final String symbol;
  final double amount;
  final double price;
  final bool isBuy;
  final DateTime date;

  PortfolioTransaction({
    required this.coin,
    required this.symbol,
    required this.amount,
    required this.price,
    required this.isBuy,
    required this.date,
  });

  double get totalValue => amount * price;
}