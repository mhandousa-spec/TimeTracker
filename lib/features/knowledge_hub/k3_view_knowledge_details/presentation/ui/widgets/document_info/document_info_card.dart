/// Module: knowledge_hub / presentation / s3_view_knowledge_details / master_page/widgets/document_info/document_info_card.dart
/// ************************* FILE INFO *************************** ///
/// File Name: document_info_card.dart
/// Purpose: Contains the document info without inquiries and comments.
/// Author: Youssef Khaled
/// Created At: 11/10/2025

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import '../../../../../main_controller/helper/responsive_helper.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import './build_document_header.dart';
import 'document_info.dart' hide buildDocumentDescription;

Widget buildDocumentInfoCard(
    BuildContext context, {
      required String publishDate,
      required String documentName,
      required String documentType,
      required String owningDepartment,
      required String documentDescription,
      required String documentExtension,
    }) {
  final isMobile = ResponsivePage.isMobile(context);
  final lightMode = Theme.of(context).brightness == Brightness.light;

  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8.r),
      color: lightMode ? AppColors.white : AppColors.chatBackground,
    ),
    padding: EdgeInsets.all(15.sp),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildDocumentHeader(
          context,
          documentName: documentName,
          documentType: documentType,
          owningDepartment: owningDepartment,
          documentExtension: documentExtension,
        ),
        SizedBox(height: 15.h),
        buildDocumentDescription(
          context,
          documentDescription: documentDescription,
        ),
        if (isMobile) ...[
          SizedBox(height: 15.h),
          Row(
            children: [
              CustomSvgImage(
                assetPath: 'assets/icons_assets/knowledge_hub_assets/document_type_icon.svg',
                height: 15.h,
                width: 15.h,
              ),
              SizedBox(width: 5.w),
              Text(
                '${S.of(context).document_type}: ',
                style: StyleText.fontSize14Weight400.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
              Expanded(
                child: Text(
                  documentType,
                  style: StyleText.fontSize14Weight400.copyWith(
                    color: lightMode
                        ? AppColors.blackButton
                        : AppColors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          Row(
            children: [
              CustomSvgImage(
                assetPath: 'assets/icons_assets/knowledge_hub_assets/owning_department_icon.svg',
                height: 15.h,
                width: 15.h,
              ),
              SizedBox(width: 5.w),
              Text(
                '${S.of(context).owning_department}: ',
                style: StyleText.fontSize14Weight400.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
              Expanded(
                child: Text(
                  owningDepartment,
                  style: StyleText.fontSize14Weight400.copyWith(
                    color: lightMode
                        ? AppColors.blackButton
                        : AppColors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ],
    ),
  );
}

Widget buildPublishDate(BuildContext context, {required String publishDate}) {
  var lightMode = Theme.of(context).brightness == Brightness.light;

  return Row(
    children: [
      Text(
        '${S.of(context).publish_date}: ',
        style: StyleText.fontSize10Weight400.copyWith(
          color: lightMode ? AppColors.secondaryText : AppColors.grey
        ),
      ),
      Text(
        publishDate,
        style: StyleText.fontSize10Weight400.copyWith(
            color: lightMode ? AppColors.blackButton : AppColors.white
        ),
      ),
    ],
  );
}