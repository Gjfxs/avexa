import 'package:flutter/material.dart';

import '../theme.dart';
import 'settings_screen.dart';
import 'subscription_screen.dart';
import '../services/subscription_service.dart';
import 'help_center_screen.dart';
import 'report_bug_screen.dart';
import 'contact_support_screen.dart';
import 'about_analyx_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';
import '../widgets/app_page_header.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).extension<AvexaColors>()!;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            18,
            20,
            110,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppPageHeader(
                title: 'More',
              ),

              const SizedBox(height: 24),

              FutureBuilder<bool>(
                future: SubscriptionService.isPro(),
                builder: (context, snapshot) {
                  final isPro = snapshot.data == true;

                  return AnimatedSubscriptionBadge(
                    isPro: isPro,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const SubscriptionScreen(),
                        ),
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 32),

              _sectionTitle(
                "PREFERENCES",
                colors,
              ),

              const SizedBox(height: 12),

              _menuGroup(
                colors: colors,
                children: [
                  _menuTile(
                    icon: Icons.settings_outlined,
                    title: "App Settings",
                    colors: colors,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const SettingsScreen(),
                        ),
                      );
                    },
                  ),

                  _menuTile(
                    icon: Icons.tune_rounded,
                    title: "Trading Preferences",
                    colors: colors,
                  ),
                ],
              ),

              const SizedBox(height: 28),

              _sectionTitle(
                "SUPPORT",
                colors,
              ),

              const SizedBox(height: 12),

              _menuGroup(
                colors: colors,
                children: [
                  _menuTile(
                    icon: Icons.help_outline_rounded,
                    title: "Help Center",
                    colors: colors,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const HelpCenterScreen(),
                        ),
                      );
                    },
                  ),

                  _menuTile(
                    icon: Icons.bug_report_outlined,
                    title: "Report a Bug",
                    colors: colors,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const ReportBugScreen(),
                        ),
                      );
                    },
                  ),

                  _menuTile(
                    icon: Icons.mail_outline_rounded,
                    title: "Contact Support",
                    colors: colors,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const ContactSupportScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 28),

              _sectionTitle(
                "ABOUT",
                colors,
              ),

              const SizedBox(height: 12),

              _menuGroup(
                colors: colors,
                children: [
                  _menuTile(
                    icon: Icons.info_outline_rounded,
                    title: "About Avexa",
                    colors: colors,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const AboutAnalyXScreen(),
                        ),
                      );
                    },
                  ),

                  _menuTile(
                    icon: Icons.privacy_tip_outlined,
                    title: "Privacy Policy",
                    colors: colors,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const PrivacyPolicyScreen(),
                        ),
                      );
                    },
                  ),

                  _menuTile(
                    icon: Icons.description_outlined,
                    title: "Terms of Service",
                    colors: colors,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const TermsOfServiceScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),
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
      style: TextStyle(
        color: colors.secondaryText,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _menuGroup({
    required List<Widget> children,
    required AvexaColors colors,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.border,
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String title,
    required AvexaColors colors,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 58,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: colors.border.withOpacity(.65),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: neonBlue.withOpacity(.09),
                  borderRadius:
                      BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.settings_outlined,
                  color: neonBlue,
                  size: 20,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: colors.primaryText,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              Icon(
                Icons.arrow_forward_ios_rounded,
                color: colors.mutedText,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// ANIMATED SUBSCRIPTION BADGE
// ============================================================================

class AnimatedSubscriptionBadge extends StatefulWidget {
  final bool isPro;
  final VoidCallback onTap;

  const AnimatedSubscriptionBadge({
    super.key,
    required this.isPro,
    required this.onTap,
  });

  @override
  State<AnimatedSubscriptionBadge> createState() =>
      _AnimatedSubscriptionBadgeState();
}

class _AnimatedSubscriptionBadgeState
    extends State<AnimatedSubscriptionBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _vertical;
  late final Animation<double> _rotation;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _vertical = Tween<double>(
      begin: -3.0,
      end: 3.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _rotation = Tween<double>(
      begin: -0.006,
      end: 0.006,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _scale = Tween<double>(
      begin: 0.995,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = widget.isPro
        ? 'assets/images/analyx_pro_banner.png'
        : 'assets/images/analyx_free_banner.png';

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            0,
            -12 + _vertical.value,
          ),
          child: Transform.rotate(
            angle: _rotation.value,
            child: Transform.scale(
              scale: _scale.value,
              child: GestureDetector(
                onTap: widget.onTap,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color:
                            neonBlue.withOpacity(0.10),
                        blurRadius: 16,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(24),
                    child: Image.asset(
                      imagePath,
                      width: double.infinity,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}