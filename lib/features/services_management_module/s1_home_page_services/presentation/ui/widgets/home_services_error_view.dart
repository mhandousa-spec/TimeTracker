/// Module: services_management_module
/// Description: Full-screen error state (with retry) shown on the home
///              services page when the initial data load fails.
/// Author: Knowticed Team
/// Date: 02/07/2026
/// Dependencies: AppColors, StyleText, customButtonWithIcon
/// Revision History:
///   - 02/07/2026 (Knowticed Team): Extracted from home_page_services.dart
///     (fix item 1c — build-method decomposition).
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/7-custom_button_with_icon.dart';

import 'package:knowticed_plus/core/custom/7-custom_button_with_icon.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class HomeServicesErrorView extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRetry;

  const HomeServicesErrorView({
    super.key,
    required this.title,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.red),
            const SizedBox(height: 16),
            Text(
              title,
              style: StyleText.fontSize16Weight500.copyWith(
                color: lightMode
                    ? AppColors.black.withOpacity(0.87)
                    : AppColors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: StyleText.fontSize12Weight400.copyWith(
                color: lightMode
                    ? AppColors.black.withOpacity(0.54)
                    : AppColors.white.withOpacity(0.70),
              ),
            ),
            const SizedBox(height: 24),
            customButtonWithIcon(
              title: S.of(context).retry ?? 'Retry',
              function: onRetry,
              textStyle: StyleText.fontSize16Weight500.copyWith(
                color: AppColors.textButton,
              ),
              width: 160.sp,
              height: 44.sp,
              space: 8.sp,
              radius: 8.r,
              color: AppColors.primary,
              icon: Icons.refresh,
              iconColor: AppColors.textButton,
              iconSize: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}
