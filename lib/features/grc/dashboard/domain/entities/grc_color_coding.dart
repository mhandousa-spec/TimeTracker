/// Module: GRC — Dashboard
///
///*************************** FILE INFO ****************************///
/// File Name: grc_color_coding.dart
/// Purpose: The "Color Coding" dialog's settings (Figma: Choose Category,
///          Choose Policy, Choose Colors, Increment, Color Coding) and the
///          score → colour rule they produce.
/// Author: Amr Mesbah
/// Created: 16/9/2026
///
/// How a rule colours a 0–100 score: the range is cut into bands of
/// [GrcColorRule.increment] points (25 → 0–24, 25–49, 50–74, 75–100) and
/// each band takes a colour spread evenly across the chosen palette, low
/// band first ([GrcColorOrder.lowToHigh]) or reversed.
///
/// Category decides which cards a rule paints:
/// * policy  → Policy Compliance bars (one policy, or all);
/// * control → Departments, Department Performance, Compliance Timeline
///   (applies when those cards are filtered to the rule's policy, or always
///   when the rule is for all policies).
///
/// Rules live in the dashboard cubit for the session; nothing is written to
/// Firestore (no schema for it exists yet).
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

enum GrcColorCategory { policy, control }

enum GrcColorPalette { trafficLight, warm, primary }

enum GrcColorOrder { lowToHigh, highToLow }

extension GrcColorPaletteX on GrcColorPalette {
  /// Low score first.
  List<Color> get colors {
    switch (this) {
      case GrcColorPalette.trafficLight:
        return [AppColors.red, AppColors.orange, AppColors.green];
      case GrcColorPalette.warm:
        return const [
          AppColors.chartDarkRed,
          AppColors.chartOrange,
          AppColors.chartGold,
        ];
      case GrcColorPalette.primary:
        return [
          AppColors.primary.withOpacity(0.35),
          AppColors.primary.withOpacity(0.65),
          AppColors.primary,
        ];
    }
  }
}

class GrcColorRule {
  final GrcColorCategory category;

  /// Null = every policy.
  final String? policyId;
  final GrcColorPalette palette;

  /// Band width in score points: 10, 20, 25 or 50.
  final int increment;
  final GrcColorOrder order;

  const GrcColorRule({
    required this.category,
    this.policyId,
    this.palette = GrcColorPalette.trafficLight,
    this.increment = 25,
    this.order = GrcColorOrder.lowToHigh,
  });

  static const List<int> increments = [10, 20, 25, 50];

  bool appliesTo(String? policyId) =>
      this.policyId == null || this.policyId == policyId;

  Color colorFor(double score) {
    var colors = palette.colors;
    if (order == GrcColorOrder.highToLow) colors = colors.reversed.toList();
    final bands = (100 / increment).ceil();
    final band = (score.clamp(0, 100) / increment).floor().clamp(0, bands - 1);
    if (bands <= 1) return colors.last;
    final index = (band / (bands - 1) * (colors.length - 1)).round();
    return colors[index];
  }
}

/// The dashboard's default banding before anyone opens the dialog: the
/// Figma frame paints Policy Compliance red / orange / green.
const GrcColorRule kDefaultPolicyColorRule = GrcColorRule(
  category: GrcColorCategory.policy,
  palette: GrcColorPalette.trafficLight,
  increment: 25,
);
