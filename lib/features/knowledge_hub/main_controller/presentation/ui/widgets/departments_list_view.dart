// departments_list_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/department_model.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../../../../k3_view_knowledge_details/presentation/controller/create_knowledge_state.dart';
import '../../../../k1_create_new_knowledge/presentation/controller/create_knowledge_cubit.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

/// Rewrite the ASCII digits in [value] as Arabic-Indic numerals (٠١٢…) when
/// [arabic] is true, so the per-department filter counts read in Arabic figures
/// under the Arabic locale.
String _localizeDigits(String value, bool arabic) {
  if (!arabic) return value;
  const western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const eastern = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  var out = value;
  for (var i = 0; i < western.length; i++) {
    out = out.replaceAll(western[i], eastern[i]);
  }
  return out;
}

Widget departmentsListView(
    BuildContext context, {
      required int selectedIndex,
      required CreateKnowledgeCubit cubit,
      required List<DepartmentModelPro> departmentNames,
    }) {
  // Sort departments by knowledge count (descending)
  final sortedDepartments = [...departmentNames];
  sortedDepartments.sort((a, b) {
    int countA = cubit.getKnowledgeCountByDepartment(a.departmentName ?? '');
    int countB = cubit.getKnowledgeCountByDepartment(b.departmentName ?? '');
    return countB.compareTo(countA); // Descending order (highest first)
  });

  final allDepartments = [
    DepartmentModelPro(
      departmentName: S.of(context)!.all,
      departmentNameInArabic: 'الكل', // Add Arabic translation
      departmentID: '0',
    ),
    ...sortedDepartments, // Use sorted list instead of departmentNames
  ];

  final isMobile = ContextExtension(context).isPhone;
  final isLightMode = Theme.of(context).brightness == Brightness.light;

  // Check if current locale is Arabic
  final isArabic = Get.locale?.languageCode == 'ar';

  return BlocBuilder<CreateKnowledgeCubit, CreateKnowledgeState>(
    buildWhen: (previous, current) =>
    current is FetchingKnowledgeSuccessState ||
        current is FetchingKnowledgeEmptyState,
    builder: (context, state) {
      return SizedBox(
        height: isMobile ? 35.h : 45.h,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: allDepartments.length,
          itemBuilder: (context, index) {
            final dept = allDepartments[index];

            // Get department name based on locale
            String department = isArabic
                ? (dept.departmentNameInArabic ?? dept.departmentName ?? '')
                : (dept.departmentName ?? '');

            // For filtering, always use English name
            String departmentForFilter = dept.departmentName ?? '';

            int count = cubit.getKnowledgeCountByDepartment(departmentForFilter);
            final lightMode = Theme.of(context).brightness == Brightness.light;

            return GestureDetector(
              onTap: () {
                // Use English name for filtering
                cubit.filterByDepartment(departmentForFilter, index);
              },
              child: Padding(
                padding: const EdgeInsetsDirectional.only(end: 30),
                child: Row(
                  children: [
                    Container(
                      width: isMobile ? 35.h : 45.h,
                      height: isMobile ? 35.w : 45.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.r),
                        color: selectedIndex == index
                            ? AppColors.primary
                            : AppColors.card

                      ),
                      child: Center(
                        child: Text(
                          _localizeDigits('$count', isArabic),
                          style: isMobile
                              ? StyleText.fontSize14Weight600.copyWith(
                            color: selectedIndex == index
                                ? AppColors.textButton
                                :  AppColors.secondaryText,
                          )
                              : StyleText.fontSize20Weight500.copyWith(
                            color: selectedIndex == index
                                ? AppColors.textButton
                                : AppColors.secondaryText,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 15.w),
                    Text(
                      // Display localized name (no need to capitalize Arabic)
                      isArabic ? department : FormatHelper.capitalize(department),
                      style: isMobile
                          ? StyleText.fontSize14Weight600.copyWith(
                        color: selectedIndex == index
                            ? isLightMode
                            ? AppColors.blackButton
                            : AppColors.white
                            : isLightMode
                            ? AppColors.secondaryText
                            : AppColors.grey,
                      )
                          : StyleText.fontSize18Weight500.copyWith(
                        color: selectedIndex == index
                            ? isLightMode
                            ? AppColors.blackButton
                            : AppColors.white
                            : isLightMode
                            ? AppColors.secondaryText
                            : AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    },
  );
}