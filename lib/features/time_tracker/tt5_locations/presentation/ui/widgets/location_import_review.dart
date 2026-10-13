/// Module: time_tracker / tt5_locations / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: location_import_review.dart
/// Purpose: Declares `LocationImportReview` — the Locations import's
///          bulk-upload review (the shared `TtImportReview`): every column of
///          the file, the row's result, red cells with the reason; editing a
///          cell re-checks the file at once ([LocationImportReview.onEdited]).
/// Author: Knowticed Plus team
/// Created at: 13/10/2026
///
/// Owner (13/10/2026): "after upload, show the bulk-upload section with the
/// columns and the errors" — the house CRM bulk-upload pattern
/// (`crm_bulk_upload_table.dart`: total badge, header row, editable
/// `CustomTextField` cells, red warning icon). Values never end in "…"
/// (they wrap); one column gap (`ttTableColumnGap`).

import 'package:flutter/material.dart';

import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/location_form_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/location_import_rules.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_import_review.dart';
import 'package:knowticed_plus/features/time_tracker/tt5_locations/presentation/ui/widgets/location_form_fields.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class LocationImportReview extends StatelessWidget {
  const LocationImportReview({super.key, required this.grid, required this.plan, required this.onEdited});

  /// The uploaded file (first row = headings).
  final List<List<String>> grid;

  /// The check of [grid] (`LocationsCubit.planImport`).
  final LocationImportPlan plan;

  /// The file after a cell was edited.
  final ValueChanged<List<List<String>>> onEdited;

  /// The name of an import action ("New", "Update", "No Change", "Skipped").
  static String actionText(S s, LocationImportAction a) {
    switch (a) {
      case LocationImportAction.create:
        return s.timeTrackerImportActionCreate;
      case LocationImportAction.update:
        return s.timeTrackerImportActionUpdate;
      case LocationImportAction.unchanged:
        return s.timeTrackerImportActionUnchanged;
      case LocationImportAction.skip:
        return s.timeTrackerImportActionSkip;
    }
  }

  static Color actionColor(LocationImportAction a) {
    switch (a) {
      case LocationImportAction.create:
        return AppColors.lightGreen;
      case LocationImportAction.update:
        return AppColors.blue;
      case LocationImportAction.unchanged:
        return AppColors.secondaryText;
      case LocationImportAction.skip:
        return AppColors.red;
    }
  }

  /// What is wrong, in words.
  static String problemText(S s, LocationImportIssue issue) {
    if (identical(issue, LocationImportIssue.duplicateName)) return s.timeTrackerImportDuplicate;
    final LocationFormError? e = issue.error;
    // Unreadable values (and coordinates out of range) name their column.
    if (e == null || e == LocationFormError.latitudeInvalid || e == LocationFormError.longitudeInvalid) {
      return s.timeTrackerImportUnreadable(issue.column?.heading ?? '');
    }
    return LocationFormErrorText.of(s, e);
  }

  static LocationImportColumn? _columnOf(String heading) {
    final String h = heading.trim().toLowerCase();
    for (final LocationImportColumn c in LocationImportColumn.values) {
      if (c.heading.toLowerCase() == h) return c;
    }
    return null;
  }

  static double _width(LocationImportColumn? c) {
    switch (c) {
      case LocationImportColumn.nameEn:
      case LocationImportColumn.nameAr:
      case LocationImportColumn.googleMapsUrl:
        return 220;
      case LocationImportColumn.country:
      case LocationImportColumn.city:
      case LocationImportColumn.workingDays:
        return 190;
      default:
        return 160;
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final List<LocationImportColumn?> columns = <LocationImportColumn?>[
      for (final String h in grid.first) _columnOf(h),
    ];
    final Map<int, TtImportReviewRow> rows = <int, TtImportReviewRow>{};
    for (final LocationImportRow r in plan.rows) {
      // Problems by column; the ones without a column of the file go under
      // the row's status.
      final Map<int, List<String>> byCell = <int, List<String>>{};
      final List<String> general = <String>[];
      for (final LocationImportIssue issue in r.issues) {
        final int at = issue.column == null ? -1 : columns.indexOf(issue.column);
        final String text = problemText(s, issue);
        if (at >= 0) {
          (byCell[at] ??= <String>[]).add(text);
        } else {
          general.add(text);
        }
      }
      rows[r.line] = TtImportReviewRow(
        status: actionText(s, r.action),
        color: actionColor(r.action),
        cellProblems: byCell,
        rowProblems: general,
      );
    }
    return TtImportReview(
      keyPrefix: 'locationImport',
      grid: grid,
      rows: rows,
      totals: <(String, Color)>[
        for (final LocationImportAction a in LocationImportAction.values)
          ('${actionText(s, a)}: ${LocalizedNumber.of(context, plan.count(a))}', actionColor(a)),
      ],
      columnWidth: (int i) => _width(columns[i]),
      rtl: <int>{
        for (int i = 0; i < columns.length; i++)
          if (columns[i] == LocationImportColumn.nameAr) i,
      },
      onEdited: onEdited,
    );
  }
}
