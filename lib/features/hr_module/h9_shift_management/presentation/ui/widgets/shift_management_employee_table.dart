// ***************************** FILE INFO ***************************** //
// File Name: shift_management_employee_table.dart
// Purpose: Displays assigned employees and their resolved shift details.
// Author: Mohamed Elrashidy
// Created At: 2026-08-24
// ********************************************************************* //

import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:knowticed_plus/features/hr_module/h2_employees/presentation/ui/widgets/hr_table_viewport.dart';
import 'package:knowticed_plus/features/hr_module/h2_employees/utils/hr_table_display_value.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../utils/shift_employee_table_row.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

/// Displays assigned employees in the Shift Management table layout.
class ShiftManagementEmployeeTable extends StatelessWidget {
  const ShiftManagementEmployeeTable({
    required this.rows,
    required this.showBranch,
    super.key,
  });

  final List<ShiftEmployeeTableRow> rows;
  final bool showBranch;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return SizedBox(height: 180.h);
    }

    final departmentCubit = Get.find<MainCoreDepartmentCubit>();
    final localization = S.of(context);
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final columns = <String>[
      localization.number,
      localization.employeeId,
      localization.firstName,
      localization.lastName,
      localization.department,
      localization.jobTitle,
      if (showBranch) localization.branch,
      localization.startTime,
      localization.endTime,
    ];

    return HrTableViewport(
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8.r),
          topRight: Radius.circular(8.r),
        ),
        child: DataTable(
          border: TableBorder(
            horizontalInside: BorderSide(
              width: 0,
              color: Theme.of(context).brightness == Brightness.light
                  ? AppColors.white
                  : AppColors.totalBlack,
            ),
          ),
          headingRowColor: WidgetStatePropertyAll(AppColors.header),
          dataRowMinHeight: 46.h,
          dataRowMaxHeight: 46.h,
          headingRowHeight: 46.h,
          horizontalMargin: 16.w,
          columnSpacing: 36.w,
          dividerThickness: 0,
          columns: columns
              .map((column) => DataColumn(label: _header(context, column)))
              .toList(),
          rows: rows.indexed.map((entry) {
            final index = entry.$1;
            final row = entry.$2;
            final employee = row.employee;
            final values = [
              '${index + 1}',
              employee.id ?? '',
              employee.firstNameForLanguage(isEnglish: isEnglish),
              employee.lastNameForLanguage(isEnglish: isEnglish),
              _departmentName(
                employee.departmentId,
                departmentCubit,
                isEnglish: isEnglish,
              ),
              employee.jobTitleForLanguage(isEnglish: isEnglish),
              if (showBranch) row.branch.name,
              row.shift.toEntity().startTimeLabel,
              row.shift.toEntity().endTimeLabel,
            ];
            return DataRow(
              color: WidgetStatePropertyAll(
                index.isEven ? AppColors.evenRowColor : AppColors.oddRowColor,
              ),
              cells: [
                ...values.map((value) => DataCell(_value(value,
                    capitalize: value != values[1] && value != values[0]))),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Method Name: [_departmentName]
  ///
  /// Purpose: Resolves the employee department through shared HR data.
  ///
  /// Parameters:
  /// - [departmentId]: Stable department identifier.
  /// - [departmentCubit]: Shared department resolver.
  /// - [isEnglish]: Whether to resolve the English department name.
  ///
  /// Returns: The localized department name, or an empty value.
  String _departmentName(
      String? departmentId, MainCoreDepartmentCubit departmentCubit,
      {required bool isEnglish}) {
    if (departmentId == null ||
        !departmentCubit.departmentIds.contains(departmentId)) {
      return '';
    }
    return departmentCubit.getDepartmentName(departmentId, isEnglish);
  }

  /// Method Name: [_header]
  ///
  /// Purpose: Builds the shared dark table header cell.
  ///
  /// Parameters:
  /// - [value]: Localized header label.
  ///
  /// Returns: Styled table header text.
  Widget _header(BuildContext context, String value) => Text(
        value,
        style: StyleText.fontSize14Weight600.copyWith(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.white
              : AppColors.textButton,
        ),
      );

  /// Method Name: [_value]
  ///
  /// Purpose: Builds a constrained employee table value cell.
  ///
  /// Parameters:
  /// - [value]: Raw value to display.
  /// - [capitalize]: Whether human-readable text may be formatted.
  ///
  /// Returns: Styled table value cell.
  Widget _value(String value, {required bool capitalize}) => SizedBox(
        height: 46.h,
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            HrTableDisplayValue.format(value, capitalize: capitalize),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: StyleText.fontSize14Weight600,
          ),
        ),
      );
}
