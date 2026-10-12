/// Module: knowledge_hub / presentation / s5_submission_details / widgets/analytics_section/statistics_tab/statistics_table.dart
/// ************************* FILE INFO *************************** ///
/// File Name: statistics_table.dart
/// Purpose: Statistics table — Submission Details (S5) screen UI.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'dart:developer';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/features/knowledge_hub/main_controller/data/models/employee_data.dart' as KnowledgeHubEmployee;
import 'package:knowticed_plus/features/knowledge_hub/main_controller/helper/format_helper.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import '../../../../../../main_controller/data/models/document_utilization_model.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../../../../controller/analytics_cubit.dart';
import './filter_statistics.dart';

String _getLocalizedAction(BuildContext context, String action) {
  final isArabic = Localizations.localeOf(context).languageCode == 'ar';

  switch (action.toLowerCase()) {
    case 'view':
      return isArabic ? 'عرض' : 'View';
    case 'download':
      return isArabic ? 'تحميل' : 'Download';
    default:
      return action;
  }
}

Widget statisticsTable(
    BuildContext context, {
      required bool lightMode,
      required List<DocumentUtilizationModel> actions,
      required TextEditingController searchStatisticsController,
      required Map<String, KnowledgeHubEmployee.EmployeeData> usersCache, // ✅ FIXED: Use correct type
    }) {
  final cubit = context.read<AnalyticsCubit>();
  final employeeController = Get.find<MainCoreEmployeeController>();
  final isArabic = Localizations.localeOf(context).languageCode == 'ar';
  final isLight = Theme.of(context).brightness == Brightness.light;

  // Header style
  final headerStyle = StyleText.fontSize12Weight400.copyWith(
    color: AppColors.colorWhite,
  );

  // Cell style
  TextStyle cellStyle(BuildContext context) => StyleText.fontSize12Weight400.copyWith(
    color: lightMode
        ? AppColors.blackButton
        : AppColors.white,
  );

  // Column headers
  final headers = <String>[
    S.of(context)!.number,
    S.of(context)!.employeeName,
    S.of(context)!.department,
    S.of(context)!.jobTitle,
    S.of(context)!.date,
    S.of(context)!.time,
    S.of(context)!.action,
  ];

  // Column widths
  final columnWidths = <int, TableColumnWidth>{
    0: FixedColumnWidth(60.sp),   // Number
    1: FixedColumnWidth(180.sp),  // Employee Name
    2: FixedColumnWidth(150.sp),  // Department
    3: FixedColumnWidth(150.sp),  // Job Title
    4: FixedColumnWidth(120.sp),  // Date
    5: FixedColumnWidth(100.sp),  // Time
    6: FixedColumnWidth(100.sp),  // Action
  };

  // Helper method for basic cell
  Widget _cell(Widget child, {EdgeInsets? padding}) {
    return Container(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 10.sp, vertical: 8.sp),
      child: DefaultTextStyle.merge(
        style: cellStyle(context),
        child: child,
      ),
    );
  }

  // Helper method for text cell
  Widget _textCell(String text, {int maxLines = 2, TextAlign textAlign = TextAlign.start}) {
    return _cell(
      Text(
        text.isEmpty ? '-' : text,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        textAlign: textAlign,
      ),
    );
  }

  // Employee name cell with avatar
  Widget _employeeCell(String userName, String userPhoto) {
    return _cell(
      Row(
        children: [
          CircleAvatar(
            radius: 12.5.sp,
            backgroundColor: AppColors.transparent,
            backgroundImage: userPhoto.isNotEmpty
                ? NetworkImage(userPhoto)
                : null,
            child: userPhoto.isEmpty
                ? ClipOval(
              child: CustomSvgImage(
                assetPath: "assets/icons_assets/main_icons_assets/assets_male.svg",
                width: 30.w,
                height: 30.h,
                fit: BoxFit.fill,
              ),
            )
                : null,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              FormatHelper.capitalize(userName),
              style: cellStyle(context),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  return Column(
    children: [
      Padding(
        padding: EdgeInsets.symmetric(vertical: 10.w),
        child: filterStatistics(
          context,
          searchController: searchStatisticsController,
          // WIRED 22/9/2026 — this callback was an empty body, so typing in
          // the search field did nothing at all.
          onSearchChanged: (query) => cubit.setStatisticsSearch(query),
        ),
      ),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Directionality(
          textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
          child: Padding(
            padding: EdgeInsets.only(top: 10.w),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.sp),
              child: Table(
                border: TableBorder.all(
                  color: AppColors.transparent,
                  borderRadius: BorderRadius.circular(10.sp),
                ),
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                columnWidths: columnWidths,
                children: [
                  // Header Row
                  TableRow(
                    decoration: BoxDecoration(color: AppColors.header),
                    children: headers
                        .map(
                          (name) => Padding(
                        padding: EdgeInsets.all(10.sp),
                        child: Text(
                          name,
                          style: headerStyle,
                          maxLines: 1,
                          textAlign: TextAlign.start,
                        ),
                      ),
                    )
                        .toList(),
                  ),

                  // Data Rows
                  ...List.generate(actions.length, (index) {
                    final action = actions[index];
                    final isEven = index.isEven;

                    // Row color
                    final rowColor = isLight
                        ? (isEven ? AppColors.white : AppColors.background)
                        : (isEven ? AppColors.background : AppColors.chatBackground);

                    // Get user data from cache
                    final userData = usersCache[action.currentUserId];

                    // Debug log
                    if (userData == null) {
                      log('⚠️ [Table Row $index] Missing user data for userId: "${action.currentUserId}"',
                          name: 'StatisticsTable');
                      log('   Available cache keys: ${usersCache.keys.take(5).join(", ")}...',
                          name: 'StatisticsTable');
                    }

                    // Get localized employee name
                    final userName = userData != null
                        ? (isArabic
                        ? userData.currentemployeeNameArabic ?? userData.currentemployeeName ?? 'مستخدم غير معروف'
                        : userData.currentemployeeName ?? 'Unknown User')
                        : (isArabic
                        ? 'مستخدم غير معروف (${action.currentUserId.substring(0, 8)}...)'
                        : 'Unknown User (ID: ${action.currentUserId.substring(0, 8)}...)');

                    final userPhoto = userData?.currentemployeePhoto ?? '';

                    // Get localized job title
                    String userRole;
                    if (userData != null) {
                      final userEmail = userData.currentemployeeEmail;
                      if (userEmail.isNotEmpty) {
                        userRole = employeeController.getEmployeeJobTitle(userEmail);
                      } else {
                        userRole = isArabic ? 'غير متاح' : 'N/A';
                      }
                    } else {
                      userRole = isArabic ? 'غير متاح' : 'N/A';
                    }

                    // Get department
                    final departmentId = userData?.currentemployeeDepartment ?? '';
                    final userDepartment = departmentId.isNotEmpty
                        ? cubit.getDepartmentName(departmentId, isEnglish: !isArabic)
                        : (isArabic ? 'غير متاح' : 'N/A');

                    // Parse timestamp
                    final timestampStr = action.currentTimestamp;
                    final timestamp = timestampStr.isNotEmpty
                        ? _parseTimestamp(timestampStr)
                        : DateTime.now().millisecondsSinceEpoch;

                    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
                    final formattedDate = DateFormat('dd MMM yyyy').format(dateTime);
                    final formattedTime = DateFormat('h:mm a').format(dateTime);

                    // Build row cells
                    final cells = [
                      // Number
                      _textCell('${index + 1}', maxLines: 1),

                      // Employee Name with Avatar
                      _employeeCell(userName, userPhoto),

                      // Department
                      _textCell(FormatHelper.capitalize(userDepartment)),

                      // Job Title
                      _textCell(FormatHelper.capitalize(userRole)),

                      // Date
                      _textCell(FormatHelper.capitalize(formattedDate), maxLines: 1),

                      // Time
                      _textCell(FormatHelper.capitalize(formattedTime), maxLines: 1),

                      // Action
                      _cell(
                        Container(
                          width: 60.w,
                          height: 20.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Center(
                            child: Text(
                              FormatHelper.capitalize(_getLocalizedAction(context, action.currentTypeOfAction)),
                              style: StyleText.fontSize10Weight400.copyWith(
                                color: lightMode
                                    ? AppColors.blackButton
                                    : AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ];

                    return TableRow(
                      decoration: BoxDecoration(color: rowColor),
                      children: cells,
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

int _parseTimestamp(String timestampStr) {
  try {
    DateTime dateTime = DateTime.parse(timestampStr);
    return dateTime.millisecondsSinceEpoch;
  } catch (e) {
    return int.tryParse(timestampStr) ?? DateTime.now().millisecondsSinceEpoch;
  }
}