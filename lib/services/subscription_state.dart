
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'subscription_service.dart';

class SubscriptionState extends ChangeNotifier
    with WidgetsBindingObserver {
  SubscriptionState._();

  static final SubscriptionState instance =
      SubscriptionState._();

  StreamSubscription<AuthState>? _authSubscription;
  Timer? _refreshTimer;

  bool _isPro = false;
  bool _isLoading = true;
  String? _userId;

  int _requestId = 0;

  bool get isPro => _isPro;
  bool get isLoading => _isLoading;
  String? get userId => _userId;

  static const Duration _refreshInterval =
      Duration(seconds: 60);

  Future<void> initialize() async {
    if (_authSubscription != null) return;

    WidgetsBinding.instance.addObserver(this);

    _authSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final currentUserId =
          Supabase.instance.client.auth.currentUser?.id;

      if (data.event == AuthChangeEvent.signedOut) {
        _stopRefreshTimer();
        _clear();
        return;
      }

      if (currentUserId != _userId ||
          data.event == AuthChangeEvent.signedIn ||
          data.event == AuthChangeEvent.initialSession) {
        refresh();
      }
    });

    await refresh();

    if (WidgetsBinding.instance.lifecycleState ==
        AppLifecycleState.resumed) {
      _startRefreshTimer();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint('SUBSCRIPTION: APP RESUMED');

      refresh();
      _startRefreshTimer();
    } else {
      _stopRefreshTimer();
    }
  }

  void _startRefreshTimer() {
    _refreshTimer?.cancel();

    _refreshTimer = Timer.periodic(
      _refreshInterval,
      (_) {
        debugPrint('SUBSCRIPTION: PERIODIC REFRESH');
        refresh();
      },
    );
  }

  void _stopRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  Future<void> refresh() async {
    final user = Supabase.instance.client.auth.currentUser;
    final requestId = ++_requestId;

    if (user == null) {
      _clear();
      return;
    }

    final needsInitialLoading =
        _isLoading || _userId != user.id;

    _userId = user.id;

    if (needsInitialLoading) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final result = await SubscriptionService.isPro();

      if (requestId != _requestId) return;

      if (Supabase.instance.client.auth.currentUser?.id != user.id) {
        return;
      }

      _isPro = result;
      _isLoading = false;

      debugPrint(
        'CENTRAL SUBSCRIPTION STATE: '
        '${_isPro ? 'PRO' : 'FREE'}',
      );

      debugPrint('SUBSCRIPTION NOTIFY LISTENERS');
      notifyListeners();
    } catch (e) {
      if (requestId != _requestId) return;

      debugPrint('CENTRAL SUBSCRIPTION ERROR: $e');

      _isLoading = false;
      notifyListeners();
    }
  }

  void _clear() {
    _requestId++;
    _userId = null;
    _isPro = false;
    _isLoading = false;

    notifyListeners();
  }

  @override
  void dispose() {
    _stopRefreshTimer();
    WidgetsBinding.instance.removeObserver(this);
    _authSubscription?.cancel();

    super.dispose();
  }
}
