/// Module: knowledge_hub_module / core/responsive_side_frame.dart
/// ************************* FILE INFO *************************** ///
/// File Name: responsive_side_frame.dart
/// Purpose: Responsive side frame — knowledge_hub_module core/widgets.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';



/// DEPRECATED 12/9/2026 — the module's private copy of the app-wide frame.
///
/// Every page in `knowledge_hub` now uses `SideFrameMasterServices` from
/// `core/custom/50-custom_side_frame_master.dart`, which is the same widget
/// with the same constructor plus the fixes the shared one has picked up
/// (fixed title row on phones, haptics on breadcrumb taps, the app's chevron
/// asset, `SideFrameBoundedBody` / `SideFrameScrollableBody` helpers).
///
/// Nothing imports this any more — it is kept only so an in-flight branch that
/// still names it keeps compiling, and can be deleted once that lands.
@Deprecated(
  'Use SideFrameMasterServices from core/custom/50-custom_side_frame_master.dart',
)
class SideFrameMaster extends StatelessWidget {
  final String titleText;
  final String? secondTitle;
  final String? thirdTitle;
  final String? fourthTitle;
  final Widget? child;

  final VoidCallback? onFirstTap;
  final VoidCallback? onSecondTap;
  final VoidCallback? onThirdTap;
  final VoidCallback? onFourthTap;

