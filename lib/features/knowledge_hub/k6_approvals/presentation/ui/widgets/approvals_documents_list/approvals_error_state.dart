/// Module: knowledge_hub / presentation / s6_approvals / widgets/approvals_documents_list/approvals_error_state.dart
/// ************************* FILE INFO *************************** ///
/// File Name: approvals_error_state.dart
/// Purpose: Approvals error state — Approvals (S6) screen UI.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../../../controller/approvals_states.dart';

Widget buildApprovalsErrorState(BuildContext context,FetchingApprovalsErrorState state) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 64.sp, color: AppColors.red),
        SizedBox(height: 16.h),
        Text(
          S.of(context)!.errorLoadingApprovals,
          style: StyleText.fontSize16Weight500.copyWith(color: AppColors.red),
        ),
        SizedBox(height: 8.h),
        Text(
          state.error,
          style: StyleText.fontSize12Weight400.copyWith(
            color: AppColors.secondaryText,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}