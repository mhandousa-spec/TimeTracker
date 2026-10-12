/// Module: database / db3_create_table / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: table_info_card.dart
/// Purpose: Declares `TableInfoCard`.
/// Author: Knowticed Plus team
/// Created at: 17/8/2026
///
/// The white summary card on "Table Name Details" and the "Hide" / "Expand"
/// link above it — Figma 7398:4102 (open, iPad H), 7398:4690 (collapsed),
/// 7398:17048 / 4498 (the 768 twins).
///
/// BOTH STATES ARE THIS WIDGET
/// ---------------------------
/// Collapsed is not "the card, hidden". The Figma replaces it with a labelled
/// row — "Table Details" on the leading edge, "Expand" on the trailing one — so
/// something still says what the link would bring back. Rendering the two states
/// from one widget keeps that link in the same place in both, which is the whole
/// reason the toggle is usable. Same construction as db2's `DatabaseInfoCard`,
/// one level up.
///
/// WHAT IS DIFFERENT FROM db2's CARD
/// ---------------------------------
/// No thumbnail — a table has no cover picture — and one addition: the yellow
/// "Comments" button on the trailing bottom corner, which is the only way into
/// the Comments screen (7398:8232). The dates also swap corners: "Last Edit" is
/// the top-right line and "Creation Date" the bottom-left one, which is what the
/// Figma draws and, unlike db2's card, is not just where a thumbnail left room.
///
/// The description is NOT clipped to a line count, for the same reason db2's is
/// not: the field takes 500 characters and a card that silently truncated would
/// make "Hide" the only way to find out there was more.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/constants/database_details_constants.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/constants/create_table_constants.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/database_table_entity.dart';

class TableInfoCard extends StatelessWidget {
  const TableInfoCard({
    super.key,
    required this.table,
    required this.isExpanded,
    required this.onToggle,
    required this.onCommentsPressed,
  });

  final DatabaseTableEntity table;
  final bool isExpanded;
  final VoidCallback onToggle;

  /// Opens the Comments screen for this table.
  final VoidCallback onCommentsPressed;

  @override
  Widget build(BuildContext context) {
    final CreateTableStrings strings = CreateTableStrings.of(context);
    final bool isArabic = context.isArabic;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            // Only the collapsed frame carries a label; when the card is open
            // it names itself. The Spacer keeps the link on the trailing edge
            // in both, which is what makes it hittable without looking.
            if (!isExpanded)
              Text(
                strings.tableDetails,
                style: StyleText.fontSize12Weight400
                    .copyWith(color: AppColors.text),
              ),
            const Spacer(),
            GestureDetector(
              onTap: onToggle,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                // The link is 11pt text in the Figma — far under a comfortable
                // tap target on its own — so the padding is the hit area
                // rather than a visual gap.
                padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 4.w),
                child: Text(
                  isExpanded ? strings.hide : strings.expand,
                  style: StyleText.fontSize12Weight500.copyWith(
                    color: AppColors.blue,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.blue,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (isExpanded) ...<Widget>[
          SizedBox(height: 6.h),
          _card(strings, isArabic),
        ],
      ],
    );
  }

  Widget _card(CreateTableStrings strings, bool isArabic) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: CardStyles.shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  FormatHelper.capitalize(
                    table.localizedName(isArabic: isArabic),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: StyleText.fontSize16Weight500
                      .copyWith(color: AppColors.text),
                ),
              ),
              // "Last Edit", falling back to the creation date — a record's
              // last write IS its creation until something edits it, so the
              // two dates agreeing is the truth rather than a substitution.
              // The guard stays for the one case with no answer: a record with
              // neither date, which is a read that came back half-empty.
              if ((table.updatedAt ?? table.createdAt) != null)
                Padding(
                  padding: EdgeInsetsDirectional.only(start: 8.w),
                  child: _labelled(
                    strings.lastEditLabel,
                    DatabaseDateFormat.short(
                      table.updatedAt ?? table.createdAt,
                      isArabic: isArabic,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 8.h),
          _description(strings, isArabic),
          SizedBox(height: 12.h),

          // The date and the button share the bottom line at the Figma's width
          // and stack below it, rather than the button being pushed off the
          // edge of a narrow card. `Wrap` with the two ends aligned is what
          // gives that for free — `alignment: spaceBetween` puts them on
          // opposite corners while there is room and lets them fall when there
          // is not.
          //
          // IT WAS A `Row` UNTIL 17/8/2026, which is not what that paragraph
          // describes and not what it did. A `Row` with a `Spacer` cannot let
          // anything fall: the date takes its intrinsic width, the button takes
          // its own, and on the phone card (345 wide, Figma 7398:1701 — date at
          // x=25, "Comments" 95 wide at x=255) an Arabic date overran the line
          // and painted the overflow stripes across the bottom of the card.
          // `Wrap` is what the comment always meant.
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,

            children: <Widget>[
              _labelled(
                strings.creationDateLabel,
                DatabaseDateFormat.short(table.createdAt, isArabic: isArabic),
              ),
              Spacer(),
              customButtonWithSvg(
                title: strings.comments,
                function: onCommentsPressed,
                color: AppColors.primary,
                colorBorder: AppColors.transparent,
                image: CreateTableAssets.comments,
                widthImage: 18.r,
                heightImage: 18.r,
                svgColor: AppColors.textButton,
                textStyle: StyleText.fontSize14Weight500
                    .copyWith(color: AppColors.textButton),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _description(CreateTableStrings strings, bool isArabic) {
    final String text = FormatHelper.capitalize(
      table.localizedDescription(isArabic: isArabic),
    );

    return Text.rich(
      TextSpan(
        text: '${strings.descriptionLabel} ',
        style: StyleText.fontSize12Weight400
            .copyWith(color: AppColors.secondaryText),
        children: <InlineSpan>[
          TextSpan(
            text: text.isEmpty ? strings.noDescription : text,
            style: StyleText.fontSize12Weight400.copyWith(
              // An absent description is drawn in the muted tone so it reads
              // as an explanation of the empty state rather than as content
              // somebody typed.
              color: text.isEmpty ? AppColors.secondaryText : AppColors.text,
            ),
          ),
        ],
      ),
    );
  }

  /// "Label: value" on ONE line — the pattern every date line in this module
  /// uses. Only the colour separates the two halves; wrapping between them
  /// would split the only thing the line means.
  Widget _labelled(String label, String value) => Text.rich(
        TextSpan(
          text: '$label ',
          style: StyleText.fontSize10Weight400
              .copyWith(color: AppColors.secondaryText),
          children: <InlineSpan>[
            TextSpan(
              text: value,
              style:
                  StyleText.fontSize10Weight400.copyWith(color: AppColors.text),
            ),
          ],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
}