  const SideFrameMaster({
    super.key,
    required this.titleText,
    this.secondTitle,
    this.thirdTitle,
    this.fourthTitle,
    this.onFirstTap,
    this.onSecondTap,
    this.onThirdTap,
    this.onFourthTap,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Directionality.of(context) == TextDirection.rtl;
    final bool isTablet = ContextExtension(context).isTablet;
    final bool isLandscape = ContextExtension(context).isLandscape;
    final bool isVerticalTablet = isTablet && !isLandscape;
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;

    if (isMobile) {
      return Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? AppColors.background
            : AppColors.background,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 0.sp, vertical: 0.sp),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (secondTitle != null || thirdTitle != null || fourthTitle != null)
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).maybePop(); // Go back
                        },
                        child: Padding(
                          padding: EdgeInsets.only(top: 10.sp,right: 8.sp,left: 8.sp),
                          child: Transform.rotate(
                            angle: isArabic ? 0 : 3.1416,
                            child: SvgPicture.asset(
                              'assets/icons_assets/main_icons_assets/images_arrow.svg',
                              width: 24.sp,
                              height: 24.sp,
                              color: Theme.of(context).brightness == Brightness.light
                                  ? AppColors.blackButton
                                  : AppColors.whiteShadow,
                            ),
                          ),
                        ),
                      ),
                    Expanded(
                      child: Padding(
                        padding:  EdgeInsets.only( top: 10.sp ,right:  thirdTitle == null  && secondTitle  == null && fourthTitle  == null ? 8.0 : 0,left:  thirdTitle == null  && secondTitle  == null && fourthTitle  == null ? 8.0 : 0),
                        child: GestureDetector(
                          onTap: onFourthTap ?? onThirdTap ?? onSecondTap ?? onFirstTap,
                          child: Text(
                            fourthTitle ?? thirdTitle ?? secondTitle ?? titleText,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: StyleText.fontSize23Weight400.copyWith(
                              color: Theme.of(context).brightness == Brightness.light
                                  ? AppColors.blackButton
                                  : AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),


                Padding(
                  padding:  EdgeInsets.symmetric(horizontal: 15.sp),
                  child: Column(
                    children: [
                      SizedBox(height: 20.sp),
                      if (child != null) child!,
                    ],
                  ),
                )


              ],
            ),
          ),
        ),
      );
    } else {
      return Row(
        children: [
          // Container(
          //   width: 80.sp,
          //   color: Theme.of(context).brightness == Brightness.light
          //       ? AppColors.white
          //       : AppColors.chatBackground,
          //   child: Column(
          //     children: [
          //       SizedBox(height: 26.sp),
          //       SvgPicture.asset(
          //         "assets/icons_assets/main_icons_assets/branding.svg",
          //         width: 49.sp,
          //         height: 38.sp,
          //         semanticsLabel: 'Branding Logo',
          //       ),
          //       SizedBox(height: 44.sp),
          //       Container(
          //         width: 55.sp,
          //         height: 55.sp,
          //         decoration: BoxDecoration(
          //           color: AppColors.secondaryPrimary,
          //           borderRadius: BorderRadius.circular(14.r),
          //         ),
          //         child: SvgPicture.asset(
          //           "assets/icons_assets/main_icons_assets/logoApp.svg",
          //           width: 24.sp,
          //           height: 24.sp,
          //           fit: BoxFit.scaleDown,
          //           semanticsLabel: 'App Logo',
          //         ),
          //       ),
          //       SizedBox(height: 44.sp),
          //       GestureDetector(
          //         onTap: (){
          //         //  navigateTo(context, SettingsPage());
          //         },
          //         child: Container(
          //           width: 55.sp,
          //           height: 55.sp,
          //           decoration: BoxDecoration(
          //             color: AppColors.secondaryPrimary,
          //             borderRadius: BorderRadius.circular(14.r),
          //           ),
          //           child: Icon(Icons.settings)
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          Expanded(
            child: Column(
              children: [
                // Container(
                //   width: MediaQuery.sizeOf(context).width,
                //   height: 90.sp,
                //   color: Theme.of(context).brightness == Brightness.light
                //       ? AppColors.white
                //       : AppColors.chatBackground,
                //   child: Row(
                //     children: [
                //       const Spacer(),
                //       SvgPicture.asset(
                //         "assets/icons_assets/main_icons_assets/images_Bell.svg",
                //         semanticsLabel: 'Notification Icon',
                //         color: Theme.of(context).brightness == Brightness.light
                //             ? AppColors.colorGrey
                //             : AppColors.colorWhite,
                //       ),
                //       SizedBox(width: 30.sp),
                //       Row(
                //         children: [
                //           SvgPicture.asset(
                //             "assets/icons_assets/main_icons_assets/PersonStatic.svg",
                //             width: 40.sp,
                //             height: 40.sp,
                //             semanticsLabel: 'User Icon',
                //           ),
                //           SizedBox(width: 10.sp),
                //           Column(
                //             mainAxisAlignment: MainAxisAlignment.center,
                //             crossAxisAlignment: CrossAxisAlignment.start,
                //             children: [
                //               Text(
                //                 "Amro Handousa",
                //                 style: StyleText.fontSize16Weight500.copyWith(
                //                   color: Theme.of(context).brightness == Brightness.light
                //                       ? AppColors.blackButton
                //                       : AppColors.white,
                //                 ),
                //               ),
                //               Text(
                //                 "Employee",
                //                 style: StyleText.fontSize14Weight500.copyWith(
                //                   color: Theme.of(context).brightness == Brightness.light
                //                       ? AppColors.secondaryText
                //                       : AppColors.white,
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ],
                //       ),
                //       SizedBox(width: 18.sp),
                //     ],
                //   ),
                // ),
                // ⬇️ Replace your whole Expanded(...) block with this:
                Expanded(
                  child: Container(
                    width: MediaQuery.sizeOf(context).width,
                    color: Theme.of(context).brightness == Brightness.light
                        ? AppColors.background
                        : AppColors.background,
                    // ;;;
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ---------- Fixed (non-scrollable) header/breadcrumb ----------
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical:15.sp),
                          child: Row(
                            children: () {
                              List<String?> titles = [titleText, secondTitle, thirdTitle, fourthTitle];
                              List<VoidCallback?> taps = [onFirstTap, onSecondTap, onThirdTap, onFourthTap];

                              List<MapEntry<String, VoidCallback?>> valid = [];
                              for (int i = 0; i < titles.length; i++) {
                                if (titles[i] != null) {
                                  valid.add(MapEntry(titles[i]!, taps[i]));
                                }
                              }



                              if (isVerticalTablet && valid.length > 2) {
                                valid = valid.sublist(valid.length - 2); // last 2 items in vertical tablet
                              } else if (!isVerticalTablet && valid.length > 3) {
                                valid = valid.sublist(valid.length - 3); // last 3 items in horizontal mode
                              }

                              List<Widget> widgets = [];

                              for (int i = 0; i < valid.length; i++) {
                                if (i != 0) {
                                  widgets.add(SizedBox(width: 10.sp));
                                  widgets.add(
                                    Transform.rotate(
                                      angle: isArabic ? 3.1416 : 0,
                                      child: Padding(
                                        padding: isArabic
                                            ? EdgeInsets.only(bottom: 7.sp)
                                            : EdgeInsets.only(top: 3.sp),
                                        child: SvgPicture.asset(
                                          'assets/icons_assets/main_icons_assets/images_arrow.svg',
                                          width: 30.sp,
                                          height: 30.sp,
                                          color: Theme.of(context).brightness == Brightness.light
                                              ? AppColors.blackButton
                                              : AppColors.whiteShadow,
                                        ),
                                      ),
                                    ),
                                  );
                                  widgets.add(SizedBox(width: 10.sp));
                                }

                                widgets.add(
                                  GestureDetector(
                                    onTap: valid[i].value,
                                    child: Text(
                                      valid[i].key,
                                      style: StyleText.fontSize28Weight500.copyWith(
                                        color: Theme.of(context).brightness == Brightness.light
                                            ? AppColors.blackButton
                                            : AppColors.white,
                                      ),
                                    ),
                                  ),
                                );
                              }

                              return widgets;
                            }(),
                          ),
                        ),

                        // ---------- Scrollable content ----------
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15.sp, vertical: 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 10.sp), // same spacing that was under the breadcrumb
                                if (child != null) Expanded(child: child!),  // ← give the screen area a bounded height

                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              ],
            ),
          ),
        ],
      );
    }
  }
}
