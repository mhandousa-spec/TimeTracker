// ****************** FILE INFO ******************
// File Name: crm_template_details_actions_bar.dart
// Purpose: Details page action buttons for CRM template elements
// Author: Mohand Adel
// Created At: 05/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/12-custom_delete_icon.dart';
import 'package:knowticed_plus/core/custom/13-custom_edit_icon.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

class CrmTemplateDetailsActionsBar extends StatelessWidget {
  const CrmTemplateDetailsActionsBar({
    required this.onEdit,
    required this.onRemove,
    super.key,
  });

  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.sizeOf(context).width < 600;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomEditIcon(onTap: onEdit),
        SizedBox(width: isMobile ? 8.sp : 14.sp),
        CustomDeleteIcon(
          color: AppColors.red,
          svgColor: AppColors.white,
          onTap: onRemove,
        ),
      ],
    );
  }
}
