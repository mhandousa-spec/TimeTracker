/// Module: knowledge_hub / presentation / s6_approvals / widgets/status_list.dart
/// ************************* FILE INFO *************************** ///
/// File Name: status_list.dart
/// Purpose: Status list — Approvals (S6) screen UI.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/knowledge_hub/main_controller/domain/constants/knowledge_hub_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../../controller/approvals_cubit.dart';
import '../../controller/approvals_states.dart';

Widget statusList(
    BuildContext context, {
      required bool isMobile,
      required int selectedIndex,
    }) {
  final lightMode = Theme.of(context).brightness == Brightness.light;

  // Use index-based approach instead of localized strings
  List<String> status = [
    S.of(context)!.all,
    S.of(context)!.approved,
    S.of(context)!.pending,
    S.of(context)!.rejected,
    S.of(context)!.removed,
  ];

  // Status keys for comparison (language-independent)
  List<String> statusKeys = [
    'all',
    'approved',
    'pending',
    'rejected',
    'removed',
  ];

  // Function to get color based on status index
  Color getStatusTextColor(int statusIndex, bool lightMode) {
    switch (statusIndex) {
      case 1: // Approved
        return KnowledgeHubColors.greenAccent;
      case 2: // Pending
        return KnowledgeHubColors.statusOrange;
      case 3: // Rejected
        return KnowledgeHubColors.redBright;
      case 4: // Removed
        return KnowledgeHubColors.redCrimson;
      default: // All
        return lightMode
            ? AppColors.blackButton
            : AppColors.white;
    }
  }

  return BlocBuilder<ApprovalsCubit, ApprovalsStates>(
    buildWhen: (previous, current) =>
    current is FetchingApprovalsSuccessState ||
        current is FetchingApprovalsEmptyState,
    builder: (context, state) {
      final cubit = context.read<ApprovalsCubit>();

      return SizedBox(
        height: isMobile ? 35.h : 45.h,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: status.length,
          itemBuilder: (context, index) {
            String currentStatus = status[index];
            String statusKey = statusKeys[index];

            // Get count using language-independent key
            int count = cubit.getStatusCountByKey(statusKey);

            return GestureDetector(
              onTap: () {
                // Filter using language-independent key
                cubit.filterByStatusKey(statusKey, index);
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
                      currentStatus,
                      style: isMobile
                          ? StyleText.fontSize14Weight600.copyWith(
                        color: getStatusTextColor(index, lightMode),
                      )
                          : StyleText.fontSize16Weight600.copyWith(
                        color: getStatusTextColor(index, lightMode),
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