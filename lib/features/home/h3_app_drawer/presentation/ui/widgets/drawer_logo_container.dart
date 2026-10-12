/// Module: home/h3_app_drawer
///
///*************************** FILE INFO ****************************///
/// File Name: drawer_logo_container.dart
/// Purpose: Company logo shown at the top of the app drawer.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
///
/// Extracted from the 586-line `custom_drawer.dart`, which had no
/// `presentation/ui/widgets/` folder at all.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';

class DrawerLogoContainer extends StatelessWidget {
  const DrawerLogoContainer({super.key, this.logoUrl});

  /// Remote logo URL for the tenant, or `null` to fall back to the bundled
  /// Knowticed asset. Read from `GetStorage` by the caller so this widget
  /// stays free of storage dependencies.
  final String? logoUrl;

  @override
  Widget build(BuildContext context) {
    final bool lightMode = Theme.of(context).brightness == Brightness.light;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Center(
        child: CircleAvatar(
          radius: 40.w,
          backgroundColor: AppColors.transparent,
          child: logoUrl == null
              ? SvgPicture.asset(
                  lightMode
                      ? "assets/icons_assets/home_assets/new_size_logo.svg"
                      : "assets/icons_assets/main_icons_assets/knowticed_logo_dark.svg",
                  width: 60.w,
                  height: 60.w,
                  fit: BoxFit.contain,
                )
              : SvgPicture.network(
                  logoUrl!,
                  width: 60.w,
                  height: 60.w,
                  fit: BoxFit.contain,
                ),
        ),
      ),
    );
  }
}
