/// Module: home/h2_nav_bar
///
///*************************** FILE INFO ****************************///
/// File Name: persistent_tab_controller.dart
/// Purpose: Declares `PersistentTabController`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Extracted from the oversized model.dart as part of
///          breaking up the vendored persistent-nav-bar god files.

import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/home/h2_nav_bar/persistent_nav_bar.dart';

///Navigation bar controller for `PersistentTabView`.
class PersistentTabController extends ChangeNotifier {
  PersistentTabController({final int initialIndex = 0})
      : _index = initialIndex,
        assert(initialIndex >= 0, "Value cannot be less than zero");

  bool _isDisposed = false;

  /// Whether [dispose] has already run.
  ///
  /// Public because `persistent_tab_scaffold.dart` must check it before
  /// calling `removeListener` on a controller it does not own — the private
  /// `_isDisposed` is not visible outside this library.
  bool get isDisposed => _isDisposed;

  int get index => _index;
  int _index;

  set index(final int value) {
    assert(value >= 0, "Value cannot be less than zero");
    if (_index == value) {
      return;
    }
    _index = value;
    notifyListeners();
  }

  void jumpToTab(final int value) {
    assert(value >= 0, "Value cannot be less than zero");
    if (_index == value) {
      return;
    }
    _index = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
