
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_localizations.dart';
import '../services/onboarding_service.dart';
import '../theme.dart';
import 'main_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinished;

  const OnboardingScreen({
    super.key,
    required this.onFinished,
  });

  @override
  State<OnboardingScreen> createState() =>
      _OnboardingScreenState();
}

class _OnboardingSlide {
  final int page;
  final String section;
  final String title;
  final String description;
  final String image;

  const _OnboardingSlide({
    required this.page,
    required this.section,
    required this.title,
    required this.description,
    required this.image,
  });
}

class _OnboardingScreenState
    extends State<OnboardingScreen> {
  final PageController _controller = PageController();

  int _currentPage = 0;
  bool _finishing = false;

  List<_OnboardingSlide> _slides(AppLocalizations l10n) {
    return [
      _OnboardingSlide(
        page: 2,
        section: l10n.onboardingHomeSection,
        title: l10n.onboardingHomeTitle,
        description: l10n.onboardingHomeDescription,
        image: 'assets/onboarding/01_home.png',
      ),
      _OnboardingSlide(
        page: 0,
        section: l10n.onboardingChartsSection,
        title: l10n.onboardingChartsTitle,
        description: l10n.onboardingChartsDescription,
        image: 'assets/onboarding/02_charts.png',
      ),
      _OnboardingSlide(
        page: 1,
        section: l10n.onboardingSignalsSection,
        title: l10n.onboardingSignalsTitle,
        description: l10n.onboardingSignalsDescription,
        image: 'assets/onboarding/03_signals.png',
      ),
      _OnboardingSlide(
        page: 3,
        section: l10n.onboardingAiChartSection,
        title: l10n.onboardingAiChartTitle,
        description: l10n.onboardingAiChartDescription,
        image: 'assets/onboarding/04_ai_chart.png',
      ),
      _OnboardingSlide(
        page: 4,
        section: l10n.onboardingPortfolioSection,
        title: l10n.onboardingPortfolioTitle,
        description: l10n.onboardingPortfolioDescription,
        image: 'assets/onboarding/04_portfolio.png',
      ),
    ];
  }

  Future<void> _finish() async {
    if (_finishing) return;

    setState(() {
      _finishing = true;
    });

    try {
      await OnboardingService.instance.markCompleted();

      if (!mounted) return;

      widget.onFinished();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _finishing = false;
      });

      debugPrint('ONBOARDING FINISH ERROR: $error');
    }
  }

  void _next(int slideCount) {
    if (_finishing) return;

    if (_currentPage == slideCount - 1) {
      _finish();
      return;
    }

    _controller.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).extension<AvexaColors>()!;
    final l10n = AppLocalizations.of(context)!;
    final slides = _slides(l10n);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // REAL APP BACKGROUND
          Positioned.fill(
            child: _BackgroundApp(
              page: slides[_currentPage].page,
            ),
          ),

          // DARK GLASS OVERLAY
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 1.5,
                sigmaY: 1.5,
              ),
              child: Container(
                color: Colors.black.withOpacity(.52),
              ),
            ),
          ),

          // ONBOARDING
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    22,
                    12,
                    18,
                    0,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'AVEXA',
                        style: GoogleFonts.poppins(
                          color: colors.primaryText,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.6,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _finishing ? null : _finish,
                        child: Text(
                          l10n.onboardingSkip,
                          style: GoogleFonts.poppins(
                            color: colors.secondaryText,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: .8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: slides.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return _buildCard(
                        slides[index],
                        colors,
                        slides.length,
                        l10n,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    _OnboardingSlide slide,
    AvexaColors colors,
    int slideCount,
    AppLocalizations l10n,
  ) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 12,
              sigmaY: 12,
            ),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(
                maxWidth: 390,
              ),
              padding: const EdgeInsets.fromLTRB(
                20,
                18,
                20,
                20,
              ),
              decoration: BoxDecoration(
                color: colors.card.withOpacity(.82),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: neonBlue.withOpacity(.24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: neonBlue.withOpacity(.08),
                    blurRadius: 40,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // SECTION
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: neonBlue.withOpacity(.09),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: neonBlue.withOpacity(.25),
                      ),
                    ),
                    child: Text(
                      slide.section,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: neonBlue,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.3,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // SLIDE IMAGE
                  SizedBox(
                    height: screenHeight * .29,
                    child: Image.asset(
                      slide.image,
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // TITLE
                  Text(
                    slide.title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: colors.primaryText,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),

                  const SizedBox(height: 9),

                  // DESCRIPTION
                  Text(
                    slide.description,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: colors.secondaryText,
                      fontSize: 11,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 17),

                  // PROGRESS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      slideCount,
                      (index) {
                        final active = index == _currentPage;

                        return AnimatedContainer(
                          duration: const Duration(
                            milliseconds: 250,
                          ),
                          width: active ? 22 : 6,
                          height: 6,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 3,
                          ),
                          decoration: BoxDecoration(
                            color: active
                                ? neonBlue
                                : colors.mutedText,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 17),

                  // BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _finishing
                          ? null
                          : () => _next(slideCount),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: neonBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        _currentPage == slideCount - 1
                            ? l10n.onboardingGetStarted
                            : l10n.onboardingNext,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: .8,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BackgroundApp extends StatelessWidget {
  final int page;

  const _BackgroundApp({
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: MainScreen(
        key: ValueKey('onboarding-background-$page'),
        initialPage: page,
      ),
    );
  }
}
