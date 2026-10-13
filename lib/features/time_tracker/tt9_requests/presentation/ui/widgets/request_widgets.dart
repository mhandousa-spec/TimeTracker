/// Module: time_tracker / tt9_requests / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: request_widgets.dart
/// Purpose: Declares the small pieces shared by the request / approval
///          cards and details: `RequestIconBox`, `RequestInfoLine`,
///          `RequestStatusCounters` (core `StatusChipFilter`),
///          `RequestOutlinedButton` (Reject / Approve / Cancel / Send
///          Reminder) and `RequestStatusPill`.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Figma `661:14909` (cards: grey icon box, "Label: value" lines with a
/// leading icon) and `661:83996` (footer: red Reject + green Approve
/// outlined buttons, or one full-width status bar). Counters = core
/// `StatusChipFilter` (8) with the Figma label colours; a tap fires a LOW
/// haptic. Buttons: Approve / Reminder MEDIUM, Reject / Cancel HIGH
/// (haptic standard); no hover / splash (owner rule). All colours are
/// `AppColors` getters (dark mode); paddings directional (RTL).
/// Updated: 9/10/2026 - UI fix round 1: the counters row scrolls like the
/// tab strip when it does not fit (iPad portrait / iPhone) — the selected
/// counter is scrolled into view and the hidden edge fades
/// (`TtOverflowFade`), instead of a counter cut in half at the edge.
/// Updated: 9/10/2026 - code review: Material icons → the app's SVG line
/// icons (`TtAssets` / `TtGlyph`) where an equivalent asset exists.
/// Updated: 9/10/2026 - UI quality pass: info values wrap (no "…"); the
/// buttons / pill take the house button height (`ButtonSizing`).

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/41-custom_button_sizing.dart';
import 'package:knowticed_plus/core/custom/8-custom_filter_app.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/request_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_list_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_reminder_rule.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_tab_strip.dart';
import 'package:knowticed_plus/features/time_tracker/tt9_requests/presentation/ui/widgets/request_text.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_controls.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// The grey square with the "request" icon.
class RequestIconBox extends StatelessWidget {
  const RequestIconBox({super.key, this.size});

  final double? size;

  @override
  Widget build(BuildContext context) {
    final double s = size ?? 46.r;
    return Container(
      width: s,
      height: s,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadiusDirectional.circular(8.r),
      ),
      // 13/10/2026 (owner): the Figma request icon (`661:22417`).
      child: Center(child: TtIcon(const TtGlyph.svg(TtAssets.reqBox), size: s * 0.52, color: AppColors.text)),
    );
  }
}

/// "📅 Request Date: 15 Oct 2024" — [value] text, or [child] instead.
class RequestInfoLine extends StatelessWidget {
  const RequestInfoLine({super.key, required this.icon, required this.label, this.value = '', this.child});

