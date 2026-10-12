/// Module: knowledge_hub / core / knowledge_hub_colors.dart
/// ************************* FILE INFO *************************** ///
/// File Name: knowledge_hub_colors.dart
/// Purpose: Named, fixed colors for knowledge-hub charts and file-type badges.
///          Centralises values that were previously raw `Color(0xFF…)` literals
///          and `Colors.<x>.shade<n>` references in the S4/S5 widgets, so the UI
///          no longer hardcodes palette values inline (CR-KH §12).
/// Author: Knowticed Team
/// Created At: 11/10/2025
library;

import 'package:flutter/material.dart';

/// Fixed (theme-independent) palette for knowledge-hub charts and file-type
/// badges. These are intentionally NOT theme accessors: file-type brand colors
/// (Excel green, Word blue, PDF red …) and distinct chart-segment hues must stay
/// constant across light/dark mode.
abstract class KnowledgeHubColors {
  // ---- File-type / brand colors ----
  static const Color excelGreen = Color(0xFF107C41);
  static const Color excelGreenDark = Color(0xFF1D6F42);
  static const Color greenAccent = Color(0xFF4BB609);
  static const Color pdfRed = Color(0xFFD24726);
  static const Color red = Color(0xFFE74C3C);
  static const Color wordBlue = Color(0xFF2B579A);
  static const Color powerpointOrange = Color(0xFFE67E22);
  static const Color purple = Color(0xFF9B59B6);
  static const Color slateGrey = Color(0xFF95A5A6);
  static const Color darkSlate = Color(0xFF34495E);
  static const Color statusOrange = Color(0xFFFF814A);
  static const Color statusDarkRed = Color(0xFF991010);
  static const Color tableLightBg = Color(0xFFF7F8FA);
  static const Color tableDarkBg = Color(0xFF1E1F24);
  static const Color neutralGrey = Color(0xFF797979);

  // ---- Department chart palette (order preserved from the original list) ----
  static const List<Color> departmentChartPalette = [
    Color(0xFFE5C100),
    Color(0xFFE3D38C),
    Color(0xFFFFDE59),
    Color(0xFFA18A2D),
    Color(0xFFE5B800),
    Color(0xFF807B69),
    Color(0xFF8D8D8D),
    Color(0xFFCACACA),
    Color(0xFF6B5650),
    Color(0xFF795548),
    Color(0xFF64B5F6), // was Colors.blue.shade300
    Color(0xFF81C784), // was Colors.green.shade300
    Color(0xFFFFB74D), // was Colors.orange.shade300
    Color(0xFFBA68C8), // was Colors.purple.shade300
    Color(0xFF4DB6AC), // was Colors.teal.shade300
  ];

  // ---- Other chart shades ----
  static const Color chartYellow = Color(0xFFFBC02D); // was Colors.yellow.shade700
  static const Color chartGreyLight = Color(0xFFEEEEEE); // was Colors.grey.shade200
  static const Color chartGreyDark = Color(0xFF424242); // was Colors.grey.shade800

  // ---- Approvals / dashboard palette (s6/s7/s8), values preserved ----
  static const Color brownMauve = Color(0xFF6B5650);
  static const Color brown = Color(0xFF795548);
  static const Color khakiGrey = Color(0xFF807B69);
  static const Color grey8d = Color(0xFF8D8D8D);
  static const Color greyCaca = Color(0xFFCACACA);
  static const Color olive = Color(0xFFA18A2D);
  static const Color sand = Color(0xFFE3D38C);
  static const Color gold = Color(0xFFE5B800);
  static const Color goldBright = Color(0xFFE5C100);
  static const Color yellowBright = Color(0xFFFFDE59);
  static const Color slateBlueGrey = Color(0xFF768396);
  static const Color redDark = Color(0xFF931010);
  static const Color redCrimson = Color(0xFFBC1F1F);
  static const Color redBright = Color(0xFFDF1C1C);
  static const Color redLight = Color(0xFFFF6B6B);
}
