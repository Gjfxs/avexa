
import '../models/portfolio_asset.dart';
import '../models/transaction_model.dart';

class PortfolioService {
  static final PortfolioService instance = PortfolioService._();

  PortfolioService._();

  final List<PortfolioTransaction> transactions = [];
  final List<PortfolioAsset> assets = [];

  /// Replaces the current aggregated portfolio assets.
  /// The list should contain real data retrieved from connected wallets.
  void setAssets(List<PortfolioAsset> newAssets) {
    assets
      ..clear()
      ..addAll(newAssets);
  }

  /// Adds a transaction to the portfolio history.
  void addTransaction(PortfolioTransaction transaction) {
    transactions.add(transaction);
  }

  List<PortfolioTransaction> getAll() {
    return List.unmodifiable(transactions);
  }

  List<PortfolioAsset> getAssets() {
    return List.unmodifiable(assets);
  }

  double getTotalValue() {
    return assets.fold<double>(
      0,
      (total, asset) => total + asset.valueUsd,
    );
  }

  /// No artificial score is generated when there is no real portfolio data.
  int getPortfolioScore() {
    if (assets.isEmpty || getTotalValue() <= 0) {
      return 0;
    }

    // Placeholder until the real portfolio risk analysis is implemented.
    return 0;
  }

  /// Returns only factual status information.
  /// Real AI insights will be implemented after portfolio synchronization.
  List<String> getAiInsights() {
    if (assets.isEmpty) {
      return [
        'No portfolio assets have been synchronized yet.',
      ];
    }

    return [];
  }

  /// Clears the entire in-memory portfolio.
  /// Do not call this when removing just one wallet from a multi-wallet portfolio.
  void clearPortfolio() {
    assets.clear();
    transactions.clear();
  }
}
