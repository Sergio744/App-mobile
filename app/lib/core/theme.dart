import 'package:flutter/material.dart';

/// Palette « terre et raphia » : ocre, terracotta, vert profond sur un fond
/// crème. L'objectif est de rappeler les enduits de terre et les tissus du
/// sud-Bénin, sans tomber dans le folklore.
class GbeColors {
  const GbeColors._();

  static const Color cream = Color(0xFFFDF6EC);
  static const Color sand = Color(0xFFF1E4D1);
  static const Color surface = Color(0xFFFFFCF7);
  static const Color ink = Color(0xFF221C17);
  static const Color inkSoft = Color(0xFF6B5D52);
  static const Color terracotta = Color(0xFFC4623F);
  static const Color ochre = Color(0xFFD89B4A);
  static const Color forest = Color(0xFF2E6B55);
  static const Color plum = Color(0xFF7B5A86);
  static const Color success = Color(0xFF4A8B5F);
  static const Color warning = Color(0xFFC98A2E);
  static const Color danger = Color(0xFFB3564F);
}

class GbeTheme {
  const GbeTheme._();

  /// Rayon de courbure commun : des angles doux, jamais ronds à l'excès.
  static const double radius = 22;

  static ThemeData build() {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: GbeColors.terracotta,
      brightness: Brightness.light,
    ).copyWith(
      surface: GbeColors.cream,
      primary: GbeColors.terracotta,
      secondary: GbeColors.forest,
      onSurface: GbeColors.ink,
    );

    final TextTheme text = _textTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: GbeColors.cream,
      textTheme: text,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: GbeColors.cream,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
        iconTheme: const IconThemeData(color: GbeColors.ink),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: GbeColors.terracotta,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          textStyle: text.titleMedium?.copyWith(color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: GbeColors.ink,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: GbeColors.sand, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: GbeColors.sand,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: GbeColors.ink,
        contentTextStyle: text.bodyMedium?.copyWith(color: GbeColors.cream),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: GbeColors.surface,
        selectedItemColor: GbeColors.terracotta,
        unselectedItemColor: GbeColors.inkSoft,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  static TextTheme _textTheme() {
    // Pour une démo publique, remplacer par une police serif (Fraunces,
    // Literata…) pour les titres : c'est le détail qui fait « produit fini ».
    const String? serif = null;
    return const TextTheme(
      displaySmall: TextStyle(
        fontFamily: serif,
        fontSize: 38,
        height: 1.1,
        fontWeight: FontWeight.w600,
        color: GbeColors.ink,
        letterSpacing: -0.8,
      ),
      headlineMedium: TextStyle(
        fontFamily: serif,
        fontSize: 28,
        height: 1.2,
        fontWeight: FontWeight.w600,
        color: GbeColors.ink,
        letterSpacing: -0.4,
      ),
      titleLarge: TextStyle(
        fontFamily: serif,
        fontSize: 22,
        height: 1.25,
        fontWeight: FontWeight.w600,
        color: GbeColors.ink,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        height: 1.3,
        fontWeight: FontWeight.w600,
        color: GbeColors.ink,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        height: 1.5,
        color: GbeColors.ink,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 1.5,
        color: GbeColors.inkSoft,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: GbeColors.ink,
        letterSpacing: 0.1,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
        color: GbeColors.inkSoft,
      ),
    );
  }
}
