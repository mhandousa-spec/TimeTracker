/// Module: roles / r1_role_management / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: roles_filter_row.dart
/// Purpose: Declares `RolesFilterRow`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/role_status.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/controller/role_cubit.dart';

class RolesFilterRow extends StatelessWidget {
  RolesFilterRow({super.key});
  late RoleCubit controller;

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.width > 600;
    controller = context.read<RoleCubit>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          spacing: 10.sp,
          children: [
            for (RoleStatus status in RoleStatus.filterStatus)
              customButton(
                wrapContent: true,
                contentHorizontalPadding: 10.sp,
                color: controller.selectedRoleStatus == status
                    ? AppColors.primary
                    : AppColors.field,
                textStyle: controller.selectedRoleStatus == status
                    ? null
                    : StyleText.fontSize14Weight400
                    .copyWith(color: status.color),
                title: status.localizedName(context),
                function: () {
                  controller.updateSelectedRoleStatus(status);
                },
              )
          ],
        ),
      ],
    );
  }
}