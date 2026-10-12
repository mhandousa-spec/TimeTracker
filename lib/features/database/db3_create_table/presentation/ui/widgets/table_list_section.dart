/// Module: database / db3_create_table / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: table_list_section.dart
/// Purpose: Declares `TableListSection` and `TableCard`.
/// Author: Knowticed Plus team
/// Created at: 16/8/2026
/// Updated: 17/8/2026 - Rewritten as the Figma's CARD GRID. See below.
///
/// The tables inside a database, on the "Database Name Details" screen —
/// Figma 7398:2183 / 7398:1270 (iPad H 1024), 7398:2349 / 7398:1382 (iPad V
/// 768).
///
/// WHY THIS IS NO LONGER A TABLE (17/8/2026)
/// -----------------------------------------
/// It used to be a nine-column `DataTable` — NO / Table Name / Columns / Rows /
/// Comments / Members / Creation Date / Last Edit / Access — built on the
/// reasoning that the Figma's own grid in that spot was a placeholder borrowed
/// from another module. That reading was half right and drew the wrong
/// conclusion.
///
/// The placeholder grid is on the TABLE DETAILS screen (7398:4102), one level
/// down, where it stands in for the rows inside one table. On THIS screen the
/// design has never drawn a table at all: 7398:2183 lays the tables out as
/// CARDS, three across, each carrying the name, "No. of Rows", "No. of
/// Columns", a creation date and a last-edit date — the same card shape db1
/// uses for databases one level up, which is what makes the two screens read as
/// one module. So the grid is the design, and the columns that had nowhere to
/// go — Comments, Members, Access — moved to where the design puts them: the
/// four tiles and the Access button on the table's own details screen.
///
/// The card OPENS that screen. It has one action, so the whole card is the
/// target rather than a chevron: a 100pt card is a far easier hit than an 18pt
/// glyph, and there is nothing else on it to compete for the tap.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/custom/69-cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/custom/87-responsive_card_grid.dart';
import 'package:knowticed_plus/core/custom/89-custom_empty_state.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/constants/database_details_constants.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/constants/create_table_constants.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/database_table_entity.dart';
import 'package:knowticed_plus/features/database/db3_create_table/presentation/controller/table_list_cubit.dart';

class TableListSection extends StatelessWidget {
  const TableListSection({
    super.key,
    required this.state,
    required this.onTableTap,
    required this.onRetry,
  });

  final TableListState state;

  /// Opens "Table Name Details" for that table (Figma 7398:4102).
  ///
  /// UPDATED 17/8/2026. It used to open the Editing Table Name card directly,
  /// which skipped the screen the design puts in between — the one carrying the
  /// description, the tiles, the rows and the Comments button. Edit is still
  /// one tap away; it is a button on that screen now, where the Figma draws it.
  final ValueChanged<DatabaseTableEntity> onTableTap;

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final CreateTableStrings strings = CreateTableStrings.of(context);
    final bool isArabic = context.isArabic;

    if (state.isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: const CircleProgressMaster(),
      );
    }

    // A failed read is retried, not mistaken for an empty collection — the same
    // distinction db2's access screen makes, and the reason this is a block with
    // a button rather than the empty-state animation.
    if (state.hasError) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 32.h),
        child: Column(
          children: <Widget>[
            Text(
              state.errorMessage ?? strings.tablesLoadFailed,
              textAlign: TextAlign.center,
              style: StyleText.fontSize14Weight400
                  .copyWith(color: AppColors.secondaryText),
            ),
            SizedBox(height: 16.h),
            customButton(title: strings.retry, function: onRetry),
          ],
        ),
      );
    }

    final List<DatabaseTableEntity> tables = state.visible;

    // One animation for both "nothing here yet" and "nothing matched what you
    // typed" (16/8/2026). They used to be two sentences on the grounds that
    // the second is fixable by the user — but the search box they just typed
    // into is right above this, so the distinction was being drawn for someone
    // who could already see it.
    if (tables.isEmpty) return const CustomEmptyState();

    // Four text rows: the name, then three label-and-value lines. The card has
    // no thumbnail — the Figma's table card does not carry one, unlike db1's
    // database card — so nothing sets a floor and the height is purely what the
    // text needs.
    final double cardHeight = ResponsiveCardHeight.of(
      context,
      textLineSizes: <double>[14.sp, 11.sp, 11.sp, 11.sp],
      gapSizes: <double>[6.sp, 4.sp, 4.sp],
      verticalPadding: 24,
      lowerBound: 96,
      upperBound: 160,
    );

    return GridView.builder(
      // The section lives inside the details page's own scroll view, so it must
      // not scroll itself — it lays every card out and lets the page carry
      // them. Without this pair the grid claims an unbounded height and throws.
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: tables.length,
      gridDelegate: ResponsiveCardHeight.delegate(
        // The same helper db1's database grid uses, so the two screens break
        // to one, two and three columns at the same widths rather than each
        // reflowing on its own schedule.
        crossAxisCount:
            CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(context),
        cardHeight: 80.sp,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
      ),
      itemBuilder: (BuildContext context, int index) => TableCard(
        table: tables[index],
        strings: strings,
        isArabic: isArabic,
        onTap: () => onTableTap(tables[index]),
      ),
    );
  }
}

