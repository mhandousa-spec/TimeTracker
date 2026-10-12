/// Module: database / db1_create_database / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: access_rule_fields.dart
/// Purpose: Declares `AccessRuleFields` and `SummaryTileRow`.
/// Author: Knowticed Plus team
/// Created at: 15/8/2026
///
/// The "Permissions + Start Date Of Access + End Date Of Access" block, and
/// the grey summary tiles above it.
///
/// The same block appears on four Figma frames — 7398:18600 (by department),
/// 7398:17988 (review, one rule), 7398:18213 (review, one rule per department
/// tab). Whether it edits every grant or just one department's is decided by
/// the caller passing [departmentId], not by this widget knowing which screen
/// it is on.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/3-custom_dropdown_calander.dart';
import 'package:knowticed_plus/core/custom/55-custom_responsive_fields.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/constants/create_database_constants.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_access_grant.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_permission_level.dart';

class AccessRuleFields extends StatelessWidget {
  const AccessRuleFields({
    super.key,
    required this.grant,
    required this.onPermissionChanged,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    this.enabled = true,
  });

  final DatabaseAccessGrant grant;
  final ValueChanged<DatabasePermissionLevel> onPermissionChanged;
  final ValueChanged<DateTime> onStartDateChanged;
  final ValueChanged<DateTime> onEndDateChanged;
  final bool enabled;

  /// The page colour — `CustomDropdown`'s own default fill — so the permission
  /// and date fields sit on the same tone as the search box above them rather
  /// than on a near-black of their own.
  Color get _fill => AppColors.background;

  TextStyle get _label =>
      StyleText.fontSize14Weight500.copyWith(color: AppColors.text);

  // ── Date bounds (16/8/2026) ───────────────────────────────────────────────
  //
  // Two rules, both enforced AT THE PICKER rather than reported afterwards — a
  // date you cannot tap is easier to understand than a date you tap and are
  // then told off for:
  //
  //   START  today at the earliest. Access cannot begin in the past; a grant
  //          backdated to last week either did nothing, or quietly claims
  //          people had access on days when they did not.
  //   END    the day AFTER the start at the earliest. The end date is the last
  //          day of access, so an end equal to the start is a grant that
  //          expires on the day it is given.
  //
  // BOTH BOUNDS YIELD TO A DATE THE GRANT ALREADY HOLDS. This block is shared
  // with db2's editing screens, where a grant written weeks ago legitimately
  // starts in the past — and `CustomDropdownCalendar` opens on `value`, so a
  // value below `firstDate` is a calendar asked to show a day outside its own
  // range. The rule is "you cannot PICK a past date", not "this record may not
  // contain one".

  DateTime get _today => DatabaseAccessGrant.dateOnly(DateTime.now());

  /// Earliest selectable start: today, unless the grant already holds an
  /// earlier one.
  DateTime get _startFirstDate {
    final DateTime? existing = grant.startDate;
    if (existing == null) return _today;

    final DateTime existingDay = DatabaseAccessGrant.dateOnly(existing);
    return existingDay.isBefore(_today) ? existingDay : _today;
  }

  /// Earliest selectable end: the day after the start — or the day after today
  /// while no start is chosen yet, so the second field cannot be used to
  /// smuggle in a past date before the first one is filled.
  DateTime get _endFirstDate {
    final DateTime start = grant.startDate == null
        ? _today
        : DatabaseAccessGrant.dateOnly(grant.startDate!);

    final DateTime dayAfterStart = start.add(const Duration(days: 1));

    final DateTime? existing = grant.endDate;
    if (existing == null) return dayAfterStart;

    final DateTime existingDay = DatabaseAccessGrant.dateOnly(existing);
    return existingDay.isBefore(dayAfterStart) ? existingDay : dayAfterStart;
  }

