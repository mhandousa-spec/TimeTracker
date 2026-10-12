/// Module: time_tracker / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_card_grid.dart
/// Purpose: Declares `TtCardGrid` — the module's card grid: the house column
///          count (`CrossAxisCountHelperResponsive`), and every row exactly as
///          tall as its tallest card — cards HUG their content.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (UI quality pass — owner finding 13:45 #1: "far too
///            much empty padding" on the Request Types cards)
///
/// The module's grids used a fixed `mainAxisExtent` in `.h` units, which grows
/// with the screen HEIGHT (×1.33 on a 12.9" iPad) while the content does not —
/// so every card carried a large empty bottom. Here each row is an
/// `IntrinsicHeight` row: the cards of one row share the tallest one's height
/// (tidy rows, like Figma), nothing is clipped and nothing is padded. The
/// page scrolls (shrink-wrapped, like the grids it replaces). Spacing 12 / 12
/// (house grid gap). Lists are small (dozens of cards), so the intrinsic pass
/// is cheap.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/54-custom_grid_view.dart';

class TtCardGrid extends StatelessWidget {
  const TtCardGrid({super.key, required this.children, this.columns});

  final List<Widget> children;

  /// Fixed column count (null = the house responsive count).
  final int? columns;

  /// The narrowest a card may get (logical px). The house count gives FIVE
  /// columns at 1366 wide (iPad Pro landscape) — with the rail that is a
  /// ~238 px card, which cut "Created Date: 10 Aug 2…" and broke
  /// "Remainin / g". Figma (`661:35833`) shows ~270 px cards, four a row.
  static const double minCardWidth = 250;

  @override
  Widget build(BuildContext context) {
    final int? fixed = columns;
    if (fixed != null) return _grid(fixed);
    final int house = CrossAxisCountHelperResponsive.getCrossAxisCountForDefaultTabletResponsive(context);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        final double gap = 12.w;
        final int fit = ((c.maxWidth + gap) / (minCardWidth + gap)).floor();
        return _grid(math.max(1, math.min(house, fit)));
      },
    );
  }

  Widget _grid(int cols) {
    final double gapX = 12.w;
    final double gapY = 12.h;
    final List<Widget> rows = <Widget>[];
    for (int i = 0; i < children.length; i += cols) {
      final List<Widget> row = children.skip(i).take(cols).toList();
      rows.add(IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            for (int j = 0; j < cols; j++) ...<Widget>[
              if (j > 0) SizedBox(width: gapX),
              Expanded(child: j < row.length ? row[j] : const SizedBox.shrink()),
            ],
          ],
        ),
      ));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: gapY,
      children: rows,
    );
  }
}
