
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_localizations.dart';
import '../services/market_service.dart';
import '../theme.dart';

class MarketSentimentCard extends StatefulWidget {
  const MarketSentimentCard({super.key});

  @override
  State<MarketSentimentCard> createState() =>
      _MarketSentimentCardState();
}

class _MarketSentimentCardState
    extends State<MarketSentimentCard> {
  final MarketService _marketService = MarketService();

  AppLocalizations get l10n =>
      AppLocalizations.of(context)!;

  Timer? _timer;

  double _score = 50;
  String _sentiment = '';
  String _description = '';
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    _loadSentiment();

    _timer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _loadSentiment(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadSentiment() async {
    try {
      final markets = await _marketService.fetchMarkets();

      if (markets.isEmpty) {
        throw Exception('No market data available');
      }

      final result = _calculateSentiment(markets);

      if (!mounted) return;

      setState(() {
        _score = result.score;
        _sentiment = result.sentiment;
        _description = result.description;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = l10n.marketSentimentError;
      });
    }
  }

  _SentimentResult _calculateSentiment(
    List<dynamic> markets,
  ) {
    final coins = markets
        .whereType<Map>()
        .toList();

    if (coins.isEmpty) {
      return _SentimentResult(
        score: 50,
        sentiment: l10n.marketSentimentNeutral,
        description: l10n.marketSentimentBalanced,
      );
    }

    // ----------------------------------------------------------
    // 1. PRICE MOMENTUM
    // ----------------------------------------------------------

    final changes = coins.map((coin) {
      return _toDouble(
        coin['price_change_percentage_24h'],
      );
    }).toList();

    final averageChange =
        changes.reduce((a, b) => a + b) / changes.length;

    final momentumScore = _clamp(
      50 + (averageChange * 5),
      0,
      100,
    );

    // ----------------------------------------------------------
    // 2. MARKET BREADTH
    // ----------------------------------------------------------

    final gainers =
        changes.where((change) => change > 0).length;

    final losers =
        changes.where((change) => change < 0).length;

    final totalMoving = gainers + losers;

    final breadthScore = totalMoving == 0
        ? 50
        : (gainers / totalMoving) * 100;

    // ----------------------------------------------------------
    // 3. LARGE CAP MOMENTUM
    // ----------------------------------------------------------

    final largeCaps = coins.take(10).toList();

    final largeCapChanges = largeCaps.map((coin) {
      return _toDouble(
        coin['price_change_percentage_24h'],
      );
    }).toList();

    final largeCapAverage =
        largeCapChanges.isEmpty
            ? 0
            : largeCapChanges.reduce((a, b) => a + b) /
                largeCapChanges.length;

    final largeCapScore = _clamp(
      50 + (largeCapAverage * 5),
      0,
      100,
    );

    // ----------------------------------------------------------
    // 4. VOLUME CONFIDENCE
    // ----------------------------------------------------------

    double volumeScore = 50;

    final volumeChanges = coins
        .map((coin) {
          final volume =
              _toDouble(coin['total_volume']);

          final marketCap =
              _toDouble(coin['market_cap']);

          if (marketCap <= 0) return null;

          return volume / marketCap;
        })
        .whereType<double>()
        .toList();

    if (volumeChanges.isNotEmpty) {
      final averageVolumeRatio =
          volumeChanges.reduce((a, b) => a + b) /
              volumeChanges.length;

      volumeScore = _clamp(
        50 + ((averageVolumeRatio - 0.05) * 300),
        0,
        100,
      );
    }

    // ----------------------------------------------------------
    // FINAL AVEXA SCORE
    // ----------------------------------------------------------

    final finalScore = _clamp(
      (momentumScore * 0.40) +
          (breadthScore * 0.30) +
          (largeCapScore * 0.20) +
          (volumeScore * 0.10),
      0,
      100,
    );

    final sentiment = _getSentiment(finalScore);

    final description = _getDescription(
      finalScore,
      averageChange,
      gainers,
      losers,
    );

    return _SentimentResult(
      score: finalScore,
      sentiment: sentiment,
      description: description,
    );
  }

  String _getSentiment(double score) {
    if (score >= 80) {
      return l10n.marketSentimentExtremeGreed;
    }

    if (score >= 60) {
      return l10n.marketSentimentGreed;
    }

    if (score >= 40) {
      return l10n.marketSentimentNeutral;
    }

    if (score >= 20) {
      return l10n.marketSentimentFear;
    }

    return l10n.marketSentimentExtremeFear;
  }

  String _getDescription(
    double score,
    double averageChange,
    int gainers,
    int losers,
  ) {
    if (score >= 80) {
      return l10n.marketSentimentStrongBullish;
    }

    if (score >= 60) {
      return l10n.marketSentimentBullish;
    }

    if (score >= 40) {
      return l10n.marketSentimentBalanced;
    }

    if (score >= 20) {
      return l10n.marketSentimentBearish;
    }

    return l10n.marketSentimentStrongBearish;
  }

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  double _clamp(
    double value,
    double min,
    double max,
  ) {
    return value.clamp(min, max).toDouble();
  }

  Color _sentimentColor() {
    if (_score >= 60) {
      return neonGreen;
    }

    if (_score >= 40) {
      return neonYellow;
    }

    return neonRed;
  }

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).extension<AvexaColors>()!;

    final sentimentColor = _sentimentColor();

    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            neonBlue.withOpacity(0.14),
            colors.card,
            colors.card,
          ],
        ),
        border: Border.all(
          color: neonBlue.withOpacity(0.30),
        ),
        boxShadow: [
          BoxShadow(
            color: neonBlue.withOpacity(0.08),
            blurRadius: 24,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ----------------------------------------------------
          // HEADER
          // ----------------------------------------------------

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  l10n.marketSentimentTitle,
                  style: GoogleFonts.poppins(
                    color: colors.primaryText,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: sentimentColor.withOpacity(0.14),
                  borderRadius:
                      BorderRadius.circular(16),
                  border: Border.all(
                    color:
                        sentimentColor.withOpacity(0.30),
                  ),
                ),
                child: Text(
                  _loading
                      ? l10n.marketSentimentLoading
                      : _sentiment,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: sentimentColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ----------------------------------------------------
          // SCORE
          // ----------------------------------------------------

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              Text(
                _loading
                    ? '--'
                    : _score.toStringAsFixed(0),
                style: GoogleFonts.poppins(
                  color: colors.primaryText,
                  fontSize: 42,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),

              const SizedBox(width: 8),

              Padding(
                padding:
                    const EdgeInsets.only(bottom: 4),
                child: Text(
                  '/ 100',
                  style: GoogleFonts.poppins(
                    color: colors.mutedText,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ----------------------------------------------------
          // PROGRESS BAR
          // ----------------------------------------------------

          ClipRRect(
            borderRadius:
                BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: _loading
                  ? null
                  : _score / 100,
              minHeight: 16,
              backgroundColor:
                  colors.elevatedCard,
              valueColor:
                  AlwaysStoppedAnimation<Color>(
                sentimentColor,
              ),
            ),
          ),

          const SizedBox(height: 18),

          // ----------------------------------------------------
          // LABELS
          // ----------------------------------------------------

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.marketSentimentFear,
                style: GoogleFonts.poppins(
                  color: neonRed,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                l10n.marketSentimentNeutral,
                style: GoogleFonts.poppins(
                  color: colors.mutedText,
                ),
              ),
              Text(
                l10n.marketSentimentGreed,
                style: GoogleFonts.poppins(
                  color: neonGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // ----------------------------------------------------
          // AI EXPLANATION
          // ----------------------------------------------------

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color:
                      neonBlue.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        neonBlue.withOpacity(0.22),
                  ),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: neonBlue,
                  size: 20,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  _error ??
                      (_loading
                          ? l10n.marketSentimentLoadingDescription
                          : _description),
                  style: GoogleFonts.poppins(
                    color: _error != null
                        ? neonRed
                        : colors.secondaryText,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ----------------------------------------------------
          // LIVE INDICATOR
          // ----------------------------------------------------

          Row(
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

              Flexible(
                child: Text(
                  l10n.marketSentimentLiveUpdates,
                  style: GoogleFonts.poppins(
                    color: colors.mutedText,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SentimentResult {
  final double score;
  final String sentiment;
  final String description;

  const _SentimentResult({
    required this.score,
    required this.sentiment,
    required this.description,
  });
}
