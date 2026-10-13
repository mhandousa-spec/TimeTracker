/// Module: time_tracker / tt5_locations / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: location_form_fields.dart
/// Purpose: Declares the Location form parts that are not plain text fields:
///          `TtLabeledTimeField` (Work Start / End Time), `TtWorkingDaysChips`
///          (Sun … Sat) and `TtFieldError`.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Owner-approved additions to Figma `661:39468` (decisions 13 / 22). Chips
/// share one height and radius 8 (owner rule); a selected chip is yellow
/// with `AppColors.textButton` text; LOW haptic on toggle. Weekday names
/// come from `intl` in the app language, Sunday first.
/// Updated: 9/10/2026 - QA KP-TT-005: a chip hugs its label (its `Container`
/// used `alignment`, which made every chip as wide as the form — seven
/// stacked full-width bars on iPad portrait); QA KP-TT-006:
/// `TtSearchPickerDialog` — a searchable list for long option lists (the
/// ~250 countries).

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/location_form_rules.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_controls.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_time_field.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// A red error line under a field.
class TtFieldError extends StatelessWidget {
  const TtFieldError(this.message, {super.key});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final String? text = message;
    if (text == null) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsetsDirectional.only(top: 4.h),
      child: Text(text, style: StyleText.fontSize12Weight400.copyWith(color: AppColors.red)),
    );
  }
}

/// "Work Start Time" + the 12-hour time field (minutes since midnight).
class TtLabeledTimeField extends StatelessWidget {
  const TtLabeledTimeField({
    super.key,
    required this.label,
    required this.minutes,
    required this.onChanged,
    this.error,
  });

  final String label;

  /// Null = not picked yet (13/10/2026: a new location starts empty).
  final int? minutes;
  final ValueChanged<int> onChanged;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: EdgeInsetsDirectional.only(bottom: kFieldLabelGap.sp),
          child: Text(label, style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text)),
        ),
        TimeTrackerTimeField(
          value: minutes == null ? null : TimeOfDay(hour: minutes! ~/ 60, minute: minutes! % 60),
          hint: S.of(context).chooseTime,
          hasError: error != null,
          onPicked: (TimeOfDay t) => onChanged(t.hour * 60 + t.minute),
        ),
        TtFieldError(error),
      ],
    );
  }
}

/// "Working Days": Sun · Mon · Tue · Wed · Thu · Fri · Sat chips.
class TtWorkingDaysChips extends StatelessWidget {
  const TtWorkingDaysChips({
    super.key,
    required this.selected,
    required this.onToggle,
    this.error,
  });

  final List<int> selected;
  final ValueChanged<int> onToggle;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final String locale = Localizations.localeOf(context).languageCode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: EdgeInsetsDirectional.only(bottom: kFieldLabelGap.sp),
          child: Text(S.of(context).timeTrackerWorkingDays,
              style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text)),
        ),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: <Widget>[
            for (final int day in LocationFormRules.weekOrder)
              _chip(
                // 1 Jan 2024 was a Monday → day d of that week.
                DateFormat('EEE', locale).format(DateTime(2024, 1, day)),
                day,
              ),
          ],
        ),
        TtFieldError(error),
      ],
    );
  }

  Widget _chip(String label, int day) {
    final bool on = selected.contains(day);
    return GestureDetector(
      key: ValueKey<String>('workingDay_$day'),
      onTap: () {
        HapticController.low();
        onToggle(day);
      },
      child: Container(
        height: 32.h,
        constraints: BoxConstraints(minWidth: 52.w),
        // KP-TT-005 (9/10/2026): no `alignment` here — it made the chip fill
        // the whole Wrap width. `Center(widthFactor: 1)` hugs the label.
        padding: EdgeInsetsDirectional.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: on ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadiusDirectional.circular(8.r),
        ),
        child: Center(
          widthFactor: 1,
          child: Text(
            label,
            style: StyleText.fontSize12Weight500
                .copyWith(color: on ? AppColors.textButton : AppColors.secondaryText),
          ),
        ),
      ),
    );
  }
}

