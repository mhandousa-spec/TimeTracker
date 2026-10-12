/// Module: home/h2_nav_bar
///
///*************************** FILE INFO ****************************///
/// File Name: nav_bar_essentials.dart
/// Purpose: Declares `NavBarEssentials`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Extracted from the oversized model.dart as part of
///          breaking up the vendored persistent-nav-bar god files.

import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/home/h2_nav_bar/persistent_nav_bar.dart';

class NavBarEssentials {
  const NavBarEssentials({
    required this.items,
    this.selectedIndex,
    this.previousIndex,
    this.backgroundColor,
    this.popScreensOnTapOfSelectedTab,
    this.popAllScreensOnTapAnyTabs,
    this.itemAnimationProperties,
    this.navBarHeight = 0.0,
    this.onItemSelected,
    this.padding,
    this.selectedScreenBuildContext,
  });

  final int? selectedIndex;
  final int? previousIndex;
  final Color? backgroundColor;
  final List<PersistentBottomNavBarItem>? items;
  final ValueChanged<int>? onItemSelected;
  final double? navBarHeight;
  final NavBarPadding? padding;
  final bool? popScreensOnTapOfSelectedTab;
  final bool? popAllScreensOnTapAnyTabs;
  final ItemAnimationProperties? itemAnimationProperties;
  final BuildContext? selectedScreenBuildContext;

  NavBarEssentials copyWith({
    final int? selectedIndex,
    final int? previousIndex,
    final double? iconSize,
    final Color? backgroundColor,
    final List<PersistentBottomNavBarItem>? items,
    final ValueChanged<int>? onItemSelected,
    final double? navBarHeight,
    final NavBarPadding? padding,
    final Function(int)? popAllScreensForTheSelectedTab,
    final bool? popScreensOnTapOfSelectedTab,
    final ItemAnimationProperties? itemAnimationProperties,
  }) =>
      NavBarEssentials(
        selectedIndex: selectedIndex ?? this.selectedIndex,
        previousIndex: previousIndex ?? this.previousIndex,
        backgroundColor: backgroundColor ?? this.backgroundColor,
        items: items ?? this.items,
        onItemSelected: onItemSelected ?? this.onItemSelected,
        navBarHeight: navBarHeight ?? this.navBarHeight,
        padding: padding ?? this.padding,
        popScreensOnTapOfSelectedTab:
            popScreensOnTapOfSelectedTab ?? this.popScreensOnTapOfSelectedTab,
        itemAnimationProperties:
            itemAnimationProperties ?? this.itemAnimationProperties,
      );
}
