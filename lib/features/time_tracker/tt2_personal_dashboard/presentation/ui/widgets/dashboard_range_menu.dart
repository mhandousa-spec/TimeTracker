/// Module: time_tracker / tt2_personal_dashboard / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: dashboard_range_menu.dart
/// Purpose: Declares `DashboardRangeMenu` — the "Time" dropdown (Day · Week ·
///          Month · Year · Custom) — and `CustomRangeDialog`, the "Custom
///          Date Selector" with Apply.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Figma `661:35168` (menu, white 100-wide button, radius 8) and `661:35259`
/// (custom selector). Both are core widgets: `CustomDropdown` and
/// `CustomDropdownCalendar` (dates "16 Oct 2026" via `LocalizedDate`).
/// Apply stays disabled until both dates are picked (owner form rule).
/// Updated: 9/10/2026 - phase 5: the dropdown itself is
/// `DashboardRangeDropdown` (value + callbacks) so the HR dashboard reuses
/// it; `DashboardRangeMenu` binds it to the personal dashboard as before.
/// Updated: 9/10/2026 - owner review: toolbar dropdowns take the toolbar's
/// one height + corner radius (`TtToolbar` — same as Search / Export / Import).
/// Updated: 13/10/2026 - owner review: Custom is one date-range picker
/// (`CustomDropdownRangeCalendar.showRangePicker`); the Start / End dialog
/// is gone.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/4-custom_dropdown_range_calander.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/dashboard_range.dart';
import 'package:knowticed_plus/features/time_tracker/tt2_personal_dashboard/presentation/controller/personal_dashboard_cubit.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_controls.dart';

class DashboardRangeMenu extends StatelessWidget {
  const DashboardRangeMenu({super.key});

  static String label(BuildContext context, DashboardRange range) {
    final S s = S.of(context);
    switch (range) {
      case DashboardRange.day:
        return s.timeTrackerRangeDay;
      case DashboardRange.week:
        return s.timeTrackerRangeWeek;
      case DashboardRange.month:
        return s.timeTrackerRangeMonth;
      case DashboardRange.year:
        return s.timeTrackerRangeYear;
      case DashboardRange.custom:
        return s.timeTrackerRangeCustom;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PersonalDashboardCubit, PersonalDashboardState>(
      buildWhen: (PersonalDashboardState a, PersonalDashboardState b) =>
          a.range != b.range,
      builder: (BuildContext context, PersonalDashboardState state) {
        final PersonalDashboardCubit cubit = context.read<PersonalDashboardCubit>();
        return DashboardRangeDropdown(
          key: const ValueKey<String>('timeTrackerRangeMenu'),
          range: state.range,
          customSpan: () => cubit.state.customSpan,
          onRange: cubit.selectRange,
          onCustom: (DateSpan s) => cubit.applyCustom(s.first, s.last),
        );
      },
    );
  }
}

/// ADDED 9/10/2026 (phase 5): the same "Time" dropdown, bound to any owner
/// (the HR dashboard reuses it with its own cubit). Custom opens
/// [CustomRangeDialog] and reports the picked span.
class DashboardRangeDropdown extends StatelessWidget {
  const DashboardRangeDropdown({
    super.key,
    required this.range,
    required this.customSpan,
    required this.onRange,
    required this.onCustom,
    this.width,
  });

  final DashboardRange range;

  /// ADDED 9/10/2026 (UI pass): the trigger width (null = 130; the HR filter
  /// row passes `double.infinity` so every control shares the row evenly).
  final double? width;

  /// The current custom span (pre-fills the dialog).
  final DateSpan? Function() customSpan;
  final ValueChanged<DashboardRange> onRange;
  final ValueChanged<DateSpan> onCustom;

  /// 13/10/2026 (owner review): "Custom" opens ONE date-range picker (the
  /// core range calendar) — no Start Date / End Date form in between. One
  /// tapped day = that single day.
  Future<void> _openCustom(BuildContext context) async {
    final DateSpan? current = customSpan();
    final List<DateTime?>? picked = await CustomDropdownRangeCalendar.showRangePicker(
      context,
      start: current?.first,
      end: current?.last,
    );
    final DateTime? first = (picked == null || picked.isEmpty) ? null : picked.first;
    if (first == null) return;
    final DateTime last = (picked!.length > 1 ? picked[1] : null) ?? first;
    onCustom(DateSpan(first, last));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 130.w,
      child: CustomDropdown<DashboardRange>(
        hint: S.of(context).timeTrackerRangeTime,
        height: TtToolbar.height,
        borderRadius: TtToolbar.radius,
        fillColor: AppColors.card,
        itemStyle: StyleText.fontSize12Weight400,
        value: range,
        items: <DropdownItem<DashboardRange>>[
          for (final DashboardRange r in DashboardRange.values)
            DropdownItem<DashboardRange>(value: r, label: DashboardRangeMenu.label(context, r)),
        ],
        onChanged: (DashboardRange? r) {
          if (r == null) return;
          HapticController.low();
          if (r == DashboardRange.custom) {
            _openCustom(context);
          } else {
            onRange(r);
          }
        },
      ),
    );
  }
}
