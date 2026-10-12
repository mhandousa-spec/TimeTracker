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
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/request_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_list_rules.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_tab_strip.dart';
import 'package:knowticed_plus/features/time_tracker/tt9_requests/presentation/ui/widgets/request_text.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_controls.dart';

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
      child: Center(child: TtIcon(const TtGlyph.svg(TtAssets.edit), size: s * 0.55, color: AppColors.text)),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsetsDirectional.only(top: 2.sp),
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
  });

  final String label;
  final TtGlyph icon;
  final Color color;
  final VoidCallback onTap;
  final bool high;

  /// Yellow filled (Send Reminder) instead of outlined.
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final Color fg = filled ? AppColors.textButton : color;
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
            color: filled ? AppColors.primary : AppColors.card,
            borderRadius: BorderRadiusDirectional.circular(8.r),
            border: filled ? null : Border.all(color: color),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TtIcon(icon, size: 18.r, color: fg),
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

  // No OUTLINE status icons exist in the app's assets (only filled colour
  // badges), so these stay Material (code review 9/10/2026).
  static TtGlyph iconOf(RequestStatus status) {
    switch (status) {
      case RequestStatus.approved:
        return const TtGlyph.icon(Icons.check_circle_outline);
      case RequestStatus.rejected:
        return const TtGlyph.icon(Icons.block);
      case RequestStatus.canceled:
      case RequestStatus.canceledByHr:
        return const TtGlyph.icon(Icons.cancel_outlined);
      case RequestStatus.pending:
      case RequestStatus.underReview:
        return const TtGlyph.icon(Icons.hourglass_empty);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color color = RequestText.statusColor(status);
    return Container(
      key: ValueKey<String>('requestStatusPill_${status.storageKey}'),
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
          TtIcon(iconOf(status), size: 18.r, color: color),
          SizedBox(width: 6.w),
          Text(RequestText.statusLabel(context, status),
              style: StyleText.fontSize14Weight500.copyWith(color: color)),
        ],
      ),
    );
  }
}
