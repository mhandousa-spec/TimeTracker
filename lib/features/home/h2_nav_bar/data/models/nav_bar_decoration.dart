/// Module: home/h2_nav_bar
///
///*************************** FILE INFO ****************************///
/// File Name: nav_bar_decoration.dart
/// Purpose: Declares `NavBarDecoration`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Extracted from the oversized model.dart as part of
///          breaking up the vendored persistent-nav-bar god files.

import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/home/h2_nav_bar/persistent_nav_bar.dart';

class NavBarDecoration {
  const NavBarDecoration({
    this.border,
    this.gradient,
    this.borderRadius,
    this.colorBehindNavBar = CupertinoColors.black,
    this.boxShadow,
    this.adjustScreenBottomPaddingOnCurve = true,
  });

  ///Defines the curve radius of the corners of the NavBar.
  final BorderRadius? borderRadius;

  /// Color for the container which holds the bottom NavBar.
  ///
  /// When you increase the `navBarCurveRadius`, the `bottomScreenPadding` will automatically adjust to avoid layout issues. But if you want a fixed `bottomScreenPadding`, then you might want to set the color of your choice to avoid black edges at the corners of the NavBar.
  final Color colorBehindNavBar;

  final Gradient? gradient;

  final BoxBorder? border;

  final List<BoxShadow>? boxShadow;

  ///If enabled, the screen's bottom padding will be adjusted accordingly to the amount of curve applied.
  final bool adjustScreenBottomPaddingOnCurve;
}
