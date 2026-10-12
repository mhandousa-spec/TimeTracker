/// Module: knowledge_hub / presentation / s4_submissions / widgets/category_list.dart
/// ************************* FILE INFO *************************** ///
/// File Name: category_list.dart
/// Purpose: Category list — Submissions (S4) screen UI.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/knowledge_hub/main_controller/domain/constants/knowledge_hub_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../../controller/submissions_cubit.dart';
import '../../controller/submissions_states.dart';

Widget categoryList(
    BuildContext context, {
      required bool isMobile,
      required int selectedIndex,
    }) {
  final lightMode = Theme.of(context).brightness == Brightness.light;

  // ✅ Use constant English values for logic
  List<Map<String, String>> statusItems = [
    {
      'label': S.of(context)!.all,
      'value': 'All',
    },
    {
      'label': S.of(context)!.published,
      'value': 'Published',
    },
    {
      'label': S.of(context)!.approved,
      'value': 'Approved',
    },
    {
      'label': S.of(context)!.pending,
      'value': 'Pending',
    },
    {
      'label': S.of(context)!.rejected,
      'value': 'Rejected',
    },
    {
      'label': S.of(context)!.removed,
      'value': 'Removed',
    },
    {
      'label': S.of(context)!.archive,
      'value': 'Archive',
    },
  ];

  List<Color> statusColor = [
    lightMode ? AppColors.blackButton : AppColors.white, // All
    KnowledgeHubColors.excelGreen, // Published
    KnowledgeHubColors.greenAccent, // Approved
    AppColors.orange, // Pending
    AppColors.darkRed, // Rejected
    AppColors.darkRed, // Removed
    AppColors.secondaryBlack, // Archive
  ];

  // ✅ Square size using .sp for perfect square on all screens
  final double squareSize = isMobile ? 35.sp : 45.sp;

  return BlocBuilder<SubmissionsCubit, SubmissionsStates>(
    builder: (context, state) {
      final cubit = context.read<SubmissionsCubit>();

      return SizedBox(
        height: squareSize, // ✅ Match the square size
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: statusItems.length,
          itemBuilder: (context, index) {
            String displayLabel = statusItems[index]['label']!;
            String statusValue = statusItems[index]['value']!;
            Color currentStatusColor = statusColor[index];
            int count = cubit.getStatusCount(statusValue);

            return GestureDetector(
              onTap: () {
                cubit.filterByStatus(statusValue, index);
              },
              child: Padding(
                padding: const EdgeInsetsDirectional.only(end: 30),
                child: Row(
                  children: [
                    Container(
                      width: squareSize,  // ✅ Same variable for both
                      height: squareSize, // ✅ Guaranteed perfect square
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.r),
                        color: selectedIndex == index
                            ? AppColors.primary
                            : lightMode
                            ? AppColors.white
                            : AppColors.chatBackground,
                      ),
                      child: Center(
                        child: Text(
                          count.toString(),
                          style: isMobile
                              ? StyleText.fontSize14Weight600.copyWith(
                            color: selectedIndex == index
                                ? AppColors.textButton
                                : lightMode
                                ? AppColors.secondaryText
                                : AppColors.grey,
                          )
                              : StyleText.fontSize20Weight500.copyWith(
                            color: selectedIndex == index
                                ? AppColors.textButton
                                : lightMode
                                ? AppColors.secondaryText
                                : AppColors.grey,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 15.w),
                    Text(
                      displayLabel,
                      style: isMobile
                          ? StyleText.fontSize14Weight600.copyWith(
                        color: currentStatusColor,
                      )
                          : StyleText.fontSize18Weight500.copyWith(
                        color: currentStatusColor,
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