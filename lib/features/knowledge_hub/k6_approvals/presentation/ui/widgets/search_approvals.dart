/// Module: knowledge_hub / presentation / s6_approvals / widgets/search_approvals.dart
/// ************************* FILE INFO *************************** ///
/// File Name: search_approvals.dart
/// Purpose: Search approvals — Approvals (S6) screen UI.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import '../../controller/approvals_cubit.dart';
import '../../controller/approvals_states.dart';
import '../pages/approval_filter.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdwon.dart';
import 'package:knowticed_plus/core/custom/14-custom_filter_icon.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class SearchApprovals extends StatefulWidget {
  final TextEditingController searchApprovalsController;
  final VoidCallback? onStatusChanged;

  const SearchApprovals({
    Key? key,
    required this.searchApprovalsController,
    this.onStatusChanged,
  }) : super(key: key);

  @override
  State<SearchApprovals> createState() => _SearchApprovalsState();
}

class _SearchApprovalsState extends State<SearchApprovals> {
  String? selectedDepartmentId;
  final MainCoreDepartmentCubit departmentController = Get.find<MainCoreDepartmentCubit>();

  @override
  void initState() {
    super.initState();
    _loadDepartments();
  }

  Future<void> _loadDepartments() async {
    await departmentController.getAllDepartments();
    if (mounted) {
      setState(() {});
    }
  }

  List<Map<String, String>> _getDepartmentItems() {
    bool isEnglish = Get.locale.toString().contains('en');
    List<Map<String, String>> items = [];

    // Add "All Departments" option at the beginning
    items.add({
      "key": "all",
      "value": isEnglish ? "All Departments" : "جميع الأقسام",
    });

    // Add all departments
    for (int i = 0; i < departmentController.departmentIds.length; i++) {
      String departmentId = departmentController.departmentIds[i];
      String departmentName = isEnglish
          ? departmentController.departmentsEnglishName[i]
          : departmentController.departmentsArabicName[i];

      items.add({
        "key": departmentId,
        "value": departmentName,
      });
    }

    return items;
  }

  void _onDepartmentChanged(String? departmentId) {
    final cubit = context.read<ApprovalsCubit>();

    // Always reflect the chosen option in the trigger — including the
    // "All Departments" option (key "all"), which previously mapped to null and
    // left the trigger showing only the hint. The cubit still filters on null
    // for the show-everything case.
    setState(() => selectedDepartmentId = departmentId);
    cubit.filterByDepartment(
      (departmentId == null || departmentId == "all") ? null : departmentId,
    );
  }

  // ✅ Public method to reset department filter
  void resetDepartmentFilter() {
    if (selectedDepartmentId != null) {
      setState(() => selectedDepartmentId = null);
      final cubit = context.read<ApprovalsCubit>();
      cubit.filterByDepartment(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final isMobile = ContextExtension(context).isPhone;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppSearchTextField(
          controller: widget.searchApprovalsController,
          onChanged: (query) {
            context.read<ApprovalsCubit>().searchKnowledge(query);
          },
        ),

        isMobile ? SizedBox() : SizedBox(width: 10.w),
        isMobile
            ? SizedBox()
            : SizedBox(
                width: 135.w,
                height: 38.sp,
                child: CustomDropdown<String>(

                  triggerPadding: EdgeInsets.symmetric(vertical: 15.sp,horizontal: 8.sp),
                  borderRadius: BorderRadius.circular(6.r),
                  value: selectedDepartmentId,
                  items: _getDepartmentItems()
                  .map((e) => DropdownItem<String>(
                    value: e['key'] ?? '',
                    label: e['value'] ?? '',
                  ))
                  .toList(),
                  onChanged: (v) => _onDepartmentChanged(v),
                  hint: S.of(context).department,
                  hintStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400),
                  fillColor: AppColors.card,
                ),
              ),


        SizedBox(width: 10.w),

        // Custom filter action button (core/custom/14-custom_filter_icon.dart).
        // Handles mobile (icon-only) vs tablet/desktop (icon + text) sizing
        // internally, replacing the previous hand-rolled GestureDetector.
        //
        // Wrapped in a BlocBuilder so the button reflects the ACTIVE filter
        // state: once the user applies any filter (status / document type /
        // date range) it turns primary with textButton-colored icon & text, and
        // reverts when the filters are reset. CustomFilterIcon ties its text
        // color to [svgColor], so setting svgColor also recolors the label.
        BlocBuilder<ApprovalsCubit, ApprovalsStates>(
          builder: (context, state) {
            final cubit = context.read<ApprovalsCubit>();
            // CHANGED 12/9/2026 — reads the dialog's own flag instead of the
            // four filter fields. `selectedStatus` is shared with the category
            // tab row above the list, so the old test was true as soon as a tab
            // was selected (i.e. always) and the button sat primary from the
            // first frame. See [ApprovalsCubit.dialogFilterActive].
            final bool isFilterActive = cubit.dialogFilterActive;

            return CustomFilterIcon(
              title: S.of(context).filter,
              color: isFilterActive ? AppColors.primary : AppColors.card,
              svgColor: isFilterActive
                  ? AppColors.textButton
                  : AppColors.secondaryText.withOpacity(.5),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => Center(
                    child: BlocProvider.value(
                      value: context.read<ApprovalsCubit>(),
                      child: ApprovalsFilterDialog(),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}