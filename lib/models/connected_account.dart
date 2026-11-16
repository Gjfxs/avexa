
class ConnectedAccount {
  /// Zachowane dla zgodności ze starszymi ekranami.
  final String provider;

  final bool connected;
  final String? walletAddress;
  final String? apiKey;
  final String? customName;
  final DateTime? connectedAt;
  final DateTime? lastSync;

  /// Nowe pole identyfikujące sieć blockchain.
  /// Przykłady: solana, ethereum, base, arbitrum, polygon.
  final String? network;

  const ConnectedAccount({
    required this.provider,
    required this.connected,
    this.walletAddress,
    this.apiKey,
    this.customName,
    this.connectedAt,
    this.lastSync,
    this.network,
  });

  /// Czy wpis reprezentuje adres portfela blockchain.
  bool get isWalletAddress =>
      network != null &&
      network!.isNotEmpty &&
      walletAddress != null &&
      walletAddress!.isNotEmpty;

  /// Unikalny identyfikator konkretnego połączenia.
  String get connectionId {
    if (isWalletAddress) {
      return '${network!.toLowerCase()}:$walletAddress';
    }

    return 'legacy:$provider';
  }

  ConnectedAccount copyWith({
    String? provider,
    bool? connected,
    String? walletAddress,
    String? apiKey,
    String? customName,
    DateTime? connectedAt,
    DateTime? lastSync,
    String? network,
  }) {
    return ConnectedAccount(
      provider: provider ?? this.provider,
      connected: connected ?? this.connected,
      walletAddress: walletAddress ?? this.walletAddress,
      apiKey: apiKey ?? this.apiKey,
      customName: customName ?? this.customName,
      connectedAt: connectedAt ?? this.connectedAt,
      lastSync: lastSync ?? this.lastSync,
      network: network ?? this.network,
    );
  }
}
