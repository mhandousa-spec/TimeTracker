/// Module: time_tracker / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_filter_frame.dart
/// Purpose: Declares the module's ONE filter-popup pattern: `TtFilterFrame`
///          (header · rows of fields · Reset / Apply), `TtFilterDropdown`
///          (a labelled "All"-first dropdown) and `TtDateRangeFields`
///          (From Date – To Date with its validation).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (UI quality pass — owner finding 13:45 #3: "the
///            same professional pattern" for the Requests, Approvals and
///            Attendance filters)
///
/// House rules: filters are compact dropdowns (values text only), dependent
/// fields ordered parent → child, fields side by side top-aligned (an error
/// never misaligns the row), field title 14 / value 12, validation = red
/// text under the field with Apply disabled (grey) while invalid; Reset grey
/// on the start side, Apply yellow on the end side (Cancel-left / Save-right
/// rule). Haptics: Reset LOW, Apply MEDIUM (core button). Scale-in (dialog
/// animation standard).

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/31-custom_multi_select_dropdown.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/3-custom_dropdown_calander.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_date.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_controls.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_setup_widgets.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Header "Filter", the field [rows] (each a `TtPair` or a single field),
/// then Reset (start) · Apply (end).
class TtFilterFrame extends StatelessWidget {
  const TtFilterFrame({
    super.key,
    required this.rows,
    required this.onReset,
    required this.onApply,
    this.canApply = true,
    this.applyKey,
  });

  final List<Widget> rows;
  final VoidCallback onReset;
  final VoidCallback onApply;

  /// False while a field is invalid (Apply grey, tap does nothing).
  final bool canApply;
  final Key? applyKey;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return ScaleInContent(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TtDialogHeader(title: s.filter, icon: AppAssets.filter),
          SizedBox(height: 15.h),
          for (int i = 0; i < rows.length; i++) ...<Widget>[
            if (i > 0) SizedBox(height: 15.h),
            rows[i],
          ],
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox(
                width: 130.w,
                child: customButton(
                  title: s.reset,
                  haptic: HapticController.low,
                  function: onReset,
                  color: AppColors.secondaryAction,
                  textStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.onSecondaryAction),
                ),
              ),
              SizedBox(
                width: 130.w,
                child: KeyedSubtree(
                  key: applyKey,
                  child: canApply
                      ? ShrinkOnTap(
                          child: customButton(
                            title: s.apply,
                            function: onApply,
                            color: AppColors.primary,
                            textStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.textButton),
                          ),
                        )
                      : customButton(
                          title: s.apply,
                          function: () {},
                          haptic: () {},
                          color: AppColors.disabledButton,
                          textStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.colorGreyDark),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A labelled dropdown whose first entry is "All" (= null).
class TtFilterDropdown<T> extends StatelessWidget {
  const TtFilterDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T? value;

  /// (value, text) in display order.
  final List<(T, String)> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return CustomDropdown<T?>(
      label: label,
      hint: s.timeTrackerAll,
      height: 36,
      itemStyle: StyleText.fontSize12Weight400,
      value: value,
      items: <DropdownItem<T?>>[
        DropdownItem<T?>(value: null, label: s.timeTrackerAll),
        for (final (T v, String text) in items) DropdownItem<T?>(value: v, label: text),
      ],
      onChanged: (T? v) {
        HapticController.low();
        onChanged(v);
      },
    );
  }
}

/// 13/10/2026 (owner): a MULTI-select filter field (core
/// `CustomMultiSelectDropdown`) — nothing picked reads "All"; one pick shows
/// its name; several read "Label (3)" (never a cut-off list).
class TtFilterMultiDropdown<T> extends StatelessWidget {
  const TtFilterMultiDropdown({
    super.key,
    required this.label,
    required this.values,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final Set<T> values;

  /// (value, text) in display order.
  final List<(T, String)> items;
  final ValueChanged<Set<T>> onChanged;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return CustomMultiSelectDropdown<T>(
      label: label,
      hint: s.timeTrackerAll,
      // Same grey field as the single-choice filters beside it.
      fillColor: kDropdownFillColor,
      height: 36,
      heightSizesWholeTrigger: true,
      itemStyle: StyleText.fontSize12Weight400,
      values: <T>[
        for (final (T v, String _) in items)
          if (values.contains(v)) v
      ],
      items: <MultiSelectDropdownItem<T>>[
        for (final (T v, String text) in items) MultiSelectDropdownItem<T>(value: v, label: text),
      ],
      selectedTextBuilder: (List<MultiSelectDropdownItem<T>> picked) =>
          picked.length == 1 ? picked.single.label : '$label (${picked.length})',
      onChanged: (List<T> v) {
        HapticController.low();
        onChanged(v.toSet());
      },
    );
  }
}

/// From Date · To Date, side by side; "To" before "From" shows the error
/// under To (the caller disables Apply through [isValid]).
class TtDateRangeFields extends StatelessWidget {
  const TtDateRangeFields({
    super.key,
    required this.from,
    required this.to,
    required this.onFrom,
    required this.onTo,
  });

  final DateTime? from;
  final DateTime? to;
  final ValueChanged<DateTime?> onFrom;
  final ValueChanged<DateTime?> onTo;

  /// Function Name: [isValid]
  ///
  /// Purpose: To is not before From (either may be empty).
  ///
  /// Return type: [bool]
  static bool isValid(DateTime? from, DateTime? to) =>
      from == null ||
      to == null ||
      !DateTime(to.year, to.month, to.day).isBefore(DateTime(from.year, from.month, from.day));

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    Widget field(String label, DateTime? value, ValueChanged<DateTime?> onChanged, {String? error}) =>
        CustomDropdownCalendar(
          label: label,
          hint: s.chooseDate,
          value: value,
          height: 36,
          errorText: error,
          dateFormatter: (DateTime d) => LocalizedDate.of(context, d),
          onChanged: onChanged,
        );
    return TtPair(
      start: field(s.timeTrackerDateFrom, from, onFrom),
      end: field(s.timeTrackerDateTo, to, onTo, error: isValid(from, to) ? null : s.timeTrackerDateRangeError),
    );
  }
}

/// MOVED 13/10/2026 from the HR dashboard (owner: every Department filter is
/// multi-select): a toolbar multi-select — toolbar height + radius, card
/// fill; "Department (2)" when several are picked; nothing picked = all.
class TtToolbarMultiFilter extends StatelessWidget {
  const TtToolbarMultiFilter({
    super.key,
    required this.hint,
    required this.values,
    required this.items,
    required this.onChanged,
  });

  final String hint;
  final Set<String> values;

  /// Id → name.
  final Map<String, String> items;
  final ValueChanged<Set<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    return CustomMultiSelectDropdown<String>(
      hint: hint,
      height: TtToolbar.height,
      heightSizesWholeTrigger: true,
      borderRadius: TtToolbar.radius,
      fillColor: AppColors.card,
      itemStyle: StyleText.fontSize12Weight400,
      values: <String>[
        for (final String v in values)
          if (items.containsKey(v)) v
      ],
      items: <MultiSelectDropdownItem<String>>[
        for (final MapEntry<String, String> e in items.entries)
          MultiSelectDropdownItem<String>(value: e.key, label: e.value),
      ],
      selectedTextBuilder: (List<MultiSelectDropdownItem<String>> picked) =>
          picked.length == 1 ? picked.single.label : '$hint (${picked.length})',
      onChanged: (List<String> v) {
        HapticController.low();
        onChanged(v.toSet());
      },
    );
  }
}