/// ADDED 9/10/2026 (QA KP-TT-006): a searchable list of [options] (value →
/// label in the app language) for a long dropdown — type to filter, tap a
/// row to choose it (the dialog pops with its value). Rows are plain text,
/// so screen readers read them.
class TtSearchPickerDialog extends StatefulWidget {
  const TtSearchPickerDialog({
    super.key,
    required this.title,
    required this.searchHint,
    required this.options,
    this.selected,
  });

  final String title;
  final String searchHint;

  /// (value, label) in display order.
  final List<(String, String)> options;
  final String? selected;

  @override
  State<TtSearchPickerDialog> createState() => _TtSearchPickerDialogState();
}

class _TtSearchPickerDialogState extends State<TtSearchPickerDialog> {
  final TextEditingController _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  List<(String, String)> get _shown {
    final String q = _query.text.trim().toLowerCase();
    if (q.isEmpty) return widget.options;
    return <(String, String)>[
      for (final (String, String) o in widget.options)
        if (o.$2.toLowerCase().contains(q) || o.$1.toLowerCase() == q) o,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final List<(String, String)> shown = _shown;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(widget.title, style: StyleText.fontSize16Weight500.copyWith(color: AppColors.text)),
        SizedBox(height: 12.h),
        Row(children: <Widget>[
          TtSearchField(
            key: const ValueKey<String>('searchPickerField'),
            controller: _query,
            hint: widget.searchHint,
            fillColor: AppColors.background,
            onChanged: (_) => setState(() {}),
          ),
        ]),
        SizedBox(height: 10.h),
        SizedBox(
          height: 360.h,
          child: shown.isEmpty
              ? Center(
                  child: Text(S.of(context).noResults,
                      style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText)),
                )
              : ListView.builder(
                  itemCount: shown.length,
                  itemBuilder: (BuildContext context, int i) {
                    final (String value, String label) = shown[i];
                    final bool on = value == widget.selected;
                    return GestureDetector(
                      key: ValueKey<String>('searchPickerItem_$value'),
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        HapticController.low();
                        Navigator.of(context).pop(value);
                      },
                      child: Padding(
                        padding: EdgeInsetsDirectional.symmetric(vertical: 10.h, horizontal: 8.w),
                        child: Text(
                          label,
                          style: (on ? StyleText.fontSize12Weight500 : StyleText.fontSize12Weight400)
                              .copyWith(color: on ? AppColors.primary : AppColors.text),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// ADDED 13/10/2026: the message of each location form / import problem —
/// one place, so the form and the import review say the same thing.
class LocationFormErrorText {
  const LocationFormErrorText._();

  static String of(S s, LocationFormError e) {
    switch (e) {
      case LocationFormError.nameEnRequired:
        return s.timeTrackerNameRequired;
      case LocationFormError.nameArRequired:
        return s.timeTrackerArabicNameRequired;
      case LocationFormError.latitudeInvalid:
        return s.timeTrackerLatitudeInvalid;
      case LocationFormError.longitudeInvalid:
        return s.timeTrackerLongitudeInvalid;
      case LocationFormError.coordinatesRequired:
        return s.timeTrackerCoordinatesRequired;
      case LocationFormError.radiusRequired:
        return s.timeTrackerRadiusRequired;
      case LocationFormError.workTimesSame:
        return s.timeTrackerWorkTimesSame;
      case LocationFormError.workingDaysRequired:
        return s.timeTrackerWorkingDaysRequired;
      case LocationFormError.breakLengthRequired:
        return s.timeTrackerBreakLengthRequired;
      case LocationFormError.mapsUrlInvalid:
        return s.timeTrackerMapsUrlInvalid;
      case LocationFormError.lateAfterTooLong:
        return s.timeTrackerLateAfterTooLong;
      case LocationFormError.pauseTooLong:
        return s.timeTrackerPauseTooLong;
      case LocationFormError.countryRequired:
        return s.countryRequired;
      case LocationFormError.stateRequired:
        return s.stateRequired;
      case LocationFormError.cityRequired:
        return s.cityRequired;
      case LocationFormError.workStartRequired:
        return s.timeTrackerWorkStartRequired;
      case LocationFormError.workEndRequired:
        return s.timeTrackerWorkEndRequired;
    }
  }
}
