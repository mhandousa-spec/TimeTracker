/// Module: database / db3_create_table / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: table_comment_bubble.dart
/// Purpose: Declares `TableCommentBubble`.
/// Author: Knowticed Plus team
/// Created at: 17/8/2026
///
/// One message on the Comments screen — Figma 7398:8232 (iPad H 1024),
/// 7398:8360 / 8437 (iPad V 768), 7398:8587 / 8311.
///
/// TWO SIDES, ONE WIDGET
/// ---------------------
/// The Figma draws the incoming message with the avatar on the leading edge,
/// the name above a light bubble and, UNDER the bubble, one footer line holding
/// the two thumbs on the leading edge and the timestamp on the trailing one; the
/// outgoing one mirrors all of it. That is one layout read in two directions,
/// not two layouts — so this takes [isMine] and flips the cross-axis alignment,
/// and every horizontal offset in it is `EdgeInsetsDirectional` so the whole
/// thing mirrors again for Arabic without a second branch.
///
/// THE FOOTER LINE
/// ---------------
/// Thumbs and date share ONE row (Figma 7398:8587, the red-boxed strip): the
/// date is not a property of the identity line, it belongs to the message, and
/// giving it its own row under the bubble would spend a whole line of vertical
/// rhythm on eleven characters. `spaceBetween` across the card's full width is
/// what pins the thumbs to one edge and the date to the other on BOTH sides of
/// the thread, so the eye finds the timestamp in the same place every time.
///
/// The bubble's own corner radius is the one asymmetry that is real: the corner
/// nearest the avatar is square in the design, which is what makes a bubble
/// point at its author.
///
/// THE THUMBS
/// ----------
/// The bundle ships a thumbs-UP and no thumbs-down, and the design's two glyphs
/// are the same shape mirrored — so dislike is [CreateTableAssets.thumb] flipped
/// on the X axis. `Matrix4.rotationX(pi)` rather than `Transform.rotate`, which
/// spins in the plane and would give a thumb pointing sideways.
///
/// A count is drawn beside each thumb only when it is non-zero. The Figma shows
/// bare glyphs because its messages have one reaction each; a real thread needs
/// to say how many, and a column of zeroes says nothing.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/46-custom_image_picker.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/constants/database_details_constants.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/constants/create_table_constants.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/table_comment.dart';

class TableCommentBubble extends StatelessWidget {
  const TableCommentBubble({
    super.key,
    required this.comment,
    required this.isMine,
    required this.myReaction,
    required this.canReact,
    required this.onReact,
    required this.onDelete,
  });

  final TableComment comment;

  /// True when the reader wrote it — which is what puts the bubble on the
  /// trailing edge and offers Delete.
  final bool isMine;

  /// The reader's own thumb, or null. Passed in rather than read off [comment]
  /// so the widget never needs to know who is signed in.
  final TableCommentReaction? myReaction;

  /// False on a Private table for anyone but its creator, and whenever nobody
  /// is signed in. The thumbs are HIDDEN rather than greyed: a disabled control
  /// invites the user to work out why, and the answer is a setting on another
  /// screen.
  final bool canReact;

  final ValueChanged<TableCommentReaction> onReact;

  /// Long-press on your own bubble. Null on everyone else's.
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final CreateTableStrings strings = CreateTableStrings.of(context);
    final bool isArabic = context.isArabic;

