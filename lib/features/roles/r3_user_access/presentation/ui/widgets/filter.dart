/// Module: roles / r3_user_access / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: filter.dart
/// Purpose: Declares `Filter` — the department/date filter dialog for the
///          user-access list.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header;
///          removed GetX and two dead methods.
/// Updated: 29/8/2026 - "Discard" replaced by "Reset", which clears the selected
///          department here and on the cubit and re-runs the list.

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/core/helper/data_grc_module/core/extensions/extensions.dart';
import 'package:knowticed_plus/features/roles/r3_user_access/domain/entities/user_access_entity.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';

import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/custom/53-custom_date_pic.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdwon.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/helper/role/constants.dart';
import 'package:knowticed_plus/features/roles/r3_user_access/presentation/controller/user_access_cubit.dart';
import 'package:knowticed_plus/generated/l10n.dart';
class Filter extends StatefulWidget {
   Filter({
     super.key});
   

  @override
  State<Filter> createState() => _FilterState();
}

class _FilterState extends State<Filter> {
   late UserAccessCubit controller;
   String? selectedDepartment;
   String? selectedTitle;

  @override
  void initState() {
    super.initState();
    controller = context.read<UserAccessCubit>();

    selectedDepartment = controller.selectedDepartment;
    selectedTitle = controller.selectedTitle;
  }

  /// One entry per job title across every loaded account (English value,
  /// localized label). Role QA p.37.
  List<DropdownItem<String>> _titleItems() {
    final Map<String, UserAccessEntity> byTitle = <String, UserAccessEntity>{};
    for (final UserAccessEntity e
        in controller.accountStatusEntities.values.expand((l) => l)) {
      final String key = e.englishTitle.trim();
      if (key.isEmpty) continue;
      byTitle.putIfAbsent(key.toLowerCase(), () => e);
    }
    final List<UserAccessEntity> unique = byTitle.values.toList()
      ..sort((a, b) => a.englishTitle
          .toLowerCase()
          .compareTo(b.englishTitle.toLowerCase()));
    return unique
        .map((e) => DropdownItem<String>(
              value: e.englishTitle.trim(),
              label: context.isArabic && e.arabicTitle.trim().isNotEmpty
                  ? e.arabicTitle.trim()
                  : FormatHelper.capitalize(e.englishTitle.trim()),
            ))
        .toList();
  }
  @override
  Widget build(BuildContext context) {

    // REMOVED 12/8/2026: unused `lightMode` local.
    bool isTablet = MediaQuery.of(context).size.width > 600;
    return Container(

      padding: EdgeInsets.all(15.sp),
      decoration: BoxDecoration(
        color:  AppColors.card,
        borderRadius: BorderRadius.circular(8.sp),
      ),
      width: isTablet ? 400.sp : 300.sp,
      child: Column(
        spacing: 15.sp,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          Row(
            spacing: 5.sp,
            children: [
              CircleAvatar(
                radius: 15.sp,
                backgroundColor: AppColors.primary,
                child: Container(
                  padding: EdgeInsets.all(4.sp),
                  child: CustomSvgImage(assetPath: 'assets/icons_assets/main_icons_assets/filter_sliders.svg',
                  width: 16.sp,
                    height: 16.sp,
                    color: AppColors.textButton,
                  ),
                ),
              ),
              Text(S.of(context).Filter, style: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.text
              )),
            ],
          ),
          SizedBox(
            width: double.infinity,
            child: CustomDropdown<String>(
              label: S.of(context).select_department,
              value: selectedDepartment,
              fillColor: AppColors.background,
              hint: S.of(context).department,
              // Size the TRIGGER only. The fixed height used to be on the
              // wrapping SizedBox, which squeezed the whole label+field Column
              // and hid the field; `CustomDropdown.height` pins just the box.
              height: 36,
              items: context.read<MainCoreDepartmentCubit>()
                  .departmentIds
                  .map((String department) {
                return DropdownItem<String>(
                  value: department,
                  label: FormatHelper.capitalize(
                    context.isArabic
                        ? context.read<MainCoreDepartmentCubit>()
                            .getArabicDepartmentNameFromDepartmentId(
                                departmentId: department)!
                        : context.read<MainCoreDepartmentCubit>()
                            .getEnglishDepartmentNameFromDepartmentId(
                                departmentId: department)!,
                  ),
                );
              }).toList(),
              onChanged: (p0) {
                setState(() {
                  selectedDepartment = p0;
                });
              },
            ),
          ),

          // Role QA p.37: Title filter under Department.
          SizedBox(
            width: double.infinity,
            child: CustomDropdown<String>(
              label: S.of(context).jobTitle,
              value: selectedTitle,
              fillColor: AppColors.background,
              hint: S.of(context).jobTitle,
              height: 36,
              items: _titleItems(),
              onChanged: (p0) {
                setState(() {
                  selectedTitle = p0;
                });
              },
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // EDIT 29/8/2026: "Discard" is now "Reset", and it clears the
              // filter instead of closing the dialog.
              //
              // "Discard" only called `pop()` — it threw away an unsaved change
              // and left an already-applied department filter in place, so
              // there was no way to get back to an unfiltered list from this
              // dialog at all: the dropdown has no empty option to pick.
              //
              // Reset clears BOTH halves — the dropdown here and the applied
              // `selectedDepartment` on the cubit — then re-runs the search so
              // the list behind the dialog is unfiltered immediately.
              //
              // It deliberately does NOT close: a button that clears and closes
              // in one motion is indistinguishable from the old Discard, and
              // the user cannot see that anything happened. Tapping outside
              // still dismisses the dialog.
              Expanded(
                child: customButton(
                    color: AppColors.secondaryButton,
                    textStyle: StyleText.fontSize16Weight500
                        .copyWith(color: AppColors.blackButton),
                    title: S.of(context).reset,
                    function: () {
                      setState(() {
                        selectedDepartment = null;
                        selectedTitle = null;
                      });
                      controller.selectedDepartment = null;
                      controller.selectedTitle = null;
                      controller.searchAccountsStatusEntities(
                          controller.searchTerm, controller.selectedSortOption);
                    }),
              ),
              SizedBox(width: 20.sp),
              Expanded(
                child: customButton(
                    title:  S.of(context).Save,
                    function: () {
                    controller.selectedDepartment = selectedDepartment;
                    controller.selectedTitle = selectedTitle;
                    controller.searchAccountsStatusEntities(
                        controller.searchTerm, controller.selectedSortOption);
                    Navigator.of(context).pop();
                    }),
              ),
            ],
          )
        ],
      ),
    );
  }

   // REMOVED 12/8/2026:
   //   - `scheduleCalendar(BuildContext)` — never referenced; its onTap was
   //     empty and it rendered an empty Text("").
   //   - `_buildDropdownText()` — never referenced (analyzer dead code) and it
   //     carried a hardcoded 'Department' literal instead of an ARB key.
}