/// One table card — name, row and column counts, and the two dates
/// (Figma 7398:2183, `Frame 1597883018` and its siblings).
class TableCard extends StatelessWidget {
  const TableCard({
    super.key,
    required this.table,
    required this.strings,
    required this.isArabic,
    required this.onTap,
  });

  final DatabaseTableEntity table;
  final CreateTableStrings strings;
  final bool isArabic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      // Opaque so taps landing on the card's padding and on the gaps between
      // its text rows open the table too — without it only the glyphs
      // themselves would be hittable.
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.all(12.sp),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: CardStyles.shadow,
        ),
        child: ResponsiveCardContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      FormatHelper.capitalize(
                        table.localizedName(isArabic: isArabic),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: StyleText.fontSize14Weight500
                          .copyWith(color: AppColors.text),
                    ),
                  ),
                  // The module glyph, small and muted. The Figma's card is text
                  // only; this is the one addition, and it earns its place by
                  // telling a card apart from db1's database card at a glance —
                  // the two are the same shape on two screens one tap apart.
                  // CustomSvgImage(
                  //   assetPath: DatabaseDetailsAssets.databaseGlyph,
                  //   width: 16.r,
                  //   height: 16.r,
                  //   color: AppTheme.isDark
                  //       ? AppColors.secondaryText
                  //       : AppColors.disabledGrey,
                  // ),
                ],
              ),
              SizedBox(height: 6.h),

              // Rows and Columns share a line at the Figma's width and stack
              // below it. `Wrap` rather than a Row with a breakpoint: the two
              // pairs are short, and letting them fall is exactly what the
              // narrow card needs without a second layout to maintain.
              Wrap(
                spacing: 16.w,
                runSpacing: 4.h,
                children: <Widget>[
                  _line(strings.cardRows, '${table.rowCount}'),
                  _line(strings.cardColumns, '${table.columnCount}'),
                ],
              ),
              SizedBox(height: 4.h),

              // Both dates are `Flexible`, not a pair of intrinsic widths with
              // a `Spacer` between them (17/8/2026). The phone card is the full
              // 345 with ONE per row (Figma 7398:1674: "Creation Date:" at
              // x=26, "Last Edit:" at x=273) and in Arabic the two labels plus
              // two dates are wider than that — a `Spacer` cannot shrink, so
              // the line overflowed instead of ellipsising. Flexible lets each
              // half give way; the `_line` widgets already ellipsise.
              Row(
                children: <Widget>[
                  Flexible(
                    child: _line(
                      strings.creationDateLabel,
                      DatabaseDateFormat.short(
                        table.createdAt,
                        isArabic: isArabic,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Flexible(
                    child: _line(
                      strings.lastEditLabel,
                      // Falls back to the creation date, the same rule
                      // `DatabaseInfoCard` follows: a record's last write IS
                      // its creation until something edits it, so the two
                      // dates agreeing is the truth rather than a
                      // substitution.
                      DatabaseDateFormat.short(
                        table.updatedAt ?? table.createdAt,
                        isArabic: isArabic,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// "Label: value" on ONE line.
  ///
  /// Both halves are the same size and only the weight and colour separate
  /// them — muted 400 for the label, full-contrast 600 for the value — which is
  /// the treatment db1's database card uses. They stay on one line because
  /// "No. of Rows:" on its own says nothing and "100" on its own says nothing
  /// either.
  Widget _line(String label, String value) => Text.rich(
        TextSpan(
          text: '$label ',
          style: StyleText.fontSize11Weight400
              .copyWith(color: AppColors.secondaryText),
          children: <InlineSpan>[
            TextSpan(
              text: value.isEmpty ? '—' : value,
              style:
                  StyleText.fontSize11Weight600.copyWith(color: AppColors.text),
            ),
          ],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
}
