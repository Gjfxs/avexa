
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme.dart';
import '../l10n/app_localizations.dart';
import '../services/rug_check_service.dart';

class RugCheckScreen extends StatefulWidget {
  const RugCheckScreen({super.key});

  @override
  State<RugCheckScreen> createState() => _RugCheckScreenState();
}

class _RugCheckScreenState extends State<RugCheckScreen> {
  final TextEditingController _addressController =
      TextEditingController();

  bool _isScanning = false;

  final RugCheckService _rugCheckService = RugCheckService();

  Map<String, dynamic>? _result;

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _scanToken() async {
    final address = _addressController.text.trim();

    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.rugCheckEnterAddress),
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isScanning = true;
      _result = null;
    });

    try {
      final result = await _rugCheckService.scanToken(address);

      if (!mounted) return;

      setState(() {
        _result = result;
        _isScanning = false;
      });

      _showResult(result);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isScanning = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    }
  }

  void _showResult(Map<String, dynamic> result) {
    final l10n = AppLocalizations.of(context)!;

    final score = Map<String, dynamic>.from(
      result['score'] ?? {},
    );

    final token = Map<String, dynamic>.from(
      result['token'] ?? {},
    );

    final authorities = Map<String, dynamic>.from(
      result['authorities'] ?? {},
    );

    final liquidity = Map<String, dynamic>.from(
      result['liquidity'] ?? {},
    );

    final holders = Map<String, dynamic>.from(
      result['holders'] ?? {},
    );

    final creator = Map<String, dynamic>.from(
      result['creator'] ?? {},
    );

    final risks = (result['risks'] as List?)
            ?.map((risk) => Map<String, dynamic>.from(risk))
            .toList() ??
        [];

    final safetyScore = (score['safety'] as num?)?.toInt() ?? 0;

    final riskLevel = score['level']?.toString() ?? 'UNKNOWN';

    final tokenName =
        token['name']?.toString() ?? l10n.rugCheckUnknownToken;

    final tokenSymbol = token['symbol']?.toString() ?? '';

    final mintEnabled = authorities['mintEnabled'] == true;

    final freezeEnabled = authorities['freezeEnabled'] == true;

    final liquidityUsd =
        (liquidity['totalUsd'] as num?)?.toDouble();

    final lpLocked =
        (liquidity['lpLockedPct'] as num?)?.toDouble();

    final totalHolders = (holders['total'] as num?)?.toDouble();

    final topHolderPct =
        (holders['topHolderPct'] as num?)?.toDouble();

    final top10Pct = (holders['top10Pct'] as num?)?.toDouble();

    final creatorExposure =
        (creator['tokenExposurePct'] as num?)?.toDouble();

    Color scoreColor;

    if (safetyScore >= 80) {
      scoreColor = neonGreen;
    } else if (safetyScore >= 60) {
      scoreColor = neonYellow;
    } else {
      scoreColor = neonRed;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final colors =
            Theme.of(context).extension<AvexaColors>()!;

        return Container(
          height: MediaQuery.of(context).size.height * 0.82,
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(30),
            ),
            border: Border(
              top: BorderSide(
                color: neonBlue.withOpacity(0.25),
              ),
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colors.border,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // HEADER

                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: neonBlue.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.shield_outlined,
                          color: neonBlue,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tokenSymbol.isEmpty
                                  ? tokenName
                                  : '$tokenName ($tokenSymbol)',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                color: colors.primaryText,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              l10n.rugCheckAnalysisTitle,
                              style: GoogleFonts.poppins(
                                color: colors.mutedText,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // SAFETY SCORE

                  Center(
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: scoreColor.withOpacity(0.65),
                          width: 8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: scoreColor.withOpacity(0.12),
                            blurRadius: 30,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$safetyScore',
                            style: GoogleFonts.poppins(
                              color: colors.primaryText,
                              fontSize: 42,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '/ 100',
                            style: GoogleFonts.poppins(
                              color: colors.mutedText,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: scoreColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        riskLevel,
                        style: GoogleFonts.poppins(
                          color: scoreColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // TOKEN OVERVIEW

                  Text(
                    l10n.rugCheckTokenOverview,
                    style: GoogleFonts.poppins(
                      color: colors.primaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 12),

                  _dataRow(
                    l10n.rugCheckLiquidity,
                    liquidityUsd == null
                        ? l10n.rugCheckUnavailable
                        : _formatUsd(liquidityUsd),
                    colors,
                  ),

                  _dataRow(
                    l10n.rugCheckLpLocked,
                    lpLocked == null
                        ? l10n.rugCheckUnavailable
                        : '${lpLocked.toStringAsFixed(1)}%',
                    colors,
                  ),

                  _dataRow(
                    l10n.rugCheckHolders,
                    totalHolders == null
                        ? l10n.rugCheckUnavailable
                        : _formatNumber(totalHolders),
                    colors,
                  ),

                  _dataRow(
                    l10n.rugCheckTopHolder,
                    topHolderPct == null
                        ? l10n.rugCheckUnavailable
                        : '${topHolderPct.toStringAsFixed(1)}%',
                    colors,
                  ),

                  _dataRow(
                    l10n.rugCheckTop10Holders,
                    top10Pct == null
                        ? l10n.rugCheckUnavailable
                        : '${top10Pct.toStringAsFixed(1)}%',
                    colors,
                  ),

                  const SizedBox(height: 24),

                  // SECURITY CHECKS

                  Text(
                    l10n.rugCheckSecurityChecks,
                    style: GoogleFonts.poppins(
                      color: colors.primaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 12),

                  _riskRow(
                    l10n.rugCheckMintAuthority,
                    mintEnabled
                        ? l10n.rugCheckEnabled
                        : l10n.rugCheckDisabled,
                    mintEnabled ? neonRed : neonGreen,
                    colors,
                  ),

                  _riskRow(
                    l10n.rugCheckFreezeAuthority,
                    freezeEnabled
                        ? l10n.rugCheckEnabled
                        : l10n.rugCheckDisabled,
                    freezeEnabled ? neonRed : neonGreen,
                    colors,
                  ),

                  _riskRow(
                    l10n.rugCheckDevWallet,
                    creatorExposure == null
                        ? l10n.rugCheckUnknown
                        : l10n.rugCheckExposure(
                            creatorExposure.toStringAsFixed(1),
                          ),
                    creatorExposure != null && creatorExposure > 10
                        ? neonRed
                        : neonGreen,
                    colors,
                  ),

                  const SizedBox(height: 24),

                  // DETECTED RISKS

                  Text(
                    l10n.rugCheckDetectedRisks,
                    style: GoogleFonts.poppins(
                      color: colors.primaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (risks.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: neonGreen.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: neonGreen.withOpacity(0.18),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            color: neonGreen,
                            size: 21,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              l10n.rugCheckNoRisks,
                              style: GoogleFonts.poppins(
                                color: colors.secondaryText,
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...risks.take(5).map((risk) {
                      final level =
                          risk['level']?.toString().toLowerCase();

                      final isDanger = level == 'danger';

                      final riskColor =
                          isDanger ? neonRed : neonYellow;

                      // Nazwy i opisy ryzyk pochodzą z API.
                      // Zachowujemy je bez automatycznego tłumaczenia.
                      final name = risk['name']?.toString() ??
                          l10n.rugCheckRiskDetected;

                      final description =
                          risk['description']?.toString() ?? '';

                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: riskColor.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: riskColor.withOpacity(0.18),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              isDanger
                                  ? Icons.dangerous_outlined
                                  : Icons.warning_amber_rounded,
                              color: riskColor,
                              size: 21,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: GoogleFonts.poppins(
                                      color: colors.primaryText,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  if (description.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      description,
                                      style: GoogleFonts.poppins(
                                        color: colors.secondaryText,
                                        fontSize: 11,
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                  const SizedBox(height: 22),

                  // DISCLAIMER

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: colors.border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: neonBlue,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l10n.rugCheckDisclaimer,
                            style: GoogleFonts.poppins(
                              color: colors.mutedText,
                              fontSize: 11,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _dataRow(
    String title,
    String value,
    AvexaColors colors,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                color: colors.secondaryText,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: colors.primaryText,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _formatUsd(double value) {
    if (value >= 1000000) {
      return '\$${(value / 1000000).toStringAsFixed(2)}M';
    }

    if (value >= 1000) {
      return '\$${(value / 1000).toStringAsFixed(1)}K';
    }

    return '\$${value.toStringAsFixed(0)}';
  }

  String _formatNumber(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(2)}M';
    }

    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }

    return value.toStringAsFixed(0);
  }

  Widget _riskRow(
    String title,
    String status,
    Color statusColor,
    AvexaColors colors,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                color: colors.secondaryText,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            status,
            style: GoogleFonts.poppins(
              color: statusColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pasteAddress() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);

    if (data?.text == null || data!.text!.isEmpty) return;

    setState(() {
      _addressController.text = data.text!.trim();
      _addressController.selection = TextSelection.fromPosition(
        TextPosition(
          offset: _addressController.text.length,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AvexaColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colors.primaryText,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.rugCheckTitle,
          style: GoogleFonts.poppins(
            color: colors.primaryText,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: SizedBox(
                  width: 120,
                  height: 120,
                  child: Image.asset(
                    'assets/images/rug_check_alien.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: Text(
                  l10n.rugCheckHeadline,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: colors.primaryText,
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Center(
                child: Text(
                  l10n.rugCheckDescription,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: colors.mutedText,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Text(
                l10n.rugCheckTokenAddress,
                style: GoogleFonts.poppins(
                  color: colors.secondaryText,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.7,
                ),
              ),

              const SizedBox(height: 9),

              Container(
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: colors.border),
                ),
                child: TextField(
                  controller: _addressController,
                  style: GoogleFonts.poppins(
                    color: colors.primaryText,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  minLines: 1,
                  decoration: InputDecoration(
                    hintText: l10n.rugCheckAddressHint,
                    hintStyle: GoogleFonts.poppins(
                      color: colors.mutedText,
                      fontSize: 12,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(17),
                    suffixIcon: IconButton(
                      onPressed: _pasteAddress,
                      icon: const Icon(
                        Icons.content_paste_rounded,
                        color: neonBlue,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isScanning ? null : _scanToken,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: neonBlue,
                    disabledBackgroundColor:
                        neonBlue.withOpacity(0.45),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: _isScanning
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              l10n.rugCheckScanning,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          l10n.rugCheckScanButton,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            letterSpacing: 0.6,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 30),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.security_rounded,
                          color: neonBlue,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          l10n.rugCheckWhatWeCheck,
                          style: GoogleFonts.poppins(
                            color: colors.primaryText,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _infoItem(l10n.rugCheckLiquiditySecurity, colors),
                    _infoItem(l10n.rugCheckHolderConcentration, colors),
                    _infoItem(l10n.rugCheckAuthorities, colors),
                    _infoItem(l10n.rugCheckDevExposure, colors),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoItem(
    String text,
    AvexaColors colors,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            color: neonBlue,
            size: 17,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                color: colors.secondaryText,
                fontSize: 11.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
