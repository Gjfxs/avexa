import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';
import 'home_screen.dart';
import 'charts_screen.dart';
import 'portfolio_screen.dart';
import 'ai_chart_analysis_screen.dart';
import '../widgets/floating_ai_bubble.dart';
import 'signals_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialPage;

  /// When true, the screen is being displayed
  /// underneath the onboarding overlay.
  final bool onboardingMode;

  const MainScreen({
    super.key,
    this.initialPage = 2,
    this.onboardingMode = false,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final PageController _pageController;

  late int selectedIndex;

  // ============================================================
  // MAIN NAVIGATION
  //
  // 0 = Charts
  // 1 = Signals
  // 2 = Home
  // 3 = AI Chart
  // 4 = More / Portfolio
  // ============================================================

  final screens = [
    const ChartsScreen(),
    const SignalsScreen(),
    const HomeScreen(),
    const AiChartAnalysisScreen(),
    const PortfolioScreen(),
  ];

  @override
  void initState() {
    super.initState();

    selectedIndex = widget.initialPage;

    _pageController = PageController(
      initialPage: widget.initialPage,
    );
  }

  void goToPage(int index) {
    if (!_pageController.hasClients) return;

    _pageController.jumpToPage(index);

    if (!mounted) return;

    setState(() {
      selectedIndex = index;
    });
  }

  Widget _navIcon({
    required IconData icon,
    required double size,
    required Color color,
    required bool selected,
  }) {
    return SizedBox(
      width: size + 24,
      height: size + 24,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: selected ? 8 : 6,
              sigmaY: selected ? 8 : 6,
            ),
            child: Icon(
              icon,
              size: size,
              color: neonBlue.withValues(
                alpha: selected ? 0.42 : 0.14,
              ),
            ),
          ),
          Icon(
            icon,
            size: size,
            color: color,
          ),
        ],
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required int index,
    required AvexaColors colors,
  }) {
    final selected = selectedIndex == index;
    final isHome = index == 2;

    final iconSize = selected
        ? 30.0
        : isHome
            ? 27.0
            : 24.0;

    final iconColor = selected
        ? neonBlue
        : isHome
            ? colors.secondaryText
            : colors.mutedText;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          goToPage(index);
        },
        child: SizedBox(
          height: 76,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (selected)
                Positioned(
                  top: 0,
                  left: 13,
                  right: 13,
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: neonBlue,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: neonBlue.withValues(alpha: 0.5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _navIcon(
                    icon: icon,
                    size: iconSize,
                    color: iconColor,
                    selected: selected,
                  ),
                  if (selected) ...[
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: TextStyle(
                        color: neonBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).extension<AvexaColors>()!;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: ColoredBox(
        color: colors.background,
        child: Stack(
          fit: StackFit.expand,
          children: [
            PageView(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (index) {
                if (index != selectedIndex) {
                  setState(() {
                    selectedIndex = index;
                  });
                }
              },
              children: screens.map((screen) {
                return ColoredBox(
                  color: colors.background,
                  child: screen,
                );
              }).toList(),
            ),
            const FloatingAiBubble(),
            Positioned(
              left: 10,
              right: 10,
              bottom: 18,
              child: _buildFloatingNavigation(colors),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingNavigation(
    AvexaColors colors,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 22,
          sigmaY: 22,
        ),
        child: Container(
          height: 82,
          decoration: BoxDecoration(
            color: colors.elevatedCard.withValues(
              alpha: 0.42,
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: colors.border.withValues(
                alpha: 0.65,
              ),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: neonBlue.withValues(
                  alpha: 0.10,
                ),
                blurRadius: 26,
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.18,
                ),
                blurRadius: 18,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              _navItem(
                icon: Icons.candlestick_chart,
                label: 'Charts',
                index: 0,
                colors: colors,
              ),
              _navItem(
                icon: Icons.bolt_rounded,
                label: 'Signals',
                index: 1,
                colors: colors,
              ),
              _navItem(
                icon: Icons.home,
                label: 'Home',
                index: 2,
                colors: colors,
              ),
              _navItem(
                icon: Icons.camera_alt_outlined,
                label: 'AI Chart',
                index: 3,
                colors: colors,
              ),
              _navItem(
                icon: Icons.menu,
                label: 'More',
                index: 4,
                colors: colors,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}