
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../theme.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  late AnimationController _rocketController;
  late Animation<double> _rocketFloat;
  late Animation<double> _rocketRotate;
  late Animation<double> _rocketScale;

  static const Color avexaBlue = Color(0xFF149BFF);
  static const Color avexaBlueLight = Color(0xFF35B6FF);

  @override
  void initState() {
    super.initState();

    _rocketController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);

    _rocketFloat = Tween<double>(
      begin: -7,
      end: 7,
    ).animate(
      CurvedAnimation(
        parent: _rocketController,
        curve: Curves.easeInOutSine,
      ),
    );

    _rocketRotate = Tween<double>(
      begin: -0.018,
      end: 0.018,
    ).animate(
      CurvedAnimation(
        parent: _rocketController,
        curve: Curves.easeInOutSine,
      ),
    );

    _rocketScale = Tween<double>(
      begin: 0.985,
      end: 1.015,
    ).animate(
      CurvedAnimation(
        parent: _rocketController,
        curve: Curves.easeInOutSine,
      ),
    );
  }

  @override
  void dispose() {
    _rocketController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _openLegalLink(String url) async {
    final uri = Uri.parse(url);

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open the link.'),
          ),
        );
      }
    } catch (e) {
      debugPrint('LEGAL LINK ERROR: $e');
    }
  }

  Future<void> resetPassword(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const ResetPasswordDialog(),
    );

    if (!context.mounted) return;

    if (result == true) {
      final colors = Theme.of(context).extension<AvexaColors>()!;
      final l10n = AppLocalizations.of(context)!;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: colors.elevatedCard,
          content: Text(
            l10n.loginResetSuccess,
            style: GoogleFonts.poppins(
              color: colors.primaryText,
            ),
          ),
        ),
      );
    }
  }

  Future<void> _signInWithApple() async {
    try {
      await AuthService.signInWithApple();

      debugPrint('APPLE LOGIN: SUCCESS');
    } on SignInWithAppleAuthorizationException catch (e) {
      if (!mounted) return;

      if (e.code == AuthorizationErrorCode.canceled) {
        return;
      }

      final l10n = AppLocalizations.of(context)!;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.loginAppleSignInFailed(e.message),
          ),
        ),
      );
    } on AuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AvexaColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 18,
          ),
          child: Column(
            children: [
              const SizedBox(height: 24),

              Text(
                l10n.loginTitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: colors.primaryText,
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.8,
                ),
              ),

              const SizedBox(height: 8),

              AnimatedBuilder(
                animation: _rocketController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _rocketFloat.value),
                    child: Transform.rotate(
                      angle: _rocketRotate.value,
                      child: Transform.scale(
                        scale: _rocketScale.value,
                        child: child,
                      ),
                    ),
                  );
                },
                child: Container(
                  height: 190,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: avexaBlue.withOpacity(0.10),
                        blurRadius: 35,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/mascot/ax_rocket.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint('AVEXA LOGIN IMAGE ERROR: $error');
                      debugPrintStack(stackTrace: stackTrace);

                      return const Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: Colors.redAccent,
                          size: 36,
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 2),

              Text(
                l10n.loginSubtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: colors.secondaryText,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 32),

              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                style: GoogleFonts.poppins(
                  color: colors.primaryText,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  labelText: l10n.loginEmail,
                  labelStyle: GoogleFonts.poppins(
                    color: colors.secondaryText,
                  ),
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: colors.mutedText,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: colors.border,
                    ),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: avexaBlue,
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              TextField(
                controller: passwordController,
                obscureText: true,
                textInputAction: TextInputAction.done,
                style: GoogleFonts.poppins(
                  color: colors.primaryText,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  labelText: l10n.loginPassword,
                  labelStyle: GoogleFonts.poppins(
                    color: colors.secondaryText,
                  ),
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: colors.mutedText,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: colors.border,
                    ),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: avexaBlue,
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 6),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: avexaBlue,
                    foregroundColor: Colors.white,
                    elevation: 8,
                    shadowColor: avexaBlue.withOpacity(0.30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () async {
                    try {
                      await AuthService.signInWithEmail(
                        email: emailController.text.trim(),
                        password: passwordController.text.trim(),
                      );

                      debugPrint('LOGIN: SUCCESS');

                      debugPrint(
                        'LOGIN: SESSION EXISTS = '
                        '${Supabase.instance.client.auth.currentSession != null}',
                      );

                      // AuthGate sam obsłuży dalszą nawigację.
                    } on AuthException catch (e) {
                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(e.message),
                        ),
                      );
                    } catch (e) {
                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(e.toString()),
                        ),
                      );
                    }
                  },
                  child: Text(
                    l10n.loginButton,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      color: colors.border,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                    ),
                    child: Text(
                      l10n.loginOrContinueWith,
                      style: GoogleFonts.poppins(
                        color: colors.mutedText,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: colors.border,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SocialLoginButton(
                    onTap: () async {
                      await AuthService.signInWithGoogle();
                    },
                    child: Text(
                      "G",
                      style: TextStyle(
                        color: colors.primaryText,
                        fontSize: 23,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  const SizedBox(width: 18),

                  _SocialLoginButton(
                    onTap: () async {
                      await AuthService.signInWithX();
                    },
                    child: Text(
                      "𝕏",
                      style: TextStyle(
                        color: colors.primaryText,
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(width: 18),

                  _SocialLoginButton(
                    onTap: _signInWithApple,
                    child: Text(
                      "",
                      style: TextStyle(
                        color: colors.primaryText,
                        fontSize: 25,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Text(
                l10n.loginLegalNotice,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: colors.mutedText,
                  fontSize: 10,
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 8),

              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 6,
                children: [
                  _LegalLink(
                    text: l10n.loginLegalTerms,
                    onTap: () => _openLegalLink(
                      'https://nex-start.com/terms-of-use.html',
                    ),
                  ),
                  _LegalLink(
                    text: l10n.loginLegalPrivacy,
                    onTap: () => _openLegalLink(
                      'https://nex-start.com/privacy-policy.html',
                    ),
                  ),
                  _LegalLink(
                    text: l10n.loginLegalRisk,
                    onTap: () => _openLegalLink(
                      'https://nex-start.com/risk-disclaimer.html',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              TextButton(
                onPressed: () {
                  resetPassword(context);
                },
                child: Text(
                  l10n.loginForgotPassword,
                  style: GoogleFonts.poppins(
                    color: avexaBlueLight,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 0),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RegisterScreen(),
                    ),
                  );
                },
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      color: colors.secondaryText,
                      fontSize: 14,
                    ),
                    children: [
                      TextSpan(
                        text: l10n.loginNoAccount,
                      ),
                      TextSpan(
                        text: l10n.loginSignUp,
                        style: GoogleFonts.poppins(
                          color: avexaBlueLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SOCIAL LOGIN BUTTON
// ============================================================================

class _SocialLoginButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _SocialLoginButton({
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AvexaColors>()!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(34),
        child: Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.card,
            border: Border.all(
              color: colors.border,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: _LoginScreenState.avexaBlue.withOpacity(0.08),
                blurRadius: 18,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: child,
          ),
        ),
      ),
    );
  }
}

class _LegalLink extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _LegalLink({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: const Color(0xFF35B6FF),
          fontSize: 10,
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.underline,
          decorationColor: const Color(0xFF35B6FF),
        ),
      ),
    );
  }
}

// ============================================================================
// RESET PASSWORD
// ============================================================================

class ResetPasswordDialog extends StatefulWidget {
  const ResetPasswordDialog({super.key});

  @override
  State<ResetPasswordDialog> createState() =>
      _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends State<ResetPasswordDialog> {
  final emailController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  static const Color avexaBlue = Color(0xFF149BFF);
  static const Color avexaBlueLight = Color(0xFF35B6FF);

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    final email = emailController.text.trim();
    final l10n = AppLocalizations.of(context)!;

    if (email.isEmpty) {
      setState(() {
        errorMessage = l10n.loginEnterEmailError;
      });
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      setState(() {
        errorMessage = l10n.loginInvalidEmailError;
      });
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.flutter://login-callback',
      );

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } on AuthException catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.message;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage =
            AppLocalizations.of(context)!.loginResetGenericError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AvexaColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 24,
      ),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(
          maxWidth: 420,
        ),
        padding: const EdgeInsets.fromLTRB(
          24,
          26,
          24,
          20,
        ),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: colors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: avexaBlue.withOpacity(0.12),
              blurRadius: 40,
              spreadRadius: 2,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: avexaBlue.withOpacity(0.12),
                ),
                child: const Icon(
                  Icons.lock_reset_rounded,
                  color: avexaBlueLight,
                  size: 30,
                ),
              ),

              const SizedBox(height: 18),

              Text(
                l10n.loginResetPasswordTitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: colors.primaryText,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                l10n.loginResetPasswordDescription,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: colors.secondaryText,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 22),

              TextField(
                controller: emailController,
                enabled: !isLoading,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) {
                  if (!isLoading) {
                    _sendResetLink();
                  }
                },
                style: GoogleFonts.poppins(
                  color: colors.primaryText,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: l10n.loginEnterEmail,
                  hintStyle: GoogleFonts.poppins(
                    color: colors.mutedText,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: colors.mutedText,
                  ),
                  filled: true,
                  fillColor: colors.elevatedCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: colors.border,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: colors.border,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: avexaBlue,
                      width: 1.5,
                    ),
                  ),
                  errorText: errorMessage,
                  errorStyle: GoogleFonts.poppins(
                    color: Colors.redAccent,
                    fontSize: 11,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _sendResetLink,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: avexaBlue,
                    disabledBackgroundColor:
                        avexaBlue.withOpacity(0.4),
                    elevation: 6,
                    shadowColor: avexaBlue.withOpacity(0.25),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 21,
                          height: 21,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          l10n.loginSendResetLink,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 8),

              TextButton(
                onPressed: isLoading
                    ? null
                    : () {
                        Navigator.of(context).pop(false);
                      },
                child: Text(
                  l10n.loginCancel,
                  style: GoogleFonts.poppins(
                    color: colors.mutedText,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
