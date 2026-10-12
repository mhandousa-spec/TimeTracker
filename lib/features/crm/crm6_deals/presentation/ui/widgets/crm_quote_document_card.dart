// ****************** FILE INFO ******************
// File Name: crm_quote_document_card.dart
// Purpose: Extracted Document card widget representing an uploaded file in Quote Details grid matching Figma screenshots 3 & 4
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

class QuoteDocumentItemModel {
  final String id;
  final String fileName;
  final String fileSize;
  final String uploadedBy;
  final String uploadedOn;
  final String extension; // 'pdf', 'doc', 'xlsx', 'ppt', 'png'

  const QuoteDocumentItemModel({
    required this.id,
    this.fileName = 'Watermark.png',
    this.fileSize = '62 KB',
    this.uploadedBy = 'Aya Ahmed',
    this.uploadedOn = '28 Dec 2024',
    this.extension = 'pdf',
  });
}

class CrmQuoteDocumentCard extends StatelessWidget {
  final QuoteDocumentItemModel document;
  final bool isDeleteMode;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const CrmQuoteDocumentCard({
    super.key,
    required this.document,
    this.isDeleteMode = false,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.all(12.sp),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 1. File Type Icon Badge from AppAssets
            _buildFileIconBadge(document.extension),
            SizedBox(width: 10.sp),

            // 2. File Metadata (Title, Size, Uploaded By)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    document.fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: StyleText.fontSize14Weight500.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: 2.sp),
                  Text(
                    document.fileSize,
                    style: StyleText.fontSize10Weight400.copyWith(color: AppColors.fullBlack).copyWith(
                      color: AppColors.darkGrey,
                      fontSize: 10.sp,
                    ),
                  ),
                  SizedBox(height: 2.sp),
                  Text(
                    'Uploaded By: ${document.uploadedBy}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: StyleText.fontSize10Weight400.copyWith(color: AppColors.fullBlack).copyWith(
                      color: AppColors.darkGrey,
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            ),

            // 3. Right: Delete Badge / Uploaded Date
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                if (isDeleteMode)
                  InkWell(
                    onTap: onDelete,
                    customBorder: const CircleBorder(),
                    child: CustomSvgImage(
                      assetPath: AppAssets.minusCircle,
                      width: 18.sp,
                      height: 18.sp,
                    ),
                  )
                else
                  const SizedBox.shrink(),
                SizedBox(height: 16.sp),
                Text(
                  'Uploaded On: ${document.uploadedOn}',
                  style: StyleText.fontSize10Weight400.copyWith(color: AppColors.fullBlack).copyWith(
                    color: AppColors.darkGrey,
                    fontSize: 9.sp,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileIconBadge(String ext) {
    String assetPath;
    switch (ext.toLowerCase()) {
      case 'doc':
      case 'docx':
        assetPath = AppAssets.word;
        break;
      case 'xlsx':
      case 'xls':
        assetPath = AppAssets.excel;
        break;
      case 'ppt':
      case 'pptx':
        assetPath = AppAssets.powerPoint;
        break;
      case 'pdf':
      default:
        assetPath = AppAssets.pdf;
        break;
    }

    return Container(
      width: 36.sp,
      height: 36.sp,
      alignment: Alignment.center,
      child: CustomSvgImage(
        assetPath: assetPath,
        width: 34.sp,
        height: 34.sp,
      ),
    );
  }
}
