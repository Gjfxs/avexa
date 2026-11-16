import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'profile_service.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  static final _supabase = Supabase.instance.client;

  /// EMAIL LOGIN
  static Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {

    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    await ProfileService.createProfileIfNeeded();

    return response;
  }

  /// EMAIL REGISTER
  static Future<void> register({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Account created successfully",
          ),
        ),
      );

      Navigator.pop(context);
    } on AuthException catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }

  /// GOOGLE LOGIN
  static Future<void> signInWithGoogle() async {
    debugPrint('OAUTH GOOGLE: START');

    final result = await _supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.flutter://login-callback',
      authScreenLaunchMode: LaunchMode.externalApplication,
    );

    debugPrint('OAUTH GOOGLE: RESULT = $result');
  }

  /// X LOGIN
  static Future<void> signInWithX() async {
    debugPrint('OAUTH X: START');

    final result = await _supabase.auth.signInWithOAuth(
      OAuthProvider('x'),
      redirectTo: 'io.supabase.flutter://login-callback',
      authScreenLaunchMode: LaunchMode.externalApplication,
    );

    debugPrint('OAUTH X: RESULT = $result');
  }

  /// LOGOUT
  static Future<void> logout(BuildContext context) async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: $e'),
        ),
      );
    }
  }

  /// CURRENT USER
  static User? get currentUser =>
      _supabase.auth.currentUser;

  static bool get isLoggedIn =>
      currentUser != null;

  static Future<void> signInWithApple() async {
    final rawNonce = _supabase.auth.generateRawNonce();

    final hashedNonce =
        sha256.convert(utf8.encode(rawNonce)).toString();

    final credential =
        await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: hashedNonce,
    );

    final idToken = credential.identityToken;

    if (idToken == null) {
      throw const AuthException(
        'Could not find Apple identity token.',
      );
    }

    await _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.apple,
      idToken: idToken,
      nonce: rawNonce,
    );

    await ProfileService.createProfileIfNeeded();
  }
}