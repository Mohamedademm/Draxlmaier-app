import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Thème Premium & Moderne pour l'application Draxlmaier
class ModernTheme {
  // --- Palette de Couleurs Premium ---
  
  // Bleu Profond (Primary) - Professionnel, Confiance
  static const Color primaryBlue = Color(0xFF00828C);
  
  // Bleu Vif (Secondary/Accent) - Action, Dynamisme
  static const Color secondaryBlue = Color(0xFF00A9E0);
  
  // Gris Neutres (Backgrounds/Surface)
  static const Color background = Color(0xFFF8F9FC); // Très léger bleu-gris pour la modernité
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF0F2F5);
  
  // Textes
  static const Color textPrimary = Color(0xFF1A1C1E); // Presque noir, plus doux
  static const Color textSecondary = Color(0xFF42474E);
  static const Color textTertiary = Color(0xFF72777F);
  
  // Status (Vibrants mais pas agressifs)
  static const Color success = Color(0xFF2E7D32); // Vert forêt
  static const Color warning = Color(0xFFED6C02); // Orange brûlé
  static const Color error = Color(0xFFBA1A1A); // Rouge profond
  static const Color info = Color(0xFF0288D1); // Bleu info
  
  // Alias for compatibility
  static const Color primary = primaryBlue;

  // --- Nouveau Palette Dark Mode (Modern Midnight) ---
  static const Color darkBackground = Color(0xFF0F172A); // Slate 900 (Fond Profond)
  static const Color darkSurface = Color(0xFF1E293B); // Slate 800 (Cartes)
  static const Color darkSurfaceVariant = Color(0xFF334155); // Slate 700 (Inputs/Elements)
  static const Color darkTextPrimary = Color(0xFFF1F5F9); // Slate 100 (Texte Principal)
  static const Color darkTextSecondary = Color(0xFFCBD5E1); // Slate 300 (Texte Secondaire)
  static const Color darkTextTertiary = Color(0xFF94A3B8); // Slate 400 (Texte Tertiaire)

  /// Thème Sombre Dynamique
  static ThemeData darkTheme(BuildContext context, {Color primary = primaryBlue, Color secondary = secondaryBlue}) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Colors
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
        primary: primary,
        onPrimary: Colors.white,
        secondary: secondary,
        onSecondary: Colors.white,
        surface: darkSurface,
        onSurface: darkTextPrimary,
        background: darkBackground,
        onBackground: darkTextPrimary,
        error: error,
        onError: Colors.white,
        surfaceTint: Colors.transparent,
      ),
      
      scaffoldBackgroundColor: darkBackground,
      
      // Typography
      textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme).apply(
        bodyColor: darkTextPrimary,
        displayColor: darkTextPrimary,
      ).copyWith(
        displayLarge: const TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w700, letterSpacing: -1.0),
        displayMedium: const TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w700, letterSpacing: -0.5),
        headlineLarge: const TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w600),
        headlineMedium: const TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w600),
        titleLarge: const TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w600),
        titleMedium: const TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w500),
        bodyLarge: const TextStyle(color: darkTextSecondary, fontSize: 16),
        bodyMedium: const TextStyle(color: darkTextSecondary, fontSize: 14),
      ),
      
      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: darkTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
        iconTheme: IconThemeData(color: darkTextPrimary),
        actionsIconTheme: IconThemeData(color: darkTextPrimary),
      ),
      
      // Cards - Amélioration du contraste et des bordures
      cardTheme: CardTheme(
        color: darkSurface,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
          side: BorderSide(color: Colors.white.withOpacity(0.08), width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      
      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusM)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary.withOpacity(0.7), width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusM)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      
      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceVariant.withOpacity(0.5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: error),
        ),
        labelStyle: const TextStyle(color: darkTextSecondary),
        floatingLabelStyle: TextStyle(color: primary, fontWeight: FontWeight.w600),
        hintStyle: const TextStyle(color: darkTextTertiary),
      ),
      
      // FAB
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: secondary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusL)),
      ),
      
      // Bottom Nav
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: primary,
        unselectedItemColor: darkTextTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
      
      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: darkSurfaceVariant,
        labelStyle: const TextStyle(color: darkTextSecondary, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusL)),
        side: BorderSide.none,
      ),
      
      // Dialogs
      dialogTheme: const DialogTheme(
        backgroundColor: darkSurface,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  // --- Dimensions & Formes ---
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  
  static final BorderRadius cardRadius = BorderRadius.circular(radiusM);
  static final BorderRadius buttonRadius = BorderRadius.circular(radiusM);
  
  // --- Gradients & Shadows ---
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, secondaryBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static final List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
  
  static final List<BoxShadow> cardShadowHover = [
    BoxShadow(
      color: primaryBlue.withOpacity(0.15),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  /// Thème Clair Dynamique
  static ThemeData lightTheme(BuildContext context, {Color primary = primaryBlue, Color secondary = secondaryBlue}) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Couleurs
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        onPrimary: Colors.white,
        secondary: secondary,
        onSecondary: Colors.white,
        surface: surface,
        onSurface: textPrimary,
        background: background,
        onBackground: textPrimary,
        error: error,
        onError: Colors.white,
        surfaceTint: Colors.transparent,
      ),
      
      scaffoldBackgroundColor: background,
      
      // Typographie (Google Fonts - Inter)
      textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme).copyWith(
        displayLarge: const TextStyle(color: textPrimary, fontWeight: FontWeight.w700, letterSpacing: -1.0),
        displayMedium: const TextStyle(color: textPrimary, fontWeight: FontWeight.w700, letterSpacing: -0.5),
        headlineLarge: const TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        headlineMedium: const TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        titleLarge: const TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        titleMedium: const TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
        bodyLarge: const TextStyle(color: textSecondary, fontSize: 16),
        bodyMedium: const TextStyle(color: textSecondary, fontSize: 14),
      ),
      
      // AppBar Moderne - Updated to White Text on Primary Background
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
        iconTheme: IconThemeData(color: Colors.white),
        actionsIconTheme: IconThemeData(color: Colors.white),
      ),
      
      // Cards
      cardTheme: CardTheme(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
          side: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      
      // Boutons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusM)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusM)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      
      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: error),
        ),
        labelStyle: TextStyle(color: textSecondary.withOpacity(0.8)),
        floatingLabelStyle: TextStyle(color: primary, fontWeight: FontWeight.w600),
      ),
      
      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: secondary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusL)),
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
      
      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: surfaceVariant,
        labelStyle: const TextStyle(color: textSecondary, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusL)),
        side: BorderSide.none,
      ),
    );
  }

  static ThemeData dynamicTheme(BuildContext context, Color primary, Color secondary, bool isDark) {
    if (isDark) {
      return ThemeData.dark().copyWith(
        primaryColor: primary,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.dark,
          primary: primary,
          secondary: secondary,
        ),
      );
    }
    return lightTheme(context, primary: primary, secondary: secondary);
  }
}
