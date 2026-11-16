
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../screens/language_selection_screen.dart';
import '../screens/login_screen.dart';
import '../screens/main_screen.dart';
import '../services/app_lock_service.dart';
import '../services/first_launch_service.dart';
import '../services/local_auth_service.dart';
import '../services/onboarding_service.dart';
import '../services/subscription_service.dart';
import '../theme.dart';
import '../screens/onboarding_screen.dart' as onboarding;
import '../screens/plan_selection_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate>
    with WidgetsBindingObserver {
  StreamSubscription<AuthState>? _authSubscription;

  bool _checkingAuth = true;
  bool _authenticated = false;
  bool _authInProgress = false;

  bool _onboardingCompleted = false;
  bool _checkingOnboarding = false;

  bool _subscriptionStepCompleted = false;

  bool _checkingLanguage = true;
  bool _languageSelected = false;

  bool _wasInBackground = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    debugPrint('AUTH GATE: INIT');

    _authSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen(
      (data) {
        debugPrint('AUTH GATE EVENT: ${data.event}');

        if (data.event == AuthChangeEvent.signedIn) {
          _handleSignedIn();
        }

        if (data.event == AuthChangeEvent.signedOut) {
          _handleSignedOut();
        }
      },
    );

    _checkInitialSession();
  }

  // ============================================================
  // INITIAL SESSION
  // ============================================================

  Future<void> _checkInitialSession() async {
    final session =
        Supabase.instance.client.auth.currentSession;

    debugPrint(
      'AUTH GATE INITIAL SESSION: ${session != null}',
    );

    if (session == null) {
      final selected =
          await FirstLaunchService.instance.hasSelectedLanguage();

      bool onboardingCompleted = false;

      if (selected) {
        onboardingCompleted =
            await OnboardingService.instance.isCompleted();
      }

      if (!mounted) return;

      setState(() {
        _checkingLanguage = false;
        _languageSelected = selected;
        _onboardingCompleted = onboardingCompleted;
        _checkingAuth = false;
        _authenticated = false;
        _checkingOnboarding = false;
      });

      return;
    }

    if (mounted) {
      setState(() {
        _checkingLanguage = false;
        _languageSelected = true;
      });
    }

    await _handleSignedIn();
  }

  // ============================================================
  // LANGUAGE SELECTION
  // ============================================================

  Future<void> _continueToLogin() async {
    if (!mounted) return;

    setState(() {
      _languageSelected = true;
      _checkingOnboarding = true;
    });

    final completed =
        await OnboardingService.instance.isCompleted();

    if (!mounted) return;

    setState(() {
      _onboardingCompleted = completed;
      _checkingOnboarding = false;
    });
  }

  // ============================================================
  // APP LIFECYCLE / APP LOCK
  // ============================================================

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _wasInBackground = true;
      return;
    }

    if (state == AppLifecycleState.resumed &&
        _wasInBackground) {
      _wasInBackground = false;
      _lockAfterBackground();
    }
  }

  Future<void> _lockAfterBackground() async {
    final session =
        Supabase.instance.client.auth.currentSession;

    if (session == null) return;

    final appLockEnabled =
        await AppLockService.instance.isEnabled();

    if (!appLockEnabled || !mounted) return;

    setState(() {
      _authenticated = false;
      _checkingAuth = true;
    });

    final authenticated =
        await LocalAuthService.authenticate();

    if (!mounted) return;

    setState(() {
      _checkingAuth = false;
      _authenticated = authenticated;
    });

    debugPrint(
      'AUTH GATE APP LOCK RESULT: $authenticated',
    );
  }

  // ============================================================
  // ONBOARDING
  // ============================================================

  void _finishOnboarding() {
    if (!mounted) return;

    setState(() {
      _onboardingCompleted = true;
    });
  }

  // ============================================================
  // SUBSCRIPTION SELECTION
  // ============================================================

  void _finishSubscriptionStep() {
    if (!mounted) return;

    setState(() {
      _subscriptionStepCompleted = true;
    });
  }

  // ============================================================
  // FINISH AUTHENTICATION
  // ============================================================

  Future<void> _finishAuthentication() async {
    if (!mounted) return;

    setState(() {
      _checkingOnboarding = true;
    });

    try {
      // Check whether onboarding has already been completed.
      final onboardingCompleted =
          await OnboardingService.instance.isCompleted();

      // Check whether the user previously selected FREE or PRO.
      bool subscriptionCompleted =
          await FirstLaunchService.instance
              .hasCompletedSubscriptionStep();

      // Independently check the current PRO status.
      final isPro = await SubscriptionService.isPro();

      // Existing PRO users should never be forced
      // to see the plan selection screen.
      if (isPro && !subscriptionCompleted) {
        try {
          await FirstLaunchService.instance
              .markSubscriptionStepCompleted();
        } catch (error) {
          debugPrint(
            'AUTH GATE PRO STEP SAVE ERROR: $error',
          );
        }

        subscriptionCompleted = true;
      }

      if (!mounted) return;

      setState(() {
        _onboardingCompleted = onboardingCompleted;
        _subscriptionStepCompleted = subscriptionCompleted;

        _checkingOnboarding = false;
        _checkingAuth = false;
        _authenticated = true;
      });

      debugPrint(
        'AUTH GATE FINAL STATE: '
        'onboarding=$onboardingCompleted, '
        'subscription=$subscriptionCompleted, '
        'pro=$isPro',
      );
    } catch (error) {
      debugPrint(
        'AUTH GATE FINISH AUTH ERROR: $error',
      );

      if (!mounted) return;

      setState(() {
        _checkingOnboarding = false;
        _checkingAuth = false;
        _authenticated = true;
      });
    }
  }

  // ============================================================
  // SIGN IN
  // ============================================================

  Future<void> _handleSignedIn() async {
    if (_authInProgress) return;

    final session =
        Supabase.instance.client.auth.currentSession;

    if (session == null) return;

    _authInProgress = true;

    debugPrint('AUTH GATE: USER SIGNED IN');

    if (mounted) {
      setState(() {
        _checkingAuth = true;
      });
    }

    try {
      final appLockEnabled =
          await AppLockService.instance.isEnabled();

      if (appLockEnabled) {
        final authenticated =
            await LocalAuthService.authenticate();

        if (!mounted) return;

        final currentSession =
            Supabase.instance.client.auth.currentSession;

        if (currentSession == null) {
          setState(() {
            _checkingAuth = false;
            _authenticated = false;
          });
          return;
        }

        if (!authenticated) {
          setState(() {
            _checkingAuth = false;
            _authenticated = false;
          });
          return;
        }
      }

      await _finishAuthentication();
    } finally {
      _authInProgress = false;
    }
  }

  // ============================================================
  // RETRY APP LOCK
  // ============================================================

  Future<void> _retryAuthentication() async {
    if (_authInProgress) return;

    _authInProgress = true;

    try {
      final authenticated =
          await LocalAuthService.authenticate();

      if (!mounted) return;

      setState(() {
        _checkingAuth = false;
        _authenticated = authenticated;
      });
    } finally {
      _authInProgress = false;
    }
  }

  // ============================================================
  // SIGN OUT
  // ============================================================

  void _handleSignedOut() {
    debugPrint('AUTH GATE: USER SIGNED OUT');

    if (!mounted) return;

    setState(() {
      _checkingAuth = false;
      _authenticated = false;
      _authInProgress = false;

      // Do not reset onboarding or the user's
      // saved subscription selection.
    });
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authSubscription?.cancel();

    super.dispose();
  }

  // ============================================================
  // BUILD / ROUTING
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final session =
        Supabase.instance.client.auth.currentSession;

    if (_checkingLanguage) {
      return const _LoadingScreen();
    }

    // ----------------------------------------------------------
    // NO ACTIVE SESSION
    // ----------------------------------------------------------

    if (session == null) {
      if (!_languageSelected) {
        return LanguageSelectionScreen(
          onContinue: _continueToLogin,
        );
      }

      if (_checkingOnboarding) {
        return const _LoadingScreen();
      }

      if (!_onboardingCompleted) {
        return onboarding.OnboardingScreen(
          onFinished: _finishOnboarding,
        );
      }

      return const LoginScreen();
    }

    // ----------------------------------------------------------
    // ACTIVE SESSION
    // ----------------------------------------------------------

    if (_checkingAuth) {
      return const _LoadingScreen();
    }

    if (!_authenticated) {
      return _LockedScreen(
        onRetry: _retryAuthentication,
      );
    }

    if (_checkingOnboarding) {
      return const _LoadingScreen();
    }

    if (!_onboardingCompleted) {
      return onboarding.OnboardingScreen(
        onFinished: _finishOnboarding,
      );
    }

    // Only users who have not yet completed their
    // initial plan selection see this screen.
    if (!_subscriptionStepCompleted) {
      return PlanSelectionScreen(
        onCompleted: _finishSubscriptionStep,
      );
    }

    return const MainScreen();
  }
}

// ============================================================
// LOADING SCREEN
// ============================================================

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: CircularProgressIndicator(
          color: neonBlue,
        ),
      ),
    );
  }
}

// ============================================================
// LOCKED SCREEN
// ============================================================

class _LockedScreen extends StatelessWidget {
  final VoidCallback onRetry;

  const _LockedScreen({
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_outline,
                color: neonBlue,
                size: 64,
              ),
              const SizedBox(height: 24),
              Text(
                'Avexa Locked',
                style: GoogleFonts.poppins(
                  color: textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Use Face ID or your iPhone passcode\n'
                'to continue.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: textSecondary,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(
                    Icons.face,
                    color: Colors.white,
                  ),
                  label: Text(
                    'UNLOCK AVEXA',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: neonBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
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
