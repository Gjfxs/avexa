import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/theme_service.dart';
import '../services/app_icon_service.dart';
import '../theme.dart';
import '../l10n/app_localizations.dart';

class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key});

  @override
  State<AppearanceScreen> createState() =>
      _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  ThemeMode selectedTheme = ThemeMode.system;

  bool _lightIconSelected = false;
  bool _iconLoading = true;

  @override
  void initState() {
    super.initState();

    selectedTheme = ThemeService.instance.themeMode;

    _loadIconPreference();
  }

  Future<void> _loadIconPreference() async {
    final isLight =
        await AppIconService.instance.isLightIcon();

    if (!mounted) return;

    setState(() {
      _lightIconSelected = isLight;
      _iconLoading = false;
    });
  }

  Future<void> _selectTheme(ThemeMode mode) async {
    setState(() {
      selectedTheme = mode;
    });

    await ThemeService.instance.setThemeMode(mode);
  }

  Future<void> _toggleAppIcon(bool value) async {
    if (_iconLoading) return;

    setState(() {
      _iconLoading = true;
    });

    final success =
        await AppIconService.instance.setLightIcon(value);

    if (!mounted) return;

    if (success) {
      setState(() {
        _lightIconSelected = value;
      });
    }

    setState(() {
      _iconLoading = false;
    });
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
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: colors.primaryText,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.appearance,
          style: GoogleFonts.poppins(
            color: colors.primaryText,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            24,
            12,
            24,
            40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ============================================================
              // THEME
              // ============================================================

              Text(
                l10n.themeSection,
                style: GoogleFonts.poppins(
                  color: colors.secondaryText,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.4,
                ),
              ),

              const SizedBox(height: 18),

              _themeOption(
                colors: colors,
                icon: Icons.dark_mode_outlined,
                title: l10n.darkMode,
                subtitle: l10n.darkModeSubtitle,
                mode: ThemeMode.dark,
              ),

              const SizedBox(height: 14),

              _themeOption(
                colors: colors,
                icon: Icons.light_mode_outlined,
                title: l10n.lightMode,
                subtitle: l10n.lightModeSubtitle,
                mode: ThemeMode.light,
              ),

              const SizedBox(height: 14),

              _themeOption(
                colors: colors,
                icon: Icons.settings_brightness_outlined,
                title: l10n.systemDefault,
                subtitle: l10n.systemDefaultSubtitle,
                mode: ThemeMode.system,
              ),

              const SizedBox(height: 34),

              // ============================================================
              // APP ICON
              // ============================================================

              Text(
                l10n.appIconSection,
                style: GoogleFonts.poppins(
                  color: colors.secondaryText,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.4,
                ),
              ),

              const SizedBox(height: 18),

              _appIconOption(colors),
            ],
          ),
        ),
      ),
    );
  }

  // ========================================================================
  // THEME OPTION
  // ========================================================================

  Widget _themeOption({
    required AvexaColors colors,
    required IconData icon,
    required String title,
    required String subtitle,
    required ThemeMode mode,
  }) {
    final selected = selectedTheme == mode;

    return GestureDetector(
      onTap: () => _selectTheme(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        decoration: BoxDecoration(
          color: selected
              ? neonBlue.withOpacity(.10)
              : colors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? neonBlue.withOpacity(.45)
                : colors.border,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: neonBlue.withOpacity(.08),
                    blurRadius: 18,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: selected
                    ? neonBlue.withOpacity(.12)
                    : colors.elevatedCard,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? neonBlue.withOpacity(.20)
                      : colors.border,
                ),
              ),
              child: Icon(
                icon,
                color: selected
                    ? neonBlue
                    : colors.secondaryText,
                size: 25,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: colors.primaryText,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      color: colors.secondaryText,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),

            if (selected)
              const Icon(
                Icons.check_circle_rounded,
                color: neonBlue,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  // ========================================================================
  // APP ICON OPTION
  // ========================================================================

  Widget _appIconOption(AvexaColors colors) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: neonBlue.withOpacity(.10),
              shape: BoxShape.circle,
              border: Border.all(
                color: neonBlue.withOpacity(.16),
              ),
            ),
            child: Icon(
              _lightIconSelected
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
              color: neonBlue,
              size: 25,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.lightAppIcon,
                  style: GoogleFonts.poppins(
                    color: colors.primaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  _lightIconSelected
                      ? l10n.useLightAvexaIcon
                      : l10n.useDarkAvexaIcon,
                  style: GoogleFonts.poppins(
                    color: colors.secondaryText,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // ================================================================
          // iOS STYLE SWITCH
          // ================================================================

          Switch.adaptive(
            value: _lightIconSelected,
            onChanged: _iconLoading
                ? null
                : _toggleAppIcon,
            activeColor: neonBlue,
          ),
        ],
      ),
    );
  }
}