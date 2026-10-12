/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: 38-custom_responsive.dart
/// Purpose: Declares `ResponsiveHelper`, `ScreenSize`, and the width-based
///          breakpoint helpers every responsive screen should key off.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
/// Updated: 12/9/2026 - Added the three-way mobile / tablet / desktop
///                      breakpoints (`ScreenSize`, `screenSizeOf`,
///                      `responsiveValue`) and an optional `desktopWidget`
///                      on ResponsiveHelper, so screens designed at 375 /
///                      768 / 1024 in Figma can render their own layout at
///                      each size instead of collapsing into one "tablet"
///                      branch.

// Date: 29/9/2024
// By: Youssef Ashraf
// Objectives: This file is responsible for providing a responsive widget based
// on screen size with proper controller lifecycle management

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

/// The three layout sizes the designs are drawn at.
///
/// Figma draws every GRC screen three times — 375 (phone), 768 (iPad
/// portrait) and 1024 (iPad landscape / desktop) — so the code needs three
/// buckets too.
enum ScreenSize { mobile, tablet, desktop }

/// Layout breakpoints, in logical pixels of **width**.
///
/// Width, deliberately, and NOT `shortestSide`. An iPad reports the same
/// shortestSide (768) in both orientations, so `shortestSide` cannot tell the
/// 768-wide portrait design from the 1024-wide landscape one — the very
/// distinction these breakpoints exist to make. They line up with the
/// `designSize` ladder in main.dart (375 / 768 / 1024 / 1366 / 1920).
class Breakpoints {
  Breakpoints._();

  /// Below this width a screen uses the phone design.
  static const double tablet = 600;

  /// At or above this width a screen uses the desktop design.
  static const double desktop = 1024;
}

/// Which of the three designs [context] should render.
ScreenSize screenSizeOf(BuildContext context) {
  final double width = MediaQuery.of(context).size.width;
  if (width >= Breakpoints.desktop) return ScreenSize.desktop;
  if (width >= Breakpoints.tablet) return ScreenSize.tablet;
  return ScreenSize.mobile;
}

/// Picks one of three values for the current screen size.
///
/// [tablet] is optional and falls back to [desktop], so a caller that only
/// has two real layouts ("phone" and "everything wider") still reads clearly:
///
/// ```dart
/// final columns = responsiveValue(context, mobile: 1, tablet: 2, desktop: 3);
/// ```
T responsiveValue<T>(
  BuildContext context, {
  required T mobile,
  T? tablet,
  required T desktop,
}) {
  switch (screenSizeOf(context)) {
    case ScreenSize.mobile:
      return mobile;
    case ScreenSize.tablet:
      return tablet ?? desktop;
    case ScreenSize.desktop:
      return desktop;
  }
}

/// class name: [ResponsiveHelper]
///
/// purpose: swaps between the mobile, tablet and desktop builds of a screen.
///
/// [desktopWidget] is optional: leave it null and widths at or above
/// [Breakpoints.desktop] keep rendering [tabletWidget], which is exactly what
/// every existing two-way caller already does. Pass it and the screen gets its
/// own desktop layout.
class ResponsiveHelper extends StatefulWidget {
  final Widget mobileWidget, tabletWidget;
  final Widget? desktopWidget;

  const ResponsiveHelper({
    super.key,
    required this.mobileWidget,
    required this.tabletWidget,
    this.desktopWidget,
  });

  @override
  State<ResponsiveHelper> createState() => _ResponsiveHelperState();
}

class _ResponsiveHelperState extends State<ResponsiveHelper> {
  bool? _wasTablet;

  @override
  Widget build(BuildContext context) {
    // DELIBERATELY still `isTablet` (shortestSide >= 600), not the width
    // breakpoints above.
    //
    // Every screen in the app goes through this widget, and switching the
    // mobile/tablet decision to width would silently re-route a phone held in
    // landscape (812x375: width 812, shortestSide 375) from its mobile layout
    // to its tablet one — app-wide, in one edit, with no screen asked for it.
    // So the existing two-way choice is left exactly as it was.
    //
    // The new `desktopWidget` is purely additive on top of it: it is only
    // consulted when a caller actually supplies one, and screens that want
    // width-keyed layout decisions inside themselves use `screenSizeOf` /
    // `responsiveValue` directly.
    final isTablet = ContextExtension(context).isTablet;

    if (_wasTablet != null && _wasTablet != isTablet) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _cleanupControllersAfterResize(isTablet);
      });
    }

    _wasTablet = isTablet;

    if (!isTablet) return widget.mobileWidget;

    final bool isDesktop = screenSizeOf(context) == ScreenSize.desktop;
    if (isDesktop && widget.desktopWidget != null) {
      return widget.desktopWidget!;
    }
    return widget.tabletWidget;
  }

  void _cleanupControllersAfterResize(bool isTablet) {
    if (isTablet) {
      // Switched to tablet - remove NavBarCubit if it exists
      try {
        // if (Get.isRegistered<NavBarCubit>()) {
        //   Get.delete<NavBarCubit>(force: true);
        // }
      } catch (e) {
        // cleanup is best-effort
      }
    } else {
      // Switched to mobile - remove AppDrawerCubit if it exists
      try {
        // if (Get.isRegistered<AppDrawerCubit>()) {
        //   Get.delete<AppDrawerCubit>(force: true);
        // }
      } catch (e) {
        // cleanup is best-effort
      }
    }
  }
}
