/// Module: database / db2_database_details / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: database_info_card.dart
/// Purpose: Declares `DatabaseInfoCard`.
/// Author: Knowticed Plus team
/// Created at: 16/8/2026
///
/// The white summary card on the details screen and the "Hide" / "Expand" link
/// above it — Figma 7398:735 (open, iPad V), 7398:2082 (collapsed),
/// 7398:847 (open, iPad H).
///
/// BOTH STATES ARE THIS WIDGET
/// ---------------------------
/// Collapsed is not "the card, hidden". The Figma replaces it with a labelled
/// row — "Database Details" on the leading edge, "Expand" on the trailing one —
/// so something still says what the link would bring back. Rendering the two
/// states from one widget keeps that link in the same place in both, which is
/// the whole reason the toggle is usable.
///
/// The description is NOT clipped to a line count. The Figma frame happens to
/// fit three lines, but the field takes 500 characters and a card that silently
/// truncated would make "Hide" the only way to find out there was more.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/46-custom_image_picker.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_entity.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/constants/database_details_constants.dart';

class DatabaseInfoCard extends StatelessWidget {
  const DatabaseInfoCard({
    super.key,
    required this.database,
    required this.isExpanded,
    required this.onToggle,
  });

  final DatabaseEntity database;
  final bool isExpanded;
  final VoidCallback onToggle;

  /// When the record was last EDITED, or null when it never has been.
  ///
  /// Not simply `database.updatedAt`. `DatabaseModel.toCreateMap` stamps
  /// `updated_at` and `created_at` in ONE write, and Firestore resolves every
  /// server timestamp inside a single write to the same commit time — so a
  /// database that has never been edited comes back with the two dates EQUAL,
  /// not with `updated_at` absent. That equality is the signal, and it is the
  /// only one available: nothing counts edits.
  ///
  /// A null `updatedAt` is also "never edited" — that is a record written
  /// before `toCreateMap` stamped the field, and nothing about it says an edit
  /// ever happened either.
  ///
  /// The two dates colliding on a REAL edit would need a save committed in the
  /// same microsecond as the create, which is a person typing a title, picking
  /// an access type and pressing Save inside one Firestore commit.
  DateTime? get _lastEditedAt {
    final DateTime? updated = database.updatedAt;
    final DateTime? created = database.createdAt;

    if (updated == null) return null;
    if (created != null && updated.isAtSameMomentAs(created)) return null;
    return updated;
  }

