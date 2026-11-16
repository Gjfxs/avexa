import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_localizations.dart';
import '../services/locale_controller.dart';
import '../theme.dart';
import '../services/first_launch_service.dart';

class LanguageSelectionScreen extends StatefulWidget {
  final VoidCallback onContinue;

  const LanguageSelectionScreen({
    super.key,
    required this.onContinue,
  });

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState
    extends State<LanguageSelectionScreen> {
  String _selectedLanguage = 'English';
  bool _loading = false;

  static const List<_LanguageOption> _languages = [
    _LanguageOption('English', 'English', '🇬🇧'),
    _LanguageOption('Polski', 'Polski', '🇵🇱'),
    _LanguageOption('Deutsch', 'Deutsch', '🇩🇪'),
    _LanguageOption('Español', 'Español', '🇪🇸'),
    _LanguageOption('Português', 'Português', '🇵🇹'),
    _LanguageOption('Русский', 'Русский', '🇷🇺'),
    _LanguageOption('日本語', '日本語', '🇯🇵'),
    _LanguageOption('中文', '简体中文', '🇨🇳'),
    _LanguageOption('العربية', 'العربية', '🇸🇦'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedLanguage = LocaleController.instance.language;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AvexaColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              Center(
                child: Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    color: neonBlue.withOpacity(.10),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: neonBlue.withOpacity(.25),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: neonBlue.withOpacity(.12),
                        blurRadius: 28,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.language_rounded,
                    color: neonBlue,
                    size: 34,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Center(
                child: Text(
                  'AVEXA',
                  style: GoogleFonts.poppins(
                    color: colors.primaryText,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 4,
                  ),
                ),
              ),

              const SizedBox(height: 36),

              Text(
                'Choose your language',
                style: GoogleFonts.poppins(
                  color: colors.primaryText,
                  fontSize: 29,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Select the language you want to use in Avexa. '
                'You can change it later in Settings.',
                style: GoogleFonts.poppins(
                  color: colors.secondaryText,
                  fontSize: 13,
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 26),

              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _languages.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final language = _languages[index];
                    final selected =
                        _selectedLanguage == language.key;

                    return _LanguageTile(
                      language: language,
                      selected: selected,
                      colors: colors,
                      onTap: () {
                        setState(() {
                          _selectedLanguage = language.key;
                        });
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _loading
                      ? null
                      : () async {
                          setState(() {
                            _loading = true;
                          });

                          try {
                            await LocaleController.instance
                                .changeLanguage(_selectedLanguage);

                            await FirstLaunchService.instance.markLanguageSelected();

                            if (!mounted) return;

                            widget.onContinue();
                          } catch (error) {
                            if (!mounted) return;

                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Could not save language selection.',
                                    style: GoogleFonts.poppins(),
                                  ),
                                ),
                              );

                            setState(() {
                              _loading = false;
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: neonBlue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        neonBlue.withOpacity(.45),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Continue',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 20,
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageOption {
  final String key;
  final String name;
  final String flag;

  const _LanguageOption(
    this.key,
    this.name,
    this.flag,
  );
}

class _LanguageTile extends StatelessWidget {
  final _LanguageOption language;
  final bool selected;
  final AvexaColors colors;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.language,
    required this.selected,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 13,
          ),
          decoration: BoxDecoration(
            color: selected
                ? neonBlue.withOpacity(.09)
                : colors.card,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: selected ? neonBlue : colors.border,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              Text(
                language.flag,
                style: const TextStyle(fontSize: 27),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  language.name,
                  style: GoogleFonts.poppins(
                    color: colors.primaryText,
                    fontSize: 14,
                    fontWeight: selected
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected
                      ? neonBlue
                      : Colors.transparent,
                  border: Border.all(
                    color: selected
                        ? neonBlue
                        : colors.mutedText,
                    width: 1.4,
                  ),
                ),
                child: selected
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 15,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}