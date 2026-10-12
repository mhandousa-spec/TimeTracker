/// Module: roles / r2_user_management / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: user_limit_usage_panel.dart
/// Purpose: The "User Limits" card on Adding New Access — usage of every
///          limited module of the picked role plus the company total, and
///          why the current selection cannot be granted.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 — per-module user limits (owner-confirmed UX).
///
/// Shown once a Role Type is picked:
///   User Limits
///   Time Tracker: 8 of 10 users    Users: 18 of 20
///   ⓘ Time Tracker allows 10 users. 8 are already assigned. Only 2 more can
///     be added.                    ← only when the selection overshoots
/// A full module's line is red. Hidden when the role carries no limited
/// module and Admin set no company total.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/data/services/module_user_limit_messages.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/domain/services/module_user_limit_rule.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/presentation/controller/user_management_cubit.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class UserLimitUsagePanel extends StatelessWidget {
  const UserLimitUsagePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserManagementAccessCubit, UserManagementAccessState>(
      builder: (BuildContext context, UserManagementAccessState state) {
        final UserManagementAccessCubit controller =
            context.read<UserManagementAccessCubit>();
        final String? role = controller.newAccessSelectedRole;
        if (role == null || role.isEmpty) return const SizedBox.shrink();

        final List<ModuleUsage> usage = controller.selectedRoleUsage;

        // Neutral while loading; red when the read failed (granting is
        // blocked until it succeeds) or the selection overshoots a limit.
        final bool loading = controller.licenceUsageLoading;
        final String? problem = loading
            ? null
            : controller.licenceUsageFailed
                ? ModuleUserLimitMessages.checkFailed
                : controller.selectionLimitMessage;

        if (usage.isEmpty && problem == null && !loading) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          margin: EdgeInsets.only(top: 10.sp),
          padding: EdgeInsets.symmetric(horizontal: 15.sp, vertical: 10.sp),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8.sp),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                S.of(context).userLimitsTitle,
                style: StyleText.fontSize14Weight500
                    .copyWith(color: AppColors.text),
              ),
              if (loading) ...<Widget>[
                SizedBox(height: 6.sp),
                Text(
                  ModuleUserLimitMessages.checking,
                  style: StyleText.fontSize12Weight400
                      .copyWith(color: AppColors.secondaryText),
                ),
              ],
              if (usage.isNotEmpty) ...<Widget>[
                SizedBox(height: 6.sp),
                Wrap(
                  spacing: 16.sp,
                  runSpacing: 4.sp,
                  children: <Widget>[
                    for (final ModuleUsage u in usage)
                      Text(
                        ModuleUserLimitMessages.usage(u),
                        style: StyleText.fontSize12Weight400.copyWith(
                          color: u.assigned >= u.limit
                              ? AppColors.red
                              : AppColors.secondaryText,
                        ),
                      ),
                  ],
                ),
              ],
              if (problem != null) ...<Widget>[
                SizedBox(height: 8.sp),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(Icons.error_outline,
                        size: 16.sp, color: AppColors.red),
                    SizedBox(width: 6.sp),
                    Expanded(
                      child: Text(
                        problem,
                        style: StyleText.fontSize12Weight400
                            .copyWith(color: AppColors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
