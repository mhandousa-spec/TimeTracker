// ***************************** FILE INFO ***************************** //
// File Name: employee_bulk_upload_toolbar.dart
// Purpose: Matches the reference bulk-upload error and row-action toolbar.
// Author: Mohamed Elrashidy
// Created At: 2026-08-15
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../../../core/theme/app_colors.dart';

import '../../../../../../../generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

/// Reference-styled toolbar for error navigation and row operations.
class EmployeeBulkUploadToolbar extends StatelessWidget {
  const EmployeeBulkUploadToolbar({
    required this.errorCount,
    required this.currentErrorNumber,
    required this.hasSelection,
    required this.canDuplicate,
    required this.onPreviousError,
    required this.onNextError,
    required this.onAdd,
    required this.onDuplicate,
    required this.onRemove,
    super.key,
  });

  final int errorCount;
  final int currentErrorNumber;
  final bool hasSelection;
  final bool canDuplicate;
  final VoidCallback onPreviousError;
  final VoidCallback onNextError;
  final VoidCallback onAdd;
  final VoidCallback onDuplicate;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final localization = S.of(context);
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final localeIsArabic = Localizations.localeOf(context).languageCode == 'ar';
    final arrowColor = errorCount == 0
        ? AppColors.grey
        : lightMode
            ? AppColors.blackButton
            : AppColors.whiteShadow;
    return Row(
      children: [
        Container(
          height: 30.sp,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ErrorArrow(
                asset: localeIsArabic
                    ? 'assets/icons_assets/main_icons_assets/chevron_right.svg'
                    : 'assets/icons_assets/main_icons_assets/chevron_left.svg',
                color: arrowColor,
                onTap: errorCount == 0 ? null : onPreviousError,
              ),
              SizedBox(width: 9.sp),
              Text(
                '${localization.error}: ',
                style: StyleText.fontSize16Weight500.copyWith(
                  color: lightMode ? AppColors.blackButton : AppColors.white,
                ),
              ),
              Text(
                errorCount == 0 ? '0' : '$currentErrorNumber/$errorCount',
                style: StyleText.fontSize16Weight500.copyWith(
                  color: AppColors.red,
                ),
              ),
              SizedBox(width: 9.sp),
              _ErrorArrow(
                asset: localeIsArabic
                    ? 'assets/icons_assets/main_icons_assets/chevron_left.svg'
                    : 'assets/icons_assets/main_icons_assets/chevron_right.svg',
                color: arrowColor,
                onTap: errorCount == 0 ? null : onNextError,
              ),
            ],
          ),
        ),
        const Spacer(),
        _ToolbarButton(
          title: localization.removeSelection,
          width: 166.sp,
          enabled: hasSelection,
          asset: 'assets/icons_assets/main_icons_assets/minus_circle_red.svg',
          iconWidth: 12.sp,
          iconHeight: 12.sp,
          useDashIcon: true,
          iconColor: AppColors.background,
          onTap: onRemove,
        ),
        SizedBox(width: 10.sp),
        _ToolbarButton(
          title: localization.duplication,
          width: 103.sp,
          enabled: canDuplicate,
          onTap: onDuplicate,
        ),
        SizedBox(width: 10.sp),
        _ToolbarButton(
          title: localization.row,
          width: 82.sp,
          asset: 'assets/icons_assets/main_icons_assets/plus.svg',
          iconWidth: 12.sp,
          iconHeight: 12.sp,
          onTap: onAdd,
        ),
      ],
    );
  }
}

class _ErrorArrow extends StatelessWidget {
  const _ErrorArrow({required this.asset, required this.color, this.onTap});

  final String asset;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(4.sp),
          child: SvgPicture.asset(
            asset,
            width: 15.sp,
            height: 15.sp,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
        ),
      );
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.title,
    required this.width,
    required this.onTap,
    this.enabled = true,
    this.asset,
    this.iconWidth,
    this.iconHeight,
    this.useDashIcon = false,
    this.iconColor,
  });

  final String title;
  final double width;
  final VoidCallback onTap;
  final bool enabled;
  final String? asset;
  final double? iconWidth;
  final double? iconHeight;
  final bool useDashIcon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: enabled ? onTap : null,
        child: Opacity(
          opacity: enabled ? 1 : .45,
          child: Container(
            width: width,
            height: 30.sp,
            decoration: BoxDecoration(
              color: AppColors.blackButton,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (asset != null) ...[
                  useDashIcon
                      ? Icon(Icons.remove,
                          size: iconWidth,
                          color: iconColor ?? AppColors.blackButton)
                      : SvgPicture.asset(
                          asset!,
                          width: iconWidth,
                          height: iconHeight,
                          colorFilter: ColorFilter.mode(
                            AppColors.textButton,
                            BlendMode.srcIn,
                          ),
                        ),
                  SizedBox(width: 8.sp),
                ],
                Flexible(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: StyleText.fontSize16Weight500.copyWith(
                      color: AppColors.textButton,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
