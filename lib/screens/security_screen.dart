
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

import '../l10n/app_localizations.dart';
import '../theme.dart';
import '../services/app_lock_service.dart';
import '../services/local_auth_service.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final supabase = Supabase.instance.client;

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool currentPasswordVisible = false;
  bool newPasswordVisible = false;
  bool confirmPasswordVisible = false;

  bool saving = false;
  bool appLockEnabled = false;
  bool loadingLock = true;

  @override
  void initState() {
    super.initState();
    _loadAppLock();
  }

  Future<void> _loadAppLock() async {
    final enabled = await AppLockService.instance.isEnabled();

    if (!mounted) return;

    setState(() {
      appLockEnabled = enabled;
      loadingLock = false;
    });
  }

  Future<String?> _showCreatePinDialog(
    AppLocalizations l10n,
  ) async {
    final controller = TextEditingController();
    final confirmController = TextEditingController();

    String? error;

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: cardElevated,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(color: borderColor),
              ),
              title: Text(
                l10n.securityCreatePin,
                style: GoogleFonts.poppins(
                  color: textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.securityCreatePinDescription,
                    style: GoogleFonts.poppins(
                      color: textSecondary,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 6,
                    style: GoogleFonts.poppins(color: textPrimary),
                    decoration: _dialogInputDecoration(
                      l10n.securityPin,
                      l10n,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: confirmController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 6,
                    style: GoogleFonts.poppins(color: textPrimary),
                    decoration: _dialogInputDecoration(
                      l10n.securityConfirmPin,
                      l10n,
                    ),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      error!,
                      style: GoogleFonts.poppins(
                        color: neonRed,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    l10n.securityCancel.toUpperCase(),
                    style: const TextStyle(color: textSecondary),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    final pin = controller.text.trim();
                    final confirm = confirmController.text.trim();

                    if (pin.length < 4 || pin.length > 6) {
                      setDialogState(() {
                        error = l10n.securityPinLengthError;
                      });
                      return;
                    }

                    if (!RegExp(r'^[0-9]+$').hasMatch(pin)) {
                      setDialogState(() {
                        error = l10n.securityPinDigitsError;
                      });
                      return;
                    }

                    if (pin != confirm) {
                      setDialogState(() {
                        error = l10n.securityPinsMismatch;
                      });
                      return;
                    }

                    Navigator.pop(dialogContext, pin);
                  },
                  child: Text(
                    l10n.securitySave.toUpperCase(),
                    style: const TextStyle(
                      color: neonBlue,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
    confirmController.dispose();

    return result;
  }

  Future<String?> _showPinDialog(
    AppLocalizations l10n,
  ) async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cardElevated,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: borderColor),
          ),
          title: Text(
            l10n.securityEnterPin,
            style: GoogleFonts.poppins(
              color: textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 6,
            autofocus: true,
            style: GoogleFonts.poppins(color: textPrimary),
            decoration: _dialogInputDecoration(
              l10n.securityPin,
              l10n,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                l10n.securityCancel.toUpperCase(),
                style: const TextStyle(color: textSecondary),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(
                dialogContext,
                controller.text.trim(),
              ),
              child: Text(
                l10n.securityUnlock.toUpperCase(),
                style: const TextStyle(
                  color: neonBlue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    controller.dispose();
    return result;
  }

  InputDecoration _dialogInputDecoration(
    String hint,
    AppLocalizations l10n,
  ) {
    return InputDecoration(
      hintText: hint,
      counterText: '',
      hintStyle: GoogleFonts.poppins(color: textMuted),
      filled: true,
      fillColor: cardDark,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: neonBlue),
      ),
    );
  }

  Future<void> _toggleAppLock(bool value) async {
    if (loadingLock) return;

    final l10n = AppLocalizations.of(context)!;

    setState(() {
      loadingLock = true;
    });

    try {
      final authenticated = await LocalAuthService.authenticate();

      if (!authenticated) {
        if (!mounted) return;

        _showMessage(
          value
              ? l10n.securityVerificationCancelled
              : l10n.securityVerificationRequired,
        );

        setState(() {
          loadingLock = false;
        });
        return;
      }

      await AppLockService.instance.setEnabled(value);

      if (!mounted) return;

      setState(() {
        appLockEnabled = value;
        loadingLock = false;
      });

      _showMessage(
        value
            ? l10n.securityAppLockEnabled
            : l10n.securityAppLockDisabled,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingLock = false;
      });

      _showMessage(l10n.securityAppLockChangeError);
      debugPrint('APP LOCK ERROR: $e');
    }
  }

  Future<void> _changePassword() async {
    final l10n = AppLocalizations.of(context)!;

    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      _showMessage(l10n.securityEnterNewPassword);
      return;
    }

    if (newPassword.length < 6) {
      _showMessage(l10n.securityPasswordLengthError);
      return;
    }

    if (newPassword != confirmPassword) {
      _showMessage(l10n.securityPasswordsMismatch);
      return;
    }

    setState(() {
      saving = true;
    });

    try {
      await supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (!mounted) return;

      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();

      _showMessage(l10n.securityPasswordChanged);
    } catch (e) {
      if (!mounted) return;

      _showMessage(l10n.securityPasswordChangeError);
      debugPrint('PASSWORD CHANGE ERROR: $e');
    } finally {
      if (!mounted) return;

      setState(() {
        saving = false;
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(
            color: textPrimary,
            fontSize: 13,
          ),
        ),
        backgroundColor: cardElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: borderColor),
        ),
      ),
    );
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = supabase.auth.currentUser;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.securityTitle,
          style: GoogleFonts.poppins(
            color: textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 19,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.securityAccountTitle,
              style: GoogleFonts.poppins(
                color: textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.securityAccountDescription,
              style: GoogleFonts.poppins(
                color: textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 30),

            _sectionTitle(l10n.securityAccountSection),
            const SizedBox(height: 12),
            _accountCard(user?.email ?? '', l10n),

            const SizedBox(height: 30),

            _sectionTitle(l10n.securityChangePassword),
            const SizedBox(height: 12),

            _passwordField(
              controller: currentPasswordController,
              hint: l10n.securityCurrentPassword,
              visible: currentPasswordVisible,
              onVisibilityChanged: () {
                setState(() {
                  currentPasswordVisible = !currentPasswordVisible;
                });
              },
            ),
            const SizedBox(height: 12),

            _passwordField(
              controller: newPasswordController,
              hint: l10n.securityNewPassword,
              visible: newPasswordVisible,
              onVisibilityChanged: () {
                setState(() {
                  newPasswordVisible = !newPasswordVisible;
                });
              },
            ),
            const SizedBox(height: 12),

            _passwordField(
              controller: confirmPasswordController,
              hint: l10n.securityConfirmNewPassword,
              visible: confirmPasswordVisible,
              onVisibilityChanged: () {
                setState(() {
                  confirmPasswordVisible = !confirmPasswordVisible;
                });
              },
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: saving ? null : _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: neonBlue,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: neonBlue.withOpacity(.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 0,
                ),
                child: saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        l10n.securityChangePassword.toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          letterSpacing: .5,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 35),

            _sectionTitle(l10n.securityAppLockSection),
            const SizedBox(height: 12),
            _appLockCard(l10n),

            const SizedBox(height: 30),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: neonBlue.withOpacity(.06),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: neonBlue.withOpacity(.16),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.shield_outlined,
                    color: neonBlue,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      l10n.securitySafetyNotice,
                      style: GoogleFonts.poppins(
                        color: textSecondary,
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

  Widget _accountCard(
    String email,
    AppLocalizations l10n,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: neonBlue.withOpacity(.10),
              shape: BoxShape.circle,
              border: Border.all(
                color: neonBlue.withOpacity(.16),
              ),
            ),
            child: const Icon(
              Icons.email_outlined,
              color: neonBlue,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.securityAccountEmail,
                  style: GoogleFonts.poppins(
                    color: textMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: GoogleFonts.poppins(
                    color: textPrimary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.verified_user_outlined,
            color: neonBlue,
            size: 21,
          ),
        ],
      ),
    );
  }

  Widget _appLockCard(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: neonBlue.withOpacity(.035),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: neonBlue.withOpacity(.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.phonelink_lock_outlined,
              color: neonBlue,
              size: 23,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.securityAppLockTitle,
                  style: GoogleFonts.poppins(
                    color: textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  appLockEnabled
                      ? l10n.securityAppLockEnabledDescription
                      : l10n.securityAppLockDisabledDescription,
                  style: GoogleFonts.poppins(
                    color: textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (loadingLock)
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: neonBlue,
              ),
            )
          else
            Switch(
              value: appLockEnabled,
              onChanged: _toggleAppLock,
              activeThumbColor: Colors.white,
              activeTrackColor: neonBlue,
              inactiveThumbColor: textSecondary,
              inactiveTrackColor: cardElevated,
            ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        color: textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String hint,
    required bool visible,
    required VoidCallback onVisibilityChanged,
  }) {
    return TextField(
      controller: controller,
      obscureText: !visible,
      style: GoogleFonts.poppins(
        color: textPrimary,
        fontSize: 15,
      ),
      cursorColor: neonBlue,
      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.lock_outline,
          color: neonBlue,
        ),
        suffixIcon: IconButton(
          onPressed: onVisibilityChanged,
          icon: Icon(
            visible
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: textMuted,
          ),
        ),
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          color: textMuted,
          fontSize: 14,
        ),
        filled: true,
        fillColor: cardDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: neonBlue,
            width: 1.2,
          ),
        ),
      ),
    );
  }
}
