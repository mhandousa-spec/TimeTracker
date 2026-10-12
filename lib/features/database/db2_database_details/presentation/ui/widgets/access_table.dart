/// Module: database / db2_database_details / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: access_table.dart
/// Purpose: Declares `AccessTable` and `AccessStatusBadge`.
/// Author: Knowticed Plus team
/// Created at: 16/8/2026
///
/// The eight-column access table — Figma `Group 1597882843`, drawn inside
/// 7398:10662 (iPad V) and 7398:10875 (iPad H):
///
///   Employee Name | Department | Access Grantor |
///   Start Date Of Access | End Date Of Access | Access Type | Access Status
///
/// THE PICTURE LIVES IN THE NAME COLUMN (17/8/2026)
/// ------------------------------------------------
/// The Figma draws "Employee Picture" as a column of its own, and it was built
/// that way. It is now the avatar in front of the name, inside the Name column,
/// and the separate column is gone.
///
/// A face is part of identifying a person, not a fact about them: on its own it
/// bought a heading nobody could read ("Employee Pictu…", ellipsised at that
/// width) and 90pt of horizontal scroll to say what the name beside it already
/// said. The same change was made to `MemberAccessRuleList`'s table on
/// 16/8/2026, so the two tables in this section now match.
///
/// IT SCROLLS SIDEWAYS, ON PURPOSE
/// -------------------------------
/// The table in the Figma is 1191pt wide inside a 1024 frame and 768 frame
/// respectively — the designer drew it overflowing both, and the 768 screenshot
/// cuts off mid-way through "Start Date Of A…". Eight columns of dates and
/// names do not fit an iPad in either orientation and no amount of squeezing
/// makes them: at 768/8 each column gets 96pt, which ellipsises every name.
///
/// So the columns keep readable widths and the table scrolls horizontally,
/// which is what `DefaultDataTable` in the active-directory module already
/// does for the same reason. This is modelled on that widget — same dark
/// heading band, same 46.h rows, same zero dividers — rather
/// than importing it, because that one belongs to another feature's widget
/// folder and this one needs an alternating row fill and a status badge it
/// does not have.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/46-custom_image_picker.dart';
import 'package:knowticed_plus/core/custom/89-custom_empty_state.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_permission_level.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/constants/database_details_constants.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/entities/database_access_row.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/enums/database_access_status.dart';

class AccessTable extends StatelessWidget {
  const AccessTable({super.key, required this.rows});

  final List<DatabaseAccessRow> rows;

  // `emptyLabel` REMOVED 16/8/2026. It used to distinguish "nobody has access
  // yet" from "no rows match this filter"; both are now the shared animation,
  // which is the same answer the empty table itself was already giving. The
  // caller keeps its own branch for a FAILED read — that one is not emptiness
  // and must not look like it.

