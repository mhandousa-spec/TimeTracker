/// Module: roles / r3_user_access / presentation / ui / pages
///
///************************* FILE INFO ****************************///
/// File: user_access_container.dart
/// Purpose: Contains the ui for user access container roles_module screen.
/// Author: Amr Mesbah
/// Refactored at: 28/1/2025
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/features/roles/r3_user_access/presentation/controller/user_access_cubit.dart';

import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/features/roles/r3_user_access/presentation/controller/user_access_state.dart';
import 'package:knowticed_plus/features/roles/r3_user_access/presentation/ui/widgets/user_access_status_row.dart';
import 'package:knowticed_plus/features/roles/r3_user_access/presentation/ui/widgets/search_and_filter.dart';
import 'package:knowticed_plus/features/roles/r3_user_access/presentation/ui/widgets/user_access_card.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';

// REMOVED 12/8/2026: `EmployeeController addEmployeeController = Get.find();`
// — an unused top-level global that ran a service-locator lookup at import
// time (GetX standing rule + dead code).

class UserAccessHomePage extends StatefulWidget {
  const UserAccessHomePage({super.key});

  @override
  State<UserAccessHomePage> createState() => _UserAccessHomePageState();
}

class _UserAccessHomePageState extends State<UserAccessHomePage> {
  late UserAccessCubit controller;

  @override
  void initState() {
    controller = context.read<UserAccessCubit>();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.getAccountsStatusEntities();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    // Was a bare BlocBuilder. `UserAccessError` was emitted by the cubit but
    // nothing in the feature listened for it, so a failed load or a failed
    // activate/deactivate write could never reach the user (§16). The listener
    // surfaces it; the builder still renders the list.
    return BlocConsumer<UserAccessCubit, UserAccessState>(
      listenWhen: (_, current) => current is UserAccessError,
      listener: (context, state) {
        if (state is! UserAccessError) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              backgroundColor: AppColors.red,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
              content: Text(
                state.message,
                style: TextStyle(color: AppColors.white),
              ),
            ),
          );
      },
      buildWhen: (_, __) => true,
      builder: (context, state) {
        if (state is UserAccessLoading) {
          return Center(child: CircleProgressMaster());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserAccessStatusRow(),
            SizedBox(height: 20.sp),
            SearchAndFilter(),
            SizedBox(height: 20.sp),
            controller.filteredSortedSelectedEntities.isEmpty
                ? noMembers(isPortrait, context)
                : Expanded(
              child: ListView.separated(
                // ✅ Use ListView.separated instead of SingleChildScrollView + Column
                itemCount: controller.filteredSortedSelectedEntities.length,
                padding: EdgeInsets.only(bottom: 20.sp),
                separatorBuilder: (context, index) => SizedBox(height: 10.sp),
                itemBuilder: (context, index) {
                  final entity =
                      controller.filteredSortedSelectedEntities[index];
                  return UserAccessCard(
                    key: ValueKey(entity.employeeId),
                    entity: entity,
                    controller: controller,
                    departments: context.read<MainCoreDepartmentCubit>(),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Center noMembers(bool isPortrait, BuildContext context) {
    return Center(
      child: SizedBox(
        height: (isPortrait ? 0.62.h : 0.48.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              "assets/lottie_assets/notification_lottie_assets/empty.json",
              width: 300.w,
              height: 300.h,
              fit: BoxFit.fill,
            ),
          ],
        ),
      ),
    );
  }
}