import 'dart:async';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';

import 'services/supabase_service.dart';
import 'services/theme_service.dart';
import 'services/notification_service.dart';
import 'services/locale_controller.dart';

import 'auth/auth_gate.dart';
import 'screens/create_new_password_screen.dart';
import 'theme.dart';
import 'firebase_options.dart';
import 'services/subscription_state.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

/// ============================================================
/// ANALYX DESIGN SYSTEM
/// ============================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
  );

  await SupabaseService.initialize();

  await SubscriptionState.instance.initialize();

  await NotificationService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  StreamSubscription<AuthState>? _authSubscription;

  bool _passwordRecoveryOpen = false;

  ThemeMode _themeMode = ThemeMode.dark;



  @override
  void initState() {
    super.initState();

    LocaleController.instance.addListener(_onLocaleChanged);
    LocaleController.instance.load();

    _loadTheme();

    ThemeService.instance.addListener(
      _onThemeChanged,
    );

    _authSubscription =
        SupabaseService.client.auth.onAuthStateChange.listen((data) {
      print("========== APP AUTH LISTENER ==========");
      print("EVENT: ${data.event}");

      if (data.event == AuthChangeEvent.passwordRecovery) {
        _openPasswordRecovery();
      }
    });
  }

  Future<void> _loadTheme() async {
    await ThemeService.instance.load();

    if (!mounted) return;

    setState(() {
      _themeMode =
          ThemeService.instance.themeMode;
    });
  }

  void _onThemeChanged() {
    if (!mounted) return;

    setState(() {
      _themeMode = ThemeService.instance.themeMode;
    });
  }

  void _onLocaleChanged() {
    if (!mounted) return;

    setState(() {});
  }

  void _openPasswordRecovery() {
    if (_passwordRecoveryOpen) return;

    _passwordRecoveryOpen = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigator = navigatorKey.currentState;

      if (navigator == null) {
        _passwordRecoveryOpen = false;
        return;
      }

      navigator.push(
        MaterialPageRoute(
          builder: (_) => const CreateNewPasswordScreen(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();

    LocaleController.instance.removeListener(_onLocaleChanged);
    ThemeService.instance.removeListener(_onThemeChanged);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      navigatorKey: navigatorKey,

      navigatorObservers: [routeObserver],

      theme: buildLightTheme(),

      darkTheme: buildDarkTheme(),

      themeMode: _themeMode,

      home: Builder(
        builder: (context) {
          debugPrint('MAIN: BUILDING AUTH GATE');
          return const AuthGate();
        },
      ),

      locale: LocaleController.instance.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
