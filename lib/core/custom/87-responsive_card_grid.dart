/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: responsive_card_grid.dart
/// Purpose: Declares `ResponsiveCardHeight`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

/// ************************* FILE INFO *************************** ///
/// File Name: responsive_card_grid.dart
/// Purpose: Reusable, overflow-proof sizing for card grids.
/// Author: Amr Mesbah
/// Created At: 03/08/2026
///
/// WHY THIS EXISTS
/// ---------------
/// GridView needs a fixed cell height (`mainAxisExtent`), but card content
/// grows with fonts, locale and the user's text-scale setting. Hard-coding a
/// per-breakpoint height means it either overflows on one device or leaves
/// dead space on another.
///
/// The fix is two independent pieces — use them together:
///
///   1. [ResponsiveCardHeight] — computes the cell height from what the card's
///      content actually needs (its text line sizes, gaps and padding), NOT
///      from the cell width. A card stays the same compact size on a phone and
///      on a wide desktop; it only grows when the fonts themselves grow.
///
///   2. [ResponsiveCardContent] — wraps the card's text block so it scales
///      itself down if the cell ever turns out shorter than the content needs.
///      This is the safety net that makes overflow structurally impossible.
///
/// IS THE HEIGHT DATA-DEPENDENT?
/// -----------------------------
/// No. It depends on the card's *shape* — how many text rows it has and at
/// what font sizes — which is identical for every record in the grid. Per-record
/// data (a longer title, a missing date) is absorbed by `maxLines` + ellipsis
/// inside the card, and by [ResponsiveCardContent] as a last resort. So you
/// configure it once per card type, not per item.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Computes a grid cell height from the card's content, so the same card looks
/// right at every window size.
abstract class ResponsiveCardHeight {
  /// Multiplier turning a font size into the height of its line box.
  /// 1.45 is a safe approximation for Cairo/Roboto at these sizes.
  static const double defaultLineFactor = 1.45;

  /// Ceiling applied to the OS text-scale setting. Beyond this the card scales
  /// its content down instead of growing the grid indefinitely.
  static const double maxTextScale = 1.2;

  /// [textLineSizes]  font sizes of each stacked text row, in .sp
  ///                  e.g. `[12.sp, 10.sp, 8.sp]` for title / subtitle / dates
  /// [gapSizes]       vertical gaps between those rows, e.g. `[6.sp, 6.sp]`
  /// [verticalPadding] total top + bottom padding of the card
  /// [minimumHeight]  a floor, e.g. a thumbnail's height + padding
  /// [lowerBound] / [upperBound] absolute clamps, guard against odd .sp values
  static double of(
      BuildContext context, {
        required List<double> textLineSizes,
        List<double> gapSizes = const [],
        double verticalPadding = 20.0,
        double minimumHeight = 0.0,
        double lineFactor = defaultLineFactor,
        double lowerBound = 48.0,
        double upperBound = 320.0,
      }) {
    final double textScale =
    MediaQuery.textScalerOf(context).scale(1.0).clamp(1.0, maxTextScale);

    double contentHeight = verticalPadding;
    for (final size in textLineSizes) {
      contentHeight += size * lineFactor;
    }
    for (final gap in gapSizes) {
      contentHeight += gap;
    }

    final double base =
    contentHeight > minimumHeight ? contentHeight : minimumHeight;

    return (base * textScale).clamp(lowerBound, upperBound);
  }

  /// Convenience for the common "icon/thumbnail on the left, three text rows on
  /// the right" card used across the app (knowledge hub, submissions, etc.).
  ///
  /// Pass [thumbnailHeight] if the card has a leading image so it is respected
  /// as the floor.
  static double forListCard(
      BuildContext context, {
        double titleSize = 12,
        double subtitleSize = 10,
        double captionSize = 8,
        double gap = 6,
        double verticalPadding = 20.0,
        double thumbnailHeight = 0.0,
      }) {
    return of(
      context,
      textLineSizes: [titleSize.sp, subtitleSize.sp, captionSize.sp],
      gapSizes: [gap.sp, gap.sp],
      verticalPadding: verticalPadding,
      minimumHeight:
      thumbnailHeight > 0 ? thumbnailHeight + verticalPadding : 0.0,
      lowerBound: 56.0,
      upperBound: 110.0,
    );
  }

  /// Ready-made grid delegate using the computed height.
  static SliverGridDelegateWithFixedCrossAxisCount delegate({
    required int crossAxisCount,
    required double cardHeight,
    double crossAxisSpacing = 10.0,
    double mainAxisSpacing = 10.0,
  }) {
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: crossAxisCount,
      mainAxisExtent: cardHeight,
      crossAxisSpacing: crossAxisSpacing,
      mainAxisSpacing: mainAxisSpacing,
    );
  }
}

/// Wraps a card's content so it can never overflow its cell.
///
/// The child is laid out at its natural height inside the available width, then
/// uniformly scaled down if the cell is shorter than it needs. Put this around
/// the text column of any card that lives in a fixed-extent grid.
///
/// Note: the child is measured with an unbounded height, so avoid `Spacer` /
/// `Expanded` *along the vertical axis* inside it. Horizontal `Expanded` and
/// `Flexible` are fine — the width is pinned.
class ResponsiveCardContent extends StatelessWidget {
  const ResponsiveCardContent({
    super.key,
    required this.child,
    this.alignment = Alignment.centerLeft,
    this.maxTextScale = ResponsiveCardHeight.maxTextScale,
  });

  final Widget child;
  final Alignment alignment;

  /// Stops a large OS text-scale setting from blowing the layout apart.
  final double maxTextScale;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: maxTextScale,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return FittedBox(
            fit: BoxFit.scaleDown,
            alignment: alignment,
            child: SizedBox(
              width: constraints.maxWidth,
              child: child,
            ),
          );
        },
      ),
    );
  }
}
