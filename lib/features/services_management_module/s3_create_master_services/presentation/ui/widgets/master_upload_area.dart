/// Module: services_management_module
/// Description: Drag-and-drop / tap-to-browse upload target used for both
///              step 1 and step 2 of the master upload screen.
/// Author: Knowticed Team
/// Date: 02/07/2026
/// Dependencies: desktop_drop, AppColors, StyleText
/// Revision History:
///   - 02/07/2026 (Knowticed Team): Extracted from master_upload.dart
///     (fix item 5 — page LOC reduction).
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class MasterUploadArea extends StatelessWidget {
  final bool isStep2;
  final bool isDisabled;
  final bool isDragging;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onDragStateChanged;
  final void Function(DropDoneDetails)? onDragDone;

  const MasterUploadArea({
    super.key,
    required this.isStep2,
    required this.isDisabled,
    required this.isDragging,
    required this.onTap,
    this.onDragStateChanged,
    this.onDragDone,
  });

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragEntered: (_) {
        if (!isDisabled && isStep2) onDragStateChanged?.call(true);
      },
      onDragExited: (_) {
        if (isStep2) onDragStateChanged?.call(false);
      },
      onDragDone: isStep2 ? onDragDone : null,
      child: GestureDetector(
        onTap: isDisabled ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 68.sp),
          decoration: BoxDecoration(
            color: isDragging
                ? AppColors.primary.withOpacity(0.06)
                : AppColors.card,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: isDisabled ? _buildDisabled(context) : _buildActive(context),
        ),
      ),
    );
  }

  Widget _buildDisabled(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.lock_outline, size: 52.sp, color: AppColors.grey),
        SizedBox(height: 18.sp),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.sp),
          child: Text(
            'Complete The First Upload To Enable This Step',
            style: StyleText.fontSize14Weight400.copyWith(
              color: AppColors.grey,
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildActive(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: isDragging
              ? Icon(
                  Icons.cloud_upload_outlined,
                  key: const ValueKey('dragging'),
                  size: 68.sp,
                  color: AppColors.primary,
                )
              : SvgPicture.asset(
                  'assets/icons_assets/form_builder_assets/cloud_download.svg',
                  key: const ValueKey('normal'),
                  width: 150.sp,
                  height: 150.sp,
                  color: AppColors.secondaryText,
                  fit: BoxFit.fill,
                ),
        ),
        SizedBox(height: 22.sp),
        Text(
          isDragging
              ? 'Drop your Excel file here'
              : S.of(context).dragDropFilesHere,
          style: StyleText.fontSize14Weight400.copyWith(
            color: isDragging ? AppColors.primary : AppColors.secondaryText,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 18.sp),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 26.sp, vertical: 11.sp),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            S.of(context).browseFiles,
            style: StyleText.fontSize14Weight400
                .copyWith(color: AppColors.textButton),
          ),
        ),
      ],
    );
  }
}
