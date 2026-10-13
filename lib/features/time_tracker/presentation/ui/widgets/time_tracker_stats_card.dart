/// Module: time_tracker / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_stats_card.dart
/// Purpose: Declares `TtStatsCard` + `TtStat` — the module's stat tiles
///          (dashboard "Overall", HR "Today"): coloured icon · neutral label
///          on ONE line · the number below.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (UI quality pass — owner findings 13:45 #4 and
///            14:17 #1–2)
///
/// Owner (14:17, demo for government clients): every tile label on ONE line
/// — no "…", no wrapping — at iPad landscape / portrait and iPhone, English
/// and Arabic; no coloured label text on the dark card (green / red / yellow
/// "Checked In Now", "Absent Today" … was unreadable): the label is neutral,
/// the colour lives in the icon only.
///
/// How the one-line rule is kept: the card MEASURES the longest label with
/// the real text style and font, derives the narrowest tile that fits it
/// (icon + gap + label + padding) and puts as many tiles on a row as fit
/// (rows share the width equally; the last row keeps the same tile width).
/// Only on a screen narrower than one tile would a label scale down (never
/// wrap, never "…"). On a phone the tiles use smaller metrics (label 12,
/// number 16, icon 32) so two share a row; if even then one tile fills a
/// row, the icon goes ABOVE the label (stacked) so two still fit.
///
/// White card, radius 8, padding 16, title 16 Medium — same frame as the
/// core `OverallStatsCard` the module used before. A tile with [TtStat.onTap]
/// (Pending Approvals → Approvals tab) shows a small "›" after its number
/// and fires a LOW haptic. No hover / splash (owner rule).
///
/// Updated: 13/10/2026 - owner review (iPad portrait): on a tablet the tiles
/// sit on ONE line whenever they fit at their own label width (spread evenly);
/// title gap 14 → 10.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

/// One tile.
class TtStat {
  const TtStat({required this.label, required this.value, required this.icon, this.onTap, this.tileKey});

  final String label;
  final String value;

  /// The coloured line icon (40×40 box).
  final Widget icon;

  /// Makes the tile a link (LOW haptic).
  final VoidCallback? onTap;
  final Key? tileKey;
}

class TtStatsCard extends StatelessWidget {
  const TtStatsCard({super.key, required this.title, required this.stats});

  final String title;
  final List<TtStat> stats;

  /// Tablet metrics: label 14, number 18, icon 40.
  static TextStyle get _labelStyle => StyleText.fontSize14Weight400.copyWith(color: AppColors.secondaryText);
  static TextStyle get _valueStyle => StyleText.fontSize18Weight600.copyWith(color: AppColors.text);

