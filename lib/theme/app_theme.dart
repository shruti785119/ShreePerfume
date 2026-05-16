import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF1FD58B);
  static const Color secondaryColor = Color(0xFFE55767);
  static const Color textColor = Color(0xFF1D2740);
  static const Color mutedTextColor = Color(0xFF7B8AA5);
  static const Color panel = Colors.white;
  static const Color panelSoft = Color(0xFFF8FBFF);
  static const Color border = Color(0xFFE1E8F2);
  static const Color rose = Color(0xFFE55767);
  static const Color night = Color(0xFF0E1726);
  static const Color deepForest = Color(0xFF10231F);
  static const String fontFamily = 'ShreeSans';
  static const String serifFontFamily = 'ShreeSerif';

  static const LinearGradient appGradient = LinearGradient(
    colors: [Color(0xFFF7FAFF), Color(0xFFFFFFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF1A233B), Color(0xFF6E4A1E), Color(0xFF281A13)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGlowGradient = LinearGradient(
    colors: [Color(0xFFF7FAFF), Color(0xFFFFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFE1A6), Color(0xFFE0AF55)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.white,
    fontFamily: fontFamily,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: Colors.white,
      error: Colors.redAccent,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textColor,
    ),
    textTheme: const TextTheme(
      displayMedium: TextStyle(
        fontFamily: serifFontFamily,
        color: textColor,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: TextStyle(
        fontFamily: serifFontFamily,
        color: textColor,
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: TextStyle(
        fontFamily: fontFamily,
        color: textColor,
        fontWeight: FontWeight.w800,
      ),
      titleLarge: TextStyle(
        fontFamily: fontFamily,
        color: textColor,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: TextStyle(
        fontFamily: fontFamily,
        color: textColor,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: TextStyle(
        fontFamily: fontFamily,
        color: textColor,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        color: mutedTextColor,
      ),
      labelLarge: TextStyle(
        fontFamily: fontFamily,
        color: textColor,
        fontWeight: FontWeight.w700,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: textColor),
      titleTextStyle: TextStyle(
        fontFamily: fontFamily,
        color: textColor,
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: panelSoft,
      hintStyle: const TextStyle(
        fontFamily: fontFamily,
        color: mutedTextColor,
        fontSize: 14,
      ),
      prefixIconColor: const Color(0xFF97A7BC),
      suffixIconColor: mutedTextColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primaryColor, width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: textColor,
        side: const BorderSide(color: border),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: primaryColor,
      contentTextStyle: const TextStyle(
        fontFamily: fontFamily,
        color: Colors.white,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
