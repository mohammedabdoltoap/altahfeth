import 'package:flutter/material.dart';
import 'color.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final baseScheme = ColorScheme.fromSeed(seedColor: kPrimaryColor).copyWith(
      primary: kPrimaryColor,
      secondary: kAccentYellow,
      onPrimary: Colors.white, // نص وأيقونات فوق الأزرار الأساسية
      surface: kSurfaceWhite,
      background: kBackground,
    );

    return ThemeData(
      fontFamily: 'Cairo', // ← نختار خط جميل ومقروء
      primaryColor: kPrimaryColor,
      scaffoldBackgroundColor: kBackground,
      colorScheme: baseScheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        bodyMedium: TextStyle(fontSize: 16, color: Colors.black87),
        titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        bodySmall: TextStyle(fontSize: 13, color: Colors.black54),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          foregroundColor: baseScheme.onPrimary,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: kSurfaceWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: kPrimaryColor.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: kPrimaryColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kPrimaryColor, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.8),
        ),
        hintStyle: const TextStyle(color: Colors.black45),
        labelStyle: const TextStyle(color: Colors.black87),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: kPrimaryColor,
        contentTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}
