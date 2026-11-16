
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_localizations.dart';
import '../services/locale_controller.dart';
import '../theme.dart';
import '../services/theme_service.dart';
import 'notifications_screen.dart';
import 'appearance_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String get selectedLanguage => LocaleController.instance.language;

  static const Map<String, Map<String, String>> _languageOptions = {
    'Polski': {
      'name': 'Polish',
      'flag': '🇵🇱',
    },
    'English': {
      'name': 'English',
      'flag': '🇬🇧',
    },
    'Deutsch': {
      'name': 'German',
      'flag': '🇩🇪',
    },
    '日本語': {
      'name': 'Japanese',
      'flag': '🇯🇵',
    },
    'Русский': {
      'name': 'Russian',
      'flag': '🇷🇺',
    },
    'العربية': {
      'name': 'Arabic',
      'flag': '🇸🇦',
    },
    '中文': {
      'name': 'Chinese',
      'flag': '🇨🇳',
    },
    'Español': {
      'name': 'Spanish',
      'flag': '🇪🇸',
    },
    'Português': {
      'name': 'Portuguese',
      'flag': '🇵🇹',
    },
  };

  String _languageEnglishName(String language) {
    return _languageOptions[language]?['name'] ?? language;
  }

  String _languageFlag(String language) {
    return _languageOptions[language]?['flag'] ?? '🌐';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AvexaColors>()!;
    final l10n = AppLocalizations.of(context)!;
    final currentTheme = ThemeService.instance.themeMode;

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
          l10n.settings,
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
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle(colors, l10n.general),

              const SizedBox(height: 18),

              _menuTile(
                colors: colors,
                icon: Icons.notifications_outlined,
                title: l10n.notifications,
                subtitle: l10n.notificationsSubtitle,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationsScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 14),

              _menuTile(
                colors: colors,
                icon: Icons.dark_mode_outlined,
                title: l10n.appearance,
                subtitle: _themeName(l10n, currentTheme),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AppearanceScreen(),
                    ),
                  ).then((_) {
                    if (mounted) {
                      setState(() {});
                    }
                  });
                },
              ),

              const SizedBox(height: 42),

              _sectionTitle(colors, l10n.languageSection),

              const SizedBox(height: 18),

              _menuTile(
                colors: colors,
                icon: Icons.language_rounded,
                title: l10n.language,
                subtitle: _languageEnglishName(selectedLanguage),
                onTap: _showLanguagePicker,
              ),

              const SizedBox(height: 42),

              Center(
                child: Text(
                  'Avexa v1.0.0',
                  style: GoogleFonts.poppins(
                    color: colors.mutedText,
                    fontSize: 13,
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

  String _themeName(AppLocalizations l10n, ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return l10n.lightMode;
      case ThemeMode.dark:
        return l10n.darkMode;
      case ThemeMode.system:
        return l10n.systemDefault;
    }
  }

  Widget _sectionTitle(AvexaColors colors, String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        color: colors.secondaryText,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.4,
      ),
    );
  }

  Widget _menuTile({
    required AvexaColors colors,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 20,
          ),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colors.border),
            boxShadow: [
              BoxShadow(
                color: neonBlue.withOpacity(.045),
                blurRadius: 20,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: neonBlue.withOpacity(.10),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: neonBlue.withOpacity(.12),
                  ),
                ),
                child: Icon(
                  icon,
                  color: neonBlue,
                  size: 28,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: colors.primaryText,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 5),

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

              Icon(
                Icons.chevron_right_rounded,
                color: colors.mutedText,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguagePicker() {
    final colors = Theme.of(context).extension<AvexaColors>()!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        final screenHeight = MediaQuery.of(sheetContext).size.height;

        return Container(
          height: screenHeight * 0.85,
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 12),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Choose language',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 24),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 8),
                  physics: const BouncingScrollPhysics(),
                  itemCount: LocaleController.supportedLanguages.length,
                  itemBuilder: (context, index) {
                    final language = LocaleController
                        .supportedLanguages.keys
                        .elementAt(index);

                    return _languageOption(
                      colors,
                      language,
                      sheetContext,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _languageOption(
    AvexaColors colors,
    String language,
    BuildContext sheetContext,
  ) {
    final selected = LocaleController.instance.language == language;

    return GestureDetector(
      onTap: () async {
        await LocaleController.instance.changeLanguage(language);

        if (!mounted) return;

        Navigator.pop(sheetContext);
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
        decoration: BoxDecoration(
          color: selected
              ? neonBlue.withOpacity(.10)
              : colors.elevatedCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? neonBlue.withOpacity(.4)
                : colors.border,
          ),
        ),
        child: Row(
          children: [
            Text(
              _languageFlag(language),
              style: const TextStyle(fontSize: 24),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Text(
                _languageEnglishName(language),
                style: GoogleFonts.poppins(
                  color: colors.primaryText,
                  fontSize: 15,
                  fontWeight: selected
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
              ),
            ),

            if (selected)
              const Icon(
                Icons.check_circle,
                color: neonBlue,
                size: 21,
              ),
          ],
        ),
      ),
    );
  }
}
