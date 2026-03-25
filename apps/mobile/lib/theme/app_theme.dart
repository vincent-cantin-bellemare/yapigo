import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand gradient colors (from logo: k-a-i-i-a-k)
  static const Color teal = Color(0xFF00D4AA);
  static const Color cyan = Color(0xFF00BCD4);
  static const Color ocean = Color(0xFF0097A7);
  static const Color deepTeal = Color(0xFF00838F);
  static const Color navyBlue = Color(0xFF1B4A6A);
  static const Color navy = Color(0xFF1B2A4A);

  // Neutral palette
  static const Color cream = Color(0xFFFBF7F2);
  static const Color slateGrey = Color(0xFF64748B);
  static const Color border = Color(0xFFCBD5E1);

  // Semantic colors
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF10B981);

  // Dark mode surfaces
  static const Color darkScaffold = Color(0xFF1A1A2E);
  static const Color darkSurface = Color(0xFF242438);
  static const Color darkBorder = Color(0xFF1E3A5F);

  // Theme-aware helpers
  static Color cardColor(BuildContext context) =>
      Theme.of(context).colorScheme.surface;
  static Color scaffoldColor(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;
  static Color textColor(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  static Color navyIcon(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF7B9BD4)
          : navy;

  static Color secondaryText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF94A3B8)
          : slateGrey;

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  // Brand gradient (for decorative use)
  static const List<Color> brandGradient = [teal, cyan, ocean, navy];

  // Reactive theme mode switching
  static final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier(ThemeMode.light);

  static void toggleTheme() {
    themeMode.value =
        themeMode.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }

  // ---------- Light Theme ----------

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: cream,
      colorScheme: ColorScheme.light(
        primary: ocean,
        secondary: navy,
        tertiary: teal,
        surface: Colors.white,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: navy,
        onError: Colors.white,
      ),
      textTheme: _buildTextTheme(navy, slateGrey),
      appBarTheme: AppBarTheme(
        backgroundColor: cream,
        foregroundColor: navy,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: navy,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ocean,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: navy,
          side: const BorderSide(color: navy, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: slateGrey,
          textStyle: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cream,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: cyan, width: 2),
        ),
        hintStyle: GoogleFonts.dmSans(
          color: slateGrey,
          fontSize: 16,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: border.withValues(alpha: 0.5)),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: ocean,
        unselectedItemColor: slateGrey,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle:
            GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 12),
      ),
    );
  }

  // ---------- Dark Theme ----------

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: darkScaffold,
      colorScheme: ColorScheme.dark(
        primary: teal,
        secondary: const Color(0xFF38BDF8),
        tertiary: const Color(0xFF5EEAD4),
        surface: darkSurface,
        error: const Color(0xFFF87171),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: const Color(0xFFF1F5F9),
        onError: Colors.white,
      ),
      textTheme: _buildTextTheme(
          const Color(0xFFF1F5F9), const Color(0xFF94A3B8)),
      appBarTheme: AppBarTheme(
        backgroundColor: darkScaffold,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: teal,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(
              color: Colors.white.withValues(alpha: 0.4), width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.white70,
          textStyle: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: teal, width: 2),
        ),
        hintStyle: GoogleFonts.dmSans(
          color: Colors.white54,
          fontSize: 16,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: darkBorder),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: teal,
        unselectedItemColor: const Color(0xFF64748B),
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle:
            GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 12),
      ),
    );
  }

  // ---------- Shared text theme builder ----------

  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    return TextTheme(
      headlineLarge: GoogleFonts.nunito(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: primary,
      ),
      headlineMedium: GoogleFonts.nunito(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      headlineSmall: GoogleFonts.nunito(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      titleLarge: GoogleFonts.nunito(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      titleMedium: GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      bodyLarge: GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: primary,
      ),
      bodyMedium: GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: primary,
      ),
      bodySmall: GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: secondary,
      ),
      labelLarge: GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
    );
  }
}
