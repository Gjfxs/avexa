
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_localizations.dart';
import '../theme.dart';
import 'onboarding_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutAnalyXScreen extends StatelessWidget {
  const AboutAnalyXScreen({super.key});

  Future<void> _openOnboarding(
    BuildContext context,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OnboardingScreen(
          onFinished: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Future<void> _openLegalLink(
    BuildContext context,
    String url,
  ) async {
    final uri = Uri.parse(url);

    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open this page.'),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open this page.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).extension<AvexaColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: colors.primaryText,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          l10n.aboutTitle,
          style: GoogleFonts.poppins(
            color: colors.primaryText,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            24,
            20,
            24,
            40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

            const SizedBox(height: 36),

            _sectionTitle(
              'LEGAL & SUPPORT',
              colors,
            ),

            const SizedBox(height: 14),

            _legalTile(
              colors: colors,
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              subtitle: 'Learn how Avexa collects and protects your data.',
              onTap: () => _openLegalLink(
                context,
                'http://nex-start.com/privacy-policy.html',
              ),
            ),

            const SizedBox(height: 10),

            _legalTile(
              colors: colors,
              icon: Icons.description_outlined,
              title: 'Terms of Use',
              subtitle: 'Rules and conditions for using Avexa.',
              onTap: () => _openLegalLink(
                context,
                'http://nex-start.com/terms-of-use-en.html',
              ),
            ),

            const SizedBox(height: 10),

            _legalTile(
              colors: colors,
              icon: Icons.warning_amber_rounded,
              title: 'Risk Disclaimer',
              subtitle: 'Important information about cryptocurrency trading risks.',
              onTap: () => _openLegalLink(
                context,
                'http://nex-start.com/risk-disclaimer-en.html',
              ),
            ),

            const SizedBox(height: 36),

              Center(
                child: Column(
                  children: [
                    Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: neonBlue.withOpacity(0.06),
                        border: Border.all(
                          color: neonBlue.withOpacity(0.70),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: neonBlue.withOpacity(.20),
                            blurRadius: 30,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/images/analyx_logo.png',
                          width: 62,
                          height: 62,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      'Avexa',
                      style: GoogleFonts.poppins(
                        color: colors.primaryText,
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      l10n.aboutTagline,
                      style: GoogleFonts.poppins(
                        color: colors.secondaryText,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: neonBlue.withOpacity(.10),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: neonBlue.withOpacity(.22),
                        ),
                      ),
                      child: Text(
                        l10n.aboutVersion,
                        style: GoogleFonts.poppins(
                          color: neonBlue,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 42),

              _sectionTitle(
                l10n.aboutSection,
                colors,
              ),

              const SizedBox(height: 14),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: colors.border,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: neonBlue.withOpacity(.04),
                      blurRadius: 20,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Text(
                  l10n.aboutDescription,
                  style: GoogleFonts.poppins(
                    color: colors.secondaryText,
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
              ),

              const SizedBox(height: 36),

              _sectionTitle(
                l10n.aboutGettingStarted,
                colors,
              ),

              const SizedBox(height: 14),

              GestureDetector(
                onTap: () {
                  _openOnboarding(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: neonBlue.withOpacity(.22),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: neonBlue.withOpacity(.05),
                        blurRadius: 20,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: neonBlue.withOpacity(.10),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: neonBlue.withOpacity(.18),
                          ),
                        ),
                        child: const Icon(
                          Icons.play_circle_outline,
                          color: neonBlue,
                          size: 25,
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.aboutViewOnboarding,
                              style: GoogleFonts.poppins(
                                color: colors.primaryText,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              l10n.aboutOnboardingDescription,
                              style: GoogleFonts.poppins(
                                color: colors.secondaryText,
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 10),

                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: colors.mutedText,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 36),

              _sectionTitle(
                l10n.aboutWhatWeDo,
                colors,
              ),

              const SizedBox(height: 14),

              _featureTile(
                colors: colors,
                icon: Icons.bolt_rounded,
                title: l10n.aboutTradingSignals,
                subtitle:
                    l10n.aboutTradingSignalsDescription,
              ),

              const SizedBox(height: 12),

              _featureTile(
                colors: colors,
                icon: Icons.account_balance_wallet_outlined,
                title: l10n.aboutWhaleTracking,
                subtitle:
                    l10n.aboutWhaleTrackingDescription,
              ),

              const SizedBox(height: 12),

              _featureTile(
                colors: colors,
                icon: Icons.auto_awesome,
                title: l10n.aboutMarketIntelligence,
                subtitle:
                    l10n.aboutMarketIntelligenceDescription,
              ),

              const SizedBox(height: 36),

              _sectionTitle(
                l10n.aboutOurMission,
                colors,
              ),

              const SizedBox(height: 14),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: LinearGradient(
                    colors: [
                      neonBlue.withOpacity(.95),
                      blueDark.withOpacity(.95),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: neonBlue.withOpacity(.14),
                      blurRadius: 24,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.14),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(.18),
                        ),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      l10n.aboutMissionStatement,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              Center(
                child: Column(
                  children: [
                    Text(
                      l10n.aboutBuiltForTraders,
                      style: GoogleFonts.poppins(
                        color: colors.secondaryText,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      l10n.aboutPoweredByIntelligence,
                      style: GoogleFonts.poppins(
                        color: neonBlue,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 18),

                    Text(
                      l10n.aboutCopyright,
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
        ),
      ),
    );
  }

  Widget _sectionTitle(
    String title,
    AvexaColors colors,
  ) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        color: colors.secondaryText,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.3,
      ),
    );
  }

  Widget _featureTile({
    required AvexaColors colors,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: neonBlue.withOpacity(.035),
            blurRadius: 18,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: neonBlue.withOpacity(.10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: neonBlue.withOpacity(.18),
              ),
            ),
            child: Icon(
              icon,
              color: neonBlue,
              size: 24,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: colors.primaryText,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    color: colors.secondaryText,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legalTile({
    required AvexaColors colors,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: colors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: neonBlue.withOpacity(.10),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: neonBlue.withOpacity(.18),
                ),
              ),
              child: Icon(
                icon,
                color: neonBlue,
                size: 22,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: colors.primaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      color: colors.secondaryText,
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.open_in_new_rounded,
              color: colors.mutedText,
              size: 17,
            ),
          ],
        ),
      ),
    );
  }
}
