/// Module: services_management_module
/// Description: Responsive cross-axis-count helpers for grid views (tablet
///              landscape/portrait breakpoints for the services module).
/// Author: Knowticed Team
/// Date: 2026-07-02
/// Dependencies: flutter/cupertino.dart, flutter_screenutil, data_grc_module/core/extensions
/// Revision History: Initial version

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract class CrossAxisCountHelperResponsive {
  static int getCrossAxisCountForDefaultTabletResponsive(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isLandscape = screenWidth > screenHeight;

    // ==================== DESKTOP PLATFORMS ====================
    // `defaultTargetPlatform` instead of dart:io `Platform` (7/10/2026): the
    // latter throws on web. Web counts as desktop.
    final bool isDesktop = kIsWeb ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux;
    if (isDesktop) {
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