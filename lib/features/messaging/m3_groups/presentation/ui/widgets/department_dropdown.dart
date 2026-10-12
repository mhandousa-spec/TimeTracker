/// Module: messaging / groups / presentation/ui/widgets/department_dropdown.dart
/// ************************* FILE INFO *************************** ///
/// File Name: department_dropdown.dart
/// Purpose: Department dropdown — messaging Groups sub-feature.
/// Author: Knowticed Team
/// Created At: 11/10/2025

// Date: 28/4/2026
// Updated by: Amr Mesbah
// Objectives: Department dropdown using the core CustomDropdown

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:knowticed_plus/features/messaging/m2_connections/presentation/controller/connections_controller.dart';
import 'package:knowticed_plus/features/messaging/m3_groups/presentation/controller/groups_controller.dart';
import 'package:knowticed_plus/features/messaging/m4_messaging_home/presentation/controller/messaging_home_controller.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import '../../../../../../core/helper/message_module/interface/entity/user_category.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class DepartmentDropdown extends StatefulWidget {
  const DepartmentDropdown({super.key});

  @override
  State<DepartmentDropdown> createState() => _DepartmentDropdownState();
}

class _DepartmentDropdownState extends State<DepartmentDropdown> {
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final groupsCubit = context.read<GroupsCubit>();
    final connectionsCubit = context.read<ConnectionsCubit>();
    final messagingHomeCubit = context.read<MessagingHomeCubit>();
    final isTablet = ContextExtension(context).isTablett;
    final isAr = context.isArabic;

    final List<UserCategory> categories = connectionsCubit.categories!;

    // ── THE "All" PSEUDO-CATEGORY ────────────────────────────────────────
    //
    // categories[0] is not a real department — it is the "All" bucket, and the
    // whole messaging module treats it that way: ConnectionsCubit skips the
    // category filter entirely when the selected tab is `categories![0]`
    // (connections_controller.dart, twice), and counts EVERY connection into
    // it when building categoriesUsersCount.
    //
    // This dropdown was the one place that ignored the convention — it passed
    // the All entry's id straight through as `userCategoryId`, and
    // GroupsCubit.searchMembersToAddToGroup then filtered members by an id no
    // member carries. Result: picking "All" hid every employee.
    final String allCategoryId =
        categories.isNotEmpty ? categories.first.categoryId : '';

    final List<DropdownItem<String>> categoryItems =
        categories.map((UserCategory d) {
      return DropdownItem<String>(
        value: d.categoryId,
        label: d.name,
      );
    }).toList();

    // On phone the trigger is icon-only, so the selected label is collapsed.
    final TextStyle triggerStyle = isTablet
        ? TextStyle(fontSize: 14.sp, color: AppColors.text)
        : const TextStyle(fontSize: 0, height: 0, color: Colors.transparent);

    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: SizedBox(
        width: isTablet ? 185.sp : 38.sp,
        height: 38,
        child: CustomDropdown<String>(
          value: _selectedCategoryId,
          items: categoryItems,
          fillColor: AppColors.background,
          hint: isTablet ? (isAr ? 'القسم' : 'Department') : '',
          hintStyle: triggerStyle,
          valueStyle: triggerStyle,
          borderRadius: BorderRadius.circular(8.r),
          triggerPadding: EdgeInsets.symmetric(horizontal: 12.sp,vertical: 14.sp),
          prefixIcon: isTablet
              ? null
              : SvgPicture.asset(
                  'assets/icons_assets/messaging_assets/depart.svg',
                  width: 16.sp,
                  height: 16.sp,
                ),
          suffixIcon: isTablet ? null : const SizedBox.shrink(),
          onChanged: (selectedKey) {
            setState(() {
              _selectedCategoryId = selectedKey;
            });
            // "" means "no category filter" to searchMembersToAddToGroup.
            // CustomDropdown.onChanged is ValueChanged<String> (non-null), so
            // All is the only "show everything" case to map.
            groupsCubit.userCategoryId =
                selectedKey == allCategoryId ? '' : selectedKey;
            groupsCubit.searchMembersToAddToGroup(
              groupsCubit.searchController.text,
              connectionsCubit,
              messagingHomeCubit,
            );
          },
        ),
      ),
    );
  }
}