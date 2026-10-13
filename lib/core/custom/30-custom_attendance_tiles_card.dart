/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: attendance_tiles_card.dart
/// Purpose: Declares `AttendanceItem`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

// Figma: attendance mini-tiles — Present 03 | Absent 05 | Late 01 |
// Vacation 08 | Sick Leave 01 | Excused 08.
//
// Two layouts are supported:
//  * itemsPerCard == 1  -> one item per card (default, original behaviour).
//  * itemsPerCard >  1  -> several items stacked as rows inside one card,
//    e.g. itemsPerCard: 2 renders 3 cards each holding two rows (matches the
//    Figma where Present/Absent share a card, Late/Vacation share a card, ...).
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';

/// One attendance tile: icon + label + count, with an accent color.
class AttendanceItem {
  final String label;
  final String count;
  final Color? color;

  /// Any widget (SVG, Icon...). Tinted by [color] if you build it that way.
  final Widget? icon;
  final VoidCallback? onTap;

  /// [icon] is a complete Figma badge (its own coloured circle): drawn as
  /// is at 32, without the tinted circle (Time Tracker owner F1,
  /// 13/10/2026).
  final bool iconIsBadge;

  const AttendanceItem({
    required this.label,
    required this.count,
    this.color,
    this.icon,
    this.onTap,
    this.iconIsBadge = false,
  });
}

/// Grid of small attendance cards.
///
/// ```dart
/// // Two items per card (3 cards across) — the Figma layout:
/// AttendanceTilesCard(
///   itemsPerCard: 2,
///   items: [
///     AttendanceItem(label: 'Present', count: '03', color: AppColors.green),
///     AttendanceItem(label: 'Absent',  count: '05', color: AppColors.red),
///     // ...
///   ],
/// )
/// ```
class AttendanceTilesCard extends StatelessWidget {
  final List<AttendanceItem> items;

  /// Cards per row on a wide screen (auto-reduces on mobile).
  final int columns;

  /// How many items are stacked (as rows) inside a single card.
  final int itemsPerCard;

  final double? width;

  const AttendanceTilesCard({
    super.key,
    required this.items,
    this.columns = 3,
    this.itemsPerCard = 1,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final perCard = itemsPerCard < 1 ? 1 : itemsPerCard;

    // Chunk the items into groups of [perCard]; each group becomes one card.
    final groups = <List<AttendanceItem>>[];
    for (var i = 0; i < items.length; i += perCard) {
      final end = (i + perCard) < items.length ? (i + perCard) : items.length;
      groups.add(items.sublist(i, end));
    }

    return SizedBox(
      width: width ?? double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final perRow =
              (constraints.maxWidth / 150.w).floor().clamp(1, columns);
          final cardWidth =
              (constraints.maxWidth - (perRow - 1) * 10.w) / perRow;
          return Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: [
              for (final group in groups)
                SizedBox(
                  width: cardWidth,
                  child: _AttendanceCard(items: group),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// A card holding one or more attendance rows (stacked vertically).
class _AttendanceCard extends StatelessWidget {
  final List<AttendanceItem> items;

  const _AttendanceCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: CardStyles.radius(),
        boxShadow: CardStyles.shadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final item in items) _AttendanceRow(item: item),
        ],
      ),
    );
  }
}

/// A single icon + label + count row (no card decoration of its own).
class _AttendanceRow extends StatelessWidget {
  final AttendanceItem item;

  const _AttendanceRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final accent = item.color ?? AppColors.primary;
    return InkWell(
      onTap: item.onTap,
      borderRadius: CardStyles.radius(),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          children: [
            if (item.iconIsBadge && item.icon != null)
              SizedBox(width: 32.r, height: 32.r, child: item.icon)
            else
              Container(
                width: 28.r,
                height: 28.r,
                decoration: BoxDecoration(
                  color: accent.withOpacity(.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SizedBox(
                    width: 16.r,
                    height: 16.r,
                    child: FittedBox(
                      child: item.icon ??
                          Icon(Icons.person_outline, color: accent),
                    ),
                  ),
                ),
              ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                item.label,
                style: CardStyles.label(11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(item.count, style: CardStyles.title(14)),
          ],
        ),
      ),
    );
  }
}
