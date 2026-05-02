import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/calc_screen.dart';

void main() => runApp(const MetalCalcApp());

class MetalCalcApp extends StatelessWidget {
  const MetalCalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, __) {
        final manrope = GoogleFonts.manropeTextTheme();

        return MaterialApp(
          title: 'Калькулятор металла',
          debugShowCheckedModeBanner: false,
          themeMode: themeNotifier.flutterMode,

          // ── Светлая тема ──────────────────────────────────────────────────
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1565C0),
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            textTheme: manrope,
            appBarTheme: AppBarTheme(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
              elevation: 1,
              titleTextStyle: GoogleFonts.manrope(
                fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white,
              ),
            ),
            cardTheme: CardThemeData(
              elevation: 1,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              isDense: true,
            ),
          ),

          // ── Тёмная тема ───────────────────────────────────────────────────
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1565C0),
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            textTheme: manrope.apply(
              bodyColor: Colors.white,
              displayColor: Colors.white,
            ),
            appBarTheme: AppBarTheme(
              elevation: 1,
              titleTextStyle: GoogleFonts.manrope(
                fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white,
              ),
            ),
            cardTheme: CardThemeData(
              elevation: 1,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            // Явно задаём белый текст в полях ввода для тёмной темы
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              isDense: true,
              labelStyle: const TextStyle(
                  color: Color(0xFFB0BEC5), fontFamily: 'Manrope'),
              hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.3), fontFamily: 'Manrope'),
            ),
          ),

          home: const CalcScreen(),
        );
      },
    );
  }
}
