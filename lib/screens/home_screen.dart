
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_localizations.dart';
import '../theme.dart';
import '../widgets/market_sentiment_card.dart';
import '../widgets/live_market_widget.dart';
import '../widgets/top_movers_widget.dart';
import '../widgets/community_partners_widget.dart';

import 'rug_check_screen.dart';
import 'wallet_tracker_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AvexaColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      extendBody: false,
      backgroundColor: colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            8,
            20,
            120,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ============================================================
              // AVEXA HEADER
              // ============================================================

              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/analyx_logo.png',
                      width: 65,
                      height: 65,
                    ),

                    const SizedBox(height: 10),

                    Text(
                      l10n.homeTagline,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: colors.secondaryText,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ============================================================
              // FEATURE CARDS
              // ============================================================

              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _homeFeatureCard(
                        icon: Icons.shield_outlined,
                        title: l10n.homeRugCheck,
                        subtitle: l10n.homeRugCheckDescription,
                        colors: colors,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RugCheckScreen(),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: _homeFeatureCard(
                        icon: Icons.account_balance_wallet_rounded,
                        title: l10n.homeWalletTracker,
                        subtitle: l10n.homeWalletTrackerDescription,
                        colors: colors,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const WalletTrackerScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // ============================================================
              // AVEXA COMMUNITY
              // ============================================================

              const CommunityPartnersWidget(),

              const SizedBox(height: 22),

              // ============================================================
              // MARKET SENTIMENT
              // ============================================================

              const MarketSentimentCard(),

              const SizedBox(height: 22),

              // ============================================================
              // LIVE MARKET DATA
              // ============================================================

              _buildExpandableSection(
                context: context,
                title: l10n.homeLiveMarketData,
                child: const LiveMarketWidget(),
                colors: colors,
              ),

              const SizedBox(height: 16),

              // ============================================================
              // TOP MOVERS
              // ============================================================

              _buildExpandableSection(
                context: context,
                title: l10n.homeTopMovers,
                child: const TopMoversWidget(),
                colors: colors,
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FEATURE CARD
  // ============================================================

  Widget _homeFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required AvexaColors colors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(
          minHeight: 190,
        ),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: neonBlue.withOpacity(0.35),
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: neonBlue.withOpacity(0.07),
              blurRadius: 24,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: neonBlue.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: neonBlue,
                size: 32,
              ),
            ),

            const SizedBox(height: 14),

            Text(
              title,
              style: GoogleFonts.poppins(
                color: colors.primaryText,
                fontSize: 19,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              subtitle,
              style: GoogleFonts.poppins(
                color: colors.mutedText,
                fontSize: 11,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // AI MARKET SCORE
  // ============================================================

  Widget _buildScoreCard({
    required AvexaColors colors,
    required double? score,
    required String description,
  }) {
    final displayScore =
        score == null ? '--' : score.toStringAsFixed(0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xff149BFF),
            Color(0xff0B5DB7),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: neonBlue.withOpacity(0.16),
            blurRadius: 28,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI MARKET SCORE',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            '$displayScore / 100',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            description,
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.86),
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 20),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: score == null ? null : score / 100,
              minHeight: 11,
              backgroundColor: Colors.white.withOpacity(0.16),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(
                Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 14),

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

              Text(
                'LIVE • Market conditions',
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.65),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EXPANDABLE SECTION
  // ============================================================

  Widget _buildExpandableSection({
    required BuildContext context,
    required String title,
    required Widget child,
    required AvexaColors colors,
    Color? iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colors.border,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 4,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(
            16,
            0,
            16,
            16,
          ),
          collapsedIconColor: colors.secondaryText,
          iconColor: iconColor ?? neonBlue,
          title: Text(
            title,
            style: GoogleFonts.poppins(
              color: colors.primaryText,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          children: [
            child,
          ],
        ),
      ),
    );
  }
}
