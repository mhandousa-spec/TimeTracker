import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:intl/intl.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

Widget selectedDocumentWidget(
  BuildContext context, {
  required String fileName,
  required String fileExtension,
  required int fileSize,
  required DateTime uploadedDate,
  required VoidCallback onRemove,
}) {
  final isMobile = ContextExtension(context).isPhone;
  final lightMode = Theme.of(context).brightness == Brightness.light;

  // Format file size
  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  // Format date
  String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  String getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'assets/icons_assets/main_icons_assets/svg_pdf_icon.svg';
      case 'ppt':
      case 'pptx':
        return 'assets/icons_assets/main_icons_assets/ppt_attachment_icon.svg';
      case 'doc':
      case 'docx':
        return 'assets/icons_assets/main_icons_assets/doc_icon.svg';
      case 'png':
      case 'jpg':
      case 'jpeg':
        return 'assets/icons_assets/main_icons_assets/svg_image_icon.svg';
      case 'mp4':
      case 'avi':
      case 'mov':
      case 'wmv':
      case 'flv':
      case 'mkv':
      case 'webm':
        return 'assets/icons_assets/main_icons_assets/knowledgeVideo.svg';
      case 'xlsx':
      case 'xls':
      case 'xlsm':
      case 'csv':
        return 'assets/icons_assets/main_icons_assets/excell.svg';
      default:
        return 'assets/icons_assets/main_icons_assets/svg_image_icon.svg';
    }
  }

  return Container(
    height: 60.h,
    width: !isMobile ? 310.w : double.infinity,
    decoration: BoxDecoration(
      color: lightMode ? AppColors.white : AppColors.background,
      borderRadius: BorderRadius.circular(8.r),
      border:lightMode ? Border.all(color: AppColors.borderGrey) : Border.all(color: Colors.transparent),
    ),
    padding: EdgeInsetsDirectional.only(start: 12.w, end: 10.w),
    child: Row(
      children: [
        // Document icon
        CustomSvgImage(
          assetPath: getFileIcon(fileExtension),
          color: fileExtension.toLowerCase().replaceAll('.', '') == "png" ||
              fileExtension.toLowerCase().replaceAll('.', '') == "jpg" ||
              fileExtension.toLowerCase().replaceAll('.', '') == "jpeg"
              ? AppColors.text : null,          height: 36,
          width: 36.w,

        ),
        SizedBox(width: 10.w),
        // Document info - Wrapped in Expanded to constrain width
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fileName,
                style: StyleText.fontSize14Weight500.copyWith(
                  color: lightMode
                      ? AppColors.blackButton
                      : AppColors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 12.sp),
              Text(
                formatFileSize(fileSize),
                style: StyleText.fontSize12Weight500.copyWith(
                  color: lightMode
                      ? AppColors.secondaryText
                      : AppColors.grey,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        // Uploaded date and remove button
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: onRemove,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.red,
                  shape: BoxShape.circle,
                ),
                margin: EdgeInsetsDirectional.only(top: 10.h),
                child: Icon(Icons.remove, size: 12.w, color: Colors.white),
              ),
            ),
            Spacer(),
            Padding(
              padding: EdgeInsetsDirectional.only(bottom: 10.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${S.of(context)!.uploadedDate}: ',
                    style: StyleText.fontSize10Weight400.copyWith(
                      color: lightMode
                          ? AppColors.secondaryText
                          : AppColors.grey,
                    ),
                  ),
                  Text(
                    formatDate(uploadedDate),
                    style: StyleText.fontSize10Weight400.copyWith(
                      color: lightMode
                          ? AppColors.blackButton
                          : AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
