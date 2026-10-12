/// Module: GRC Policy Management
/// Description: Compact preview card for an uploaded policy document.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-01
/// Dependencies: Flutter SDK, AppColors, AppTheme, PolicyDocumentInfo
/// Revision History: 2026-07-01 - Initial creation
///                   2026-07-15 - Added `readOnly` mode (hides the remove
///                                button) for already-uploaded documents
///                                shown on the Policy Details page
library;

import 'package:get/get.dart';
/// ************************* FILE INFO *************************** ///
/// File Name: policy_document_preview_widget.dart
/// Purpose: Contains PolicyDocumentPreviewWidget, a compact card that
///          displays document metadata and, unless read-only, a remove
///          button.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 1/7/2026

import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/52-custom_upload_document.dart'
    show getFileIcon;
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_document_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// class name: [PolicyDocumentPreviewWidget]
///
/// purpose: stateless card that shows a PDF icon, document name, size (if
///          known), date (if known), and — unless [readOnly] — a red remove
///          button. Used in the policy info form, each control card, and
///          the read-only Policy Details page.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 1/7/2026
class PolicyDocumentPreviewWidget extends StatelessWidget {
  final PolicyDocumentInfo document;
  final VoidCallback? onRemove;
  final bool readOnly;

  const PolicyDocumentPreviewWidget({
    super.key,
    required this.document,
    this.onRemove,
    this.readOnly = false,
  });

  /// The uploaded file's extension, lower-cased and without the dot ('' when
  /// the name carries none). Feeds [getFileIcon], so a .docx shows the Word
  /// icon rather than a PDF one.
  String get _extension {
    final String name = document.name;
    final int dot = name.lastIndexOf('.');
    if (dot < 0 || dot == name.length - 1) return '';
    return name.substring(dot + 1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary.withOpacity(.4)),
        borderRadius: BorderRadius.circular(8.r),
        color: AppColors.background,
      ),
      child: Row(
        children: [
          // The app already ships per-file-type SVGs and one helper that
          // picks between them (getFileIcon), which is what the upload
          // dialog and the confirm dialogs use. A hardcoded Material
          // picture_as_pdf in raw Colors.red showed a PDF glyph over every
          // .doc/.docx too, and ignored the theme.
          CustomSvgImage(
            assetPath: getFileIcon(_extension),
            width: 26.sp,
            height: 26.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  document.name,
                  style: StyleText.fontSize14Weight500
                      .copyWith(color: AppColors.text),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.sp),
                if (document.sizeLabel.isNotEmpty)
                  Text(
                    document.sizeLabel,
                    style: StyleText.fontSize12Weight500
                        .copyWith(color: AppColors.secondaryText),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [

              if (!readOnly) ...[
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: onRemove,
                  child: CircleAvatar(
                    radius: 8.r,
                    backgroundColor: Colors.red,
                    child: Icon(Icons.remove, color: Colors.white, size: 12.sp),
                  ),
                ),
              ],
              SizedBox(height: context.isPhone ? 10.sp : 6.sp),

              if (document.dateLabel.isNotEmpty) ...[
                SizedBox(width: 8.w),
                Text(
                  'Date: ${document.dateLabel}',
                  style: StyleText.fontSize12Weight500
                      .copyWith(color: AppColors.secondaryText),
                ),
              ],
            ],
          )
        ],
      ),
    );
  }
}
