/// Module: time_tracker / tt13_vacation_balances / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: vacation_balance_text.dart
/// Purpose: Declares `VacationBalanceText` — the Vacation Balances columns,
///          table cells and export cells in the app language, so the table
///          and its CSV always match.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (phase 5)
///
/// Columns (brief §B): No · Employee Name · Department · Year · Total Days ·
/// Used · Remaining. Numbers with localized digits on screen ("٢١" in
/// Arabic), plain in the CSV (machine-readable, like the import template).
/// Remaining is red at 0 (nothing left), green otherwise, grey while no
/// balance is set.

import 'package:flutter/widgets.dart';

import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/vacation_balance_list_rules.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_formatters.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_setup_widgets.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_table.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class VacationBalanceText {
  const VacationBalanceText._();

  /// "21" / "2.5", localized digits.
  static String days(BuildContext context, double value) =>
      LocalizedNumber.digits(context, VacationBalanceList.days(value));

  /// Function Name: [headers]
  ///
  /// Return type: [List<String>] — every column title except "No".
  static List<String> headers(BuildContext context) {
    final S s = S.of(context);
    return <String>[
      s.timeTrackerEmployeeName,
      s.timeTrackerDepartment,
      s.timeTrackerRangeYear,
      s.timeTrackerTotalDays,
      s.timeTrackerUsedDays,
      s.timeTrackerRemainingDays,
    ];
  }

  /// Function Name: [columns]
  ///
  /// Return type: [List<TtColumn>] — the table columns ("No" first).
  static List<TtColumn> columns(BuildContext context) {
    final List<String> h = headers(context);
    return <TtColumn>[
      TtColumn(S.of(context).timeTrackerColumnNo, 50),
      TtColumn(h[0], 230),
      TtColumn(h[1], 150),
      TtColumn(h[2], 80),
      TtColumn(h[3], 100),
      TtColumn(h[4], 90),
      TtColumn(h[5], 100),
    ];
  }

  /// Function Name: [tableCells]
  ///
  /// Return type: [List<TtCell>] — row [index] of the table.
  static List<TtCell> tableCells(BuildContext context, int index, VacationBalanceRow r) {
    final bool ar = Localizations.localeOf(context).languageCode == 'ar';
    final double left = r.balance.remainingDays;
    return <TtCell>[
      TtCell(LocalizedNumber.of(context, index + 1)),
      // 13/10/2026 (owner): the employee's photo beside the name, as on the
      // cards.
      TtCell.widget(TtPersonCell(photo: r.employee.photo, name: r.employee.name(isArabic: ar))),
      TtCell(TimeTrackerFormat.orDash(r.employee.department(isArabic: ar))),
      TtCell(LocalizedNumber.digits(context, '${r.balance.year}')),
      TtCell(days(context, r.balance.totalDays)),
      TtCell(days(context, r.balance.usedDays)),
      TtCell(days(context, left), color: remainingColor(r)),
    ];
  }

  /// Remaining: red when a stored balance is used up, green while days are
  /// left, grey when no balance is set yet (nothing to warn about).
  static Color remainingColor(VacationBalanceRow r) {
    if (!r.isStored) return AppColors.secondaryText;
    return r.balance.remainingDays <= 0 ? AppColors.red : AppColors.lightGreen;
  }

  /// Function Name: [exportCells]
  ///
  /// Return type: [List<String>] — one CSV row (without "No").
  static List<String> exportCells(BuildContext context, VacationBalanceRow r) {
    final bool ar = Localizations.localeOf(context).languageCode == 'ar';
    return <String>[
      r.employee.name(isArabic: ar),
      r.employee.department(isArabic: ar),
      '${r.balance.year}',
      VacationBalanceList.days(r.balance.totalDays),
      VacationBalanceList.days(r.balance.usedDays),
      VacationBalanceList.days(r.balance.remainingDays),
    ];
  }
}
