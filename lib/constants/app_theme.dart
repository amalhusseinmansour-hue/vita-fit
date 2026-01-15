import 'package:flutter/material.dart';

/// App Theme - تحويل من React Native Theme إلى Flutter
class AppTheme {
  // الألوان الأساسية - Primary Colors
  static const Color primary = Color(0xFFFF69B4);
  static const Color primaryDark = Color(0xFFFF1493);
  static const Color primaryLight = Color(0xFFFFB6D9);

  // الألوان الثانوية - Secondary Colors
  static const Color secondary = Color(0xFFDDA0DD);
  static const Color secondaryDark = Color(0xFFBA55D3);
  static const Color secondaryLight = Color(0xFFF0D9FF);

  // ألوان إضافية - Accent Colors
  static const Color accent = Color(0xFFFFC0CB);

  // ألوان الخلفية - Background Colors
  static const Color background = Color(0xFF0A0A0F);
  static const Color backgroundLight = Color(0xFF1A1A24);
  static const Color surface = Color(0xFF252535);
  static const Color card = Color(0xFF2D2D40);

  // ألوان النصوص - Text Colors
  static const Color text = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFD0B5E0);
  static const Color textLight = Color(0xFFB8A5C7);

  // ألوان الحدود - Border Colors
  static const Color border = Color(0xFF3D3D52);

  // ألوان الحالة - Status Colors
  static const Color success = Color(0xFF98D8C8);
  static const Color warning = Color(0xFFFFB6C1);
  static const Color error = Color(0xFFFF69B4);
  static const Color info = Color(0xFF9B9EF9);

  // ألوان أنثوية إضافية - Additional Feminine Colors
  static const Color lavender = Color(0xFFE6E6FA);
  static const Color peach = Color(0xFFFFDAB9);
  static const Color mintCream = Color(0xFFF5FFFA);
  static const Color blush = Color(0xFFFFE4E1);
  static const Color lilac = Color(0xFFC8A2C8);
  static const Color rose = Color(0xFFFFE4E1);

  // الألوان الأساسية - Basic Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // المسافات - Spacing
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // نصف الأقطار - Border Radius
  static const double radiusSm = 12.0;
  static const double radiusMd = 16.0;
  static const double radiusLg = 20.0;
  static const double radiusXl = 28.0;
  static const double radiusFull = 9999.0;

  // أحجام الخطوط - Font Sizes
  static const double fontXs = 12.0;
  static const double fontSm = 14.0;
  static const double fontMd = 16.0;
  static const double fontLg = 18.0;
  static const double fontXl = 24.0;
  static const double fontXxl = 32.0;
  static const double fontXxxl = 40.0;

  // أوزان الخطوط - Font Weights
  static const FontWeight fontRegular = FontWeight.w400;
  static const FontWeight fontMedium = FontWeight.w500;
  static const FontWeight fontSemibold = FontWeight.w600;
  static const FontWeight fontBold = FontWeight.w700;

  // تدرجات الألوان - Gradients
  static const LinearGradient gradientPrimary = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradientSecondary = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradientSoft = LinearGradient(
    colors: [Color(0xFF2D2D40), Color(0xFF3D3D52)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradientPastel = LinearGradient(
    colors: [backgroundLight, surface, card],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient gradientDark = LinearGradient(
    colors: [background, backgroundLight],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // تدرجات أنثوية جديدة - New Feminine Gradients
  static const LinearGradient gradientRose = LinearGradient(
    colors: [Color(0xFFFFE4E1), Color(0xFFFFF0F5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradientLavender = LinearGradient(
    colors: [Color(0xFFF0D9FF), Color(0xFFFFDDF4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradientPeach = LinearGradient(
    colors: [Color(0xFFFFDAB9), Color(0xFFFFE4E1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradientMint = LinearGradient(
    colors: [Color(0xFFF5FFFA), Color(0xFFE0F2F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ThemeData للتطبيق - App Theme Data
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: backgroundLight,
      cardColor: card,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: error,
        onPrimary: white,
        onSecondary: white,
        onSurface: text,
        onError: white,
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: white),
        titleTextStyle: TextStyle(
          color: white,
          fontSize: fontXl,
          fontWeight: fontBold,
        ),
      ),

      // Card Theme
      cardTheme: const CardThemeData(
        color: card,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusMd)),
        ),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: white,
          elevation: 6,
          padding: const EdgeInsets.symmetric(horizontal: md, vertical: sm),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusFull),
          ),
          textStyle: const TextStyle(
            fontSize: fontMd,
            fontWeight: fontSemibold,
          ),
        ),
      ),

      // Text Theme with Noto Kufi Arabic Font
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: fontXxxl,
          fontWeight: fontBold,
          color: text,
          fontFamily: 'NotoKufiArabic',
        ),
        displayMedium: TextStyle(
          fontSize: fontXxl,
          fontWeight: fontBold,
          color: text,
          fontFamily: 'NotoKufiArabic',
        ),
        displaySmall: TextStyle(
          fontSize: fontXl,
          fontWeight: fontBold,
          color: text,
          fontFamily: 'NotoKufiArabic',
        ),
        headlineMedium: TextStyle(
          fontSize: fontLg,
          fontWeight: fontSemibold,
          color: text,
          fontFamily: 'NotoKufiArabic',
        ),
        headlineSmall: TextStyle(
          fontSize: fontMd,
          fontWeight: fontSemibold,
          color: text,
          fontFamily: 'NotoKufiArabic',
        ),
        titleLarge: TextStyle(
          fontSize: fontMd,
          fontWeight: fontMedium,
          color: text,
          fontFamily: 'NotoKufiArabic',
        ),
        bodyLarge: TextStyle(
          fontSize: fontMd,
          fontWeight: fontRegular,
          color: text,
          fontFamily: 'NotoKufiArabic',
        ),
        bodyMedium: TextStyle(
          fontSize: fontSm,
          fontWeight: fontRegular,
          color: textSecondary,
          fontFamily: 'NotoKufiArabic',
        ),
        bodySmall: TextStyle(
          fontSize: fontXs,
          fontWeight: fontRegular,
          color: textLight,
          fontFamily: 'NotoKufiArabic',
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: primary,
        size: 24,
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: md,
          vertical: sm,
        ),
      ),
    );
  }

  // Shadows
  static List<BoxShadow> get shadowSm => [
        BoxShadow(
          color: primary.withValues(alpha: 0.15),
          offset: const Offset(0, 2),
          blurRadius: 6,
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get shadowMd => [
        BoxShadow(
          color: primary.withValues(alpha: 0.25),
          offset: const Offset(0, 4),
          blurRadius: 12,
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get shadowLg => [
        BoxShadow(
          color: primary.withValues(alpha: 0.35),
          offset: const Offset(0, 8),
          blurRadius: 20,
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get shadowGlow => [
        BoxShadow(
          color: primary.withValues(alpha: 0.6),
          offset: const Offset(0, 0),
          blurRadius: 15,
          spreadRadius: 0,
        ),
      ];
}
