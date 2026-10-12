// ignore_for_file: unrelated_type_equality_checks, sized_box_for_whitespace, unused_local_variable

import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';
class CustomAnalyticsDescriptionContainer extends StatelessWidget {
  final String title;
  final String imagePath;
  final bool isTransparent;

  const CustomAnalyticsDescriptionContainer({
    required this.title,
    required this.imagePath,
    this.isTransparent = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    return Container(
      decoration: BoxDecoration(
        color: isTransparent && isTablet == false
            ? Theme.of(context).colorScheme.inversePrimary
            : Theme.of(context).colorScheme.inversePrimary,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 12, bottom: 5, left: 15),
            child: Row(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary,
                      radius: 13,
                      child: SvgPicture.asset(imagePath, color: AppColors.black),
                    ),
                    SizedBox(
                        width: isTablet
                            ? isPortrait
                                ? 0.01.w
                                : 0.01.h
                            : 0.008.h),
                    Text(
                      title,
                      style: AppFontStyle.cairoRegularStyle.copyWith(
                          fontSize: isTablet
                              ? isPortrait
                                  ? FontConstants.fontSize014.h
                                  : FontConstants.fontSize022.h
                              : FontConstants.fontSize020.h,
                          color: AppColors.text,
                          fontWeight: isTablet
                              ? isPortrait
                                  ? FontWeight.w400
                                  : FontWeight.w600
                              : FontWeight.w400,
                          height: isTablet
                              ? isPortrait
                                  ? 2
                                  : 1.8
                              : 1.8),
                    ),
                  ],
                ),
                Spacer(),
                Padding(
                  padding: EdgeInsets.only(right: 15),
                  child: Container(
                    width: isTablet ? 185 : 105,
                    height: 30,
                    decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8)),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(isTablet ? "Total Responses: " : "Total: ",
                              style: StyleText.fontSize16Weight500.copyWith(color: AppColors.darkGrey)
                                  .copyWith(
                                      fontSize: 14,
                                      color: AppColors.inputColor)),
                          Text("11/50",
                              style: StyleText.fontSize16Weight500.copyWith(color: AppColors.darkGrey)
                                  .copyWith(
                                      fontSize: 14, color: AppColors.black))
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                left: isTablet ? 47 : 15,
                top: 15,
                right: isTablet ? 20 : 15,
                bottom: isTablet ? 10 : 15),
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset("assets/png_assets/flags/Ellipse 226.png",
                          height: 30, width: 30),
                      SizedBox(width: 5),
                      Column(
                        children: [
                          Text("Mona Mohammed",
                              style: StyleText.fontSize12Weight400.copyWith(color: AppColors.mediumGrey)
                                  .copyWith(color: AppColors.text)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text("Job Title: ",
                                  style: StyleText.fontSize16Weight500.copyWith(color: AppColors.darkGrey)
                                      .copyWith(
                                          fontSize: 10,
                                          color: AppColors.inputColor)),
                              Text("Technician",
                                  style: StyleText.fontSize16Weight500.copyWith(color: AppColors.darkGrey)
                                      .copyWith(
                                          fontSize: 10, color: AppColors.black))
                            ],
                          ),
                        ],
                      ),
                      Spacer(),
                      Align(
                        alignment: Alignment.topCenter,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text("Date: ",
                                style: StyleText.fontSize16Weight500.copyWith(color: AppColors.darkGrey)
                                    .copyWith(
                                        fontSize: 10,
                                        color: AppColors.inputColor)),
                            Text("20 Nov 2025",
                                style: StyleText.fontSize16Weight500.copyWith(color: AppColors.darkGrey)
                                    .copyWith(
                                        fontSize: 10, color: AppColors.black))
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(right: 24.0),
                    child: Text(
                      "Table is designed to store and manage employee information within an organization. It includes essential details such as employee names, contact information, roles, and system access credentials. This table facilitates the assignment of roles and permissions to employees, ensuring proper access control",
                      style: StyleText.fontSize12Weight400
                          .copyWith(color: AppColors.inputColor, height: 1.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isTablet)
            Padding(
              padding: EdgeInsets.only(
                  left: isTablet ? 47 : 15,
                  top: 0,
                  right: isTablet ? 20 : 15,
                  bottom: 20),
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset("assets/png_assets/flags/Ellipse 226.png",
                            height: 30, width: 30),
                        SizedBox(width: 5),
                        Column(
                          children: [
                            Text("Mona Mohammed",
                                style: StyleText.fontSize12Weight400.copyWith(color: AppColors.mediumGrey)
                                    .copyWith(color: AppColors.text)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text("Job Title: ",
                                    style: StyleText.fontSize16Weight500.copyWith(color: AppColors.darkGrey)
                                        .copyWith(
                                            fontSize: 10,
                                            color: AppColors.inputColor)),
                                Text("Technician",
                                    style: StyleText.fontSize16Weight500.copyWith(color: AppColors.darkGrey)
                                        .copyWith(
                                            fontSize: 10,
                                            color: AppColors.black))
                              ],
                            ),
                          ],
                        ),
                        Spacer(),
                        Align(
                          alignment: Alignment.topCenter,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text("Date: ",
                                  style: StyleText.fontSize16Weight500.copyWith(color: AppColors.darkGrey)
                                      .copyWith(
                                          fontSize: 10,
                                          color: AppColors.inputColor)),
                              Text("20 Nov 2025",
                                  style: StyleText.fontSize16Weight500.copyWith(color: AppColors.darkGrey)
                                      .copyWith(
                                          fontSize: 10, color: AppColors.black))
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(right: 24.0),
                      child: Text(
                        "Table is designed to store and manage employee information within an organization. It includes essential details such as employee names, contact information, roles, and system access credentials. This table facilitates the assignment of roles and permissions to employees, ensuring proper access control",
                        style: StyleText.fontSize12Weight400
                            .copyWith(color: AppColors.inputColor, height: 1.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
