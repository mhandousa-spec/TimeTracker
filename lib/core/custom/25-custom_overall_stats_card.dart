/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: overall_stats_card.dart
/// Purpose: Declares `StatItem`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
/// Updated: 9/10/2026 - (Time Tracker UI fix round 1) optional
///          `StatItem.labelColor` and `OverallStatsCard.wrapLabels`; both
///          default to the previous look, so existing callers are unchanged.

// Figma: "Overall" stats row — tiles with icon + label + count.
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';

/// One stat tile entry. [icon] can be any widget (SVG, Icon...).
class StatItem {
  final String label;
  final String value;
  final Widget? icon;
  final VoidCallback? onTap;

  /// ADDED 9/10/2026: label colour (Figma Time Tracker "Overall": Present
  /// green, Absence / Late red, Vacations Credit yellow). Null keeps the
  /// card's dark value colour.
  final Color? labelColor;

  const StatItem({
    required this.label,
    required this.value,
    this.icon,
    this.onTap,
    this.labelColor,
  });
}

/// "Overall" card: a responsive row of stat tiles
/// (Products 11 | Orders 11 | Warehouses 11 | ...).
class OverallStatsCard extends StatelessWidget {
  final String title;
  final List<StatItem> items;
  final double? width;

  /// ADDED 9/10/2026: let a label wrap onto more lines instead of ending in
  /// "…" (owner rule for the Time Tracker Overall tiles — "Vacations Credit"
  /// must read in full on iPad portrait and iPhone). False keeps the
  /// single-line ellipsis every other caller has.
  final bool wrapLabels;

  const OverallStatsCard({
    super.key,
    this.title = 'Overall',
    required this.items,
    this.width,
    this.wrapLabels = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      // Figma: card padding 16, radius 8, white bg + 2% shadow.
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: CardStyles.radius(),
        boxShadow: CardStyles.shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: CardStyles.title(16)),
          SizedBox(height: 12.h),
          LayoutBuilder(
            builder: (context, constraints) {
              // ~140w per tile, min 2 per row (mobile) max items.length.
              final perRow =
                  (constraints.maxWidth / 140.w).floor().clamp(2, items.length);
              final tileWidth =
                  (constraints.maxWidth - (perRow - 1) * 8.w) / perRow;
              return Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  for (final item in items)
                    SizedBox(
                      width: tileWidth,
                      child: _StatTile(item: item, wrapLabel: wrapLabels),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final StatItem item;
  final bool wrapLabel;

  const _StatTile({required this.item, this.wrapLabel = false});

  @override
  Widget build(BuildContext context) {
    // Figma "Overall" tile: large line icon + [label above, count below],
    // no background box.
    return InkWell(
      onTap: item.onTap,
      borderRadius: CardStyles.radius(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
        child: Row(
          // 9/10/2026: a wrapped (two-line) label grows downwards; the icons
          // of the row stay on one line.
          crossAxisAlignment:
              wrapLabel ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            if (item.icon != null) ...[
              SizedBox(
                width: 40.r,
                height: 40.r,
                child: FittedBox(child: item.icon),
              ),
              SizedBox(width: 8.w),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.label,
                    style: item.labelColor == null
                        ? CardStyles.value(14)
                        : CardStyles.value(14).copyWith(color: item.labelColor),
                    maxLines: wrapLabel ? null : 1,
                    softWrap: wrapLabel ? true : null,
                    overflow: wrapLabel ? TextOverflow.visible : TextOverflow.ellipsis,
                  ),
                  Text(item.value, style: CardStyles.title(16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
