/// Module: knowledge_hub / presentation / s3_view_knowledge_details / master_page/widgets/document_info/document_info.dart
/// ************************* FILE INFO *************************** ///
/// File Name: document_info.dart
/// Purpose: Contains the name, type, department and description of files.
/// Author: Youssef Khaled
/// Created At: 11/10/2025

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import '../../../../../main_controller/helper/responsive_helper.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

Widget buildDocumentInfo(
  BuildContext context, {
  required String documentName,
  required String documentType,
  required String owningDepartment,
}) {
  final isMobile = ResponsiveHelper.isMobile(context);
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildInfoRow(
        iconPath: 'assets/icons_assets/knowledge_hub_assets/document_name_icon.svg',
        label: '${S.of(context).document_name}: ',
        value: documentName,
      ),
      if (!isMobile) ...[
        _buildInfoRow(
          iconPath: 'assets/icons_assets/knowledge_hub_assets/document_type_icon.svg',
          label: '${S.of(context).document_type}: ',
          value: documentType,
        ),
        _buildInfoRow(
          iconPath: 'assets/icons_assets/knowledge_hub_assets/owning_department_icon.svg',
          label: S.of(context).owning_department,
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
}) {
  return Row(
    children: [
      CustomSvgImage(assetPath: iconPath, height: 20.h, width: 15.w, fit: BoxFit.fill,),
      SizedBox(width: 5.w),
      Text(
        label,
        style: StyleText.fontSize14Weight400.copyWith(
          color: AppColors.secondaryText,
        ),
      ),
      Text(value, style: StyleText.fontSize14Weight400),
    ],
  );
}

Widget buildDocumentDescription(
  BuildContext context, {
  required String documentDescription,
}) {
 var  lightMode = Theme.of(context).brightness == Brightness.light;
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          // Icon(Icons.description_outlined, size: 14, color: AppColors.grey),
          CustomSvgImage(
            assetPath: 'assets/icons_assets/knowledge_hub_assets/document_description_icon.svg',
            height: 18.h,
            width: 13.w,
            fit: BoxFit.fill,
          ),
          SizedBox(width: 4.w),
          Text(
            '${S.of(context).document_description}: ',
            style: StyleText.fontSize14Weight400.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
      SizedBox(height: 4.h),
      Text(
        FormatHelper.capitalize('$documentDescription'),
        maxLines: null,
        style: StyleText.fontSize10Weight400.copyWith(
          color: lightMode ? AppColors.blackButton : AppColors.white
        ),
      ),
    ],
  );
}
