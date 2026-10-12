/// Module: services_management_module
/// Description: Full-screen loading state shown on the home services page
///              while employee/department/services data is first loading.
/// Author: Knowticed Team
/// Date: 02/07/2026
/// Dependencies: AppColors, StyleText, CircleProgressMaster
/// Revision History:
///   - 02/07/2026 (Knowticed Team): Extracted from home_page_services.dart
///     (fix item 1c — build-method decomposition).
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';



import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class HomeServicesLoadingView extends StatelessWidget {
  final String? subtitle;

  const HomeServicesLoadingView({super.key, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleProgressMaster(),
            const SizedBox(height: 20),
            Text(
              S.of(context).loading ?? 'Loading...',
              style: StyleText.fontSize16Weight500.copyWith(
                color: lightMode
                    ? AppColors.black.withOpacity(0.54)
                    : AppColors.white.withOpacity(0.70),
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: StyleText.fontSize12Weight400.copyWith(
                  color: lightMode
                      ? AppColors.black.withOpacity(0.38)
                      : AppColors.white.withOpacity(0.54),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
