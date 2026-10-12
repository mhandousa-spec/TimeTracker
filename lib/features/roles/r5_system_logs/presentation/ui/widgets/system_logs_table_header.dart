/// Module: roles / r5_system_logs / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: system_logs_table_header.dart
/// Purpose: Declares `SystemLogsTableHeader`.
/// Author: Knowticed Plus team
/// Created At: 12/8/2026
/// Updated: 30/8/2026 - Rebuilt as `DataTable` columns, copied verbatim from
///          `UserData` (r4_active_directory/.../tabs/user_data_tab.dart) so
///          the two tables are the same table: the label is a plain `Text`
///          in `StyleText.fontSize14Weight600` recoloured to
///          `AppColors.white`, padded 12.h / 8.w, start-aligned, and with NO
///          fixed cell width — `DataTable` measures each column from its own
///          content, which is what gives Active Directory its tight columns.
///          The old hand-painted `Container` header (its own rounded corners,
///          `colorBlack`/`totalBlack` ternary, 0.2.w slots and centred text)
///          is gone; the heading row is now painted by `DefaultDataTable`.
/// Updated: 30/8/2026 - Labels centred over their column (`headingRowAlignment`),
///          matching the values below them. Type size is unchanged at 14.sp.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/features/roles/r5_system_logs/domain/constants/system_logs_constants.dart';

/// The system logs table heading, as `DataTable` columns.
///
/// Not a widget any more: `DefaultDataTable` takes `List<DataColumn>`, and a
/// widget wrapper would only have to be unwrapped again at the call site.
/// The class is kept (rather than a bare top-level function) so the call reads
/// `SystemLogsTableHeader.columns()` and the file name still matches what it
/// declares.
abstract class SystemLogsTableHeader {
  /// White on `AppColors.header`, in both themes.
  ///
  /// `AppColors.header` already carries the light/dark split (0xff2D2D2D /
  /// 0xFF171717) and `DefaultDataTable` applies it as `headingRowColor`, so
  /// nothing here reads `Theme.of(context).brightness` — the old ternary
  /// between `colorBlack` and `totalBlack` was restating the palette.
  ///
  /// 14.sp — `font14BlackSemiBoldCairo` is exactly that, so the size is the
  /// style's, not a local `copyWith`.
  static TextStyle get _headerStyle =>
      StyleText.fontSize14Weight600.copyWith(color: AppColors.white);

  static List<DataColumn> columns() {
    return [
      for (final item in SystemLogsConstants.systemLogsItems)
        DataColumn(
          // CENTRED 30/8/2026: heading labels were start-aligned while the
          // column is as wide as its widest value, so a short heading ("Date")
          // sat hard against the edge of a column whose values now sit in the
          // middle. `DataTable` lays the heading out in a `Row`, which gives
          // its child unbounded width — a `Center` around the `Text` would
          // therefore centre nothing. `headingRowAlignment` is the knob that
          // moves the label itself, and it is direction-aware, so this reads
          // the same in Arabic.
          headingRowAlignment: MainAxisAlignment.center,
          label: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
            child: Text(
              item.name,
              style: _headerStyle,
              textAlign: TextAlign.center,
            ),
          ),
        ),
    ];
  }
}
