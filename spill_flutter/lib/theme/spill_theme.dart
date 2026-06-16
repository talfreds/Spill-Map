import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SpillTheme {
  static const Color background = Color(0xFFF4F4F0);

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.black,
        brightness: Brightness.light,
      ),
    );

    final bodyText = GoogleFonts.spaceMonoTextTheme(base.textTheme);

    return base.copyWith(
      textTheme: bodyText.copyWith(
        displayLarge: GoogleFonts.archivoBlack(textStyle: bodyText.displayLarge),
        displayMedium:
            GoogleFonts.archivoBlack(textStyle: bodyText.displayMedium),
        displaySmall: GoogleFonts.archivoBlack(textStyle: bodyText.displaySmall),
        headlineLarge:
            GoogleFonts.archivoBlack(textStyle: bodyText.headlineLarge),
        headlineMedium:
            GoogleFonts.archivoBlack(textStyle: bodyText.headlineMedium),
        headlineSmall:
            GoogleFonts.archivoBlack(textStyle: bodyText.headlineSmall),
        titleLarge: GoogleFonts.archivoBlack(textStyle: bodyText.titleLarge),
      ),
    );
  }
}
