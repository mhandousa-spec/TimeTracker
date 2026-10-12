/// Module: home/h2_nav_bar
///
///*************************** FILE INFO ****************************///
/// File Name: screen_transition_animation.dart
/// Purpose: Declares `ScreenTransitionAnimation`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Extracted from the oversized model.dart as part of
///          breaking up the vendored persistent-nav-bar god files.

import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/home/h2_nav_bar/persistent_nav_bar.dart';

class ScreenTransitionAnimation {
  const ScreenTransitionAnimation({
    this.animateTabTransition = false,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.ease,
  });
  final bool animateTabTransition;
  final Duration duration;
  final Curve curve;
}
