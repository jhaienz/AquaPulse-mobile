import 'package:flutter/material.dart';

/// Design tokens from the figma mockup: deep navy/teal dark UI,
/// with status colors green=normal, amber=warning, red=critical.
class AppColors {
  // Base surfaces
  static const bg = Color(0xFF0B1519); // deep navy-teal page background
  static const surface = Color(0xFF12212A); // card background
  static const surfaceAlt = Color(0xFF1A2E38); // raised/pill background
  static const border = Color(0xFF25404C);

  // Text
  static const textPrimary = Color(0xFFE6EEF0);
  static const textSecondary = Color(0xFF8FA6AE);

  // Brand accent (teal-green from nav + primary buttons)
  static const accent = Color(0xFF4CAF7D);

  // Status
  static const normal = Color(0xFF4CAF7D); // green
  static const warning = Color(0xFFE0A94C); // amber
  static const critical = Color(0xFFE05C4C); // red
}

/// Water-quality status of an enclosure, mapped to the figma status colors.
enum EnclosureStatus { normal, warning, critical }

extension EnclosureStatusColor on EnclosureStatus {
  Color get color => switch (this) {
        EnclosureStatus.normal => AppColors.normal,
        EnclosureStatus.warning => AppColors.warning,
        EnclosureStatus.critical => AppColors.critical,
      };

  String get label => switch (this) {
        EnclosureStatus.normal => 'NORMAL',
        EnclosureStatus.warning => 'WARNING',
        EnclosureStatus.critical => 'CRITICAL',
      };
}

ThemeData buildTheme() {
  const scheme = ColorScheme.dark(
    surface: AppColors.surface,
    primary: AppColors.accent,
    error: AppColors.critical,
    onPrimary: Colors.white,
    onSurface: AppColors.textPrimary,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.bg,
    fontFamily: 'Roboto',
    cardTheme: const CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.accent.withValues(alpha: 0.18),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 11, color: AppColors.textSecondary),
      ),
    ),
  );
}
