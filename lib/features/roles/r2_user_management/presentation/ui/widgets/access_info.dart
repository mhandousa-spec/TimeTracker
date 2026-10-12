/// Module: roles / r2_user_management / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: access_info.dart
/// Purpose: Declares `AccessInfo`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'package:flutter/cupertino.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/core/helper/data_grc_module/core/extensions/extensions.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/presentation/controller/user_management_cubit.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_font_weights.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/helper/role/constants.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class AccessInfo extends StatelessWidget {
  AccessInfo({super.key});
  late UserManagementAccessCubit controller;
  @override
  Widget build(BuildContext context) {
    controller = context.read<UserManagementAccessCubit>();

    return Column(
      spacing: 8.sp,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          FormatHelper.capitalize(controller.selectedRole),
          style: StyleText.fontSize16Weight600,
        ),
        Row(
          spacing: 10.sp,
          children: [
            Expanded(
                child: mainBlock(
                    title: S.of(context).creationDate,
                    value: DateFormat(Constants.userAccessDateFormat,
                            context.isArabic ? 'ar' : 'en')
                        .format(controller.creationDate!))),
            Expanded(
                child: mainBlock(
                    title: S.of(context).totalEmployees,
                    value: controller.employeeToGiveAccess.length.toString())),
            Expanded(
                child: mainBlock(
                    title: S.of(context).totalDepartments,
                    value: controller.employeeToGiveAccess
                        .map((e) => e.departmentId)
                        .toSet()
                        .length
                        .toString())),
          ],
        )
      ],
    );
  }

  Widget mainBlock({required String title, required String value}) {
    return Container(
        height: 75.sp,
        padding: EdgeInsets.all(15.sp),
        decoration: BoxDecoration(
          color: AppColors.field,
          borderRadius: BorderRadius.circular(8.sp),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FittedBox(
              child: Text(title,
                  style: StyleText.fontSize14Weight600
                      .copyWith(fontSize: 13.sp)),
            ),
            Text(value,
                style: StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryBlack).copyWith(
                    fontSize: 13.sp, fontWeight: AppFontWeights.semiBold)),
          ],
        ));
  }
}
