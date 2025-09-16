import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextTheme get tipografia {
  return TextTheme(
    // --- Estilos para Poppins ---
    headlineLarge: GoogleFonts.poppins(
      fontSize: 36,
      fontWeight: FontWeight.bold,
    ),
    bodyLarge: GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.w300, // Light
    ),
    bodySmall: GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.w200, // Extra-light
    ),

    // --- Estilos para Quicksand ---
    displayLarge: GoogleFonts.quicksand(
      fontSize: 32,
      fontWeight: FontWeight.bold,
    ),
    displayMedium: GoogleFonts.quicksand(
      fontSize: 24,
      fontWeight: FontWeight.w400, // Regular
    ),
    labelLarge: GoogleFonts.quicksand(
      fontSize: 22,
      fontWeight: FontWeight.w400, // Regular
    ),
    labelSmall: GoogleFonts.quicksand(
      fontSize: 18,
      fontWeight: FontWeight.w300, // Light
    ),
  );
}