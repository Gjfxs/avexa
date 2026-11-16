import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() =>
      _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  bool notifications = true;
  bool priceAlerts = true;
  bool signalAlerts = true;
  bool vibrations = true;

  String language = 'English';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      notifications =
          prefs.getBool('notifications') ?? true;

      priceAlerts =
          prefs.getBool('price_alerts') ?? true;

      signalAlerts =
          prefs.getBool('signal_alerts') ?? true;

      vibrations =
          prefs.getBool('vibrations') ?? true;

      language =
          prefs.getString('language') ?? 'English';
    });
  }

  Future<void> _setBool(
    String key,
    bool value,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(key, value);
  }

  Future<void> _setLanguage(
    String value,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'language',
      value,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).extension<AvexaColors>()!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: colors.primaryText,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Preferences',
          style: GoogleFonts.poppins(
            color: colors.primaryText,
            fontWeight: FontWeight.w600,
            fontSize: 19,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              'App preferences',
              style: GoogleFonts.poppins(
                color: colors.primaryText,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Customize how Avexa behaves and notifies you.',
              style: GoogleFonts.poppins(
                color: colors.secondaryText,
                fontSize: 14,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 30),

            _sectionTitle(
              'NOTIFICATIONS',
              colors,
            ),

            const SizedBox(height: 12),

            _switchTile(
              colors: colors,
              icon: Icons.notifications_outlined,
              title: 'Push notifications',
              subtitle:
                  'Receive notifications from Avexa.',
              value: notifications,
              onChanged: (value) {
                setState(() {
                  notifications = value;
                });

                _setBool(
                  'notifications',
                  value,
                );
              },
            ),

            _switchTile(
              colors: colors,
              icon: Icons.show_chart_rounded,
              title: 'Signal alerts',
              subtitle:
                  'Get notified when a new signal appears.',
              value: signalAlerts,
              onChanged: (value) {
                setState(() {
                  signalAlerts = value;
                });

                _setBool(
                  'signal_alerts',
                  value,
                );
              },
            ),

            _switchTile(
              colors: colors,
              icon: Icons.price_change_outlined,
              title: 'Price alerts',
              subtitle:
                  'Receive important price movement alerts.',
              value: priceAlerts,
              onChanged: (value) {
                setState(() {
                  priceAlerts = value;
                });

                _setBool(
                  'price_alerts',
                  value,
                );
              },
            ),

            const SizedBox(height: 30),

            _sectionTitle(
              'APP',
              colors,
            ),

            const SizedBox(height: 12),

            _switchTile(
              colors: colors,
              icon: Icons.vibration_outlined,
              title: 'Vibration',
              subtitle:
                  'Use vibration for important alerts.',
              value: vibrations,
              onChanged: (value) {
                setState(() {
                  vibrations = value;
                });

                _setBool(
                  'vibrations',
                  value,
                );
              },
            ),

            const SizedBox(height: 30),

            _sectionTitle(
              'LANGUAGE',
              colors,
            ),

            const SizedBox(height: 12),

            _languageTile(colors),

            const SizedBox(height: 30),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: neonBlue.withOpacity(.07),
                borderRadius:
                    BorderRadius.circular(20),
                border: Border.all(
                  color: neonBlue.withOpacity(.18),
                ),
              ),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.tune_rounded,
                    color: neonBlue,
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Text(
                      'More personalization options will be added as Avexa grows.',
                      style: GoogleFonts.poppins(
                        color: colors.secondaryText,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
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
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
      ),
    );
  }

  Widget _switchTile({
    required AvexaColors colors,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin:
          const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius:
            BorderRadius.circular(20),
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
              color: neonGreen.withOpacity(.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: neonGreen,
              size: 23,
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
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    color: colors.secondaryText,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: neonGreen,
            inactiveThumbColor:
                colors.secondaryText,
            inactiveTrackColor:
                colors.border,
          ),
        ],
      ),
    );
  }

  Widget _languageTile(
    AvexaColors colors,
  ) {
    return GestureDetector(
      onTap: _showLanguagePicker,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius:
              BorderRadius.circular(20),
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
                color: neonBlue.withOpacity(.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.language,
                color: neonBlue,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Language',
                    style: GoogleFonts.poppins(
                      color: colors.primaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    language,
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
    );
  }

  void _showLanguagePicker() {
    final colors =
        Theme.of(context).extension<AvexaColors>()!;

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.card,
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'Choose language',
                  style:
                      GoogleFonts.poppins(
                    color: colors.primaryText,
                    fontSize: 20,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 20),

                _languageOption(
                  'English',
                  colors,
                ),

                _languageOption(
                  'Polski',
                  colors,
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _languageOption(
    String value,
    AvexaColors colors,
  ) {
    final selected = language == value;

    return ListTile(
      onTap: () async {
        setState(() {
          language = value;
        });

        await _setLanguage(value);

        if (!mounted) return;

        Navigator.pop(context);
      },
      title: Text(
        value,
        style: GoogleFonts.poppins(
          color: colors.primaryText,
          fontSize: 15,
        ),
      ),
      trailing: selected
          ? const Icon(
              Icons.check_circle,
              color: neonGreen,
            )
          : null,
    );
  }
}