import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';

import '../../../../../home/h2_nav_bar/presentation/ui/pages/nav_screen.dart';
import 'package:knowticed_plus/core/theme/theme_controller.dart' hide themeController;

class IndicatorContainerScreen extends StatefulWidget {
   IndicatorContainerScreen({super.key,
  required this.value
  
  });
  double value;

  @override
  State<IndicatorContainerScreen> createState() =>
      _IndicatorContainerScreenState();
}

class _IndicatorContainerScreenState extends State<IndicatorContainerScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.015.h),
      child: Container(
        width: 0.99.w,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.inversePrimary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 0.015.w, vertical: 0.02.h),
          child: SizedBox(
            width: double.infinity,
            child: LinearProgressIndicator(
              value: widget.value,
              minHeight: 0.015.h,
              borderRadius: BorderRadius.circular(64),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.signOut),
               backgroundColor:themeController.currentTheme == AppColors.lightTheme
                  ?
                          AppColors.secondaryPrimary.withOpacity(0.1) : AppColors.grey.withOpacity(0.4),
            ),
          ),
        ),
      ),
    );
  }
}