  @override
  Widget build(BuildContext context) {
    final DatabaseDetailsStrings strings = DatabaseDetailsStrings.of(context);
    final bool isArabic = context.isArabic;

    if (rows.isEmpty) return const CustomEmptyState();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8.r),
          topRight: Radius.circular(8.r),
        ),
        child: DataTable(
          // ONE HEADING COLOUR FOR EVERY TABLE IN THIS MODULE (17/8/2026).
          // Black in light mode, `blackShadow` in dark — the same pair
          // `TableRowsGrid` and `MemberAccessRuleList` use, so the three
          // tables a user meets inside one database cannot drift apart.
          // It replaced `AppColors.header`, which was a shade lighter in dark
          // mode and made this table's band look like a different component.
          headingRowColor: WidgetStatePropertyAll<Color>(
            AppTheme.isDark ? AppColors.blackShadow : AppColors.black,
          ),
          // Zebra striping comes from the ROW, not from this property, because
          // `DataRow.color` is resolved per row and this one is not — see
          // `_row`. Set to transparent so the two do not fight.
          dataRowColor:
              WidgetStatePropertyAll<Color>(AppColors.transparent),
          dataRowMinHeight: 46.h,
          dataRowMaxHeight: 46.h,
          headingRowHeight: 46.h,
          horizontalMargin: 16.w,
          columnSpacing: 28.w,
          dividerThickness: 0,
          showCheckboxColumn: false,
          border: TableBorder(
            horizontalInside: BorderSide(
              width: 0,
              color: AppColors.transparent,
            ),
          ),
          columns: <DataColumn>[
            // No picture column — the face is inside the name cell. See the
            // file header.
            _column(strings.colName),
            _column(strings.colDepartment),
            _column(strings.colGrantor),
            _column(strings.colStart),
            _column(strings.colEnd),
            _column(strings.colAccessType),
            _column(strings.colAccessStatus),
          ],
          rows: <DataRow>[
            for (int i = 0; i < rows.length; i++)
              _row(context, rows[i], i, isArabic),
          ],
        ),
      ),
    );
  }

  DataColumn _column(String label) => DataColumn(
        label: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          // The heading band is dark in BOTH themes (black light /
          // `blackShadow` dark), so the heading text is white in both rather
          // than following the body text colour.
          style: StyleText.fontSize12Weight500.copyWith(color: AppColors.white),
        ),
      );

  DataRow _row(
    BuildContext context,
    DatabaseAccessRow row,
    int index,
    bool isArabic,
  ) {
    final bool dark = AppTheme.isDark;
    final Color stripe = index.isEven
        ? (dark ? AppColors.tableRowDark : AppColors.evenRowColor)
        : (dark ? AppColors.tableDarkBackground : AppColors.oddRowColor);

    // A revoked row is still readable but visibly inactive — the red badge
    // says what happened, the muted text says it is history. Without this the
    // "All" view mixes current and revoked access at identical weight, which
    // is the one thing an access list must not do.
    final Color textColor =
        row.isRemoved ? AppColors.secondaryText : AppColors.text;

    return DataRow(
      color: WidgetStatePropertyAll<Color>(stripe),
      cells: <DataCell>[
        // Face and name in ONE cell. `MainAxisSize.min` so the cell still
        // measures to its content — a DataTable column is as wide as its widest
        // cell, and an unbounded Row here would stretch the column to the
        // table's full scroll width.
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _avatar(row),
              SizedBox(width: 8.w),
              Flexible(
                child: _text(
                  FormatHelper.capitalize(
                    row.member.localizedName(isArabic: isArabic),
                  ),
                  textColor,
                ),
              ),
            ],
          ),
        ),
        DataCell(_text(row.departmentName, textColor)),
        DataCell(_text(row.grantorName, textColor)),
        DataCell(_text(
          DatabaseDateFormat.short(row.startDate, isArabic: isArabic),
          textColor,
        )),
        DataCell(_text(
          DatabaseDateFormat.short(row.endDate, isArabic: isArabic),
          textColor,
        )),
        DataCell(_text(_permissionLabel(row.permission, isArabic), textColor)),
        DataCell(AccessStatusBadge(status: row.status)),
      ],
    );
  }

  Widget _avatar(DatabaseAccessRow row) {
    final String? photo = row.member.photoUrl;

    // `foregroundImage` plus an SVG child, NOT `backgroundImage`: the app's
    // default avatar (`AppAssets.defaultEmployeeAvatar`) is an SVG, which
    // `AssetImage` cannot decode. A foreground image draws OVER the child, so
    // the placeholder shows while the photo loads and stays visible if the URL
    // 404s — the same arrangement `PersonChipCard` uses, which is why these
    // rows match the people cards elsewhere in the module.
    return CircleAvatar(
      radius: 14.r,
      backgroundColor: AppColors.moreLightGrey,
      foregroundImage: (photo == null || photo.isEmpty)
          ? null
          : appImageProvider(photo),
      child: ClipOval(
        child: CustomSvgImage(
          assetPath: AppAssets.defaultEmployeeAvatar,
          width: 28.r,
          height: 28.r,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _text(String value, Color color) => Text(
        value.isEmpty ? '—' : value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: StyleText.fontSize12Weight400.copyWith(color: color),
      );

  /// The "Access Type" column.
  ///
  /// The Figma writes "Full Access" and "View" where the app's enum says
  /// "Admin" and "Viewer" — the same three levels under the words the
  /// Permissions popover uses (Figma 7398:8029: View / Edit / Export / Full
  /// Access). The enum's own labels are used rather than a second vocabulary,
  /// so the value in this column always matches what the dropdown that set it
  /// said. Changing the wording is one edit in
  /// `DatabasePermissionLevel.labelEn`, not a lookup table here that could
  /// disagree with it.
  String _permissionLabel(DatabasePermissionLevel? level, bool isArabic) {
    if (level == null) return '';
    return isArabic ? level.labelAr : level.labelEn;
  }
}

/// The coloured word in the last column — green Active, red Deactivated, dark
/// red Removed, yellow Scheduled (Figma `Group 1597882843`).
///
/// Colour-only status is unreadable to anyone who cannot separate red from
/// green, so the word carries the meaning and the colour reinforces it; that
/// is why this is tinted TEXT rather than a coloured dot.
class AccessStatusBadge extends StatelessWidget {
  const AccessStatusBadge({super.key, required this.status});

  final DatabaseAccessStatus status;

  @override
  Widget build(BuildContext context) {
    return Text(
      status.localizedLabel(isArabic: context.isArabic),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: StyleText.fontSize12Weight500.copyWith(color: colorFor(status)),
    );
  }

  /// Shared with the chip row above the table, so a chip and the rows it
  /// selects can never be different colours.
  static Color colorFor(DatabaseAccessStatus status) {
    switch (status) {
      case DatabaseAccessStatus.active:
        return AppColors.green;
      case DatabaseAccessStatus.deactivated:
        return AppColors.red;
      case DatabaseAccessStatus.removed:
        return AppColors.darkRed;
      case DatabaseAccessStatus.scheduled:
        return AppColors.primary;
    }
  }
}
