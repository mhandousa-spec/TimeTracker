/// Module: GRC shared widgets
/// Description: The "Edit Controls" surface shared by the Control Champion
///              and Control Owner edit flows -- a dialog at 768 / 1024 and a
///              full "Editing Controls" page at 375, as MAGDY draws them.
/// Author: Knowticed Plus team
/// Date: 2026-09-15
/// Dependencies: customButton (5), customButtonWithSvg (6), CustomSvgImage
///               (32), PaginationAppBar, GrcAssignmentChip
library;

import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/38-custom_responsive.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/grc/shared/widgets/grc_assignment_chip.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// One removable "Assigned Controls" chip.
class GrcEditableChip {
  final String label;
  final VoidCallback onRemove;

  const GrcEditableChip({required this.label, required this.onRemove});
}

/// The black "+ Policy" / "+ Add Policy" button every assigning form uses.
Widget grcAddPolicyButton(
  BuildContext context, {
  required VoidCallback onTap,
  String? title,
}) {
  return customButtonWithSvg(
    title: title ?? S.of(context).policy,
    function: onTap,
    // darkGrey fill + fixed white text/icon: `blackButton` / `white` swap
    // in dark mode, which left a white button with white text.
    textStyle:
        StyleText.fontSize14Weight400.copyWith(color: AppColors.colorWhite),
    color: AppColors.darkGrey,
    image: AppAssets.add,
    widthImage: 16.sp,
    heightImage: 16.sp,
    space: 8.w,
    colorBorder: AppColors.transparent,
    svgColor: AppColors.colorWhite,
  );
}

/// Discard / primary button pair at the foot of the add / reassign / edit
/// forms. 375 splits the row in half; 768 / 1024 keep 135-wide buttons at
/// the two ends.
Widget grcFormButtons(
  BuildContext context, {
  required VoidCallback onDiscard,
  required String primaryTitle,
  required VoidCallback onPrimary,
  bool isBusy = false,
  // ADDED 28/9/2026 (GRC bug report p8): greyed and inert until the form
  // actually has something to save. Defaults to true for existing callers.
  bool primaryEnabled = true,
}) {
  final bool isMobile = screenSizeOf(context) == ScreenSize.mobile;
  final TextStyle style =
      StyleText.fontSize16Weight400.copyWith(color: AppColors.textButton);

  Widget discard = customButton(
    title: S.of(context).discard,
    function: onDiscard,
    width: isMobile ? double.infinity : 135.w,
    color: AppColors.darkGrey,
    textStyle: StyleText.fontSize16Weight400.copyWith(color: AppColors.white),
  );
  Widget primary = isBusy
      ? Container(
          width: isMobile ? double.infinity : 135.w,
          height: 38.sp,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: SizedBox(
            width: 18.sp,
            height: 18.sp,
            child: const CircleProgressMaster(),
          ),
        )
      : customButton(
          title: primaryTitle,
          function: primaryEnabled ? onPrimary : () {},
          width: isMobile ? double.infinity : 135.w,
          color: primaryEnabled ? AppColors.primary : AppColors.colorGrey,
          textStyle: style,
        );

  if (isMobile) {
    return Row(
      children: [
        Expanded(child: discard),
        SizedBox(width: 15.w),
        Expanded(child: primary),
      ],
    );
  }
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [discard, primary],
  );
}

/// class name: [GrcEditControlsLayout]
///
/// purpose: renders the edit surface around state the caller owns.
///          [pickerRows] are the caller's GrcPolicyControlPickerRow widgets.
///          The result travels back through `Navigator.pop`, which works the
///          same for the dialog route and the page route.
class GrcEditControlsLayout extends StatelessWidget {
  final List<GrcEditableChip> chips;
  final List<Widget> pickerRows;
  final VoidCallback onAddPolicy;
  final VoidCallback onSave;
  final bool isSaving;

  /// GRC bug report p8: Save stays disabled until the user has changed
  /// something (removed a chip or picked a new control).
  final bool canSave;

  const GrcEditControlsLayout({
    super.key,
    required this.chips,
    required this.pickerRows,
    required this.onAddPolicy,
    required this.onSave,
    required this.isSaving,
    this.canSave = true,
  });

  @override
  Widget build(BuildContext context) {
    return screenSizeOf(context) == ScreenSize.mobile
        ? _page(context)
        : _dialog(context);
  }

  Widget _assignedChips(BuildContext context) {
    if (chips.isEmpty) {
      return Text(
        S.of(context).noControlsAssigned,
        style: StyleText.fontSize12Weight400
            .copyWith(color: AppColors.secondaryText),
      );
    }
    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: [
        for (final GrcEditableChip c in chips)
          GrcAssignmentChip(label: c.label, onRemove: c.onRemove),
      ],
    );
  }

  Text _sectionTitle(String text) => Text(
        text,
        style: StyleText.fontSize14Weight400.copyWith(color: AppColors.text),
      );

  // ── 768 / 1024 ──────────────────────────────────────────────────────
  Widget _dialog(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: CardStyles.radius()),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 0.7.sh, maxWidth: 540.w),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(12.sp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32.sp,
                    height: 32.sp,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: CustomSvgImage(
                      assetPath:
                          'assets/icons_assets/data_grc_assets/editButton.svg',
                      width: 18.sp,
                      height: 18.sp,
                      color: AppColors.textButton,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    S.of(context).editControls,
                    style: StyleText.fontSize16Weight400
                        .copyWith(color: AppColors.text),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              _sectionTitle(S.of(context).assignedControls),
              SizedBox(height: 8.h),
              _assignedChips(context),
              SizedBox(height: 15.h),
              ...pickerRows,
              grcAddPolicyButton(
                context,
                onTap: onAddPolicy,
                title: S.of(context).addPolicy,
              ),
              SizedBox(height: 20.h),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: isSaving
                    ? SizedBox(
                        width: 150.w,
                        height: 38.sp,
                        child: Center(
                          child: const CircleProgressMaster(),
                        ),
                      )
                    : customButton(
                        title: S.of(context).Save,
                        function: canSave ? onSave : () {},
                        width: 150.w,
                        color:
                            canSave ? AppColors.primary : AppColors.colorGrey,
                        textStyle: StyleText.fontSize16Weight400
                            .copyWith(color: AppColors.textButton),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── 375 ─────────────────────────────────────────────────────────────
  Widget _page(BuildContext context) {
    BoxDecoration card = BoxDecoration(
      color: AppColors.card,
      borderRadius: CardStyles.radius(),
    );
    // The frame owns the Scaffold, SafeArea, back chevron and title.
    return SideFrameMasterServices(
      titleText: S.of(context).controls,
      onFirstTap: () => Navigator.pop(context),
      secondTitle: S.of(context).editingControls,
      child: SideFrameScrollableBody(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 10.h),
                      // Sized by its chips + 12.sp padding -- no fixed
                      // minimum height.
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12.sp),
                        decoration: card,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionTitle(S.of(context).assignedControls),
                            SizedBox(height: 8.h),
                            _assignedChips(context),
                          ],
                        ),
                      ),
                      SizedBox(height: 15.h),
                      Container(
                        padding: EdgeInsets.all(12.sp),
                        decoration: card,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...pickerRows,
                            grcAddPolicyButton(context, onTap: onAddPolicy),
                          ],
                        ),
                      ),
                      SizedBox(height: 15.h),
                      grcFormButtons(
                        context,
                        onDiscard: () => Navigator.pop(context),
                        primaryTitle: S.of(context).Save,
                        onPrimary: onSave,
                        isBusy: isSaving,
                        primaryEnabled: canSave,
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
      ),
    );
  }
}