  @override
  Widget build(BuildContext context) {
    final CreateDatabaseStrings strings = CreateDatabaseStrings.of(context);
    final bool isArabic = context.isArabic;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // ── Permissions ───────────────────────────────────────────────────
        Text(strings.permissions, style: _label),
        SizedBox(height: 6.h),
        buildResponsiveFields(
          context: context,
          left: CustomDropdown<DatabasePermissionLevel>(
            value: grant.permission,
            hint: strings.choosePermissions,
            fillColor: _fill,
            enabled: enabled,
            valueStyle:
                StyleText.fontSize14Weight400.copyWith(color: AppColors.text),
            itemStyle:
                StyleText.fontSize14Weight400.copyWith(color: AppColors.text),
            items: DatabasePermissionLevel.selectable
                .map((DatabasePermissionLevel level) =>
                    DropdownItem<DatabasePermissionLevel>(
                      value: level,
                      label: isArabic ? level.labelAr : level.labelEn,
                    ))
                .toList(),
            onChanged: onPermissionChanged,
          ),
          right: const SizedBox.shrink(),
        ),
        SizedBox(height: 15.h),

        // ── Start / End date ──────────────────────────────────────────────
        // `CustomDropdownCalendar` (core/custom/3), not a hand-rolled field:
        // it renders its own label and an InputDecorator with the SAME
        // contentPadding and radius as `CustomDropdown` above, so Permissions
        // and the two date boxes line up pixel for pixel, and the dialog it
        // opens is the app's themed calendar with the right chevrons, Arabic
        // numerals and Set Date / Cancel buttons.
        buildResponsiveFields(
          context: context,
          left: CustomDropdownCalendar(
            label: strings.startDateOfAccess,
            labelStyle: _label,
            hint: strings.date,
            value: grant.startDate,
            fillColor: _fill,
            enabled: enabled,
            // No backdating — see the bounds block above.
            firstDate: _startFirstDate,
            // Its own default is dd/MM/yyyy; the Figma (7398:18213) shows
            // "26 Nov 2025", and that has to follow the language.
            dateFormatter: (DateTime date) => _formatDate(context, date),
            valueStyle:
                StyleText.fontSize14Weight400.copyWith(color: AppColors.text),
            hintStyle: StyleText.fontSize14Weight400
                .copyWith(color: AppColors.secondaryText),
            // The picker hands back null when the user clears the field; the
            // draft has no way to express "unset", so only real dates travel.
            onChanged: (DateTime? date) {
              if (date != null) onStartDateChanged(date);
            },
          ),
          right: CustomDropdownCalendar(
            label: strings.endDateOfAccess,
            labelStyle: _label,
            hint: strings.date,
            value: grant.endDate,
            fillColor: _fill,
            enabled: enabled,
            // Strictly AFTER the start, not merely "not before it" — the old
            // bound was `grant.startDate`, which let the two fields hold the
            // same day and produced a grant that expired on the day it was
            // given.
            firstDate: _endFirstDate,
            dateFormatter: (DateTime date) => _formatDate(context, date),
            valueStyle:
                StyleText.fontSize14Weight400.copyWith(color: AppColors.text),
            hintStyle: StyleText.fontSize14Weight400
                .copyWith(color: AppColors.secondaryText),
            onChanged: (DateTime? date) {
              if (date != null) onEndDateChanged(date);
            },
          ),
        ),

        if (grant.hasInvalidDateRange) ...<Widget>[
          SizedBox(height: 6.h),
          Text(
            strings.endBeforeStart,
            style:
                StyleText.fontSize12Weight400.copyWith(color: AppColors.red),
          ),
        ],
      ],
    );
  }
}

/// "26 Nov 2025" — the format the Figma shows (7398:18213), in the active
/// language.
///
/// Fed to `CustomDropdownCalendar.dateFormatter`; the widget's own default is
/// dd/MM/yyyy, which is not what the design asks for.
String _formatDate(BuildContext context, DateTime date) {
  const List<String> monthsEn = <String>[
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  const List<String> monthsAr = <String>[
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];
  final List<String> months = context.isArabic ? monthsAr : monthsEn;
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

/// The row of grey stat tiles above the review card — "Total Employees / 20",
/// "Access Management / Restricted Access" (7398:17988), growing to four on
/// the per-department variant (7398:18213).
class SummaryTileRow extends StatelessWidget {
  const SummaryTileRow({super.key, required this.tiles});

  final List<SummaryTile> tiles;

  @override
  Widget build(BuildContext context) {
    if (tiles.isEmpty) return const SizedBox.shrink();

    // PHONE (Figma 7398:13377): the four-tile review lays the tiles out 2 x 2,
    // each 150 wide in a 345 card — not four across. Four tiles squeezed into
    // a 345-wide row leaves ~78pt each, which cuts "Access Management" and
    // "Restricted Access" to two ellipsised lines. So the phone chunks the
    // list into rows of two; the two-tile review is unaffected either way.
    final int perRow = context.isPhone ? 2 : tiles.length;

    final List<List<SummaryTile>> rows = <List<SummaryTile>>[
      for (int i = 0; i < tiles.length; i += perRow)
        tiles.sublist(i, (i + perRow).clamp(0, tiles.length)),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int r = 0; r < rows.length; r++) ...<Widget>[
          if (r > 0) SizedBox(height: 12.h),
          _row(rows[r], perRow),
        ],
      ],
    );
  }

  /// One row of tiles, padded with blanks so a trailing odd tile keeps the
  /// column width of the row above instead of stretching to full bleed.
  Widget _row(List<SummaryTile> rowTiles, int perRow) {
    // `CrossAxisAlignment.stretch` tells the Row to size its children to the
    // Row's own height — but this Row lives inside a SingleChildScrollView,
    // where the height is UNBOUNDED. Stretching to infinity is what threw
    // "BoxConstraints forces an infinite height".
    //
    // IntrinsicHeight measures the tallest tile first and gives the Row that
    // as a bound, so `stretch` then means "as tall as the tallest tile" —
    // which is the equal-height row the Figma shows. It costs an extra layout
    // pass; with two to four tiles that is not worth optimising away.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (int i = 0; i < perRow; i++) ...<Widget>[
            if (i > 0) SizedBox(width: 12.w),
            Expanded(
              child: i < rowTiles.length
                  ? _Tile(tile: rowTiles[i])
                  : const SizedBox.shrink(),
            ),
          ],
        ],
      ),
    );
  }
}

class SummaryTile {
  const SummaryTile({required this.label, required this.value});

  final String label;
  final String value;
}

class _Tile extends StatelessWidget {
  const _Tile({required this.tile});

  final SummaryTile tile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 10.w),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            tile.label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: StyleText.fontSize12Weight400
                .copyWith(color: AppColors.secondaryText),
          ),
          SizedBox(height: 6.h),
          Text(
            tile.value,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style:
                StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
          ),
        ],
      ),
    );
  }
}