  @override
  Widget build(BuildContext context) {
    final DatabaseDetailsStrings strings = DatabaseDetailsStrings.of(context);
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
                strings.databaseDetails,
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
          _card(context, strings, isArabic),
        ],
      ],
    );
  }

  Widget _card(
    BuildContext context,
    DatabaseDetailsStrings strings,
    bool isArabic,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: CardStyles.shadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _thumbnail(context, strings, isArabic),
          SizedBox(width: 12.w),
          Expanded(
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
                            database.localizedTitle(isArabic: isArabic)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: StyleText.fontSize16Weight500
                            .copyWith(color: AppColors.text),
                      ),
                    ),
                    // "Last Edit", the Figma's top-right line on this card.
                    //
                    // AN EM DASH UNTIL THE RECORD IS ACTUALLY EDITED
                    // (17/8/2026). It used to fall back to the creation date on
                    // the reasoning that a record's last write IS its creation
                    // until something edits it. True, but not what the label
                    // says: someone reading "Last Edit: 17 Aug 2026" on a
                    // database nobody has touched has been told an edit
                    // happened. "—" says the honest thing, which is that there
                    // has not been one yet.
                    //
                    // The line is ALWAYS drawn now, dash and all. Its absence
                    // was the old way of saying "never edited", and a line that
                    // appears out of nowhere on the first save moves the title
                    // beside it — see [_lastEditedAt] for how "never edited" is
                    // detected.
                    Padding(
                      padding: EdgeInsetsDirectional.only(start: 8.w),
                      child: _labelled(
                        strings.lastEditLabel,
                        // `short` renders null as "—" on its own, so there is
                        // no second placeholder here to keep in step.
                        DatabaseDateFormat.short(
                          _lastEditedAt,
                          isArabic: isArabic,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                // 12sp, matching the Description line directly beneath it —
                // see [_labelled]'s `large`.
                _labelled(
                  strings.accessManagementLabel,
                  isArabic
                      ? database.accessType.labelAr
                      : database.accessType.labelEn,
                  large: true,
                ),
                SizedBox(height: 6.h),
                _description(strings, isArabic),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// The cover picture, or the module glyph on a record that never had one.
  ///
  /// The creation date sits UNDER it, which is where the Figma puts it — not
  /// in the text column — so it reads as a property of the record rather than
  /// as one more line of the description block.
  Widget _thumbnail(
    BuildContext context,
    DatabaseDetailsStrings strings,
    bool isArabic,
  ) {
    final double size = context.isPhone ? 72.sp : 100.sp;
    final String? cover = database.coverImageUrl;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: size,
          height: size,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppTheme.isDark
                ? AppColors.colorBlack
                : AppColors.fieldFillLight,
            borderRadius: BorderRadius.circular(8.r),
          ),
          alignment: Alignment.center,
          child: (cover == null || cover.isEmpty)
              ? CustomSvgImage(
                  assetPath: DatabaseDetailsAssets.databaseGlyph,
                  width: size * 0.45,
                  height: size * 0.45,
                  fit: BoxFit.contain,
                  color: AppColors.secondaryText,
                )
              : Image(
                  image: appImageProvider(cover),
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  // A cover URL that 404s falls back to the glyph rather than
                  // to Flutter's broken-image icon, which on this card reads
                  // as the record itself being damaged.
                  errorBuilder: (_, __, ___) => CustomSvgImage(
                    assetPath: DatabaseDetailsAssets.databaseGlyph,
                    width: size * 0.45,
                    height: size * 0.45,
                    fit: BoxFit.contain,
                    color: AppColors.secondaryText,
                  ),
                ),
        ),
        SizedBox(height: 6.h),
        // CLAMPED TO THE THUMBNAIL AGAIN (19/8/2026).
        //
        // This Column is the Row's non-flexible child, so it is laid out with
        // an UNBOUNDED width and ends up as wide as its widest child. Left
        // free, that child was this line, not the picture — "Creation: 19 Aug
        // 2026" is wider than the 100sp thumbnail — so the column grew past
        // the picture and pushed the title/description column right, leaving
        // an empty band down the side of the thumbnail. That band was the
        // reported gap: it was never padding, it was this text.
        //
        // The previous note here said clamping made it read "Creation: 16 ..."
        // — true when the line was 12sp. It is 10sp now (`_labelled`'s default,
        // the quiet size the card's margin lines use), and rather than rely on
        // that fitting exactly, it is allowed to break after the label. Two
        // short lines under the picture lose nothing; an ellipsised date loses
        // the date.
        SizedBox(
          width: size,
          child: _labelled(
            strings.creationLabel,
            DatabaseDateFormat.short(database.createdAt, isArabic: isArabic),
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  Widget _description(DatabaseDetailsStrings strings, bool isArabic) {
    final String text = FormatHelper.capitalize(
        database.localizedDescription(isArabic: isArabic));

    // 12sp like every other pair on the card. This one is the exception to the
    // one-line rule — a 500-character description has to wrap, and there is no
    // meaning lost by wrapping it — so it carries no `maxLines`.
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

  /// "Label: value" — the pattern every line on this card uses.
  ///
  /// BOTH halves are the same size and they stay on ONE line. They are one
  /// sentence, not a heading with a body: "Creation:" on its own says nothing
  /// and "16 Aug 2026" on its own says nothing either, so wrapping between them
  /// splits the only thing the line means. `maxLines: 1` is what enforces
  /// that; keeping the two spans at the same size is what stops the value
  /// reading as a separate, louder field.
  ///
  /// Only the colour separates them — muted for the label, full-contrast for
  /// the value — which is the same treatment the list cards use.
  ///
  /// TWO SIZES (17/8/2026). [large] is 12sp, the size of the description, and
  /// is for the card's BODY line — "Access Management: Restricted Access", a
  /// property of the record in the same way the description is. Everything else
  /// stays at 10sp: the two dates sit in the card's margins and are meant to be
  /// the quietest thing on it.
  ///
  /// A flag rather than a `TextStyle` parameter, so a caller cannot hand this a
  /// third size and start the drift over again.
  ///
  /// [maxLines] is 1 for the same reason the sizes match — the pair is one
  /// sentence. The creation line raises it to 2 because it is the only pair
  /// drawn inside a fixed width (the thumbnail's), where the choice is not
  /// "one line or two" but "two lines or an ellipsised date".
  Widget _labelled(
    String label,
    String value, {
    bool large = false,
    int maxLines = 1,
  }) {
    final TextStyle base =
        large ? StyleText.fontSize12Weight400 : StyleText.fontSize10Weight400;

    return Text.rich(
      TextSpan(
        text: '$label ',
        style: base.copyWith(color: AppColors.secondaryText),
        children: <InlineSpan>[
          TextSpan(
            text: value,
            style: base.copyWith(color: AppColors.text),
          ),
        ],
      ),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}
