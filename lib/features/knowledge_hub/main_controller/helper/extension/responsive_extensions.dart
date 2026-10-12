/// Module: knowledge_hub / core/extension/responsive_extensions.dart
/// ************************* FILE INFO *************************** ///
/// File Name: responsive_extensions.dart
/// Purpose: Responsive extensions — knowledge_hub core/widgets.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:flutter/material.dart';

extension BuildContextResponsiveExtensions on BuildContext {
  bool get isLandscape =>
      MediaQuery.of(this).orientation == Orientation.landscape;
  bool get isPortrait =>
      MediaQuery.of(this).orientation == Orientation.portrait;

  // You'll need to define what constitutes a "tablet" based on screen width.
  // These are common breakpoints, but you might adjust them.
  bool get isTablet {
    final double diagonal = MediaQuery.of(this).size.longestSide;
    // A common heuristic: devices with a diagonal of 600dp or more are often considered tablets.
    return diagonal >= 912;
  }

  // Another common way to define tablet: based on shortest side width
  bool get isSmallTablet {
    final double shortestSide = MediaQuery.of(this).size.shortestSide;
    return shortestSide >= 912 && shortestSide < 1024;
  }

  bool get isLargeTablet {
    final double shortestSide = MediaQuery.of(this).size.shortestSide;
    return shortestSide >= 1024;
  }

  bool get isPhone => !isTablet; // If it's not a tablet, assume it's a phone.

  bool get isDarkMode =>
      MediaQuery.of(this).platformBrightness == Brightness.dark;
}
