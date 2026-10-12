/// Module: knowledge_hub / presentation / s3_view_knowledge_details / master_page/widgets/document_info/build_document_header.dart
/// ************************* FILE INFO *************************** ///
/// File Name: build_document_header.dart
/// Purpose: Contains the document header with dynamic file icon
/// Author: Youssef Khaled
/// Created At: 11/10/2025

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import '../../../../../main_controller/helper/responsive_helper.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

Widget buildDocumentHeader(
    BuildContext context, {
      required String documentName,
      required String documentType,
      required String owningDepartment,
      required String documentExtension,
    }) {
  final isMobile = ResponsiveHelper.isMobile(context);
  final lightMode = Theme.of(context).brightness == Brightness.light;

  return Row(
    children: [
      Center(
        child: CustomSvgImage(
          assetPath: _getFileIcon(documentExtension),
          width: 70.w,
          height: 70.h,
          color: lightMode ? AppColors.colorBlack : AppColors.colorWhite,
          fit: BoxFit.contain,
        ),
      ),
      SizedBox(width: 8.w),
      Expanded(
        child: buildDocumentInfo(
          context,
          documentName: documentName,
          documentType: documentType,
          owningDepartment: owningDepartment,
        ),
      ),
    ],
  );
}

Widget buildDocumentInfo(
    BuildContext context, {
      required String documentName,
      required String documentType,
      required String owningDepartment,
    }) {
  final isMobile = ResponsiveHelper.isMobile(context);
  final lightMode = Theme.of(context).brightness == Brightness.light;

  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildInfoRow(
        lightMode: lightMode,
        iconPath: 'assets/icons_assets/knowledge_hub_assets/document_name_icon.svg',
        label: '${S.of(context).document_name}: ',
        value: documentName,
      ),
      if (!isMobile) ...[
        SizedBox(height: 8.h),
        _buildInfoRow(
          lightMode: lightMode,
          iconPath: 'assets/icons_assets/knowledge_hub_assets/document_type_icon.svg',
          label: '${S.of(context).document_type}: ',
          value: documentType,
        ),
        SizedBox(height: 8.h),
        _buildInfoRow(
          lightMode: lightMode,
          iconPath: 'assets/icons_assets/knowledge_hub_assets/owning_department_icon.svg',
          label: '${S.of(context).owning_department}: ',
          value: owningDepartment,
        ),
      ],
    ],
  );
}

Widget _buildInfoRow({
  required String label,
  required String value,
  required String iconPath,
  required bool lightMode,
}) {
  return Row(
    children: [
      CustomSvgImage(
        assetPath: iconPath,
        height: 16.h,
        width: 16.w,
        fit: BoxFit.contain,
      ),
      SizedBox(width: 5.w),
      Text(
        label,
        style: StyleText.fontSize12Weight400.copyWith(
          color: AppColors.secondaryText,
        ),
      ),
      Expanded(
        child: Text(
          value,
          style: StyleText.fontSize12Weight500.copyWith(
            color: lightMode
                ? AppColors.blackButton
                : AppColors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}

Widget buildDocumentDescription(
    BuildContext context, {
      required String documentDescription,
    }) {
  var lightMode = Theme.of(context).brightness == Brightness.light;

  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          CustomSvgImage(
            assetPath: 'assets/icons_assets/knowledge_hub_assets/document_description_icon.svg',
            height: 16.h,
            width: 16.w,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 6.w),
          Text(
            '${S.of(context).document_description}: ',
            style: StyleText.fontSize12Weight500.copyWith(

              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
      SizedBox(height: 8.h),
      Text(
        FormatHelper.capitalize('$documentDescription'),
        maxLines: null,
        style: StyleText.fontSize12Weight400.copyWith(
          height: 1.6,
          color: AppColors.text
        ),
      ),
    ],
  );
}

// ✅ GET CORRECT FILE ICON BASED ON EXTENSION
String _getFileIcon(String extension) {
  final ext = extension.toLowerCase().trim().replaceAll('.', '');

  switch (ext) {
    case 'pdf':
      return 'assets/icons_assets/main_icons_assets/svg_pdf_icon.svg';
    case 'ppt':
    case 'pptx':
      return 'assets/icons_assets/main_icons_assets/ppt_attachment_icon.svg';
    case 'doc':
      return 'assets/icons_assets/main_icons_assets/doc_icon.svg';
    case 'docx':
      return 'assets/icons_assets/knowledge_hub_assets/docx_icon.svg';
    case 'xls':
    case 'xlsx':
      return 'assets/icons_assets/knowledge_hub_assets/xls_icon.svg';
    case 'jpg':
    case 'jpeg':
    case 'png':
    case 'gif':
    case 'bmp':
    case 'webp':
      return 'assets/icons_assets/main_icons_assets/svg_image_icon.svg';
    case 'mp4':
    case 'mov':
    case 'avi':
    case 'mkv':
      return 'assets/svg/video_icon.svg';
    default:
      return 'assets/icons_assets/knowledge_hub_assets/document_type_icon.svg';
  }
}