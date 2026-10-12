/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: gradient_container.dart
/// Purpose: Declares `GradientContainer`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

/// ************************ FILe INFO ********************************///
/// File: gradiant_container.dart
/// Purpose: Contains the gradient container widget for the home screen
/// Author: Amr Mesbah
/// Refactored at: 9/2/2025
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/services_mangment_module/core/new_theme.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/skeleton_home_controller.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
class GradientContainer extends StatelessWidget {

  GradientContainer({Key? key}) : super(key: key);
  SkeletonHomeController controller = Get.find();
  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    bool orientation =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.only(top: 20.h),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: context.isEnglish
                    ? [
                        AppColors.white.withOpacity(0.5),
                        AppColors.primary.withOpacity(0.5),
                      ]
                    : [
                        AppColors.primary.withOpacity(0.5),
                       AppColors.white.withOpacity(0.5),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8.r),
            ),
            padding: EdgeInsets.symmetric(
                vertical: 10.h, horizontal: orientation ? 30.w : 15.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.quote,
                  style: StyleText.fontSize16Weight500.copyWith(
                    color: AppColors.textButton
                  )
                ),
                SizedBox(height:  10.h ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "- ${controller.author}",
                      style: StyleText.fontSize16Weight500.copyWith(
                          color: AppColors.textButton
                      )
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: context.isEnglish ? 0 : null,
          right: context.isArabic ? 0 : null,
          child: SvgPicture.asset(
            "assets/icons_assets/home_assets/gradiant_icon.svg",
            height: 25.h,
            color: AppColors.text,
            width: 25.h,
          ),
        ),
      ],
    );
  }
}