  /// Phone metrics (iPhone 390 wide): label 12, number 16, icon 32 — so two
  /// tiles share a row instead of one tile per row.
  static TextStyle get _phoneLabelStyle => StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText);
  static TextStyle get _phoneValueStyle => StyleText.fontSize16Weight600.copyWith(color: AppColors.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsetsDirectional.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: CardStyles.radius(),
        boxShadow: CardStyles.shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(title, style: StyleText.fontSize16Weight500.copyWith(color: AppColors.text)),
          // 13/10/2026 (owner): 14 → 10 under the title.
          SizedBox(height: 10.h),
          LayoutBuilder(builder: (BuildContext context, BoxConstraints c) => _rows(context, c.maxWidth)),
        ],
      ),
    );
  }

  Widget _rows(BuildContext context, double width) {
    final bool phone = context.isPhone;
    final TextStyle label = phone ? _phoneLabelStyle : _labelStyle;
    final TextStyle value = phone ? _phoneValueStyle : _valueStyle;
    final double icon = phone ? 32.r : 40.r;
    final double gap = phone ? 8.w : 10.w;
    final double spacing = phone ? 10.w : 12.w;
    final TextDirection direction = Directionality.of(context);
    final TextScaler scaler = MediaQuery.textScalerOf(context);
    double longest = 0;
    final List<double> labelWidths = <double>[];
    for (final TtStat s in stats) {
      final TextPainter p = TextPainter(
        text: TextSpan(text: s.label, style: label),
        textDirection: direction,
        textScaler: scaler,
        maxLines: 1,
      )..layout();
      longest = math.max(longest, p.width);
      labelWidths.add(p.width);
      p.dispose();
    }
    // 13/10/2026 (owner): on a tablet every tile on ONE line when the tiles,
    // each only as wide as its OWN label, fit — spread evenly across the
    // card. (Sizing every tile for the longest label, "Vacations Credit",
    // pushed the fourth tile onto a second line on iPad portrait.)
    if (!phone && stats.length > 1) {
      final List<double> natural = <double>[
        for (final double w in labelWidths) icon + gap + math.max(w, 24.w) + 4.w,
      ];
      final double needed = natural.fold<double>(0, (double a, double b) => a + b) + spacing * (stats.length - 1);
      if (needed <= width) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (int i = 0; i < stats.length; i++)
              SizedBox(
                width: natural[i],
                child: _Tile(
                  stat: stats[i],
                  iconSize: icon,
                  gap: gap,
                  labelStyle: label,
                  valueStyle: value,
                  stacked: false,
                ),
              ),
          ],
        );
      }
    }
    int fit(double tile) =>
        stats.isEmpty ? 1 : ((width + spacing) / (tile + spacing)).floor().clamp(1, stats.length);
    // Side by side: icon + gap + the longest label + a little air.
    int perRow = fit(icon + gap + longest + 6.w);
    // Phone fallback: when side-by-side tiles leave ONE per row, stack the
    // icon over the label (the tile is then only as wide as the label) so
    // two tiles still share a row — the label stays on one line.
    final bool stacked = phone && perRow < 2 && fit(math.max(icon, longest) + 4.w) >= 2;
    if (stacked) perRow = fit(math.max(icon, longest) + 4.w);
    final double tileWidth = (width - spacing * (perRow - 1)) / perRow;
    final List<Widget> rows = <Widget>[];
    for (int i = 0; i < stats.length; i += perRow) {
      final List<TtStat> row = stats.skip(i).take(perRow).toList();
      rows.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (int j = 0; j < row.length; j++) ...<Widget>[
            if (j > 0) SizedBox(width: spacing),
            SizedBox(
              width: tileWidth,
              child: _Tile(
                stat: row[j],
                iconSize: icon,
                gap: gap,
                labelStyle: label,
                valueStyle: value,
                stacked: stacked,
              ),
            ),
          ],
        ],
      ));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: phone ? 12.h : 14.h,
      children: rows,
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.stat,
    required this.iconSize,
    required this.gap,
    required this.labelStyle,
    required this.valueStyle,
    required this.stacked,
  });

  final TtStat stat;
  final double iconSize;
  final double gap;
  final TextStyle labelStyle;
  final TextStyle valueStyle;

  /// Icon above the texts (phone fallback) instead of beside them.
  final bool stacked;

  @override
  Widget build(BuildContext context) {
    final VoidCallback? tap = stat.onTap;
    final Widget iconBox = SizedBox(width: iconSize, height: iconSize, child: FittedBox(child: stat.icon));
    final Widget texts = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // One line, never "…": the card sized the tile for this label;
        // scaleDown is only a safety net on an absurdly narrow screen.
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Text(stat.label, maxLines: 1, softWrap: false, style: labelStyle),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Owner 10 Oct: no arrow next to the value — a tappable tile
            // still opens its page, it just doesn't show a chevron.
            Text(stat.value, style: valueStyle),
          ],
        ),
      ],
    );
    final Widget body = stacked
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[iconBox, SizedBox(height: 6.h), texts],
          )
        : Row(
            children: <Widget>[iconBox, SizedBox(width: gap), Expanded(child: texts)],
          );
    if (tap == null) return KeyedSubtree(key: stat.tileKey, child: body);
    return Semantics(
      button: true,
      label: stat.label,
      child: GestureDetector(
        key: stat.tileKey,
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticController.low();
          tap();
        },
        child: body,
      ),
    );
  }
}
