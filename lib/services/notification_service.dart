import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  static final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  static final SupabaseClient _supabase =
      Supabase.instance.client;

  static StreamSubscription<String>? _tokenRefreshSubscription;
  static StreamSubscription<RemoteMessage>? _messageSubscription;
  static StreamSubscription<RemoteMessage>? _openedMessageSubscription;

  static Future<void> initialize() async {
    print('========== AVEXA NOTIFICATIONS ==========');
    print('Initializing Firebase Messaging...');

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    print(
      'Notification permission: ${settings.authorizationStatus}',
    );

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    String? apnsToken;

    for (int i = 0; i < 10; i++) {
      apnsToken = await _messaging.getAPNSToken();

      if (apnsToken != null) {
        break;
      }

      await Future.delayed(
        const Duration(milliseconds: 500),
      );
    }

    print('APNs token: $apnsToken');

    if (apnsToken == null) {
      print('WARNING: APNs token is not available.');
      return;
    }

    final fcmToken = await _messaging.getToken();

    print('FCM TOKEN RECEIVED: ${fcmToken != null}');

    if (fcmToken != null) {
      await _saveToken(fcmToken);
    }

    await _tokenRefreshSubscription?.cancel();

    _tokenRefreshSubscription =
        _messaging.onTokenRefresh.listen((newToken) async {
      print('FCM TOKEN REFRESHED');

      await _saveToken(newToken);
    });

    await _messageSubscription?.cancel();

    _messageSubscription =
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('========== FCM MESSAGE ==========');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');
    });

    await _openedMessageSubscription?.cancel();

    _openedMessageSubscription =
        FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) {
        print('========== FCM OPENED ==========');
        print('Data: ${message.data}');
      },
    );

    final initialMessage =
        await _messaging.getInitialMessage();

    if (initialMessage != null) {
      print('========== FCM INITIAL MESSAGE ==========');
      print('Data: ${initialMessage.data}');
    }

    print('========== NOTIFICATIONS READY ==========');
  }

  static Future<void> _saveToken(String token) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      print(
        'FCM token not saved: no authenticated Supabase user.',
      );
      return;
    }

    try {
      await _supabase
          .from('user_devices')
          .upsert(
        {
          'user_id': user.id,
          'fcm_token': token,
          'platform': 'ios',
          'updated_at':
              DateTime.now().toUtc().toIso8601String(),
        },
        onConflict: 'fcm_token',
      );

      print('FCM TOKEN SAVED TO SUPABASE');
    } catch (e) {
      print('ERROR SAVING FCM TOKEN: $e');
    }
  }

  static Future<void> dispose() async {
    await _tokenRefreshSubscription?.cancel();
    await _messageSubscription?.cancel();
    await _openedMessageSubscription?.cancel();
  }
}