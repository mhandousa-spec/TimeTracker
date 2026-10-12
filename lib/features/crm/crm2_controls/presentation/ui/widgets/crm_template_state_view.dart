// ****************** FILE INFO ******************
// File Name: crm_template_state_view.dart
// Purpose: Shared loading and error states for CRM template pages
// Author: Mohand Adel
// Created At: 05/08/2026

import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmTemplateStateView extends StatelessWidget {
  const CrmTemplateStateView({
    required this.isLoading,
    required this.errorMessage,
    required this.child,
    this.onRetry,
    this.overlayLoading = false,
    this.minHeight,
    super.key,
  });

  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final bool overlayLoading;
  final double? minHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final String? error = errorMessage;
    final double stateHeight = minHeight ?? 240.sp;
    final Widget content = ConstrainedBox(
      constraints: BoxConstraints(minHeight: stateHeight),
      child: SizedBox(width: double.infinity, child: child),
    );
    if (isLoading) {
      if (overlayLoading) {
        return Stack(
          children: [
            content,
            Positioned.fill(
              child: Container(
                color: AppColors.background.withValues(alpha: 0.78),
                alignment: Alignment.center,
                child: const CircleProgressMaster(),
              ),
            ),
          ],
        );
      }
      return SizedBox(
        height: stateHeight,
        child: const Center(child: CircleProgressMaster()),
      );
    }
    if (error != null && error.isNotEmpty) {
      return SizedBox(
        height: stateHeight,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                error,
                textAlign: TextAlign.center,
                style: StyleText.fontSize14Weight500.copyWith(
                  color: AppColors.red,
                ),
              ),
              if (onRetry != null) ...[
                SizedBox(height: 14.sp),
                customButton(
                  title: S.current.crmRetry,
                  function: onRetry!,
                  color: AppColors.primary,
                  textStyle: StyleText.fontSize14Weight500.copyWith(
                    color: AppColors.black,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }
    return content;
  }
}
