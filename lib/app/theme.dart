import 'package:flutter/material.dart';

/// Paleta institucional DCC (constitución, principio 9): blanco, naranja,
/// azul — fija, sin variaciones por pantalla.
class DccColors {
  DccColors._();

  static const white = Color(0xFFFFFFFF);
  static const orange = Color(0xFFF37021);
  static const blue = Color(0xFF00337F);
}

ThemeData buildDccTheme() {
  const colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: DccColors.blue,
    onPrimary: DccColors.white,
    secondary: DccColors.orange,
    onSecondary: DccColors.white,
    error: Color(0xFFB00020),
    onError: DccColors.white,
    surface: DccColors.white,
    onSurface: DccColors.blue,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: DccColors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: DccColors.blue,
      foregroundColor: DccColors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: DccColors.orange,
        foregroundColor: DccColors.white,
      ),
    ),
  );
}
