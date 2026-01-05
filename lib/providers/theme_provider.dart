import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme Provider pour la personnalisation des couleurs par l'admin
class ThemeProvider with ChangeNotifier {
  static const String _primaryColorKey = 'primary_color';
  static const String _accentColorKey = 'accent_color';
  static const String _backgroundColorKey = 'background_color';
  static const String _isDarkModeKey = 'is_dark_mode';
  
  Color _primaryColor = const Color(0xFF0F4C81);
  Color _accentColor = const Color(0xFFE63946);
  Color _backgroundColor = const Color(0xFFF8F9FA);
  bool _isDarkMode = false;
  
  Color get primaryColor => _primaryColor;
  Color get accentColor => _accentColor;
  Color get backgroundColor => _backgroundColor;
  bool get isDarkMode => _isDarkMode;
  
  ThemeProvider() {
    _loadColors();
  }
  
  /// Charger les couleurs depuis SharedPreferences
  Future<void> _loadColors() async {
    final prefs = await SharedPreferences.getInstance();
    
    final primaryValue = prefs.getInt(_primaryColorKey);
    final accentValue = prefs.getInt(_accentColorKey);
    final backgroundValue = prefs.getInt(_backgroundColorKey);
    final isDark = prefs.getBool(_isDarkModeKey);
    
    if (primaryValue != null) {
      _primaryColor = Color(primaryValue);
    }
    if (accentValue != null) {
      _accentColor = Color(accentValue);
    }
    if (backgroundValue != null) {
      _backgroundColor = Color(backgroundValue);
    }
    if (isDark != null) {
      _isDarkMode = isDark;
    }
    
    notifyListeners();
  }
  
  /// Mettre à jour la couleur primaire
  Future<void> updatePrimaryColor(Color color) async {
    _primaryColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_primaryColorKey, color.value);
    notifyListeners();
  }
  
  /// Mettre à jour la couleur d'accent
  Future<void> updateAccentColor(Color color) async {
    _accentColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_accentColorKey, color.value);
    notifyListeners();
  }
  
  /// Mettre à jour la couleur de fond
  Future<void> updateBackgroundColor(Color color) async {
    _backgroundColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_backgroundColorKey, color.value);
    notifyListeners();
  }

  /// Basculer le mode sombre
  Future<void> toggleThemeMode(bool isDark) async {
    _isDarkMode = isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isDarkModeKey, isDark);
    notifyListeners();
  }
  
  /// Réinitialiser aux couleurs par défaut
  Future<void> resetToDefault() async {
    _primaryColor = const Color(0xFF0F4C81);
    _accentColor = const Color(0xFFE63946);
    _backgroundColor = const Color(0xFFF8F9FA);
    _isDarkMode = false;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_primaryColorKey);
    await prefs.remove(_accentColorKey);
    await prefs.remove(_backgroundColorKey);
    await prefs.remove(_isDarkModeKey);
    
    notifyListeners();
  }
  
  /// Générer le ThemeData personnalisé
  ThemeData getTheme() {
    return ThemeData(
      useMaterial3: true,
      primaryColor: _primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        secondary: _accentColor,
        surface: _backgroundColor,
      ),
      scaffoldBackgroundColor: _backgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _accentColor,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: _primaryColor,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
