/// Module: knowledge_hub / presentation / s4_submissions / widgets/inner_status_section.dart
/// ************************* FILE INFO *************************** ///
/// File Name: inner_status_section.dart
/// Purpose: Inner status section — Submissions (S4) screen UI.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/knowledge_hub/main_controller/domain/constants/knowledge_hub_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../../controller/submissions_cubit.dart';

Widget innerStatusSection(
  BuildContext context, {
  required int selectedInnerIndex,
  required bool lighMode,
}) {
  // ✅ Use map with constant values for logic
  List<Map<String, String>> innerStatusItems = [
    {
      'label': S.of(context)!.all,
      'value': 'All', // Constant value
    },

    {
      'label': S.of(context)!.scheduled,
      'value': 'Scheduled', // Constant value
    },
    {
      'label': S.of(context)!.expiringSoon,
      'value': 'ExpiringSoon', // Constant value (no spaces)
    },
  ];

  List<Color> innerStatusColors = [
    AppColors.text,
    KnowledgeHubColors.statusOrange,
    KnowledgeHubColors.statusDarkRed,
  ];

  return SizedBox(
    height: 28.sp,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: innerStatusItems.length,
      itemBuilder: (context, index) {
        String displayLabel = innerStatusItems[index]['label']!;
        String statusValue = innerStatusItems[index]['value']!;

        return GestureDetector(
          onTap: () {
            // Update the inner index for UI
            context.read<SubmissionsCubit>().chooseInnerIndex(index);

            // Apply inner filter based on selected status using constant value
            context.read<SubmissionsCubit>().filterByInnerStatus(
              statusValue, // ✅ Pass constant value
              index,
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.r),
              color: selectedInnerIndex == index
                  ? AppColors.primary
                  : AppColors.card
            ),
            padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 5.sp),
            margin: EdgeInsets.only(right: 5.sp,),
            child: Center(

              child: Text(
                displayLabel, // ✅ Display localized label
                style: StyleText.fontSize14Weight500.copyWith(
                  color: selectedInnerIndex == index
                      ? AppColors.textButton
                      : innerStatusColors[index],
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}
