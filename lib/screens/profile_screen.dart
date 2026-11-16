
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:in_app_review/in_app_review.dart';

import '../theme.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../services/avatar_service.dart';
import '../widgets/avatar_picker_sheet.dart';

import 'personal_information_screen.dart';
import 'connected_accounts_screen.dart';
import 'security_screen.dart';
import 'login_screen.dart';
import 'subscription_screen.dart';
import 'settings_screen.dart';
import 'help_center_screen.dart';
import 'report_bug_screen.dart';
import 'contact_support_screen.dart';
import 'about_analyx_screen.dart';
import '../services/subscription_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final supabase = Supabase.instance.client;

  String? avatarUrl;
  String userPlan = 'Free';
  String profileUsername = 'User';

  int? freeSignalCount;
  int? aiAnalysisCount;

  bool isStatsLoading = true;

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();

    userPlan = SubscriptionState.instance.isPro ? 'Pro' : 'Free';

    SubscriptionState.instance.addListener(_onSubscriptionChanged);

    // Pobierz aktualny status z Supabase po otwarciu profilu.
    SubscriptionState.instance.refresh();

    _loadAvatar();
    _loadProfileName();
    _loadLiveStats();
  }

  void _onSubscriptionChanged() {
    if (!mounted) return;

    final subscription = SubscriptionState.instance;

    debugPrint('PROFILE LISTENER TRIGGERED');
    debugPrint('PROFILE CENTRAL IS PRO: ${subscription.isPro}');
    debugPrint('PROFILE CENTRAL IS LOADING: ${subscription.isLoading}');

    setState(() {
      userPlan = subscription.isPro ? 'Pro' : 'Free';
    });

    debugPrint('PROFILE PLAN UPDATED: $userPlan');
  }

  Future<void> _loadAvatar() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response = await supabase
          .from('profiles')
          .select('avatar_url')
          .eq('id', user.id)
          .maybeSingle();

      if (!mounted) return;

      setState(() {
        avatarUrl = response?['avatar_url']?.toString();
      });

    } catch (e) {
      debugPrint('PROFILE AVATAR LOAD ERROR: $e');
    }
  }

  Future<void> _loadProfileName() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final profile = await supabase
          .from('profiles')
          .select('username')
          .eq('id', user.id)
          .maybeSingle();

      if (!mounted) return;

      setState(() {
        profileUsername = profile?['username']?.toString() ??
            user.email?.split('@').first ??
            'User';
      });
    } catch (e) {
      debugPrint('PROFILE NAME LOAD ERROR: $e');
    }
  }

  Future<void> _loadLiveStats() async {
    if (!mounted) return;

    setState(() => isStatsLoading = true);

    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User is not authenticated.');
      }

      final chartResult = await supabase
          .from('ai_chart_analyses')
          .select('id')
          .eq('user_id', user.id)
          .count();

      final freeSignalResult = await supabase
          .from('signals')
          .select('id')
          .eq('market', 'MEME')
          .eq('tier', 'FREE')
          .count();

      // AI Trading Assistant history is not stored per user yet.
      const tradingAssistantCount = 0;

      if (!mounted) return;

      setState(() {
        aiAnalysisCount = chartResult.count + tradingAssistantCount;
        freeSignalCount = freeSignalResult.count;
        isStatsLoading = false;
      });
    } catch (e) {
      debugPrint('PROFILE STATS LOAD ERROR: $e');

      if (!mounted) return;

      setState(() {
        freeSignalCount = null;
        aiAnalysisCount = null;
        isStatsLoading = false;
      });
    }
  }

  Future<void> _openAvatarPicker() async {
    final selectedAvatar = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AvatarPickerSheet(
        isPremium: userPlan.toLowerCase() == 'pro',
      ),
    );

    if (selectedAvatar == null) return;

    try {
      final savedAvatar = await AvatarService.saveAvatar(selectedAvatar);

      if (!mounted) return;

      if (savedAvatar == null) {
        _showMessage(l10n.profileAvatarSaveError);
        return;
      }

      setState(() => avatarUrl = savedAvatar);
      _showMessage(l10n.profileAvatarUpdated);
    } catch (e) {
      debugPrint('AVATAR ERROR: $e');
      if (!mounted) return;
      _showMessage(l10n.profileAvatarUpdateError);
    }
  }

  void _showMessage(String message) {
    final colors = Theme.of(context).extension<AvexaColors>()!;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.poppins(
              color: colors.primaryText,
              fontSize: 13,
            ),
          ),
          backgroundColor: colors.elevatedCard,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: colors.border),
          ),
        ),
      );
  }

  Future<void> _openAppStoreReview() async {
    try {
      await InAppReview.instance.openStoreListing(
        appStoreId: '6813684731',
      );
    } catch (e) {
      debugPrint('RATE US ERROR: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AvexaColors>()!;
    final user = supabase.auth.currentUser;
    final email = user?.email ?? '';

    final createdAt = user?.createdAt != null
        ? DateFormat('yyyy').format(DateTime.parse(user!.createdAt))
        : '2026';

    final isPro = userPlan.toLowerCase() == 'pro';

    return Scaffold(
      extendBody: false,
      backgroundColor: colors.background,
      body: RefreshIndicator(
        color: neonBlue,
        backgroundColor: colors.card,
        onRefresh: () async {
          await Future.wait([
            _loadAvatar(),
            _loadProfileName(),
            _loadLiveStats(),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: colors.primaryText,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              GestureDetector(
                onTap: _openAvatarPicker,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: neonBlue.withOpacity(.22),
                        blurRadius: 40,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: neonBlue.withOpacity(.35),
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 58,
                          backgroundColor: colors.elevatedCard,
                          backgroundImage: avatarUrl != null &&
                                  avatarUrl!.isNotEmpty
                              ? (avatarUrl!.startsWith('http')
                                  ? NetworkImage(avatarUrl!)
                                  : AssetImage(avatarUrl!))
                              : null,
                          child: avatarUrl == null || avatarUrl!.isEmpty
                              ? Icon(
                                  Icons.person,
                                  color: colors.primaryText,
                                  size: 62,
                                )
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: neonBlue,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colors.background,
                              width: 3,
                            ),
                          ),
                          child: const Icon(
                            Icons.photo_camera,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                profileUsername,
                style: GoogleFonts.poppins(
                  color: colors.primaryText,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                email,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: colors.secondaryText,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _statusBadge(
                    icon: Icons.verified,
                    label: l10n.profileActive,
                    color: neonGreen,
                  ),
                  const SizedBox(width: 10),
                  _statusBadge(
                    label: isPro
                        ? l10n.profileProPlan
                        : l10n.profileFreePlan,
                    color: neonBlue,
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Text(
                l10n.profileMemberSince(createdAt),
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: colors.mutedText,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      title: l10n.profileFreeSignals,
                      value: freeSignalCount?.toString() ?? '—',
                      icon: Icons.bolt_rounded,
                      colors: colors,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statCard(
                      title: l10n.profileAiAnalyses,
                      value: aiAnalysisCount?.toString() ?? '—',
                      icon: Icons.auto_awesome_rounded,
                      colors: colors,
                    ),
                  ),
                ],
              ),

              if (isStatsLoading) ...[
                const SizedBox(height: 10),
                const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: neonBlue,
                  ),
                ),
              ],

              const SizedBox(height: 42),

              _sectionTitle(l10n.profileSubscriptionSection, colors),
              const SizedBox(height: 14),
              _accountGroup(
                colors: colors,
                children: [
                  _subscriptionTile(colors),
                ],
              ),

              const SizedBox(height: 40),

              _sectionTitle(l10n.profileAccountSection, colors),
              const SizedBox(height: 14),
              _accountGroup(
                colors: colors,
                children: [
                  _menuTile(
                    icon: Icons.person_outline,
                    title: l10n.profilePersonalInformation,
                    colors: colors,
                    onTap: () async {
                      final updatedUsername = await Navigator.push<String>(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const PersonalInformationScreen(),
                        ),
                      );

                      if (updatedUsername == null || !mounted) return;

                      await Future.wait([
                        _loadProfileName(),
                        _loadAvatar(),
                      ]);
                    },
                  ),
                  _menuDivider(colors),
                  _menuTile(
                    icon: Icons.link,
                    title: l10n.profileConnectedAccounts,
                    colors: colors,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ConnectedAccountsScreen(),
                        ),
                      );
                    },
                  ),
                  _menuDivider(colors),
                  _menuTile(
                    icon: Icons.lock_outline,
                    title: l10n.profileSecurity,
                    colors: colors,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SecurityScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 40),

              _sectionTitle(l10n.profilePreferencesSection, colors),
              const SizedBox(height: 14),
              _accountGroup(
                colors: colors,
                children: [
                  _menuTile(
                    icon: Icons.settings_outlined,
                    title: l10n.profileAppSettings,
                    colors: colors,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                  _menuDivider(colors),
                  _menuTile(
                    icon: Icons.star_outline_rounded,
                    title: l10n.profileRateUs,
                    colors: colors,
                    onTap: _openAppStoreReview,
                  ),
                  _menuDivider(colors),
                  _menuTile(
                    icon: Icons.info_outline_rounded,
                    title: l10n.profileAboutAvexa,
                    colors: colors,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AboutAnalyXScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 40),

              _sectionTitle(l10n.profileSupportSection, colors),
              const SizedBox(height: 14),
              _accountGroup(
                colors: colors,
                children: [
                  _menuTile(
                    icon: Icons.help_outline_rounded,
                    title: l10n.profileHelpCenter,
                    colors: colors,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HelpCenterScreen(),
                        ),
                      );
                    },
                  ),
                  _menuDivider(colors),
                  _menuTile(
                    icon: Icons.bug_report_outlined,
                    title: l10n.profileReportBug,
                    colors: colors,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ReportBugScreen(),
                        ),
                      );
                    },
                  ),
                  _menuDivider(colors),
                  _menuTile(
                    icon: Icons.mail_outline_rounded,
                    title: l10n.profileContactSupport,
                    colors: colors,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ContactSupportScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: neonRed,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: neonRed.withOpacity(.25),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () async {
                    await AuthService.logout(context);

                    if (!context.mounted) return;

                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  child: Text(
                    l10n.profileLogOut,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, AvexaColors colors) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: GoogleFonts.poppins(
          color: colors.secondaryText,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.8,
        ),
      ),
    );
  }

  Widget _statusBadge({
    IconData? icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: GoogleFonts.poppins(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _subscriptionTile(AvexaColors colors) {
    final isPro = userPlan.toLowerCase() == 'pro';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SubscriptionScreen(),
            ),
          );

          if (!mounted) return;

          await SubscriptionState.instance.refresh();
          await _loadAvatar();

        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: neonBlue.withOpacity(.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.workspace_premium_outlined,
                  color: neonBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            isPro
                                ? l10n.profileProPlan
                                : l10n.profileFreePlan,
                            style: GoogleFonts.poppins(
                              color: colors.primaryText,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: isPro ? neonGreen : colors.mutedText,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isPro
                          ? l10n.profileActiveSubscription
                          : l10n.profileCurrentSubscription,
                      style: GoogleFonts.poppins(
                        color: colors.secondaryText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: colors.mutedText,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _accountGroup({
    required List<Widget> children,
    required AvexaColors colors,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: neonBlue.withOpacity(.025),
            blurRadius: 18,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(children: children),
      ),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required AvexaColors colors,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: neonBlue.withOpacity(.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: neonBlue, size: 23),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: colors.primaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: colors.mutedText,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuDivider(AvexaColors colors) {
    return Container(
      height: 1,
      margin: const EdgeInsets.only(left: 82),
      color: colors.border,
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required AvexaColors colors,
  }) {
    return Container(
      height: 150,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: neonBlue.withOpacity(.035),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: neonBlue, size: 25),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: colors.primaryText,
              fontWeight: FontWeight.bold,
              fontSize: 21,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: colors.secondaryText,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
  @override
  void dispose() {
    SubscriptionState.instance.removeListener(_onSubscriptionChanged);
    super.dispose();
  }

}
