import 'package:flutter/services.dart';

class AppIconService {
  AppIconService._();

  static final AppIconService instance =
      AppIconService._();

  static const MethodChannel _channel =
      MethodChannel('com.avexa.app/icon');

  Future<bool> isLightIcon() async {
    try {
      final result =
          await _channel.invokeMethod<bool>(
        'getCurrentIcon',
      );

      return result == true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> setLightIcon(bool enabled) async {
    try {
      final result =
          await _channel.invokeMethod<bool>(
        'setAppIcon',
        {
          'light': enabled,
        },
      );

      return result == true;
    } catch (_) {
      return false;
    }
  }
}