/// Module: home/h2_nav_bar
///
///*************************** FILE INFO ****************************///
/// File Name: neumorphic_properties.dart
/// Purpose: Declares `NeumorphicProperties`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Extracted from the oversized model.dart as part of
///          breaking up the vendored persistent-nav-bar god files.

import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/home/h2_nav_bar/persistent_nav_bar.dart';

class NeumorphicProperties {
  const NeumorphicProperties({
    this.bevel = 12.0,
    this.borderRadius = 15.0,
    this.border,
    this.shape = BoxShape.rectangle,
    this.curveType = CurveType.concave,
    this.showSubtitleText = false,
  });
  final double bevel;
  final double borderRadius;
  final BoxBorder? border;
  final BoxShape shape;
  final CurveType curveType;
  final bool showSubtitleText;
}
