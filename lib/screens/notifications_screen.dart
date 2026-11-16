import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../l10n/app_localizations.dart';

import '../theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends State<NotificationsScreen> {
  final supabase = Supabase.instance.client;

  bool pushNotifications = true;
  bool freeSignals = true;
  bool proSignals = true;
  bool tpHits = true;
  bool hapticFeedback = true;

  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  // ===============================================================
  // LOAD SETTINGS
  // ===============================================================

  Future<void> _loadNotificationSettings() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      return;
    }

    try {
      final response = await supabase
          .from('notification_settings')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (response == null) {
        await supabase
            .from('notification_settings')
            .insert({
          'user_id': user.id,
          'push_enabled': true,
          'free_signals': true,
          'pro_signals': true,
          'tp_hits': true,
          'haptic_feedback': true,
        });

        if (!mounted) return;

        setState(() {
          pushNotifications = true;
          freeSignals = true;
          proSignals = true;
          tpHits = true;
          hapticFeedback = true;
          isLoading = false;
        });

        return;
      }

      if (!mounted) return;

      setState(() {
        pushNotifications =
            response['push_enabled'] ?? true;

        freeSignals =
            response['free_signals'] ?? true;

        proSignals =
            response['pro_signals'] ?? true;

        tpHits =
            response['tp_hits'] ?? true;

        hapticFeedback =
            response['haptic_feedback'] ?? true;

        isLoading = false;
      });
    } catch (e) {
      debugPrint(
        'NOTIFICATION SETTINGS LOAD ERROR: $e',
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  // ===============================================================
  // SAVE SETTINGS
  // ===============================================================

  Future<void> _saveNotificationSettings() async {
    final user = supabase.auth.currentUser;

    if (user == null) return;

    try {
      setState(() {
        isSaving = true;
      });

      await supabase
          .from('notification_settings')
          .upsert(
        {
          'user_id': user.id,
          'push_enabled': pushNotifications,
          'free_signals': freeSignals,
          'pro_signals': proSignals,
          'tp_hits': tpHits,
          'haptic_feedback': hapticFeedback,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        },
        onConflict: 'user_id',
      );
    } catch (e) {
      debugPrint(
        'NOTIFICATION SETTINGS SAVE ERROR: $e',
      );
    } finally {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });
    }
  }

  // ===============================================================
  // CHANGE SETTING
  // ===============================================================

  Future<void> _changeSetting({
    required String setting,
    required bool value,
  }) async {
    if (setting == 'push') {
      setState(() {
        pushNotifications = value;
      });
    }

    if (setting == 'free') {
      setState(() {
        freeSignals = value;
      });
    }

    if (setting == 'pro') {
      setState(() {
        proSignals = value;
      });
    }

    if (setting == 'tp') {
      setState(() {
        tpHits = value;
      });
    }

    if (setting == 'haptic') {
      setState(() {
        hapticFeedback = value;
      });
    }

    await _saveNotificationSettings();
  }

  // ===============================================================
  // BUILD
  // ===============================================================

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
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          l10n.notifications,
          style: GoogleFonts.poppins(
            color: colors.primaryText,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: neonBlue,
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  24,
                  12,
                  24,
                  40,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    // =================================================
                    // ALERTS
                    // =================================================

                    _sectionTitle(
                      l10n.alerts,
                      colors,
                    ),

                    const SizedBox(height: 18),

                    _switchTile(
                      colors: colors,
                      icon: Icons.notifications_outlined,
                      title: l10n.pushNotifications,
                      subtitle: l10n.pushNotificationsSubtitle,
                      value: pushNotifications,
                      onChanged: (value) {
                        _changeSetting(
                          setting: 'push',
                          value: value,
                        );
                      },
                    ),

                    const SizedBox(height: 18),

                    _switchTile(
                      colors: colors,
                      icon: Icons.bolt_rounded,
                      title: l10n.freeSignals,
                      subtitle: l10n.freeSignalsSubtitle,
                      value: freeSignals,
                      enabled: pushNotifications,
                      onChanged: (value) {
                        _changeSetting(
                          setting: 'free',
                          value: value,
                        );
                      },
                    ),

                    const SizedBox(height: 18),

                    _switchTile(
                      colors: colors,
                      icon: Icons.auto_awesome_rounded,
                      title: l10n.proSignals,
                      subtitle: l10n.proSignalsSubtitle,
                      value: proSignals,
                      enabled: pushNotifications,
                      onChanged: (value) {
                        _changeSetting(
                          setting: 'pro',
                          value: value,
                        );
                      },
                    ),

                    const SizedBox(height: 18),

                    _switchTile(
                      colors: colors,
                      icon: Icons.track_changes_rounded,
                      title: l10n.takeProfitHits,
                      subtitle: l10n.takeProfitHitsSubtitle,
                      value: tpHits,
                      enabled: pushNotifications,
                      onChanged: (value) {
                        _changeSetting(
                          setting: 'tp',
                          value: value,
                        );
                      },
                    ),

                    const SizedBox(height: 42),

                    // =================================================
                    // EXPERIENCE
                    // =================================================

                    _sectionTitle(
                      l10n.experience,
                      colors,
                    ),

                    const SizedBox(height: 18),

                    _switchTile(
                      colors: colors,
                      icon: Icons.vibration_rounded,
                      title: l10n.hapticFeedback,
                      subtitle: l10n.hapticFeedbackSubtitle,
                      value: hapticFeedback,
                      onChanged: (value) {
                        _changeSetting(
                          setting: 'haptic',
                          value: value,
                        );
                      },
                    ),

                    const SizedBox(height: 40),

                    Center(
                      child: Text(
                        isSaving
                            ? l10n.savingPreferences
                            : l10n.notificationPreferences,
                        style: GoogleFonts.poppins(
                          color: colors.mutedText,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // ===============================================================
  // SECTION TITLE
  // ===============================================================

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
        letterSpacing: 1.4,
      ),
    );
  }

  // ===============================================================
  // SWITCH TILE
  // ===============================================================

  Widget _switchTile({
    required AvexaColors colors,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
  }) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: enabled ? 1.0 : .45,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 20,
        ),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(24),
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

                  const SizedBox(height: 5),

                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      color: colors.secondaryText,
                      fontSize: 12.5,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Switch(
              value: value,
              onChanged: enabled
                  ? onChanged
                  : null,
              activeThumbColor: Colors.white,
              activeTrackColor: neonBlue,
              inactiveThumbColor:
                  colors.secondaryText,
              inactiveTrackColor:
                  colors.border,
            ),
          ],
        ),
      ),
    );
  }
}