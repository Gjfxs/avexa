
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../models/meme_signal.dart';
import '../theme.dart';

class SignalDetailScreen extends StatelessWidget {
  final MemeSignal signal;
  final VoidCallback? onViewDex;

  const SignalDetailScreen({
    super.key,
    required this.signal,
    this.onViewDex,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: textPrimary,
            size: 19,
          ),
        ),
        title: Text(
          l.signalDetailTitle,
          style: GoogleFonts.poppins(
            color: textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 35),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTokenHeader(l),
              const SizedBox(height: 24),
              _buildConfidence(l),
              const SizedBox(height: 20),
              _buildPriceLevels(l),
              const SizedBox(height: 16),
              _buildRiskSection(l),
              const SizedBox(height: 16),
              _buildTokenAddress(l),
              const SizedBox(height: 18),
              _buildActions(context, l),
              if (signal.reason != null &&
                  signal.reason!.trim().isNotEmpty) ...[
                const SizedBox(height: 24),
                _buildAnalysis(l),
              ],
              const SizedBox(height: 24),
              _buildDisclaimer(l),
            ],
          ),
        ),
      ),
    );
  }

  // TOKEN HEADER

  Widget _buildTokenHeader(AppLocalizations l) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: neonBlue.withOpacity(.20)),
        boxShadow: [
          BoxShadow(
            color: neonBlue.withOpacity(.045),
            blurRadius: 30,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildTokenImage(),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      signal.symbol,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: textPrimary,
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${l.signalDetailSolanaMeme}  •  ${signal.timeframe}',
                      style: GoogleFonts.poppins(
                        color: textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _headerInfo(
                  title: l.signalDetailDirection,
                  value: signal.direction,
                  valueColor:
                      signal.direction.toUpperCase() == 'SHORT'
                          ? neonRed
                          : neonGreen,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _headerInfo(
                  title: l.signalDetailTier,
                  value: signal.tier,
                  valueColor: neonBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTokenImage() {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: neonBlue.withOpacity(.10),
        border: Border.all(color: neonBlue.withOpacity(.22)),
        boxShadow: [
          BoxShadow(
            color: neonBlue.withOpacity(.10),
            blurRadius: 20,
          ),
        ],
      ),
      child: signal.imageUrl != null && signal.imageUrl!.isNotEmpty
          ? ClipOval(
              child: Image.network(
                signal.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.currency_bitcoin_rounded,
                  color: neonBlue,
                  size: 31,
                ),
              ),
            )
          : const Icon(
              Icons.currency_bitcoin_rounded,
              color: neonBlue,
              size: 31,
            ),
    );
  }

  Widget _headerInfo({
    required String title,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: borderColor.withOpacity(.60)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: textMuted,
                fontSize: 8,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: valueColor,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // AI CONFIDENCE

  Widget _buildConfidence(AppLocalizations l) {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l.signalDetailAiConfidence,
                  style: GoogleFonts.poppins(
                    color: textMuted,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .5,
                  ),
                ),
              ),
              Text(
                '${signal.confidence}%',
                style: GoogleFonts.poppins(
                  color: neonBlue,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              minHeight: 7,
              value: (signal.confidence / 100).clamp(0.0, 1.0),
              backgroundColor: Colors.white10,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(neonBlue),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l.signalDetailConfidenceDescription,
            style: GoogleFonts.poppins(
              color: textMuted,
              fontSize: 9,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // TRADE LEVELS

  Widget _buildPriceLevels(AppLocalizations l) {
    return _sectionCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel(
            icon: Icons.show_chart_rounded,
            title: l.signalDetailTradeLevels,
          ),
          const SizedBox(height: 14),
          _priceRow(
            title: l.signalDetailEntry,
            value: _formatPrice(signal.entryPrice),
            color: neonBlue,
          ),
          const SizedBox(height: 9),
          _priceRow(
            title: l.signalDetailStopLoss,
            value: _formatPrice(signal.stopLoss),
            color: neonRed,
          ),
          const SizedBox(height: 9),
          _priceRow(
            title: l.signalDetailTakeProfit1,
            value: _formatPrice(signal.takeProfit1),
            color: neonGreen,
          ),
          if (signal.takeProfit2 != null) ...[
            const SizedBox(height: 9),
            _priceRow(
              title: l.signalDetailTakeProfit2,
              value: _formatPrice(signal.takeProfit2!),
              color: neonGreen,
            ),
          ],
          if (signal.takeProfit3 != null) ...[
            const SizedBox(height: 9),
            _priceRow(
              title: l.signalDetailTakeProfit3,
              value: _formatPrice(signal.takeProfit3!),
              color: neonGreen,
            ),
          ],
        ],
      ),
    );
  }

  Widget _priceRow({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor.withOpacity(.65)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                color: textMuted,
                fontSize: 8,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // RISK

  Widget _buildRiskSection(AppLocalizations l) {
    return _sectionCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _riskBox(
              title: l.signalDetailRiskLevel,
              value: _localizedRisk(l),
              color: _riskColor(signal.riskLevel),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _riskBox(
              title: l.signalDetailRiskReward,
              value: signal.riskReward != null
                  ? '1:${signal.riskReward!.toStringAsFixed(2)}'
                  : '—',
              color: neonBlue,
            ),
          ),
        ],
      ),
    );
  }

  String _localizedRisk(AppLocalizations l) {
    switch (signal.riskLevel.toUpperCase()) {
      case 'LOW':
        return l.signalDetailRiskLow;
      case 'MEDIUM':
        return l.signalDetailRiskMedium;
      case 'HIGH':
        return l.signalDetailRiskHigh;
      default:
        return signal.riskLevel;
    }
  }

  Widget _riskBox({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor.withOpacity(.65)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: textMuted,
              fontSize: 7,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Color _riskColor(String risk) {
    switch (risk.toUpperCase()) {
      case 'LOW':
        return neonGreen;
      case 'MEDIUM':
        return neonYellow;
      default:
        return neonRed;
    }
  }

  // TOKEN ADDRESS

  Widget _buildTokenAddress(AppLocalizations l) {
    final address = signal.tokenAddress;

    return _sectionCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel(
            icon: Icons.link_rounded,
            title: l.signalDetailTokenAddress,
          ),
          const SizedBox(height: 13),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: borderColor.withOpacity(.65)),
            ),
            child: Text(
              address == null || address.isEmpty
                  ? l.signalDetailAddressUnavailable
                  : address,
              style: GoogleFonts.robotoMono(
                color: textSecondary,
                fontSize: 9,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ACTION BUTTONS

  Widget _buildActions(BuildContext context, AppLocalizations l) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: () => _copyTokenAddress(context, l),
            style: ElevatedButton.styleFrom(
              backgroundColor: neonBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.copy_rounded, size: 18),
                const SizedBox(width: 9),
                Flexible(
                  child: Text(
                    l.signalDetailCopyAddress,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: OutlinedButton(
            onPressed: () => _openDexScreener(context, l),
            style: OutlinedButton.styleFrom(
              foregroundColor: neonBlue,
              side: BorderSide(color: neonBlue.withOpacity(.35)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.candlestick_chart_rounded, size: 18),
                const SizedBox(width: 9),
                Flexible(
                  child: Text(
                    l.signalDetailViewDexScreener,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: neonBlue,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openDexScreener(
    BuildContext context,
    AppLocalizations l,
  ) async {
    final pairAddress = signal.pairAddress;
    final tokenAddress = signal.tokenAddress;
    final address = pairAddress != null && pairAddress.trim().isNotEmpty
        ? pairAddress.trim()
        : tokenAddress?.trim();

    if (address == null || address.isEmpty) {
      if (!context.mounted) return;
      _showMessage(context, l.signalDetailDexLinkUnavailable);
      return;
    }

    final uri = Uri.parse('https://dexscreener.com/solana/$address');

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        _showMessage(context, l.signalDetailDexOpenError);
      }
    } catch (_) {
      if (!context.mounted) return;
      _showMessage(context, l.signalDetailDexOpenError);
    }
  }

  Future<void> _copyTokenAddress(
    BuildContext context,
    AppLocalizations l,
  ) async {
    final address = signal.tokenAddress;

    if (address == null || address.isEmpty) {
      _showMessage(context, l.signalDetailAddressUnavailable);
      return;
    }

    await Clipboard.setData(ClipboardData(text: address));

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: cardElevated,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: neonGreen,
              size: 18,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                l.signalDetailAddressCopied,
                style: GoogleFonts.poppins(
                  color: textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: cardElevated,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        content: Text(
          message,
          style: GoogleFonts.poppins(
            color: textPrimary,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  // AI ANALYSIS

  Widget _buildAnalysis(AppLocalizations l) {
    return _sectionCard(
      padding: const EdgeInsets.all(17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel(
            icon: Icons.auto_awesome_rounded,
            title: l.signalDetailAiAnalysis,
          ),
          const SizedBox(height: 13),
          Text(
            signal.reason!,
            style: GoogleFonts.poppins(
              color: textSecondary,
              fontSize: 10,
              height: 1.65,
            ),
          ),
        ],
      ),
    );
  }

  // DISCLAIMER

  Widget _buildDisclaimer(AppLocalizations l) {
    return Center(
      child: Text(
        l.signalDetailDisclaimer,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          color: textMuted.withOpacity(.55),
          fontSize: 9,
          height: 1.5,
        ),
      ),
    );
  }

  // HELPERS

  Widget _sectionCard({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(18),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor.withOpacity(.75)),
      ),
      child: child,
    );
  }

  Widget _sectionLabel({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Icon(icon, color: neonBlue, size: 16),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.poppins(
              color: textSecondary,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: .7,
            ),
          ),
        ),
      ],
    );
  }

  String _formatPrice(double price) {
    if (price == 0) return '—';
    if (price >= 1000) return price.toStringAsFixed(2);
    if (price >= 1) return price.toStringAsFixed(4);
    if (price >= 0.01) return price.toStringAsFixed(6);

    return price
        .toStringAsFixed(10)
        .replaceFirst(RegExp(r'0+$'), '');
  }
}
