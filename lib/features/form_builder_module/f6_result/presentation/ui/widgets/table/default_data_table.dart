/// Module: form_builder_module / f6_result / presentation / ui / widgets / table
///
///*************************** FILE INFO ****************************///
/// File Name: default_data_table.dart
/// Purpose: Declares the Form Builder `DefaultDataTable`.
/// Updated: 26/9/2026 - Form bug report #31: now a thin wrapper around the
///          shared r4 `DefaultDataTable` (the table Services, System Logs and
///          Active Directory use), styled like the Services table: dark
///          AppColors.header band, centred 14.sp semibold white headings,
///          centred 12.sp semibold cells, striped rows, 10.sp rounded corners,
///          stretched to the available width. Callers keep passing plain
///          DataColumn/DataRow lists; this widget restyles them.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/helper/main_helper/arabic_number_format.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/ui/widgets/table/default_data_table.dart'
    as shared;
import 'package:knowticed_plus/generated/l10n.dart';

class DefaultDataTable extends StatelessWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final double? columnSpacing;

  const DefaultDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.columnSpacing,
  });

  bool get _isArabic => Get.locale?.languageCode == 'ar';

  TextStyle get _headerStyle =>
      StyleText.fontSize14Weight600.copyWith(color: AppColors.white);

  TextStyle _cellStyle(bool lightMode) => StyleText.fontSize12Weight600
      .copyWith(color: lightMode ? AppColors.black : AppColors.white);

  DataColumn _headerColumn(Widget label) {
    // Re-style whatever label the caller built: if it is a Text, keep its
    // string and apply the shared header style.
    final String text = label is Text ? (label.data ?? '') : '';
    return DataColumn(
      headingRowAlignment: MainAxisAlignment.center,
      label: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
        child: label is Text
            ? Text(text,
                style: _headerStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center)
            : label,
      ),
    );
  }

  DataCell _cell(DataCell cell, bool lightMode) {
    final child = cell.child;
    return DataCell(
      Center(
        child: child is Text
            ? Text(
                (child.data == null || child.data!.isEmpty) ? '-' : child.data!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: _cellStyle(lightMode),
              )
            : child,
      ),
      onTap: cell.onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;

    final List<DataColumn> allColumns = [
      _headerColumn(Text(S.of(context).number)),
      ...columns.map((c) => _headerColumn(c.label)),
    ];

    final List<DataRow> allRows = List.generate(rows.length, (i) {
      final isEven = i.isEven;
      final rowColor = lightMode
          ? (isEven ? AppColors.background : AppColors.white)
          : (isEven ? AppColors.darkDashboardTable : AppColors.black);
      final number = _isArabic
          ? ArabicDigits((i + 1).toString()).toArabicNumbers()
          : (i + 1).toString();
      return DataRow(
        color: WidgetStatePropertyAll(rowColor),
        onSelectChanged: rows[i].onSelectChanged,
        cells: [
          _cell(DataCell(Text(number)), lightMode),
          ...rows[i].cells.map((c) => _cell(c, lightMode)),
        ],
      );
    });

    return ClipRRect(
      borderRadius: BorderRadius.circular(10.sp),
      child: shared.DefaultDataTable(
        fillWidth: true,
        columns: allColumns,
        rows: allRows,
      ),
    );
  }
}
