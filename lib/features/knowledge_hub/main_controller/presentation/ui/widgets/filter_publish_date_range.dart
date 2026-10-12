/// Module: knowledge_hub / main_controller / presentation / ui / widgets
/// ************************* FILE INFO *************************** ///
/// File Name: filter_publish_date_range.dart
/// Purpose: "Publish date" From/To range row inside FilterSearchDialog.
/// Author: Knowticed Plus team
/// Created At: 28/8/2026
///
/// Lives beside filter_search_dialog.dart rather than in
/// filter_search_dialog_widgets/ so the whole filter row stays in one file the
/// dialog can read at a glance.
///
/// The two fields deliberately copy DateTimePicker's field chrome (14sp label,
/// 6h gap, 36-high background-filled box, calendar glyph trailing, dd MMM yyyy)
/// so the row reads as part of the same form as the dropdowns above it instead
/// of as a bolted-on control.

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/53-custom_date_pic.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// The publish-date range row: `From` and `To`, side by side on desktop and
/// tablet, stacked on phones — the same responsive rule the dropdown row above
/// it follows.
///
/// Both ends are optional and independent. Picking only [fromDate] means
/// "published on or after"; only [toDate] means "published on or before".
/// A small clear (×) appears on a field once it holds a date, because a range
/// with no way back to "any date" is a trap: the only other way out would be
/// Reset, which also throws away the document type and department the user
/// picked.
class FilterPublishDateRange extends StatelessWidget {
  final bool isMobile;
  final bool lightMode;
  final DateTime? fromDate;
  final DateTime? toDate;
  final ValueChanged<DateTime?> onFromChanged;
  final ValueChanged<DateTime?> onToChanged;

  const FilterPublishDateRange({
    super.key,
    required this.isMobile,
    required this.lightMode,
    required this.fromDate,
    required this.toDate,
    required this.onFromChanged,
    required this.onToChanged,
  });

  @override
  Widget build(BuildContext context) {
    final Widget fromField = _dateField(
      context,
      label: '${S.of(context).publish_date} - ${S.of(context).from}',
      value: fromDate,
      // The start of the range has no lower bound of its own — documents can
      // have been published at any time in the past.
      firstSelectable: null,
      onPicked: (picked) {
        onFromChanged(picked);

        // Keep the range coherent: a `from` moved past the existing `to` would
        // leave a window that can never match anything, and the user would see
        // an empty list with no hint why. Clearing the far end is the quieter
        // fix — the field visibly empties, so the change is not silent.
        if (picked != null && toDate != null && picked.isAfter(toDate!)) {
          onToChanged(null);
        }
      },
    );

    final Widget toField = _dateField(
      context,
      label: '${S.of(context).publish_date} - ${S.of(context).to}',
      value: toDate,
      // The end of the range cannot precede its start.
      firstSelectable: fromDate,
      onPicked: onToChanged,
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          fromField,
          SizedBox(height: 15.h),
          toField,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: fromField),
        SizedBox(width: 15.w),
        Expanded(child: toField),
      ],
    );
  }

  Widget _dateField(
    BuildContext context, {
    required String label,
    required DateTime? value,
    required DateTime? firstSelectable,
    required ValueChanged<DateTime?> onPicked,
  }) {
    // CHANGED 12/9/2026 — ON PHONES THE LABEL IS THE PLACEHOLDER.
    //
    // "Publish Date - From" sat above the box and "Select Date" inside it, so
    // an empty field spent two lines saying one thing, in a dialog that is
    // already a tall stack of six controls on a phone. The label text now goes
    // inside as the hint and the line above is dropped: the field still names
    // itself while empty, and once a date is picked the date replaces it, the
    // same way the dropdowns above swap their hint for the chosen value.
    //
    // Tablet and desktop keep the label line — there the two fields sit side
    // by side with room to spare, and a hint that disappears on selection
    // would leave an unlabelled date in a row of labelled fields.
    final bool labelAbove = !isMobile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelAbove) ...[
          Text(
            label,
            style: StyleText.fontSize14Weight400.copyWith(
              color: lightMode ? AppColors.blackButton : AppColors.white,
            ),
          ),
          SizedBox(height: 6.h),
        ],
        InkWell(
          onTap: () => _pickDate(
            context,
            current: value,
            firstSelectable: firstSelectable,
            onPicked: onPicked,
          ),
          child: Container(
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.r),
              // CHANGED 12/9/2026 — on phones the field takes the DROPDOWN's
              // own fill rather than its own copy of the colour, so the date
              // row and the three dropdowns above it can never drift apart.
              color: isMobile ? kDropdownFillColor : AppColors.background,
            ),
            padding: EdgeInsetsDirectional.only(start: 16.sp,end: 10.sp),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value != null
                        ? DateFormat('dd MMM yyyy').format(value)
                        : (labelAbove ? S.of(context).selectdate : label),
                    overflow: TextOverflow.ellipsis,
                    style: StyleText.fontSize12Weight400.copyWith(
                      color:
                      AppColors.secondaryText.withOpacity(0.5),
                    ),
                  ),
                ),
                // Clear (×) only once there is something to clear, so an empty
                // field shows the plain calendar glyph the rest of the app uses.
                if (value != null)
                  GestureDetector(
                    onTap: () => onPicked(null),
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(end: 4.w),
                      child: Icon(
                        Icons.close,
                        size: 16.sp,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ),
                CustomSvgImage(
                  assetPath:
                      'assets/icons_assets/main_icons_assets/images_Calendar.svg',
                  width: 20.w,
                  height: 20.h,
                  fit: BoxFit.fill,
                  // CHANGED 12/9/2026 — on phones the calendar glyph follows
                  // the dropdown chevron's rule (dim while empty, normal once
                  // a date is picked). It used to be full-opacity
                  // secondaryText, which read heavier than the chevrons
                  // sitting right above it in the same dialog.
                  color: isMobile
                      ? kDropdownTrailingIconColor(hasValue: value != null)
                      : AppColors.secondaryText,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate(
    BuildContext context, {
    required DateTime? current,
    required DateTime? firstSelectable,
    required ValueChanged<DateTime?> onPicked,
  }) async {
    final DateTime today = DateTime.now();

    // Opening on the value already in the field (or today when empty) puts the
    // calendar where the user last was rather than at an arbitrary month.
    final DateTime initial = current ?? firstSelectable ?? today;

    final List<DateTime?>? picked = await DatePicker().showDatePicker(
      context,
      [initial],
      initial,
      CalendarDatePicker2Type.single,
      // Null lets DatePicker fall back to its own DateTime(1900) floor, which
      // is what the start of the range wants — publish dates are historical.
      firstDate: firstSelectable == null
          ? null
          : DateTime(
              firstSelectable.year,
              firstSelectable.month,
              firstSelectable.day,
            ),
    );

    if (picked != null && picked.isNotEmpty && picked.first != null) {
      final DateTime day = picked.first!;
      // Store the DAY only. applyFilters is what widens the `to` end to the end
      // of its day; keeping a stray time here would make the two ends of the
      // range behave differently depending on when the picker happened to run.
      onPicked(DateTime(day.year, day.month, day.day));
    }
  }
}
