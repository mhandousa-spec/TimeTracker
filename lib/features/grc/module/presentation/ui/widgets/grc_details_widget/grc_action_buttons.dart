/// Module: GRC Module Management
/// Description: Provides the Edit and Delete action buttons shown at the top
///              of the GRC Module details page (and, since 2026-07-15, the
///              Policy Details page) in view mode.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-06-29
/// Dependencies: AppColors, AppTheme, customButtonWithSvg, showConfirmDialog
/// Revision History: 2026-06-29 - Initial creation
///                    2026-06-30 - Added onDeleteTap callback (Mohamed Magdy Abdelkhalek)
///                    2026-07-15 - Made the delete confirm dialog's title/
///                                 subtitle/icon overridable so other GRC
///                                 pages (e.g. Policy Details) can reuse this
///                                 widget with their own wording
library;

/// ************************* FILE INFO *************************** ///
/// File Name: grc_action_buttons.dart
/// Purpose: Contains GrcActionButtons, a row of Edit and Delete buttons
///          reused across GRC detail pages.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 29/6/2026

import 'package:knowticed_plus/core/custom/11-custom_confirm_diaolog.dart';
import 'package:knowticed_plus/core/custom/41-custom_button_sizing.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_l10n.dart';

class GrcActionButtons extends StatelessWidget {
  final VoidCallback onEditTap;
  final VoidCallback onDeleteTap;

  /// Whether to draw each button.
  ///
  /// Edit and Delete are separate switches in the admin dashboard
  /// (Edit_Module / Delete_Module), so a user can hold one without the other
  /// and the row has to be able to show just one. Default true, so the other
  /// GRC pages that reuse this widget (Control Details, Policy Details) are
  /// unchanged until they gate themselves.
  final bool showEdit;
  final bool showDelete;
  final String deleteDialogTitle;
  final String deleteDialogSubtitle;
  /// Lottie played at the top of the delete confirm dialog.
  ///
  /// WAS `deleteDialogIconAsset`, an SVG passed to showConfirmDialog's
  /// `iconWidget`. That parameter short-circuits the dialog's own animation
  /// (`if (iconWidget != null) return iconWidget!`), so the delete confirm
  /// came up with a flat icon and no motion. No caller ever overrode the
  /// default, so this is a straight swap to the Lottie path.
  final String deleteDialogLottieAsset;

  const GrcActionButtons({
    super.key,
    required this.onEditTap,
    required this.onDeleteTap,
    this.showEdit = true,
    this.showDelete = true,
    this.deleteDialogTitle = "Deleting GRC Module",
    this.deleteDialogSubtitle =
        "Are You Sure You Want To Delete This GRC Module ?",
    this.deleteDialogLottieAsset = AppAssets.trash,
  });

  @override
  Widget build(BuildContext context) {
    // Figma draws Edit/Delete with their labels at 768 and 1024, and as
    // bare 38x38 icon squares at 375.
    //
    // Read from ButtonSizing rather than re-deriving the breakpoint here:
    // ButtonSizing is what actually picks the 38.sp vs 135.sp width, so a
    // second, differently-keyed check could show a label inside a button
    // only wide enough for an icon.
    final bool isCompact = ButtonSizing.isMobile(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (showEdit)
          customButtonWithSvg(
          colorBorder: AppColors.primary,
          space: 10.w,
          radius: 8.r,
          widthImage: 16.w,
          heightImage: 16.h,
          svgColor: AppColors.textButton,
          image: "assets/icons_assets/data_grc_assets/edit_pen.svg",
          title: isCompact ? "" : S.of(context).Edit,
          function: onEditTap,
          width: isCompact ? 38.w : 135.w,
          color: AppColors.primary,
          textStyle: StyleText.fontSize16Weight500
              .copyWith(color: AppColors.textButton),
        ),
        // Gutter only when both buttons are actually present.
        if (showEdit && showDelete) SizedBox(width: 10.w),
        if (showDelete)
          customButtonWithSvg(
          colorBorder: AppColors.red,
          space: 10.w,
          radius: 8.r,
          widthImage: 16.w,
          heightImage: 16.h,
          image: "assets/icons_assets/organization_chart_assets/trashd.svg",
          title: isCompact ? "" : S.of(context).Delete,
          function: () {
            showConfirmDialog(
              context: context,
              title: grcTr(context, deleteDialogTitle),
              cancelLabel: S.of(context).no,
              confirmLabel: S.of(context).yes,
              lottieAsset: deleteDialogLottieAsset,
              subtitle: grcTr(context, deleteDialogSubtitle),
              onConfirm: onDeleteTap,
            );
          },
          width: isCompact ? 38.w : 135.w,
          color: AppColors.red,
          textStyle:
              StyleText.fontSize16Weight500.copyWith(color: AppColors.white),
        ),
      ],
    );
  }
}
