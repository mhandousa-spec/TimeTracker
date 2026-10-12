/// Module: settings/main_controller
///
///*************************** FILE INFO ****************************///
/// File Name: settings_appbar.dart
/// Purpose: The profile header at the top of the settings menu — avatar, name,
///          role, supervisor and start date.
/// Author: Amr Mesbah
/// Created at: 10/11/2024
/// Updated: 11/8/2026 - Moved out of widgets/shared/ (CR-SKEL-SEMAIN-N03);
///          raw Colors.* routed through AppColors (N23); header added.

import 'package:get/get.dart';

import 'dart:isolate';

import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_font_size.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/settings/main_controller/presentation/ui/pages/settings_screen.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';


class SettingsAppBar extends StatefulWidget {
  String? name;
  String? image;
  String? role;
  String? startDate;
  String? superVisor;
  SettingsAppBar({Key? key, this.name, this.role, this.image, this.startDate, this.superVisor})
      : super(key: key);
  @override
  State<SettingsAppBar> createState() => _SettingsAppBarState();
}



class _SettingsAppBarState extends State<SettingsAppBar> {

  String _formatDate(String dateString) {
    try {
      // Parse the date string
      DateTime date = DateTime.parse(dateString);

      // Check if the current locale is Arabic
      if (context.isArabic) {
        // Arabic month names
        List<String> arabicMonths = [
          'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
          'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
        ];

        // Convert numbers to Arabic numerals
        String day = _convertToArabicNumbers(date.day.toString());
        String year = _convertToArabicNumbers(date.year.toString());
        String month = arabicMonths[date.month - 1];

        return '$day $month $year';
      } else {
        // English format
        List<String> months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];

        return '${date.day} ${months[date.month - 1]} ${date.year}';
      }
    } catch (e) {
      // If parsing fails, return original string
      return dateString;
    }
  }

