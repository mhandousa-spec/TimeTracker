// ****************** FILE INFO ******************
// File Name: crm_template_layout_actions_bar.dart
// Purpose: Bottom actions bar of the template layout editor: add row/page,
//          discard, save and preview actions
// Author: Mohand Adel
// Created At: 12/08/2026

import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Bottom actions bar of the template layout editor.
///
/// Composes the "Add Row / Add Page" row, the "Discard / Save" row and the
/// "Preview" row. All actions are delegated to the owning page.
class CrmTemplateLayoutActionsBar extends StatelessWidget {
  const CrmTemplateLayoutActionsBar({
    super.key,
    required this.canAddMore,
    required this.canSave,
    required this.isSaving,
    required this.onAddRow,
    required this.onAddPage,
    required this.onLimitReached,
    required this.onDiscard,
    required this.onSave,
    required this.onPreview,
  });

  /// Whether the layout still has unassigned items (enables add actions).
  final bool canAddMore;

  /// Whether the layout contains at least one assigned required item.
  final bool canSave;

  /// Whether a save is in progress (shows a spinner instead of the save button).
  final bool isSaving;

  final VoidCallback onAddRow;
  final VoidCallback onAddPage;

  /// Invoked when add actions are tapped but no items remain to assign.
  final VoidCallback onLimitReached;

  final VoidCallback onDiscard;
  final VoidCallback onSave;
  final VoidCallback onPreview;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 80.w,
              height: 32.h,
              child: customButtonWithSvg(
                radius: 4.r,
                title: S.current.crmAddRow,
                function: canAddMore ? onAddRow : onLimitReached,
                textStyle: StyleText.fontSize12Weight500.copyWith(color: AppColors.textButton).copyWith(
                  color: AppColors.white,
                ),
                color: AppColors.blackButton,
                image: AppAssets.crmPlusBold,
                widthImage: 14.sp,
                heightImage: 14.sp,
                colorBorder: AppColors.blackButton,
                svgColor: AppColors.white,
              ),
            ),
            SizedBox(width: 14.sp),
            SizedBox(
              width: 80.w,
              height: 32.h,
              child: customButtonWithSvg(
                radius: 4.r,
                title: S.current.crmPage,
                function: canAddMore ? onAddPage : onLimitReached,
                textStyle: StyleText.fontSize12Weight500.copyWith(color: AppColors.textButton).copyWith(
                  color: AppColors.white,
                ),
                color: AppColors.blackButton,
                image: AppAssets.crmPlusBold,
                widthImage: 14.sp,
                heightImage: 14.sp,
                colorBorder: AppColors.blackButton,
                svgColor: AppColors.white,
              ),
            ),
          ],
        ),
        SizedBox(height: 24.sp),
        Row(
          children: [
            customButtonWithSvg(
              title: S.current.crmDiscard,
              function: onDiscard,
              textStyle: StyleText.fontSize18Weight600.copyWith(
                color: AppColors.black,
              ),
              color: AppColors.grey,
              image: '',
              widthImage: 0,
              heightImage: 0,
              colorBorder: AppColors.grey,
            ),
            const Spacer(),
            if (isSaving)
              Center(
                child: SizedBox(
                  width: 24.sp,
                  height: 24.sp,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              customButtonWithSvg(
                title: S.current.crmSave,
                function: canSave ? onSave : () {},
                textStyle: StyleText.fontSize18Weight600.copyWith(
                  color: canSave ? AppColors.black : AppColors.darkGrey,
                ),
                color: canSave ? AppColors.primary : AppColors.disabledGrey,
                image: '',
                widthImage: 0,
                heightImage: 0,
                colorBorder:
                    canSave ? AppColors.primary : AppColors.disabledGrey,
              ),
          ],
        ),
        SizedBox(height: 14.sp),
        Row(
          children: [
            customButtonWithSvg(
              title: S.current.crmPreview,
              function: onPreview,
              textStyle: StyleText.fontSize18Weight600.copyWith(
                color: AppColors.white,
              ),
              color: AppColors.darkGrey,
              image: '',
              widthImage: 0,
              heightImage: 0,
              colorBorder: AppColors.darkGrey,
            ),
          ],
        ),
      ],
    );
  }
}
