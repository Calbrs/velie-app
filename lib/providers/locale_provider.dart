import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the active app locale and persists the user's language choice
/// across app restarts. Supported locales: English (en), Swahili (sw),
/// Chinese Simplified (zh).
///
/// This is a device-level preference — it survives logout/login and is
/// never wiped by the session cleanup.
class LocaleProvider extends ChangeNotifier {
  LocaleProvider();

  static const _prefsKey = 'velie_locale';

  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  /// Supported locales that mirror the ARB files in lib/l10n/.
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('sw'),
    Locale('zh'),
  ];

  /// Loads the persisted locale from SharedPreferences. Should be called
  /// once before [runApp] so the first frame already uses the correct locale.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tag = prefs.getString(_prefsKey);
      if (tag != null) {
        final locale = Locale(tag);
        if (supportedLocales.any((l) => l.languageCode == locale.languageCode)) {
          _locale = locale;
        }
      }
    } catch (_) {
      // If storage fails keep the default English locale.
    }
  }

  /// Switches the active locale and persists the choice.
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, locale.languageCode);
    } catch (_) {}
  }
}
