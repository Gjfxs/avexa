import 'package:flutter/material.dart';

/// ============================================================
/// AVEXA DESIGN SYSTEM
/// ============================================================

/// ============================================================
/// BRAND COLORS
/// ============================================================

const neonBlue = Color(0xFF149BFF);

const blueDark = Color(0xFF0B5DB7);

/// ============================================================
/// TRADING COLORS
/// ============================================================

const neonGreen = Color(0xFF00FFA3);

const neonRed = Color(0xFFFF4D67);

const neonYellow = Color(0xFFFFC857);

/// ============================================================
/// DARK COLORS
/// ============================================================

const bgColor = Color(0xFF070B16);

const cardDark = Color(0xFF0D1628);

const cardElevated = Color(0xFF101C31);

const textPrimary = Color(0xFFF8FAFC);

const textSecondary = Color(0xFF9CA8B8);

const textMuted = Color(0xFF667386);

const borderColor = Color(0xFF1C2940);

/// ============================================================
/// LIGHT COLORS
/// ============================================================

const lightBgColor = Color(0xFFF5F7FB);

const lightCard = Color(0xFFFFFFFF);

const lightCardElevated = Color(0xFFF0F4F9);

const lightTextPrimary = Color(0xFF101828);

const lightTextSecondary = Color(0xFF667085);

const lightTextMuted = Color(0xFF98A2B3);

const lightBorderColor = Color(0xFFD9E1EC);

/// ============================================================
/// AVEXA THEME COLORS
/// ============================================================

@immutable
class AvexaColors extends ThemeExtension<AvexaColors> {
  final Color background;
  final Color card;
  final Color elevatedCard;
  final Color primaryText;
  final Color secondaryText;
  final Color mutedText;
  final Color border;

  const AvexaColors({
    required this.background,
    required this.card,
    required this.elevatedCard,
    required this.primaryText,
    required this.secondaryText,
    required this.mutedText,
    required this.border,
  });

  static const dark = AvexaColors(
    background: bgColor,
    card: cardDark,
    elevatedCard: cardElevated,
    primaryText: textPrimary,
    secondaryText: textSecondary,
    mutedText: textMuted,
    border: borderColor,
  );

  static const light = AvexaColors(
    background: lightBgColor,
    card: lightCard,
    elevatedCard: lightCardElevated,
    primaryText: lightTextPrimary,
    secondaryText: lightTextSecondary,
    mutedText: lightTextMuted,
    border: lightBorderColor,
  );

  @override
  AvexaColors copyWith({
    Color? background,
    Color? card,
    Color? elevatedCard,
    Color? primaryText,
    Color? secondaryText,
    Color? mutedText,
    Color? border,
  }) {
    return AvexaColors(
      background:
          background ?? this.background,
      card:
          card ?? this.card,
      elevatedCard:
          elevatedCard ?? this.elevatedCard,
      primaryText:
          primaryText ?? this.primaryText,
      secondaryText:
          secondaryText ?? this.secondaryText,
      mutedText:
          mutedText ?? this.mutedText,
      border:
          border ?? this.border,
    );
  }

  @override
  AvexaColors lerp(
    covariant ThemeExtension<AvexaColors>? other,
    double t,
  ) {
    if (other is! AvexaColors) {
      return this;
    }

    return AvexaColors(
      background:
          Color.lerp(
            background,
            other.background,
            t,
          )!,
      card:
          Color.lerp(
            card,
            other.card,
            t,
          )!,
      elevatedCard:
          Color.lerp(
            elevatedCard,
            other.elevatedCard,
            t,
          )!,
      primaryText:
          Color.lerp(
            primaryText,
            other.primaryText,
            t,
          )!,
      secondaryText:
          Color.lerp(
            secondaryText,
            other.secondaryText,
            t,
          )!,
      mutedText:
          Color.lerp(
            mutedText,
            other.mutedText,
            t,
          )!,
      border:
          Color.lerp(
            border,
            other.border,
            t,
          )!,
    );
  }
}

/// ============================================================
/// DARK THEME
/// ============================================================

ThemeData buildDarkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgColor,

    extensions: const [
      AvexaColors.dark,
    ],

    colorScheme: const ColorScheme.dark(
      primary: neonBlue,
      secondary: neonBlue,
      surface: cardDark,
      error: neonRed,
    ),

    textTheme: ThemeData.dark().textTheme.apply(
      bodyColor: textPrimary,
      displayColor: textPrimary,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: bgColor,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      foregroundColor: textPrimary,
    ),

    cardTheme: CardThemeData(
      color: cardDark,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: const BorderSide(
          color: borderColor,
          width: 1,
        ),
      ),
    ),

    bottomNavigationBarTheme:
        const BottomNavigationBarThemeData(
      backgroundColor: Color(0xff080D19),
      selectedItemColor: neonBlue,
      unselectedItemColor: textMuted,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: neonBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: textPrimary,
        side: const BorderSide(
          color: borderColor,
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardDark,
      hintStyle: const TextStyle(
        color: textMuted,
      ),
      labelStyle: const TextStyle(
        color: textSecondary,
      ),
      prefixIconColor: textSecondary,
      suffixIconColor: textSecondary,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: borderColor,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: neonBlue,
          width: 1.5,
        ),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    ),

    dividerTheme: const DividerThemeData(
      color: borderColor,
      thickness: 1,
      space: 1,
    ),

    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: textSecondary,
      ),
    ),
  );
}

/// ============================================================
/// LIGHT THEME
/// ============================================================

ThemeData buildLightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBgColor,

    extensions: const [
      AvexaColors.light,
    ],

    colorScheme: const ColorScheme.light(
      primary: neonBlue,
      secondary: neonBlue,
      surface: lightCard,
      error: neonRed,
    ),

    textTheme: ThemeData.light().textTheme.apply(
      bodyColor: lightTextPrimary,
      displayColor: lightTextPrimary,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: lightBgColor,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      foregroundColor: lightTextPrimary,
    ),

    cardTheme: CardThemeData(
      color: lightCard,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: const BorderSide(
          color: lightBorderColor,
          width: 1,
        ),
      ),
    ),

    bottomNavigationBarTheme:
        const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: neonBlue,
      unselectedItemColor: lightTextMuted,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: neonBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: lightTextPrimary,
        side: const BorderSide(
          color: lightBorderColor,
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightCard,
      hintStyle: const TextStyle(
        color: lightTextMuted,
      ),
      labelStyle: const TextStyle(
        color: lightTextSecondary,
      ),
      prefixIconColor: lightTextSecondary,
      suffixIconColor: lightTextSecondary,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: lightBorderColor,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: neonBlue,
          width: 1.5,
        ),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    ),

    dividerTheme: const DividerThemeData(
      color: lightBorderColor,
      thickness: 1,
      space: 1,
    ),

    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: lightTextSecondary,
      ),
    ),
  );
}