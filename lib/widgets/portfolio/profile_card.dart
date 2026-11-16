import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../theme.dart';

class ProfileCard extends StatefulWidget {
  const ProfileCard({super.key});

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  final supabase = Supabase.instance.client;

  String? username;
  String? avatarUrl;
  String plan = 'free';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        if (!mounted) return;

        setState(() {
          loading = false;
        });

        return;
      }

      final profile = await supabase
          .from('profiles')
          .select('username, avatar_url, plan')
          .eq('id', user.id)
          .maybeSingle();

      if (!mounted) return;

      setState(() {
        username =
            profile?['username']?.toString() ??
            user.userMetadata?['preferred_username']?.toString() ??
            user.userMetadata?['user_name']?.toString() ??
            'User';

        avatarUrl = profile?['avatar_url']?.toString();

        plan =
            profile?['plan']?.toString().toLowerCase() ??
            'free';

        loading = false;
      });
    } catch (e) {
      debugPrint('PROFILE CARD ERROR: $e');

      if (!mounted) return;

      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPro = plan == 'pro';

    return _buildCard(
      context: context,
      username: loading
          ? 'Loading...'
          : username ?? 'User',
      avatarUrl: loading ? null : avatarUrl,
      isPro: isPro,
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required String username,
    required String? avatarUrl,
    required bool isPro,
  }) {
    final colors =
        Theme.of(context).extension<AvexaColors>()!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // Proporcje grafiki 1536 × 576
        final height = width * (576 / 1536);

        // Rozmiar avatara dopasowany do otworu
        final avatarSize = height * 0.58;

        return SizedBox(
          width: width,
          height: height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // =========================================================
              // AVATAR — POD PLAKIETKĄ
              // =========================================================

              Positioned(
                left: width * 0.045,
                top: height * 0.22,
                child: Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: neonBlue.withOpacity(.35),
                        blurRadius: 14,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _buildAvatar(
                    avatarUrl,
                    colors,
                  ),
                ),
              ),

              // =========================================================
              // PLAKIETKA — NAD AVATAREM
              // =========================================================

              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Image.asset(
                    'assets/images/portfolio_profile_banner.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                ),
              ),

              // =========================================================
              // INFORMACJE UŻYTKOWNIKA
              // =========================================================

              Positioned(
                left: width * 0.28,
                right: width * 0.08,
                top: height * 0.19,
                bottom: height * 0.14,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // USERNAME
                    Text(
                      username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: width * 0.055,
                        fontWeight: FontWeight.w700,
                        height: 1.0,
                      ),
                    ),

                    const SizedBox(height: 5),

                    // PLAN + ACTIVE
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isPro
                                ? neonBlue.withOpacity(.16)
                                : Colors.white.withOpacity(.08),
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(
                              color: isPro
                                  ? neonBlue.withOpacity(.45)
                                  : Colors.white24,
                            ),
                          ),
                          child: Text(
                            isPro ? 'PRO Plan' : 'FREE Plan',
                            style: GoogleFonts.poppins(
                              color: isPro
                                  ? neonBlue
                                  : colors.secondaryText,
                              fontSize: width * 0.028,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(width: 6),

                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: neonGreen,
                            shape: BoxShape.circle,
                          ),
                        ),

                        const SizedBox(width: 4),

                        Text(
                          'Active',
                          style: GoogleFonts.poppins(
                            color: colors.secondaryText,
                            fontSize: width * 0.026,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // MEMBER SINCE
                    Text(
                      'Member since 2026',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: colors.secondaryText,
                        fontSize: width * 0.026,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // =====================================================================
  // AVATAR
  // =====================================================================

  Widget _buildAvatar(
    String? avatarUrl,
    AvexaColors colors,
  ) {
    if (avatarUrl == null || avatarUrl.isEmpty) {
      return Container(
        color: colors.card,
        alignment: Alignment.center,
        child: Icon(
          Icons.person,
          color: colors.secondaryText,
          size: 32,
        ),
      );
    }

    if (avatarUrl.startsWith('http')) {
      return Image.network(
        avatarUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return _avatarFallback(colors);
        },
      );
    }

    return Image.asset(
      avatarUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return _avatarFallback(colors);
      },
    );
  }

  Widget _avatarFallback(AvexaColors colors) {
    return Container(
      color: colors.card,
      alignment: Alignment.center,
      child: Icon(
        Icons.person,
        color: colors.secondaryText,
        size: 32,
      ),
    );
  }
}