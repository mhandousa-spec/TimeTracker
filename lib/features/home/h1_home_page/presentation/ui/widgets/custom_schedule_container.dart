/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: custom_schedule_container.dart
/// Purpose: Declares `CustomScheduleContainer`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/get_photo_asset.dart';
import 'package:knowticed_plus/core/custom/76-date_time_in_arabic.dart';


import 'package:knowticed_plus/core/theme/app_font_size.dart';
import 'package:knowticed_plus/core/theme/theme_controller.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

/// Capitalises the month word in a "dd month yyyy" string.
///
/// Inlined from the former presentation/utils/capitalization_functions.dart,
/// which held only this and an unused capitalizeAmPm().
String capitalizeMonth(String date) {
  List<String> parts = date.split(' ');
  if (parts.length == 3) {
    parts[1] = parts[1][0].toUpperCase() + parts[1].substring(1);
  }
  return parts.join(' ');
}


/// Date Created : 11/Sep/2024
/// Developer Name : Bassem Mohamed
/// App Version : knowticed Plus
/// Date of Last Edit : 11/Sep/2024 By Bassem
/// Objectives: this widget is for showing the events , todo list, boards, or services names.
/// This widget consist of description and start time for each one in addition to images of the participants and the total number of the members enrolled in this event

class CustomScheduleContainer extends StatelessWidget {
  final String cardTitle;
  final String eventType;
  final String description;
  final String? dueDate;
  final List<String?>? imagesList;

  const CustomScheduleContainer({
    super.key,
    required this.eventType,
    required this.cardTitle,
    required this.description,
    required this.dueDate,
    List<String?>? imagesList,
  }) : imagesList = imagesList ?? const [""];

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    double imageHight = 0.018.h;
    double imageSize = isTablet ? (isPortrait? 0.05.w :0.02.w) : 0.08.w;
    // Convert the totalImagesNum to a string, handling the 1000+ case
    
    String displayTotalImagesNum = '';
    if (imagesList != null && imagesList!.isNotEmpty) {
      displayTotalImagesNum =
          imagesList!.length >= 1000 ? S.of(context).k1k : '+${imagesList!.length - 2}';
    }
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 0.008.h),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
                vertical: 0.015.h, horizontal: isTablet ? ( isPortrait? 0.02.w :0.008.w) : 0.03.w),
            decoration: BoxDecoration(
              // ignore: unrelated_type_equality_checks
              color: isPortrait
                  ? (themeController.currentTheme == AppColors.lightTheme
                      ? AppColors.colorWhite
                      : AppColors.dark)
                  : (Theme.of(context).colorScheme.inversePrimary),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    /// Photo container for each type
                    getPhotoAsset(eventType),
                  ],
                ),
                SizedBox(width: isTablet ? (isPortrait? 0.02.w : 0.01.w) : 0.02.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                  //    color: Colors.amber,
                      width: isTablet ? (isPortrait? 0.68.w : 0.17.w) : 0.73.w,
                      child: Text(
                        cardTitle.capitalize as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFontStyle.cairoRegularStyle.copyWith(
                            fontSize: FontConstants.fontSize018.h,
                            // ignore: unrelated_type_equality_checks
                            color: themeController.currentTheme ==
                                    AppColors.lightTheme
                                ? AppColors.colorBlack
                                : AppColors.colorWhiteDark,
                            fontWeight: FontWeight.w600,
                            height: 1.4),
                      ),
                    ),
                    SizedBox(height: 0.005.h),
                    Container(
                      //   color: Colors.amber,
                      width: isTablet ? (isPortrait? 0.68.w : 0.17.w) : 0.73.w,
                      child: Text(
                        description.capitalize!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppFontStyle.cairoRegularStyle.copyWith(
                          fontSize: FontConstants.fontSize016.h,
                          // ignore: unrelated_type_equality_checks
                          color: themeController.currentTheme ==
                                  AppColors.lightTheme
                              ? AppColors.colorDarkGrey
                              : AppColors.colorGreydark,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                    ),
                    SizedBox(height: 0.03.h),
                    Container(
                      // color: Colors.amber,
                      width: isTablet ? (isPortrait? 0.4.w : 0.14.w) : 0.5.w,
                      child: Text(
                        context.isEnglish
                            ? "${"Due Date"} ${capitalizeMonth("$dueDate")}"
                            : "${S.of(context).dueDate} ${translateDate(capitalizeMonth("$dueDate"))}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFontStyle.cairoRegularStyle.copyWith(
                          fontSize: FontConstants.fontSize015.h,
                          // ignore: unrelated_type_equality_checks
                          color: themeController.currentTheme ==
                                  AppColors.lightTheme
                              ? AppColors.colorBlack
                              : AppColors.colorWhiteDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (imagesList!.length > 2 &&
            imagesList != null &&
            imagesList!.isNotEmpty)
          Positioned(
            bottom: imageHight,
            right: context.isEnglish ? ((isTablet && isPortrait)? 0.015.h : 0.01.h) : null,
            left: context.isArabic ? ((isTablet && isPortrait)? 0.015.h : 0.01.h) : null,
            child: Container(
              width: imageSize,
              height: imageSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.lightPrimary,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    localizeNumber(displayTotalImagesNum),
                    style: AppFontStyle.cairoRegularStyle.copyWith(
                        fontSize: FontConstants.fontSize010.h,
                        color: AppColors.textButton,
                        fontWeight: FontWeight.w600,
                        height: isTablet ? (1.5) : 2),
                  ),
                  SizedBox(
                    width: isTablet ? (isPortrait? 0.006.w : 0.003.w) : 0.012.w,
                  ),
                ],
              ),
            ),
          ),
        if (imagesList!.isNotEmpty && imagesList != null)
          Positioned(
            bottom: imageHight,
            right: context.isEnglish ? 0.04.h : null,
            left: context.isArabic ? 0.04.h : null,
            child: Container(
              width: imageSize,
              height: imageSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.lightPrimary,
              ),
              child: Center(
                child: CircleAvatar(
                  radius: 0.03.h,
                  backgroundColor: AppColors.transparent,
                  backgroundImage: AssetImage(imagesList![0]!),
                ),
              ),
            ),
          ),
        if (imagesList!.length > 1 && imagesList != null)
          Positioned(
            bottom: imageHight,
            right: context.isEnglish ? 0.065.h : null,
            left: context.isArabic ? 0.065.h : null,
            child: Container(
              width: imageSize,
              height: imageSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.lightPrimary,
              ),
              child: Center(
                child: CircleAvatar(
                  radius: 0.03.h,
                  backgroundColor: AppColors.transparent,
                  backgroundImage: AssetImage(imagesList![1]!),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
