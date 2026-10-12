/// Module: GRC Policy Management
/// Description: Start Date + End Date paired row for the Add/Edit Control
///              form (Edit mode only), extracted from AddEditControlPage.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-15
/// Dependencies: flutter, CustomDropdownCalendar
/// Revision History: 2026-07-15 - Initial creation (inline in
///                                add_edit_control_page.dart)
///                   2026-07-27 - Split out into its own widget file
library;

/// ************************* FILE INFO *************************** ///
/// File Name: control_date_row_widget.dart
/// Purpose: Contains ControlDateRowWidget, the Start Date / End Date paired
///          row shown only in Edit mode.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 27/7/2026

import 'package:knowticed_plus/core/custom/3-custom_dropdwon_calander.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:knowticed_plus/generated/l10n.dart';

/// class name: [ControlDateRowWidget]
///
/// purpose: renders the Start Date + End Date paired row — Edit mode only.
///
/// NOTE: intentionally NOT routed through `GrcResponsiveFieldRow`. The
/// tablet layout passes a `dateFormatter` to each `CustomDropdownCalendar`
/// that the phone layout omits, so the two branches build genuinely
/// different widgets and can't share a single children list. Preserved
/// exactly as it was inline in AddEditControlPage — this is a pure move,
/// not a behavior change.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 27/7/2026
class ControlDateRowWidget extends StatelessWidget {
  final bool isTablet;
  final DateTime? startDate;
  final DateTime? endDate;
  final ValueChanged<DateTime?> onStartDateChanged;
  final ValueChanged<DateTime?> onEndDateChanged;
  final DateTime firstDate;
  final DateTime lastDate;
  final String? startDateError;
  final String? endDateError;

  const ControlDateRowWidget({
    super.key,
    required this.isTablet,
    required this.startDate,
    required this.endDate,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    required this.firstDate,
    required this.lastDate,
    required this.startDateError,
    required this.endDateError,
  });

  @override
  Widget build(BuildContext context) {
    return isTablet
        ? Row(children: [
            Expanded(
              child: CustomDropdownCalendar(
                borderRadius: BorderRadius.circular(4.r),
                label: S.of(context).startDate,
                hint: S.of(context).selectStartDate,
                value: startDate,
                onChanged: onStartDateChanged,
                fillColor: AppColors.background,
                firstDate: firstDate,
                lastDate: lastDate,
                dateFormatter: (d) => intl.DateFormat('d MMM yyyy').format(d),
                errorText: startDateError,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: CustomDropdownCalendar(
                borderRadius: BorderRadius.circular(4.r),
                label: S.of(context).endDate,
                hint: S.of(context).selectEndDate,
                value: endDate,
                onChanged: onEndDateChanged,
                fillColor: AppColors.background,
                firstDate: startDate ?? firstDate,
                lastDate: lastDate,
                dateFormatter: (d) => intl.DateFormat('d MMM yyyy').format(d),
                errorText: endDateError,
              ),
            ),
          ])
        : Column(children: [
            CustomDropdownCalendar(
              borderRadius: BorderRadius.circular(4.r),
              label: S.of(context).startDate,
              hint: S.of(context).selectStartDate,
              value: startDate,
              onChanged: onStartDateChanged,
              fillColor: AppColors.background,
              firstDate: firstDate,
              lastDate: lastDate,
              errorText: startDateError,
            ),
            SizedBox(height: 15.h),
            CustomDropdownCalendar(
              borderRadius: BorderRadius.circular(4.r),
              label: S.of(context).endDate,
              hint: S.of(context).selectEndDate,
              value: endDate,
              onChanged: onEndDateChanged,
              fillColor: AppColors.background,
              firstDate: startDate ?? firstDate,
              lastDate: lastDate,
              errorText: endDateError,
            ),
          ]);
  }
}
