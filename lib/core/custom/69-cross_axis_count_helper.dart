import 'dart:io';

import 'package:flutter/material.dart';

/// Module: services_management_module
/// Description: Responsive cross-axis-count helpers for grid views (tablet
///              landscape/portrait breakpoints for the services module).
/// Author: Knowticed Team
/// Date: 2026-07-02
/// Dependencies: flutter/cupertino.dart, flutter_screenutil, data_grc_module/core/extensions
/// Revision History: Initial version

abstract class CrossAxisCountHelper {
  static int getCrossAxisCountForDefaultTablet2(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isLandscape = screenWidth > screenHeight;

    // ==================== DESKTOP PLATFORMS ====================
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      // Large desktop (≥ 1920)
      if (screenWidth >= 1920) {
        return isLandscape ? 5 : 4;
      }

      // Laptop desktop (1366 – 1919)
      if (screenWidth >= 1366) {
        return isLandscape ? 4 : 3;
      }

      // Tablet desktop (768 – 1365)
      if (screenWidth >= 768) {
        return isLandscape ? 3 : 2;
      }

      // Small desktop (< 768)
      return isLandscape ? 1 : 1;
    }

    // ==================== LARGE DESKTOP / TV (≥ 1920) ====================
    if (screenWidth >= 1920) {
      return isLandscape ? 6 : 5;
    }

    // ==================== LAPTOP (1366 – 1919) ====================
    if (screenWidth >= 1366) {
      return isLandscape ? 5 : 4;
    }

    // ==================== TABLET (768 – 1365) ====================
    if (screenWidth >= 768) {
      return isLandscape ? 3 : 2;
    }

    // ==================== MOBILE (< 768) ====================
    return isLandscape ? 2 : 1;
  }
}
