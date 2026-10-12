import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart'; // Keep for .tr translations
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/presentation/controller/forms_group_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/presentation/controller/forms_group_state.dart';

import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/ui/widgets/dropdown/small_drop_down.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/custom/45-custom_app_dropdown.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/generated/l10n.dart';
class FilterRow extends StatelessWidget {
  const FilterRow({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FormsGroupCubit, FormsGroupState>(
      builder: (context, state) {
        if (state is! FormsGroupLoaded) {
          return const SizedBox.shrink();
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppSearchTextField(
              fillColor: AppColors.background,
              controller: state.searchController,
              onChanged: (value) {
                context.read<FormsGroupCubit>().search();
              },
            ),
            horizontalSpace(15),
            _buildDepartment(context, state),
          ],
        );
      },
    );
  }

  Widget _buildDepartment(BuildContext context, FormsGroupLoaded state) {
    final cubit = context.read<FormsGroupCubit>();
    final departments = cubit.getDepartments();

    if (ContextExtension(context).isTablett) {
      return SizedBox(
        width: 155,
        height: 36,
        child: AppDropdown(
          borderRadius: 8.r, // form bug report #8/#35: 8.r dropdowns
          value: null,
          width: double.infinity,
          fillColor: AppColors.background,
          textButton: S.of(context).department,
          items: departments.map((String department) {
            return DropdownMenuItem<String>(
              value: department,
              child: Text(
                FormatHelper.capitalize(department),
                style: StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryBlack),
              ),
            );
          }).toList(),
          onChanged: (p0) {
            if (p0 != null) {
              cubit.updateDepartment(p0.toLowerCase());
              cubit.search();
            }
          },
        ),
      );
    }

    return SizedBox(
      width: 36.sp,
      height: 36.sp,
      child: SmallDropdown(
        value: null,
        menuWidth: 300.w,
        fillColor: AppColors.background,
        textButton: S.of(context).department,
        items: departments.map((String department) {
          return DropdownMenuItem<String>(
            value: department,
            child: Text(
              FormatHelper.capitalize(department),
              style: StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryBlack),
            ),
          );
        }).toList(),
        onChanged: (p0) {
          if (p0 != null) {
            cubit.updateDepartment(p0.toLowerCase());
            cubit.search();
          }
        },
      ),
    );
  }
}