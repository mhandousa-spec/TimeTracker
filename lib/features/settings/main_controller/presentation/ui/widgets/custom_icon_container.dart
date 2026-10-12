/// Module: Settings · Presentation · Widgets · Custom Icon Container
/// Description: Settings page (presentation/ui/pages). See class doc for details.
/// Author: Knowticed Team
/// Date: 26/06/2026
/// Dependencies: see imports
/// Revision History:
///   - 26/06/2026 (Amr Mesbah): Added Module header and FILE INFO block.
///
/// ************************ FILE INFO ****************************///
/// File Name: custom_icon_container.dart
/// Purpose: Custom Icon Container widget.
/// Author: Knowticed Team
/// Created At: 26/06/2026
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/theme_controller.dart';

class CustomIconContainer extends StatelessWidget {
  final String text;
  final String? image;
  final VoidCallback? onPressed;
  final bool isEdit;
  final bool isEditIcon;
  final bool isSmallerFont;

  const CustomIconContainer({
    Key? key,
    required this.text,
    this.image,
    this.onPressed,
    this.isEdit = false,
    this.isEditIcon = false,
    this.isSmallerFont = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    final orientation = MediaQuery.of(context).orientation;
    bool isDesktop = Platform.isLinux || Platform.isMacOS || Platform.isWindows;
    return Container(
      width: isEdit
          ? isTablet
              ? orientation == Orientation.portrait
                  ? 0.29.w
                  : (0.32.w)
              : 0.4.w
          : 0.16.h,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.inversePrimary,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: AppColors.colorGreydark,
          width: 1.0,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(0.02.h),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.barrierColor,
                borderRadius: BorderRadius.circular(8.0),
              ),
              height: 0.17.h,
              child: GestureDetector(
                onTap: onPressed,
                child: Container(
                  child: Stack(
                    children: [
                      Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.barrierColor,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          height: 0.17.h,
                          child: image == null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(6.0),
                                  child: Image.asset(
                                    'assets/png_assets/emptyAsset.png',
                                    fit: BoxFit.fill,
                                  ),
                                )
                              : image!.contains('assets')
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(6.0),
                                      child: Image.asset(
                                        image!,
                                        fit: BoxFit.fill,
                                      ),
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(6.0),
                                      child: Image.network(
                                        image!,
                                        fit: BoxFit.fill,
                                      ),
                                    )),
                      Positioned(
                        top: 0.02.h,
                        right:orientation == Orientation.portrait? 0.022.w : 0.02.h,
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: AppColors.bubbleColor),
                          child: Padding(
                            padding:   EdgeInsets.all(orientation == Orientation.portrait? 4 : 2),
                            child: Center(
                              child: SvgPicture.asset(
                                "assets/icons_assets/main_icons_assets/add.svg",
                                color: AppColors.text,
                              ),
                            ),
                          ),
                        ) /*SvgPicture.asset(
                          isEditIcon
                              ? 'assets/icons_assets/settings_assets/add_info.svg'
                              : 'assets/icons_assets/settings_assets/additionIcon.svg',
                          color: isEditIcon
                              ? null
                              : image != null
                                  ? AppColors.barrierColor
                                  : AppColors.colorBlack,
                          height: 0.035.h,
                        )*/
                        ,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 0.01.h),
            child: Text(
              text,
              style: AppFontStyle.cairoRegularStyle.copyWith(
                  fontSize: MediaQuery.of(context).size.shortestSide > 600
                      ? (orientation == Orientation.portrait
                          ? FontConstants.fontSize018.h
                          : FontConstants.fontSize022.h)
                      : isSmallerFont
                          ? FontConstants.fontSize016.h
                          : FontConstants.fontSize017.h,
                  color: themeController.currentTheme == AppColors.lightTheme
                      ? AppColors.colorBlack
                      : AppColors.colorWhiteDark,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
