/// Module: knowledge_hub / presentation / s5_submission_details / widgets/analytics_section/statistics_tab/build_statistics_item.dart
/// ************************* FILE INFO *************************** ///
/// File Name: build_statistics_item.dart
/// Purpose: Build statistics item — Submission Details (S5) screen UI.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';



import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import '../../../../../../main_controller/data/models/document_utilization_model.dart';
import '../../../../../../main_controller/data/models/employee_data.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../../../../controller/analytics_cubit.dart';

Widget buildStatisticsItem(
  BuildContext context, {
  required bool lightMode,
  required bool isMobile,
  required DocumentUtilizationModel action,
  required EmployeeData? userData,
}) {
  // Parse timestamp from DocumentUtilizationModel
  final timestampStr = action.currentTimestamp;
  final timestamp = timestampStr.isNotEmpty
      ? _parseTimestamp(timestampStr)
      : DateTime.now().millisecondsSinceEpoch;
  
  final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
  final formattedDate = DateFormat('dd MMM yyyy').format(dateTime);
  final formattedTime = DateFormat('h:mm a').format(dateTime);

  // ✅ Get user data from EmployeeData model
  final userName = userData?.currentemployeeName ?? 'Unknown User';
  final userPhoto = userData?.currentemployeePhoto ?? '';
  final userRole = userData?.currentemployeeRole ?? 'N/A';
  
  // ✅ Get department ID and resolve to department name
  final departmentId = userData?.currentemployeeDepartment ?? '';
  final cubit = context.read<AnalyticsCubit>();
  final userDepartment = departmentId.isNotEmpty 
      ? cubit.getDepartmentName(departmentId) 
      : 'N/A';

  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8.r),
      color: lightMode ? AppColors.white : AppColors.background,
    ),
    margin: EdgeInsets.symmetric(vertical: 10.w),
    padding: EdgeInsets.all(10.w),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  '${S.of(context)!.date}: ',
                  style: StyleText.fontSize12Weight400.copyWith(
                    color: lightMode
                        ? AppColors.secondaryText
                        : AppColors.grey,
                  ),
                ),
                Text(
                  '$formattedDate At $formattedTime',
                  style: StyleText.fontSize12Weight400.copyWith(
                    color: lightMode
                        ? AppColors.blackButton
                        : AppColors.white,
                  ),
                ),
              ],
            ),
            Container(
              width: 60.sp,
              height: 20.sp,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.r),
                color: lightMode
                    ? AppColors.background
                    : AppColors.chatBackground,
              ),
              child: Center(
                child: Text(
                  action.currentTypeOfAction,
                  style: StyleText.fontSize10Weight400.copyWith(
                    color: lightMode
                        ? AppColors.blackButton
                        : AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Text(
              '${S.of(context)!.employeeName}: ',
              style: StyleText.fontSize12Weight400.copyWith(
                color: lightMode
                    ? AppColors.secondaryText
                    : AppColors.grey,
              ),
            ),
            CircleAvatar(
              radius: 12.5.sp,
              backgroundColor: AppColors.primary,
              backgroundImage: userPhoto.isNotEmpty
                  ? NetworkImage(userPhoto)
                  : null,
              child: userPhoto.isEmpty
                  ? Icon(Icons.person, size: 15.sp)
                  : null,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                userName,
                style: StyleText.fontSize12Weight400.copyWith(
                  color: lightMode
                      ? AppColors.blackButton
                      : AppColors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Text(
              '${S.of(context)!.jobTitle}: ',
              style: StyleText.fontSize12Weight400.copyWith(
                color: lightMode
                    ? AppColors.secondaryText
                    : AppColors.grey,
              ),
            ),
            Expanded(
              child: Text(
                userRole,
                style: StyleText.fontSize12Weight400.copyWith(
                  color: lightMode
                      ? AppColors.blackButton
                      : AppColors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Text(
              '${S.of(context)!.department}: ',
              style: StyleText.fontSize12Weight400.copyWith(
                color: lightMode
                    ? AppColors.secondaryText
                    : AppColors.grey,
              ),
            ),
            Expanded(
              child: Text(
                userDepartment, // ✅ Now shows department name, not ID
                style: StyleText.fontSize12Weight400.copyWith(
                  color: lightMode
                      ? AppColors.blackButton
                      : AppColors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

// ✅ Helper function to parse timestamp string to milliseconds
int _parseTimestamp(String timestampStr) {
  try {
    // Try parsing as DateTime string first (format: "yyyy-MM-dd HH:mm:ss")
    DateTime dateTime = DateTime.parse(timestampStr);
    return dateTime.millisecondsSinceEpoch;
  } catch (e) {
    // If it fails, try parsing as milliseconds string
    return int.tryParse(timestampStr) ?? DateTime.now().millisecondsSinceEpoch;
  }
}