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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/3-custom_dropdown_calander.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_date.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
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

  Future<void> _openCustom(BuildContext context) async {
    final DateSpan? picked = await CustomDialogManager.showContent<DateSpan>(
      context: context,
      width: 520,
      child: CustomRangeDialog(initial: customSpan()),
    );
    if (picked != null) onCustom(picked);
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

/// "Custom Date Selector": Start Date · End Date · Apply.
class CustomRangeDialog extends StatefulWidget {
  const CustomRangeDialog({super.key, this.initial});

  final DateSpan? initial;

  @override
  State<CustomRangeDialog> createState() => _CustomRangeDialogState();
}

class _CustomRangeDialogState extends State<CustomRangeDialog> {
  DateTime? _first;
  DateTime? _last;

  @override
  void initState() {
    super.initState();
    _first = widget.initial?.first;
    _last = widget.initial?.last;
  }

  Widget _field(String label, DateTime? value, ValueChanged<DateTime> onPick) =>
      CustomDropdownCalendar(
        label: label,
        value: value,
        hint: S.of(context).chooseDate,
        height: 36,
        dateFormatter: (DateTime d) => LocalizedDate.of(context, d),
        onChanged: (DateTime? d) {
          if (d != null) onPick(d);
        },
      );

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final DateTime? first = _first;
    final DateTime? last = _last;
    final bool ready = first != null && last != null;
    return ScaleInContent(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            s.timeTrackerCustomDateSelector,
            style: StyleText.fontSize18Weight500.copyWith(color: AppColors.text),
          ),
          SizedBox(height: 15.h),
          _field(s.timeTrackerStartDate, first, (DateTime d) => setState(() => _first = d)),
          SizedBox(height: 15.h),
          _field(s.timeTrackerEndDate, last, (DateTime d) => setState(() => _last = d)),
          SizedBox(height: 20.h),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: SizedBox(
              width: 150.w,
              child: ready
                  ? ShrinkOnTap(
                      child: customButton(
                        title: s.apply,
                        function: () => Navigator.of(context).pop(DateSpan(first, last)),
                        color: AppColors.primary,
                        textStyle: StyleText.fontSize16Weight500
                            .copyWith(color: AppColors.textButton),
                      ),
                    )
                  : customButton(
                      title: s.apply,
                      function: () {},
                      haptic: () {},
                      color: AppColors.disabledButton,
                      textStyle: StyleText.fontSize16Weight500
                          .copyWith(color: AppColors.colorGreyDark),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
