// ****************** FILE INFO ******************
// File Name: crm_deal_document_card.dart
// Purpose: Document card widget for Deals displaying file icon, title, size, uploader, date, and delete action in edit mode (exact replica of client document card)
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_deal_document_model.dart';
import 'package:url_launcher/url_launcher.dart';

class CrmDealDocumentCard extends StatelessWidget {
  final CrmDealDocumentModel document;
  final bool isEditMode;
  final VoidCallback? onDelete;

  const CrmDealDocumentCard({
    super.key,
    required this.document,
    this.isEditMode = false,
    this.onDelete,
  });

  String _resolveFileIcon() {
    if (document.isPdf) return AppAssets.pdf;
    if (document.isWord) return AppAssets.word;
    if (document.isExcel) return AppAssets.excel;
    if (document.isPowerPoint) return AppAssets.powerPoint;
    if (document.isImage) return AppAssets.imageIcon;
    return AppAssets.attachmentIcon;
  }

  Future<void> _handleOpenDocument() async {
    if (isEditMode) {
      onDelete?.call();
      return;
    }
    if (document.url.isEmpty) return;
    try {
      final Uri uri = Uri.parse(document.url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final String uploadedByLabel = FormatHelper.localizedString(
      englishName: 'Uploaded By: ',
      arabicName: 'بواسطة: ',
    );
    final String uploadedOnLabel = FormatHelper.localizedString(
      englishName: 'Uploaded On: ',
      arabicName: 'بتاريخ: ',
    );

    return InkWell(
      onTap: _handleOpenDocument,
      borderRadius: BorderRadius.circular(6.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 8.sp),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(color: AppColors.borderCard),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // 1. File Type Icon (40x40)
            SizedBox(
              width: 40.sp,
              height: 40.sp,
              child: Center(
                child: CustomSvgImage(
                  assetPath: _resolveFileIcon(),
                  width: 36.sp,
                  height: 36.sp,
                ),
              ),
            ),
            SizedBox(width: 10.sp),

            // 2. Center Info: Name, Size, Uploaded By
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    document.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: StyleText.fontSize14Weight600.copyWith(
                      color: AppColors.text,
                      fontSize: 13.sp,
                    ),
                  ),
                  SizedBox(height: 2.sp),
                  Text(
                    document.formattedSize,
                    style: StyleText.fontSize12Weight400.copyWith(
                      color: AppColors.darkGrey,
                      fontSize: 10.sp,
                    ),
                  ),
                  SizedBox(height: 2.sp),
                  RichText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      children: <InlineSpan>[
                        TextSpan(
                          text: uploadedByLabel,
                          style: StyleText.fontSize12Weight400.copyWith(
                            color: AppColors.darkGrey,
                            fontSize: 10.sp,
                          ),
                        ),
                        TextSpan(
                          text: document.uploadedByName.isNotEmpty
                              ? document.uploadedByName
                              : 'Staff',
                          style: StyleText.fontSize12Weight400.copyWith(
                            color: AppColors.text,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.sp),

            // 3. Right Section: Delete Action (shown ONLY in edit mode) + Upload Date
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                if (isEditMode && onDelete != null)
                  InkWell(
                    onTap: onDelete,
                    borderRadius: BorderRadius.circular(12.r),
                    child: Padding(
                      padding: EdgeInsets.all(2.sp),
                      child: CustomSvgImage(
                        assetPath: AppAssets.minus,
                        width: 16.sp,
                        height: 16.sp,
                      ),
                    ),
                  )
                else
                  SizedBox(height: 16.sp),
                RichText(
                  text: TextSpan(
                    children: <InlineSpan>[
                      TextSpan(
                        text: uploadedOnLabel,
                        style: StyleText.fontSize12Weight400.copyWith(
                          color: AppColors.darkGrey,
                          fontSize: 10.sp,
                        ),
                      ),
                      TextSpan(
                        text: document.formattedUploadDate,
                        style: StyleText.fontSize12Weight400.copyWith(
                          color: AppColors.text,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
