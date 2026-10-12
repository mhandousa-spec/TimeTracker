/// Module: knowledge_hub_module / core/settings/presentation/ui/widgets/settings_routing_button.dart
/// ************************* FILE INFO *************************** ///
/// File Name: settings_routing_button.dart
/// Purpose: Settings routing button — knowledge_hub_module core/widgets.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../pages/settings_page.dart';

class SettingsRoutingButton extends StatelessWidget {
  const SettingsRoutingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsetsDirectional.only(end: 16.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
            color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => SettingsPage()),
            );
          },
          child: Text('Settings',
              style: StyleText.fontSize14Weight600
                  .copyWith(color: AppColors.black)),
        ));
  }
}
