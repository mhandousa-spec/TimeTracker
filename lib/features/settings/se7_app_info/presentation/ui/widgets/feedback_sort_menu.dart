/// Module: settings/se7_app_info
///
///*************************** FILE INFO ****************************///
/// File Name: feedback_sort_menu.dart
/// Purpose: The "Sort" button beside the search box on the "Request Details"
///          list.
/// Author: Knowticed Plus team
/// Created at: 1/9/2026
///
/// Figma: MESBAH 7628:8696 — a 100×38 button, sort glyph plus the word "Sort".
///
/// NOT `SortDropdownMenu` from the services module: that widget hardcodes its
/// three options (Date Requested / Duration / Last Update) and a feedback
/// submission has no duration. Same visual language, different option set.
///
/// Updated: 2/9/2026 - The button has two looks. Until the user picks an
/// option, its glyph AND its label are `AppColors.secondaryText` at half
/// opacity; once one is picked, both become `AppColors.textButton`. That is
/// why [selected] is nullable — the widget cannot draw the difference if the
/// caller hands it a default and calls it a choice. The list is still ordered
/// newest-first in the meantime; see `CommentsFeedbackLoaded.sortOption`.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/presentation/controller/comments_feedback_state.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class FeedbackSortMenu extends StatelessWidget {
  const FeedbackSortMenu({
    super.key,
    required this.selected,
    required this.onSelected,
    this.compact = false,
  });

  /// The option the user picked, or null if they have not picked one.
  ///
  /// Null is not "descending" — the list happens to be ordered that way by
  /// default, but nothing on the button may claim the user asked for it.
  final FeedbackSortOption? selected;
  final ValueChanged<FeedbackSortOption> onSelected;

  /// On phone the label is dropped and only the glyph remains, so the button
  /// does not crowd the search field out.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final bool lightMode = Theme.of(context).brightness == Brightness.light;

    // One colour for both the glyph and the label — they are one control and
    // must not drift apart. Dimmed until the user has picked something.
    final Color foreground = selected == null
        ? AppColors.secondaryText.withOpacity(0.5)
        : AppColors.textButton;

    return PopupMenuButton<FeedbackSortOption>(
      tooltip: '',
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
      color: lightMode ? AppColors.white : AppColors.chatBackground,
      position: PopupMenuPosition.under,
      onSelected: onSelected,
      itemBuilder: (BuildContext context) =>
          <PopupMenuEntry<FeedbackSortOption>>[
        for (final FeedbackSortOption option in FeedbackSortOption.values)
          PopupMenuItem<FeedbackSortOption>(
            value: option,
            height: 40.h,
            child: Text(
              _label(context, option),
              style: StyleText.fontSize14Weight500.copyWith(
                color: option == selected
                    ? AppColors.secondaryPrimary
                    : AppColors.text,
              ),
            ),
          ),
      ],
      child: Container(
        height: 38.sp,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CustomSvgImage(
              assetPath: 'assets/icons_assets/main_icons_assets/sort_lines.svg',
              width: 18.sp,
              height: 18.sp,
              color: foreground,
            ),
            if (!compact) ...<Widget>[
              SizedBox(width: 8.w),
              Text(
                S.of(context).sort,
                style: StyleText.fontSize14Weight500.copyWith(color: foreground),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Just the two words.
  ///
  /// No arrow, and no "Date Requested" prefix: the menu has exactly one field
  /// to sort by, so naming it on every row says nothing the button above the
  /// menu does not already say. The ↑ / ↓ glyphs are gone for the same
  /// reason — "Ascending" is not clearer for having an arrow after it, and the
  /// two arrows read as a second, competing control.
  String _label(BuildContext context, FeedbackSortOption option) {
    final S s = S.of(context);
    switch (option) {
      case FeedbackSortOption.descending:
        return s.descending;
      case FeedbackSortOption.ascending:
        return s.ascending;
    }
  }
}