  final TtGlyph icon;
  final String label;
  final String value;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final Widget? custom = child;
    final TextStyle labelStyle = StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText);
    return Padding(
      padding: EdgeInsetsDirectional.only(top: 6.h),
      child: Row(
        // 13/10/2026 (owner): a row with a widget value (Requested By: avatar
        // + name) centres the icon on it; a text row keeps the icon on the
        // first line of a wrapping value.
        crossAxisAlignment: custom == null ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsetsDirectional.only(top: custom == null ? 2.sp : 0),
            child: TtIcon(icon, size: 14.r, color: AppColors.secondaryText),
          ),
          SizedBox(width: 6.w),
          // 9/10/2026 (UI pass): label + value in ONE paragraph, so a long
          // value (a timeframe with times) wraps back to the start — never
          // "…", never a ragged second column.
          Expanded(
            child: custom == null
                ? Text.rich(
                    TextSpan(
                      text: '$label: ',
                      style: labelStyle,
                      children: <InlineSpan>[
                        TextSpan(text: value, style: StyleText.fontSize12Weight500.copyWith(color: AppColors.text)),
                      ],
                    ),
                  )
                : Row(
                    children: <Widget>[
                      Text('$label: ', style: labelStyle),
                      Expanded(child: custom),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// "14 All · 5 Approved · …" (core `StatusChipFilter`).
class RequestStatusCounters extends StatelessWidget {
  const RequestStatusCounters({
    super.key,
    required this.buckets,
    required this.counts,
    required this.selected,
    required this.onSelected,
  });

  final List<RequestBucket> buckets;
  final Map<RequestBucket, int> counts;
  final RequestBucket selected;
  final ValueChanged<RequestBucket> onSelected;

  @override
  Widget build(BuildContext context) {
    return TtOverflowFade(
      revealText: RequestText.bucketLabel(context, selected),
      child: _chips(context),
    );
  }

  Widget _chips(BuildContext context) {
    return StatusChipFilter(
      items: <StatusChipItem>[
        for (final RequestBucket b in buckets)
          StatusChipItem(
            key: b.name,
            label: RequestText.bucketLabel(context, b),
            count: counts[b] ?? 0,
            labelColor: RequestText.bucketColor(b),
          ),
      ],
      selectedKey: selected.name,
      onSelected: (String key) {
        HapticController.low();
        onSelected(RequestBucket.values.firstWhere((RequestBucket b) => b.name == key));
      },
    );
  }
}

/// Outlined action button: coloured border, icon + label (Figma Reject /
/// Approve). [high] = destructive haptic (Reject / Cancel).
class RequestOutlinedButton extends StatelessWidget {
  const RequestOutlinedButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.high = false,
    this.filled = false,
    this.fillColor,
  });

  final String label;
  final TtGlyph icon;
  final Color color;
  final VoidCallback onTap;
  final bool high;

  /// Yellow filled (Send Reminder) instead of outlined.
  final bool filled;

  /// 13/10/2026 (owner Q1, Figma `661:22112`): a solid [fillColor] with white
  /// content — the red "Cancel" (an outlined Cancel read as disabled).
  final Color? fillColor;

  @override
  Widget build(BuildContext context) {
    final Color? solid = fillColor;
    final Color fg = solid != null ? AppColors.white : (filled ? AppColors.textButton : color);
    return ShrinkOnTap(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          high ? HapticController.high() : HapticController.medium();
          onTap();
        },
        child: Container(
          height: ButtonSizing.height,
          padding: EdgeInsetsDirectional.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: solid ?? (filled ? AppColors.primary : AppColors.card),
            borderRadius: BorderRadiusDirectional.circular(8.r),
            border: filled || solid != null ? null : Border.all(color: color),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TtIcon(icon, size: icon.tinted ? 18.r : 22.r, color: fg),
              SizedBox(width: 6.w),
              Flexible(
                child: Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: StyleText.fontSize14Weight500.copyWith(color: fg)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The status as an outlined bar ("✓ Approved", "⊘ Rejected", …).
class RequestStatusPill extends StatelessWidget {
  const RequestStatusPill({super.key, required this.status});

  final RequestStatus status;

  /// 13/10/2026 (owner, Figma `661:22458` / `661:23161` / `661:22962`): the
  /// status badge — a full-colour circle with a white glyph.
  static String badgeOf(RequestStatus status) {
    switch (status) {
      case RequestStatus.approved:
        return TtAssets.statusApproved;
      case RequestStatus.rejected:
      case RequestStatus.canceled:
      case RequestStatus.canceledByHr:
        return TtAssets.statusCanceled;
      case RequestStatus.pending:
        return TtAssets.statusPending;
      case RequestStatus.underReview:
        return TtAssets.statusReview;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color color = RequestText.statusColor(status);
    // Figma: a 200-wide outlined button at the END of the card (not the
    // full width), badge 24 + label 16 Medium.
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: Container(
        key: ValueKey<String>('requestStatusPill_${status.storageKey}'),
        width: context.isPhone ? double.infinity : 200.w,
        height: ButtonSizing.height,
        padding: EdgeInsetsDirectional.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadiusDirectional.circular(8.r),
          border: Border.all(color: color),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TtIcon(TtGlyph.svg(badgeOf(status), tinted: false), size: 24.r),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(RequestText.statusLabel(context, status),
                  style: StyleText.fontSize16Weight500.copyWith(color: color)),
            ),
          ],
        ),
      ),
    );
  }
}

/// ADDED 13/10/2026 (owner Q1 / Q2 / I2): the details' action buttons. On a
/// phone ONE row of EQUAL columns across the full width (content centred);
/// on a tablet equal fixed-width buttons at the end of the card.
class RequestActionRow extends StatelessWidget {
  const RequestActionRow({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final bool phone = context.isPhone;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        for (int i = 0; i < children.length; i++) ...<Widget>[
          if (i > 0) SizedBox(width: 12.w),
          if (phone) Expanded(child: children[i]) else SizedBox(width: 170.w, child: children[i]),
        ],
      ],
    );
  }
}

/// ADDED 13/10/2026 (owner H3): "You Can Remind Again In 23 h 59 m" — shown
/// instead of Send Reminder while the 24-hour window is still running.
class RequestReminderCountdown extends StatelessWidget {
  const RequestReminderCountdown({super.key, required this.left});

  final Duration left;

  /// The wait for [lastReminderAt] now (null = a reminder may go now).
  static Duration? leftFor(DateTime? lastReminderAt) => RequestReminderRule.waitLeft(lastReminderAt, DateTime.now());

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    // Whole minutes, rounded up (never "0 m" while still waiting).
    final int minutes = (left.inSeconds + 59) ~/ 60;
    final String time = s.timeTrackerHoursMinutesShort(
      LocalizedNumber.of(context, minutes ~/ 60),
      LocalizedNumber.of(context, minutes % 60),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        TtIcon(const TtGlyph.svg(TtAssets.clock), size: 16.r, color: AppColors.secondaryText),
        SizedBox(width: 6.w),
        Flexible(
          child: Text(
            s.timeTrackerRemindAgainIn(time),
            style: StyleText.fontSize12Weight500.copyWith(color: AppColors.secondaryText),
          ),
        ),
      ],
    );
  }
}