// Helper method to convert English numbers to Arabic numerals
  String _convertToArabicNumbers(String number) {
    const englishToArabic = {
      '0': '٠',
      '1': '١',
      '2': '٢',
      '3': '٣',
      '4': '٤',
      '5': '٥',
      '6': '٦',
      '7': '٧',
      '8': '٨',
      '9': '٩',
    };

    return number.split('').map((char) => englishToArabic[char] ?? char).join('');
  }

  @override
  Widget build(BuildContext context) {
    var isMobile = ContextExtension(context).isPhone;
    var isLandScape = ContextExtension(context).isLandscape;
    var lightMode = Theme.of(context).brightness == Brightness.light;
    bool orientation =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return isMobile ?
          Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.sp),
      child: Column(
        children: [
          Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [


                  SizedBox(height: 50.sp),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Circular image
                      widget.image == null || widget.image!.isEmpty || widget.image == '[]'
                          ? Padding(
                        padding: EdgeInsets.only(top: isMobile ? 17.sp : 0.sp),
                        child: CircleAvatar(
                          backgroundColor: AppColors.transparent,
                          radius: orientation ? 0.03.h : 0.035.w,
                          backgroundImage: AssetImage(
                              employee!.gender.last == 'female'
                                  ? 'assets/icons_assets/main_icons_assets/female_avatar.png'
                                  : 'assets/icons_assets/main_icons_assets/male_avatar.png'
                          ),
                        ),
                      )
                          : CircleAvatar(
                        backgroundColor: AppColors.transparent,
                        radius: orientation ? 0.03.h : 0.035.w,
                        backgroundImage: NetworkImage(widget.image!),
                      ),
                      SizedBox(
                        width: 0.02.h,
                      ),
                      // Texts
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 17.h),
                              Text(
                                  FormatHelper.capitalize(widget.name ?? ''),
                                  style: StyleText.fontSize18Weight500.copyWith(
                                      color: AppColors.text
                                  )
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                  FormatHelper.capitalize(
                                    context.isArabic
                                        ? employee!.titleInArabic
                                        ?.lastOrNull ??
                                        ''
                                        : employee!.title?.lastOrNull ?? '',
                                  ),
                                  style: StyleText.fontSize16Weight400.copyWith(
                                      color: AppColors.secondaryText
                                  )
                              ),
                            ],
                          ),



                        ],
                      ),



                    ],
                  ),


                  isMobile ? Spacer() :   Spacer(),

                  isMobile ? SizedBox():  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 22.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${S.of(context).start_date}: ",
                            style: StyleText.fontSize12Weight400.copyWith(
                                color: AppColors.secondaryText
                            ),
                          ),
                          Text(
                            _formatDate(widget.startDate!),
                            style: StyleText.fontSize12Weight400.copyWith(
                                color: AppColors.text
                            ),
                          ),
                        ],
                      ),

                    ],
                  )
                ],
              ),
              SizedBox(height: 15.sp),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.end,
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   children: [
              //     SizedBox(height: 22.h),
              //     Row(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         Text(
              //           "${S.of(context).start_date}: ",
              //           style: StyleText.fontSize12Weight400.copyWith(
              //               color: AppColors.secondaryText
              //           ),
              //         ),
              //         Text(
              //           _formatDate(widget.startDate!),
              //           style: StyleText.fontSize12Weight400.copyWith(
              //               color: AppColors.text
              //           ),
              //         ),
              //       ],
              //     ),
              //
              //   ],
              // )
            ],
          ),
        ],
      ),
    )
        : Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.02.h),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [


              SizedBox(height: 50.sp),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Circular image
                  widget.image == null || widget.image!.isEmpty || widget.image == '[]'
                      ? Padding(
                    padding: EdgeInsets.only(top: isMobile ? 12.sp : 0.sp),
                    child: CircleAvatar(
                      backgroundColor: AppColors.transparent,
                      radius: orientation ? 0.03.h : 0.035.w,
                      backgroundImage: AssetImage(
                          employee!.gender.last == 'female'
                              ? 'assets/icons_assets/main_icons_assets/female_avatar.png'
                              : 'assets/icons_assets/main_icons_assets/male_avatar.png'
                      ),
                    ),
                  )
                      : CircleAvatar(
                    backgroundColor: AppColors.transparent,
                    radius: orientation ? 0.03.h : 0.035.w,
                    backgroundImage: NetworkImage(widget.image!),
                  ),
                  SizedBox(
                    width: 0.02.h,
                  ),
                  // Texts
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                  //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 17.h),
                          Text(
                            FormatHelper.capitalize(widget.name ?? ''),
                            style: StyleText.fontSize18Weight500.copyWith(
                                color: lightMode ? AppColors.blackButton : AppColors.white
                            )
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            FormatHelper.capitalize(
                              context.isArabic
                                  ? employee!.titleInArabic
                                  ?.lastOrNull ??
                                  ''
                                  : employee!.title?.lastOrNull ?? '',
                            ),
                            style: StyleText.fontSize16Weight400.copyWith(
                              color: lightMode ? AppColors.secondaryText : AppColors.grey
                            )
                          ),
                        ],
                      ),



                    ],
                  ),



                ],
              ),


              isMobile ? SizedBox() :   Spacer(),

              isMobile ? SizedBox() :  Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 22.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${S.of(context).start_date}: ",
                        style: StyleText.fontSize14Weight400.copyWith(
                            color: lightMode ? AppColors.secondaryText : AppColors.grey
                        ),
                      ),
                      Text(
                        _formatDate(widget.startDate!),
                        style: StyleText.fontSize14Weight400.copyWith(
                            color: lightMode ? AppColors.blackButton : AppColors.white
                        ),
                      ),
                    ],
                  ),

                ],
              )
            ],
          ),
          isMobile ?   Row(
         mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 22.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${S.of(context).start_date}: ",
                        style: StyleText.fontSize14Weight400.copyWith(
                            color: lightMode ? AppColors.secondaryText : AppColors.grey
                        ),
                      ),
                      Text(
                        _formatDate(widget.startDate!),
                        style: StyleText.fontSize14Weight400.copyWith(
                            color: lightMode ? AppColors.blackButton : AppColors.white
                        ),
                      ),
                    ],
                  ),

                ],
              )
            ],
          ) : SizedBox()
        ],
      ),
    );
  }
}
