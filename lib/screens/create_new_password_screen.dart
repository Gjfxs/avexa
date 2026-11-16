import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../theme.dart';

class CreateNewPasswordScreen extends StatefulWidget {
  const CreateNewPasswordScreen({super.key});

  @override
  State<CreateNewPasswordScreen> createState() =>
      _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState
    extends State<CreateNewPasswordScreen> {
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool isLoading = false;

  String? errorMessage;

  static const Color analyxBlue = Color(0xFF149BFF);
  static const Color analyxBlueLight = Color(0xFF35B6FF);

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  bool get hasMinLength =>
      passwordController.text.length >= 8;

  bool get hasNumber =>
      RegExp(r'[0-9]').hasMatch(passwordController.text);

  bool get hasUppercase =>
      RegExp(r'[A-Z]').hasMatch(passwordController.text);

  bool get passwordsMatch =>
      passwordController.text.isNotEmpty &&
      passwordController.text ==
          confirmPasswordController.text;

  Future<void> _updatePassword() async {
    FocusScope.of(context).unfocus();

    final password = passwordController.text;
    final confirmPassword =
        confirmPasswordController.text;

    setState(() {
      errorMessage = null;
    });

    if (password.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        errorMessage = "Please fill in both fields.";
      });
      return;
    }

    if (!hasMinLength) {
      setState(() {
        errorMessage =
            "Password must contain at least 8 characters.";
      });
      return;
    }

    if (!hasNumber) {
      setState(() {
        errorMessage =
            "Password must contain at least one number.";
      });
      return;
    }

    if (!hasUppercase) {
      setState(() {
        errorMessage =
            "Password must contain at least one uppercase letter.";
      });
      return;
    }

    if (!passwordsMatch) {
      setState(() {
        errorMessage = "Passwords do not match.";
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(
          password: password,
        ),
      );

      if (!mounted) return;

      // Password successfully changed.
      // We sign the user out so they must log in
      // with the new password.
      await Supabase.instance.client.auth.signOut();

      if (!mounted) return;

      Navigator.of(context).popUntil(
        (route) => route.isFirst,
      );
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                24,
                28,
                24,
                24,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF0B1020),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        analyxBlue.withOpacity(0.15),
                    blurRadius: 40,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          analyxBlue.withOpacity(0.12),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: analyxBlueLight,
                      size: 34,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    "Password Updated",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Your password has been changed successfully.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade400,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 22),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();

                      },
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor: analyxBlue,
                        elevation: 6,
                        shadowColor:
                            analyxBlue.withOpacity(0.25),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        "BACK TO LOGIN",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
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
            "Something went wrong. Please try again.";
      });
    }
  }

  Widget _requirement(
    String text,
    bool fulfilled,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Icon(
            fulfilled
                ? Icons.check_circle_rounded
                : Icons.circle_outlined,
            size: 16,
            color: fulfilled
                ? analyxBlueLight
                : Colors.grey.shade600,
          ),
          const SizedBox(width: 9),
          Text(
            text,
            style: GoogleFonts.poppins(
              color: fulfilled
                  ? Colors.grey.shade200
                  : Colors.grey.shade500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
      final colors =
          Theme.of(context).extension<AvexaColors>()!;

      return Scaffold(
      backgroundColor: colors.background,
      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
          child: Column(
            children: [

              const SizedBox(height: 35),

              // ======================================================
              // LOCK ICON
              // ======================================================

              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      analyxBlue.withOpacity(0.10),
                  boxShadow: [
                    BoxShadow(
                      color:
                          analyxBlue.withOpacity(0.12),
                      blurRadius: 35,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.lock_reset_rounded,
                  color: analyxBlueLight,
                  size: 40,
                ),
              ),

              const SizedBox(height: 26),

              // ======================================================
              // TITLE
              // ======================================================

              Text(
                "Create New Password",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 9),

              Text(
                "Choose a strong password for your AnalyX account.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 34),

              // ======================================================
              // NEW PASSWORD
              // ======================================================

              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                enabled: !isLoading,
                onChanged: (_) {
                  setState(() {
                    errorMessage = null;
                  });
                },
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  labelText: "New password",
                  labelStyle: GoogleFonts.poppins(
                    color: Colors.grey.shade400,
                  ),
                  prefixIcon: Icon(
                    Icons.lock_outline_rounded,
                    color: Colors.grey.shade500,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obscurePassword =
                            !obscurePassword;
                      });
                    },
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  enabledBorder:
                      UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  focusedBorder:
                      const UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: analyxBlue,
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // ======================================================
              // CONFIRM PASSWORD
              // ======================================================

              TextField(
                controller: confirmPasswordController,
                obscureText: obscureConfirmPassword,
                enabled: !isLoading,
                onChanged: (_) {
                  setState(() {
                    errorMessage = null;
                  });
                },
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  labelText: "Confirm new password",
                  labelStyle: GoogleFonts.poppins(
                    color: Colors.grey.shade400,
                  ),
                  prefixIcon: Icon(
                    Icons.lock_outline_rounded,
                    color: Colors.grey.shade500,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obscureConfirmPassword =
                            !obscureConfirmPassword;
                      });
                    },
                    icon: Icon(
                      obscureConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  enabledBorder:
                      UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  focusedBorder:
                      const UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: analyxBlue,
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ======================================================
              // PASSWORD REQUIREMENTS
              // ======================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.035),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color:
                        Colors.white.withOpacity(0.06),
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Password requirements",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 13),

                    _requirement(
                      "At least 8 characters",
                      hasMinLength,
                    ),

                    _requirement(
                      "One number",
                      hasNumber,
                    ),

                    _requirement(
                      "One uppercase letter",
                      hasUppercase,
                    ),

                    _requirement(
                      "Passwords match",
                      passwordsMatch,
                    ),
                  ],
                ),
              ),

              if (errorMessage != null) ...[
                const SizedBox(height: 16),

                Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.redAccent,
                    fontSize: 12,
                  ),
                ),
              ],

              const SizedBox(height: 26),

              // ======================================================
              // UPDATE PASSWORD
              // ======================================================

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed:
                      isLoading ? null : _updatePassword,
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor: analyxBlue,
                    disabledBackgroundColor:
                        analyxBlue.withOpacity(0.4),
                    elevation: 7,
                    shadowColor:
                        analyxBlue.withOpacity(0.28),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(30),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          "UPDATE PASSWORD",
                          style:
                              GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight:
                                FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 25),

              Text(
                "Your password will be securely updated.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade600,
                  fontSize: 11,
                ),
              ),

              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}