    final String name = FormatHelper.capitalize(
      comment.localizedAuthorName(isArabic: isArabic),
    );
    final String jobTitle = comment.localizedAuthorJobTitle(isArabic: isArabic);

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment:
            isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          _identity(name, jobTitle),
          SizedBox(height: 6.h),
          _bubble(context),
          if (_hasFooter) ...<Widget>[
            SizedBox(height: 4.h),
            _footer(strings, isArabic),
          ],
        ],
      ),
    );
  }

  /// True while the footer line has anything to say: a thumb to offer, a
  /// reaction already cast, or a timestamp. All three empty and the row is not
  /// built at all rather than drawn as 4pt of blank space under the bubble.
  bool get _hasFooter =>
      canReact ||
      comment.likeCount > 0 ||
      comment.dislikeCount > 0 ||
      comment.createdAt != null;

  /// Avatar + name + job title. The timestamp is NOT here — it sits in the
  /// footer beside the thumbs; see this file's header.
  Widget _identity(String name, String jobTitle) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        if (!isMine) ...<Widget>[
          _avatar(name),
          SizedBox(width: 8.w),
        ],
        // Flexible, not bare: a long name inside a `MainAxisSize.min` Row has
        // nothing to shrink against and would overflow the identity line.
        Flexible(
          child: Column(
            crossAxisAlignment:
                isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                name.isEmpty ? '—' : name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: StyleText.fontSize14Weight600
                    .copyWith(color: AppColors.text),
              ),
              if (jobTitle.isNotEmpty)
                Text(
                  jobTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: StyleText.fontSize11Weight400
                      .copyWith(color: AppColors.secondaryText),
                ),
            ],
          ),
        ),
        if (isMine) ...<Widget>[
          SizedBox(width: 8.w),
          _avatar(name),
        ],
      ],
    );
  }

  /// The one line under the bubble: thumbs on the leading edge, timestamp on
  /// the trailing one.
  ///
  /// Full width and `spaceBetween`, so the date lands on the card's far edge
  /// for an incoming AND an outgoing message — the Column above aligns its
  /// children to one side, and a `MainAxisSize.min` row here would drag the
  /// date in against the thumbs.
  Widget _footer(CreateTableStrings strings, bool isArabic) {
    final bool showThumbs =
        canReact || comment.likeCount > 0 || comment.dislikeCount > 0;

    // A comment with no timestamp yet draws the thumbs alone rather than
    // "Date: — At —", which reads as broken data rather than as a write that
    // has not come back.
    final Widget when = comment.createdAt == null
        ? const SizedBox.shrink()
        : Text(
            strings.commentDate(
              DatabaseDateFormat.short(comment.createdAt, isArabic: isArabic),
              _clock(comment.createdAt),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: StyleText.fontSize10Weight400
                .copyWith(color: AppColors.secondaryText),
          );

    return SizedBox(
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          // The thumbs keep their intrinsic width; only the date is allowed to
          // shrink, because it is the one of the two that can be truncated
          // without losing a control.
          if (showThumbs) _reactions(strings) else const SizedBox.shrink(),
          SizedBox(width: 22.w),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: when,
          ),
        ],
      ),
    );
  }

  /// The face, or the initial when there is no photo — the same fallback the
  /// employee cards elsewhere in the app use, and the reason this never renders
  /// Flutter's broken-image glyph over somebody's name.
  Widget _avatar(String name) {
    final String? photo = comment.authorPhotoUrl;
    final double size = 34.r;

    final Widget initial = Center(
      child: Text(
        name.isEmpty ? '?' : name.characters.first.toUpperCase(),
        style: StyleText.fontSize14Weight700.copyWith(color: AppColors.white),
      ),
    );

    return ClipOval(
      child: Container(
        width: size,
        height: size,
        color: AppColors.background,
        child: (photo == null || photo.isEmpty)
            ? initial
            : Image(
                image: appImageProvider(photo),
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => initial,
              ),
      ),
    );
  }

  Widget _bubble(BuildContext context) {
    final bool dark = AppTheme.isDark;
    final Radius round = Radius.circular(8.r);

    return GestureDetector(
      // Long-press rather than a visible delete button. The Figma draws none,
      // and a trash icon on every bubble would be the loudest thing in a
      // conversation — for an action that is only ever available on your own
      // messages and is rarely wanted.
      onLongPress: onDelete,
      child: Container(
        constraints: BoxConstraints(
          // The Figma's bubbles stop well short of the card's edge on both
          // sides, which is what keeps a thread readable as two columns rather
          // than one full-width block. 78% is that proportion at 1024 and
          // still leaves the avatar room on a phone.
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: dark ? AppColors.chatField : AppColors.fieldFillLight,
          borderRadius: BorderRadiusDirectional.only(
            // Square on the corner nearest the author's avatar — what makes a
            // bubble point at whoever wrote it.
            topStart: isMine ? round : Radius.zero,
            topEnd: isMine ? Radius.zero : round,
            bottomStart: round,
            bottomEnd: round,
          ),
        ),
        child: Text(
          comment.text,
          style: StyleText.fontSize13Weight400.copyWith(color: AppColors.text),
        ),
      ),
    );
  }

  Widget _reactions(CreateTableStrings strings) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _thumb(
          reaction: TableCommentReaction.like,
          count: comment.likeCount,
          tooltip: strings.like,
        ),
        SizedBox(width: 12.w),
        _thumb(
          reaction: TableCommentReaction.dislike,
          count: comment.dislikeCount,
          tooltip: strings.dislike,
        ),
      ],
    );
  }

  Widget _thumb({
    required TableCommentReaction reaction,
    required int count,
    required String tooltip,
  }) {
    final bool active = myReaction == reaction;
    final bool isDislike = reaction == TableCommentReaction.dislike;

    final Widget glyph = CustomSvgImage(
      assetPath: CreateTableAssets.thumb,
      width: 16.r,
      height: 16.r,
      color: active ? AppColors.primary : AppColors.secondaryText,
    );

    return Semantics(
      label: tooltip,
      button: canReact,
      selected: active,
      child: GestureDetector(
        onTap: canReact ? () => onReact(reaction) : null,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          // A 16pt glyph is under a comfortable tap target, so the padding is
          // the hit area rather than a visual gap.
          padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 2.w),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (isDislike)
                Transform(
                  alignment: Alignment.center,
                  // Flipped on the X axis — a mirrored thumbs-up IS a
                  // thumbs-down. See this file's header.
                  transform: Matrix4.rotationX(math.pi),
                  child: glyph,
                )
              else
                glyph,
              if (count > 0) ...<Widget>[
                SizedBox(width: 4.w),
                Text(
                  '$count',
                  style: StyleText.fontSize10Weight500.copyWith(
                    color: active ? AppColors.primary : AppColors.secondaryText,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// "8:23" — the clock half of the Figma's timestamp line.
///
/// 12-hour with no meridiem, which is what 7398:8232 prints ("At 8:23"). The
/// DATE half is not formatted here: it comes from `DatabaseDateFormat.short`, so
/// a comment and the card above it cannot disagree about how a month is written.
///
/// Deliberately NOT `intl`'s `DateFormat.jm()`: that appends AM/PM, and the
/// Arabic locale renders the separator differently — a conversation timestamp
/// that changes shape with the interface language is one more thing to explain.
String _clock(DateTime? date) {
  if (date == null) return '—';
  final int hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final String minute = date.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
