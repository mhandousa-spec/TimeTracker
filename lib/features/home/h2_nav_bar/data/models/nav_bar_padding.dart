/// Module: home/h2_nav_bar
///
///*************************** FILE INFO ****************************///
/// File Name: nav_bar_padding.dart
/// Purpose: Declares `NavBarPadding`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Extracted from the oversized model.dart as part of
///          breaking up the vendored persistent-nav-bar god files.

import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/home/h2_nav_bar/persistent_nav_bar.dart';

class NavBarPadding {
  const NavBarPadding.only({this.top, this.bottom, this.right, this.left});

  const NavBarPadding.symmetric(
      {final double? horizontal, final double? vertical})
      : top = vertical,
        bottom = vertical,
        right = horizontal,
        left = horizontal;

  const NavBarPadding.all(final double? value)
      : top = value,
        bottom = value,
        right = value,
        left = value;

  const NavBarPadding.fromLTRB(this.top, this.bottom, this.right, this.left);
  final double? top;
  final double? bottom;
  final double? right;
  final double? left;
}
