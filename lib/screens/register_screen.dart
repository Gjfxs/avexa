
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  Future<void> _openLegalLink(
    BuildContext context,
    String url,
  ) async {
    final uri = Uri.parse(url);

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
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

  Future<void> _socialSignIn(
    BuildContext context,
    String provider,
  ) async {
    try {
      switch (provider) {
        case 'google':
          await AuthService.signInWithGoogle();
          break;
        case 'x':
          await AuthService.signInWithX();
          break;
        case 'apple':
          await AuthService.signInWithApple();
          break;
      }
    } on AuthException catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      debugPrint('SOCIAL SIGN-IN ERROR ($provider): $e');

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sign-in failed. Please try again.'),
        ),
      );
    }
  }

  Widget _socialButton({
    required BuildContext context,
    required String provider,
    required Widget icon,
    required AvexaColors colors,
  }) {
    return SizedBox(
      width: 62,
      height: 62,
      child: Material(
        color: colors.card,
        shape: CircleBorder(
          side: BorderSide(color: colors.border),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => _socialSignIn(context, provider),
          child: Center(child: icon),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AvexaColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        iconTheme: IconThemeData(
          color: colors.primaryText,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),

              Text(
                l10n.registerTitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: colors.primaryText,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                l10n.registerSubtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: colors.secondaryText,
                ),
              ),

              const SizedBox(height: 40),

              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                style: GoogleFonts.poppins(
                  color: colors.primaryText,
                ),
                decoration: _inputDecoration(
                  l10n.registerEmail,
                  colors,
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: passwordController,
                obscureText: true,
                autofillHints: const [AutofillHints.newPassword],
                style: GoogleFonts.poppins(
                  color: colors.primaryText,
                ),
                decoration: _inputDecoration(
                  l10n.registerPassword,
                  colors,
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                style: GoogleFonts.poppins(
                  color: colors.primaryText,
                ),
                decoration: _inputDecoration(
                  l10n.registerConfirmPassword,
                  colors,
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: neonBlue,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () async {
                    if (passwordController.text !=
                        confirmPasswordController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            l10n.registerPasswordMismatch,
                          ),
                        ),
                      );
                      return;
                    }

                    if (emailController.text.trim().isEmpty ||
                        passwordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enter your email and password.',
                          ),
                        ),
                      );
                      return;
                    }

                    try {
                      await Supabase.instance.client.auth.signUp(
                        email: emailController.text.trim(),
                        password: passwordController.text,
                      );

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.registerSuccess),
                        ),
                      );

                      Navigator.pop(context);
                    } on AuthException catch (e) {
                      debugPrint('STATUS: ${e.statusCode}');
                      debugPrint('MESSAGE: ${e.message}');
                      debugPrint('CODE: ${e.code}');

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.message)),
                      );
                    } catch (e) {
                      debugPrint('REGISTER ERROR: $e');

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.registerGenericError),
                        ),
                      );
                    }
                  },
                  child: Text(
                    l10n.registerButton,
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Social sign-in divider
              Row(
                children: [
                  Expanded(
                    child: Divider(color: colors.border),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      'Or continue with',
                      style: GoogleFonts.poppins(
                        color: colors.secondaryText,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: colors.border),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // Google, X and Apple
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _socialButton(
                    context: context,
                    provider: 'google',
                    colors: colors,
                    icon: Text(
                      'G',
                      style: GoogleFonts.poppins(
                        color: colors.primaryText,
                        fontSize: 29,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  const SizedBox(width: 20),

                  _socialButton(
                    context: context,
                    provider: 'x',
                    colors: colors,
                    icon: Text(
                      '𝕏',
                      style: TextStyle(
                        color: colors.primaryText,
                        fontSize: 27,
                      ),
                    ),
                  ),

                  const SizedBox(width: 20),

                  _socialButton(
                    context: context,
                    provider: 'apple',
                    colors: colors,
                    icon: Text(
                      '',
                      style: TextStyle(
                        color: colors.primaryText,
                        fontSize: 30,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Legal information
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
                      context,
                      'https://nex-start.com/terms-of-use.html',
                    ),
                  ),
                  _LegalLink(
                    text: l10n.loginLegalPrivacy,
                    onTap: () => _openLegalLink(
                      context,
                      'https://nex-start.com/privacy-policy.html',
                    ),
                  ),
                  _LegalLink(
                    text: l10n.loginLegalRisk,
                    onTap: () => _openLegalLink(
                      context,
                      'https://nex-start.com/risk-disclaimer.html',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    String label,
    AvexaColors colors,
  ) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(
        color: colors.secondaryText,
      ),
      filled: true,
      fillColor: colors.card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: neonBlue,
          width: 1.4,
        ),
      ),
    );
  }
}

// ============================================================================
// LEGAL LINK
// ============================================================================

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
