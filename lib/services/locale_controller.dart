import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends ChangeNotifier {
  LocaleController._();

  static final LocaleController instance = LocaleController._();

  static const String _languageKey = 'language';
  static const String _languageSelectedKey = 'language_selected';

  static const Map<String, Locale> supportedLanguages = {
    'Polski': Locale('pl'),
    'English': Locale('en'),
    'Deutsch': Locale('de'),
    '日本語': Locale('ja'),
    'Русский': Locale('ru'),
    'العربية': Locale('ar'),
    '中文': Locale('zh'),
    'Español': Locale('es'),
    'Português': Locale('pt'),
  };

  Locale _locale = const Locale('en');
  bool _hasSelectedLanguage = false;

  Locale get locale => _locale;

  bool get hasSelectedLanguage => _hasSelectedLanguage;

  String get language {
    return supportedLanguages.entries
            .where(
              (entry) =>
                  entry.value.languageCode == _locale.languageCode,
            )
            .map((entry) => entry.key)
            .firstOrNull ??
        'English';
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final savedLanguage = prefs.getString(_languageKey);
    final explicitlySelected =
        prefs.getBool(_languageSelectedKey);

    _locale = supportedLanguages[savedLanguage] ?? const Locale('en');

    // Backward compatibility: if a language was saved by an older
    // version of the app, treat it as an existing user selection.
    _hasSelectedLanguage =
        explicitlySelected ?? savedLanguage != null;

    notifyListeners();
  }

  Future<void> changeLanguage(
    String language, {
    bool markAsSelected = true,
  }) async {
    final newLocale = supportedLanguages[language];

    if (newLocale == null) return;

    _locale = newLocale;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);

    if (markAsSelected) {
      await prefs.setBool(_languageSelectedKey, true);
      _hasSelectedLanguage = true;
    }

    notifyListeners();
  }
}