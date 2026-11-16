
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_localizations.dart';
import '../services/market_service.dart';
import '../models/coin_model.dart';
import '../theme.dart';

class LiveMarketWidget extends StatefulWidget {
  const LiveMarketWidget({super.key});

  @override
  State<LiveMarketWidget> createState() =>
      _LiveMarketWidgetState();
}

class _LiveMarketWidgetState
    extends State<LiveMarketWidget> {
  final MarketService _marketService = MarketService();

  Timer? _refreshTimer;

  late Future<List<CoinModel>> _marketsFuture;

  @override
  void initState() {
    super.initState();

    _loadMarkets();

    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) {
        if (mounted) {
          _loadMarkets();
        }
      },
    );
  }

  void _loadMarkets() {
    _marketsFuture = _fetchMarkets();

    if (mounted) {
      setState(() {});
    }
  }

  Future<List<CoinModel>> _fetchMarkets() async {
    final data = await _marketService.fetchMarkets();

    return (data as List)
        .map(
          (e) => CoinModel.fromJson(e),
        )
        .toList();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).extension<AvexaColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return FutureBuilder<List<CoinModel>>(
      future: _marketsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return _loadingState(colors, l10n);
        }

        if (snapshot.hasError) {
          return _errorState(colors, l10n);
        }

        final coins = snapshot.data ?? [];

        if (coins.isEmpty) {
          return _emptyState(colors, l10n);
        }

        return Column(
          children: [
            // ==========================================================
            // LIVE HEADER
            // ==========================================================

            Padding(
              padding: const EdgeInsets.fromLTRB(
                4,
                2,
                4,
                12,
              ),
              child: Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: neonGreen,
                      shape: BoxShape.circle,
                    ),
                  ),

                  const SizedBox(width: 7),

                  Text(
                    l10n.liveMarketLive,
                    style: GoogleFonts.poppins(
                      color: neonGreen,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: .8,
                    ),
                  ),

                  const Spacer(),

                  Flexible(
                    child: Text(
                      l10n.liveMarketUpdateInterval,
                      textAlign: TextAlign.end,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: colors.mutedText,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ==========================================================
            // MARKET VALUES
            // ==========================================================

            ...coins.take(5).map(
              (coin) => _coinRow(
                coin,
                colors,
                l10n,
              ),
            ),
          ],
        );
      },
    );
  }

  // ========================================================================
  // COIN ROW
  // ========================================================================

  Widget _coinRow(
    CoinModel coin,
    AvexaColors colors,
    AppLocalizations l10n,
  ) {
    final isPositive = coin.change24h >= 0;

    final changeColor =
        isPositive ? neonGreen : neonRed;

    return Container(
      margin: const EdgeInsets.only(
        bottom: 8,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: colors.elevatedCard,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: colors.border,
        ),
      ),
      child: Row(
        children: [
          // ==============================================================
          // COIN ICON
          // ==============================================================

          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: neonBlue.withOpacity(.09),
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.network(
                coin.image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return const Icon(
                    Icons.currency_bitcoin,
                    color: neonBlue,
                    size: 20,
                  );
                },
              ),
            ),
          ),

          const SizedBox(width: 12),

          // ==============================================================
          // NAME / SYMBOL
          // ==============================================================

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  coin.symbol.toUpperCase(),
                  style: GoogleFonts.poppins(
                    color: colors.primaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  l10n.liveMarket24hLabel,
                  style: GoogleFonts.poppins(
                    color: colors.mutedText,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),

          // ==============================================================
          // PRICE
          // ==============================================================

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              Text(
                _formatPrice(coin.price),
                style: GoogleFonts.poppins(
                  color: colors.primaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 4),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: changeColor.withOpacity(.10),
                  borderRadius:
                      BorderRadius.circular(7),
                ),
                child: Row(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      size: 10,
                      color: changeColor,
                    ),

                    const SizedBox(width: 2),

                    Text(
                      '${coin.change24h.abs().toStringAsFixed(2)}%',
                      style: GoogleFonts.poppins(
                        color: changeColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ========================================================================
  // PRICE FORMAT
  // ========================================================================

  String _formatPrice(dynamic value) {
    final price = double.tryParse(
      value.toString(),
    );

    if (price == null) {
      return '\$${value.toString()}';
    }

    if (price >= 1000) {
      return '\$${price.toStringAsFixed(2)}';
    }

    if (price >= 1) {
      return '\$${price.toStringAsFixed(2)}';
    }

    if (price >= 0.01) {
      return '\$${price.toStringAsFixed(4)}';
    }

    return '\$${price.toStringAsFixed(6)}';
  }

  // ========================================================================
  // LOADING
  // ========================================================================

  Widget _loadingState(
    AvexaColors colors,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          children: [
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: neonBlue,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              l10n.liveMarketLoading,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: colors.secondaryText,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========================================================================
  // ERROR
  // ========================================================================

  Widget _errorState(
    AvexaColors colors,
    AppLocalizations l10n,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: neonRed.withOpacity(.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: neonRed.withOpacity(.18),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            color: neonRed,
            size: 22,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              l10n.liveMarketError,
              style: GoogleFonts.poppins(
                color: colors.secondaryText,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========================================================================
  // EMPTY
  // ========================================================================

  Widget _emptyState(
    AvexaColors colors,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Text(
        l10n.liveMarketEmpty,
        style: GoogleFonts.poppins(
          color: colors.secondaryText,
          fontSize: 12,
        ),
      ),
    );
  }
}
