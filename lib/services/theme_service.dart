import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  ThemeService._();

  static final ThemeService instance =
      ThemeService._();

  static const String _themeKey =
      'avexa_theme_mode';

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  Future<void> load() async {
    final prefs =
        await SharedPreferences.getInstance();

    final savedTheme =
        prefs.getString(_themeKey);

    switch (savedTheme) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;

      case 'dark':
        _themeMode = ThemeMode.dark;
        break;

      case 'system':
      default:
        _themeMode = ThemeMode.system;
        break;
    }

    notifyListeners();
  }

  Future<void> setThemeMode(
    ThemeMode mode,
  ) async {
    _themeMode = mode;

    final prefs =
        await SharedPreferences.getInstance();

    switch (mode) {
      case ThemeMode.light:
        await prefs.setString(
          _themeKey,
          'light',
        );
        break;

      case ThemeMode.dark:
        await prefs.setString(
          _themeKey,
          'dark',
        );
        break;

      case ThemeMode.system:
        await prefs.setString(
          _themeKey,
          'system',
        );
        break;
    }

    notifyListeners();
  }
}