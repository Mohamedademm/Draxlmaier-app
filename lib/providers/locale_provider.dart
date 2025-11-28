import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Locale Provider for managing app language
class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('fr'); // Default to French
  
  static const String _localeKey = 'app_locale';

  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_localeKey) ?? 'fr';
    _locale = Locale(languageCode);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (!['en', 'fr'].contains(locale.languageCode)) return;
    
    _locale = locale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }

  void toggleLocale() {
    if (_locale.languageCode == 'fr') {
      setLocale(const Locale('en'));
    } else {
      setLocale(const Locale('fr'));
    }
  }
}
