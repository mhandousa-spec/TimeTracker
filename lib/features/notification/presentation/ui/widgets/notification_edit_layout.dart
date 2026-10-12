/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: notification_edit_layout.dart
/// Purpose: The two rows of the Notification Control edit panel that must
///          always fit their width: `NotificationStatusHeader` ("Notification
///          Status" + switch + "Reset Default Messages") and
///          `NotificationEditActions` (Preview · Discard · Save).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (Time Tracker QA KP-TT-018 — shared module, for
///          Amr's handover)
///
/// QA KP-TT-018 (Major): on iPad portrait (Notification Control → Time
/// Tracker & Attendance → Edit) the bottom row of three fixed 150.w buttons
/// overflowed the right panel by 191 px — Save was off-screen, so a
/// notification could not be switched off — and "Reset Default Messages"
/// overflowed the status row by 13 px. Both rows now measure their space:
///   * [NotificationEditActions]: the Figma layout (buttons at their usual
///     width, Save at the far end) when it fits; otherwise the buttons share
///     the width equally; and when even that cannot hold the longest label,
///     one full-width button per line (Save last). Never an overflow.
///   * [NotificationStatusHeader]: title + switch at the start, the action at
///     the end — and the action moves to its own line when the two do not
///     fit side by side.
/// Buttons are the app's `customButton` (same colours, haptics, radius).

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/41-custom_button_sizing.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';

/// One button of [NotificationEditActions].
class NotificationEditAction {
  const NotificationEditAction({
    required this.title,
    required this.onTap,
    required this.color,
    required this.textStyle,
    this.key,
  });

  final String title;
  final VoidCallback onTap;
  final Color color;
  final TextStyle textStyle;

  /// Finds the button in tests.
  final Key? key;
}

/// How [NotificationEditActions] arranged its buttons (tests).
enum NotificationEditActionsLayout { spread, shared, stacked }

/// Preview · Discard … Save — always inside its width (see the header).
class NotificationEditActions extends StatelessWidget {
  const NotificationEditActions({
    super.key,
    required this.start,
    this.end,
    this.idealWidth,
    this.gap,
  });

  /// The buttons at the start (Preview, Discard).
  final List<NotificationEditAction> start;

  /// The button at the far end (Save); null = none (no permission).
  final NotificationEditAction? end;

  /// Each button's usual width (default `150.w`, the Figma value).
  final double? idealWidth;

  /// Space between buttons (default `12.w`).
  final double? gap;

  /// Function Name: [layoutFor]
  ///
  /// Purpose: Which arrangement fits [maxWidth] (pure — tests).
  ///
  /// Parameters:
  ///   [double] maxWidth: the available width.
  ///   [int] count: buttons in total.
  ///   [bool] hasEnd: a far-end button exists (needs a gap before it).
  ///   [double] ideal / [double] gap
  ///   [double] longestLabel: the widest label incl. its padding.
  ///
  /// Return type: [NotificationEditActionsLayout]
  static NotificationEditActionsLayout layoutFor({
    required double maxWidth,
    required int count,
    required bool hasEnd,
    required double ideal,
    required double gap,
    required double longestLabel,
  }) {
    if (count <= 0) return NotificationEditActionsLayout.spread;
    final double spread = ideal * count + gap * (count - 1) + (hasEnd && count > 1 ? gap : 0);
    if (maxWidth >= spread) return NotificationEditActionsLayout.spread;
    final double share = (maxWidth - gap * (count - 1)) / count;
    if (share >= math.max(longestLabel, 1)) return NotificationEditActionsLayout.shared;
    return NotificationEditActionsLayout.stacked;
  }

  static double _labelWidth(BuildContext context, NotificationEditAction a) {
    final TextPainter painter = TextPainter(
      text: TextSpan(text: a.title, style: a.textStyle),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final double width = painter.width + ButtonSizing.horizontalPadding * 2;
    painter.dispose();
    return width;
  }

  Widget _button(NotificationEditAction a, double width) => KeyedSubtree(
        key: a.key,
        child: customButton(
          title: a.title,
          function: a.onTap,
          width: width,
          color: a.color,
          textStyle: a.textStyle,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final double ideal = idealWidth ?? 150.w;
    final double space = gap ?? 12.w;
    final NotificationEditAction? last = end;
    final List<NotificationEditAction> all = <NotificationEditAction>[...start, if (last != null) last];
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double max = constraints.maxWidth;
        final NotificationEditActionsLayout layout = !max.isFinite
            ? NotificationEditActionsLayout.spread
            : layoutFor(
                maxWidth: max,
                count: all.length,
                hasEnd: last != null,
                ideal: ideal,
                gap: space,
                longestLabel: all.fold<double>(0, (double m, NotificationEditAction a) => math.max(m, _labelWidth(context, a))),
              );
        switch (layout) {
          case NotificationEditActionsLayout.spread:
            return Row(
              mainAxisSize: max.isFinite ? MainAxisSize.max : MainAxisSize.min,
              children: <Widget>[
                for (int i = 0; i < start.length; i++) ...<Widget>[
                  if (i > 0) SizedBox(width: space),
                  _button(start[i], ideal),
                ],
                if (last != null) ...<Widget>[
                  if (max.isFinite) const Spacer() else SizedBox(width: space),
                  _button(last, ideal),
                ],
              ],
            );
          case NotificationEditActionsLayout.shared:
            return Row(
              children: <Widget>[
                for (int i = 0; i < all.length; i++) ...<Widget>[
                  if (i > 0) SizedBox(width: space),
                  Expanded(child: _button(all[i], double.infinity)),
                ],
              ],
            );
          case NotificationEditActionsLayout.stacked:
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                for (int i = 0; i < all.length; i++) ...<Widget>[
                  if (i > 0) SizedBox(height: space),
                  _button(all[i], double.infinity),
                ],
              ],
            );
        }
      },
    );
  }
}

/// "Notification Status" + switch at the start, [trailing] (Reset Default
/// Messages) at the end — on its own line when both do not fit.
class NotificationStatusHeader extends StatelessWidget {
  const NotificationStatusHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.toggle,
    this.trailing,
  });

  final Widget icon;
  final Widget title;
  final Widget toggle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final Widget? action = trailing;
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8.w,
      runSpacing: 10.h,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            icon,
            SizedBox(width: 8.w),
            Flexible(child: title),
            SizedBox(width: 8.w),
            toggle,
          ],
        ),
        if (action != null) action,
      ],
    );
  }
}
