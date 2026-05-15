/// Student Numbers: 223064473, 223023603, 221003431, 220031298, 220024412
/// Student Names  : LM Mosoetsa, A Mbonambi, D Hlalele, NA Pesa, MP Lephole
/// Question: App Constants and Theme
library;

// ============================================================
// utils/app_constants.dart
// Central place for app-wide constants, theme, and colours
// ============================================================

import 'package:flutter/material.dart';

class AppConstants {
  // ─── Supabase Configuration ───────────────────────────────────
  // Replace these with your actual Supabase project URL and anon key
  static const String supabaseUrl = 'https://odjqviozlukdqdloyvkp.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9kanF2aW96bHVrZHFkbG95dmtwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg0OTcwMDIsImV4cCI6MjA5NDA3MzAwMn0.0BcV-B0ejCEblmClFJ_IZykueHMKes4siPof5U1IQ3o';

  // ─── Module options per academic level ────────────────────────
  static const Map<String, List<String>> modulesByLevel = {
    '1st Year': [
      'CIS116C - Computer Literacy',
      'PRG116C - Programming Fundamentals',
      'DBA116C - Database Administration I',
      'MIS116C - Management Info Systems',
      'NET116C - Networking Fundamentals',
    ],
    '2nd Year': [
      'PRG216C - Object Oriented Programming',
      'DBA216C - Database Administration II',
      'WEB216C - Web Development I',
      'NET216C - Network Administration',
      'SOD216C - Systems Analysis & Design',
    ],
    '3rd Year': [
      'TPG316C - Technical Programming III',
      'SOD316C - Software Development III',
      'PRJ316C - Project Management',
      'SEC316C - Information Security',
      'WEB316C - Web Development III',
    ],
  };

  static const List<String> academicLevels = [
    '1st Year',
    '2nd Year',
    '3rd Year',
  ];

  static const List<int> yearsOfStudy = [1, 2, 3];
}

// ─── App Theme ────────────────────────────────────────────────
class AppTheme {
  static const Color primaryColor = Color(0xFF1A237E); // Deep Indigo
  static const Color accentColor = Color(0xFF0D47A1);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;
  static const Color pendingColor = Color(0xFFF57C00); // Orange
  static const Color approvedColor = Color(0xFF2E7D32); // Green
  static const Color rejectedColor = Color(0xFFC62828); // Red

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: backgroundColor,

      // AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // ElevatedButton theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // InputDecoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

// ─── Status Badge Helper ──────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  Color get _color {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppTheme.approvedColor;
      case 'rejected':
        return AppTheme.rejectedColor;
      default:
        return AppTheme.pendingColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color, width: 1),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: _color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
