import 'package:flutter/material.dart';

class AppColors {
  // ── Brand palette — richer, deeper tones ──────
  static const blue        = Color(0xFF1B4FE4);   // deeper royal blue
  static const blueLight   = Color(0xFF4F79F5);   // softer blue
  static const blueDark    = Color(0xFF1340C0);   // pressed state
  static const indigo      = Color(0xFF4338CA);   // rich indigo
  static const indigoLight = Color(0xFF6366F1);
  static const violet      = Color(0xFF7C3AED);   // vibrant violet
  static const cyan        = Color(0xFF0284C7);   // ocean blue-cyan
  static const cyanLight   = Color(0xFF38BDF8);
  static const teal        = Color(0xFF0D9488);   // warm teal
  static const green       = Color(0xFF059669);   // emerald
  static const greenLight  = Color(0xFF10B981);
  static const amber       = Color(0xFFD97706);   // golden amber
  static const amberLight  = Color(0xFFF59E0B);
  static const orange      = Color(0xFFEA580C);   // deep orange
  static const red         = Color(0xFFDC2626);   // strong red
  static const redLight    = Color(0xFFEF4444);
  static const redBg       = Color(0xFFFEF2F2);
  static const redBorder   = Color(0xFFFCA5A5);
  static const purple      = Color(0xFF7C3AED);
  static const pink        = Color(0xFFDB2777);

  // ── Light mode — warm white, not cold grey ─────
  static const lBg         = Color(0xFFF0F2FA);   // blue-tinted light background
  static const lSurface    = Color(0xFFFFFFFF);
  static const lSurface2   = Color(0xFFF0F3FF);   // light blue tint
  static const lBorder     = Color(0xFFDDE3F4);   // blue-tinted border
  static const lBorderMid  = Color(0xFFC3CCEB);
  static const lText1      = Color(0xFF0D1340);   // navy-black
  static const lText2      = Color(0xFF1A2166);   // deep navy
  static const lText3      = Color(0xFF4A5280);   // blue-grey
  static const lText4      = Color(0xFF8892B8);   // muted
  static const lHint       = Color(0xFFBCC4E0);

  // ── Dark mode — deep navy, not pure black ──────
  static const dBg         = Color(0xFF080D1A);   // near-black navy
  static const dSurface    = Color(0xFF0F1629);   // dark navy card
  static const dSurface2   = Color(0xFF161F38);   // slightly lighter
  static const dBorder     = Color(0xFF1E2A45);
  static const dBorderMid  = Color(0xFF293857);
  static const dText1      = Color(0xFFEEF2FF);   // soft white
  static const dText2      = Color(0xFFD4DCFF);   // lavender white
  static const dText3      = Color(0xFF8892CC);
  static const dText4      = Color(0xFF4F5A8A);
  static const dHint       = Color(0xFF2A3558);
}

class AppTheme {
  // ── Gradients — richer, more saturated ────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1B4FE4), Color(0xFF5B21B6)],  // blue → deep violet
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1340C0), Color(0xFF3B0FA0)],  // dark blue → violet
  );

  static const LinearGradient pageGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF8FAFF), Color(0xFFF0F4FF)],
  );

  static const LinearGradient pageGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0C1224), Color(0xFF131C34)],
  );

  static const LinearGradient greenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF059669), Color(0xFF0284C7)],  // emerald → ocean
  );

  static const LinearGradient amberGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD97706), Color(0xFFEA580C)],  // gold → orange
  );

  static const LinearGradient cyanGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0284C7), Color(0xFF0D9488)],  // blue → teal
  );

  static const LinearGradient violetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],  // violet → pink
  );

  // ── Shadows — more depth ───────────────────────
  static List<BoxShadow> blueShadow = [
    BoxShadow(
      color: const Color(0xFF1B4FE4).withValues(alpha: 0.35),
      blurRadius: 24,
      spreadRadius: 0,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> greenShadow = [
    BoxShadow(
      color: const Color(0xFF059669).withValues(alpha: 0.30),
      blurRadius: 20,
      spreadRadius: 0,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: const Color(0xFF1B4FE4).withValues(alpha: 0.08),
      blurRadius: 24,
      spreadRadius: 0,
      offset: const Offset(0, 6),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 10,
      spreadRadius: 0,
      offset: const Offset(0, 3),
    ),
  ];

  static List<BoxShadow> cardShadowDark = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.35),
      blurRadius: 20,
      spreadRadius: 0,
      offset: const Offset(0, 6),
    ),
  ];

  // ── Glass morphism shadows ──────────────────────
  static List<BoxShadow> glassShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 24,
      spreadRadius: 0,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 12,
      spreadRadius: 0,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> glassShadowDark = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.40),
      blurRadius: 28,
      spreadRadius: 0,
      offset: const Offset(0, 12),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.15),
      blurRadius: 16,
      spreadRadius: 0,
      offset: const Offset(0, 6),
    ),
  ];

  // ── Flutter ThemeData ──────────────────────────
  static ThemeData light() => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.lBg,
        colorScheme: const ColorScheme.light(
          primary: AppColors.blue,
          secondary: AppColors.teal,
          surface: AppColors.lSurface,
          tertiary: AppColors.violet,
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: AppColors.blue,
          selectionColor: Color(0x441B4FE4),
          selectionHandleColor: AppColors.blue,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.lSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.lBorder),
          ),
        ),
      );

  static ThemeData dark() => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.dBg,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.blueLight,
          secondary: AppColors.teal,
          surface: AppColors.dSurface,
          tertiary: AppColors.indigoLight,
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: AppColors.blueLight,
          selectionColor: Color(0x444F79F5),
          selectionHandleColor: AppColors.blueLight,
        ),
      );
}

// ── Context extension ──────────────────────────────
extension AppColorsX on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get cBg        => isDark ? AppColors.dBg        : AppColors.lBg;
  Color get cSurface   => isDark ? AppColors.dSurface   : AppColors.lSurface;
  Color get cSurface2  => isDark ? AppColors.dSurface2  : AppColors.lSurface2;
  Color get cBorder    => isDark ? AppColors.dBorder    : AppColors.lBorder;
  Color get cBorderMid => isDark ? AppColors.dBorderMid : AppColors.lBorderMid;
  Color get cText1     => isDark ? AppColors.dText1     : AppColors.lText1;
  Color get cText2     => isDark ? AppColors.dText2     : AppColors.lText2;
  Color get cText3     => isDark ? AppColors.dText3     : AppColors.lText3;
  Color get cText4     => isDark ? AppColors.dText4     : AppColors.lText4;
  Color get cHint      => isDark ? AppColors.dHint      : AppColors.lHint;

  List<BoxShadow> get cardShadow =>
      isDark ? AppTheme.cardShadowDark : AppTheme.cardShadow;
}
