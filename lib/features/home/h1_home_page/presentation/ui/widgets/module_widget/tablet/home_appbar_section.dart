/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: home_appbar_section.dart
/// Purpose: Declares `HomeAppbarSection`.
/// Author: Knowticed Plus team
/// Updated: 23/8/2026 - The pinned header icons navigate again: the commented-out
///          tap handler is restored and resolves its destination through the
///          icon catalog (`headerIconForSvgPath`) rather than through the
///          placeholder the cubit rebuilds.
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

/// ************************ FILe INFO ********************************///
/// File Name: home_appbar_section.dart
/// Purpose: Contains the appbar section for the home screen
/// Author: Amr Mesbah
/// Refactored at: 9/2/2025

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

// REMOVED_MODULE: import 'package:knowticed_plus/core/helper/inventory_module/core/navigate.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/header_icon_item.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/gradient_container.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/icon_selector_dialog_widget.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/features/settings/main_controller/presentation/ui/pages/settings_screen.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/external/services_mangment_module/core/new_theme.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/external/todo_new_module/external/tasks_module/category/presentation/screens/to_do_list/details_screen/hr_module/add_new_employee_screen.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/external/todo_new_module/external/tasks_module/category/presentation/screens/to_do_list/details_screen/hr_module/hr_dashboard.dart';
import 'package:knowticed_plus/features/home/h3_app_drawer/presentation/controller/app_drawer_cubit.dart';
import 'package:knowticed_plus/core/services/twilio/twilio_constants.dart';
import 'package:knowticed_plus/core/services/twilio/twilio_repository.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/home_cubit.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/skeleton_home_controller.dart';

import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/generated/l10n.dart';
class HomeAppbarSection extends StatelessWidget {
  HomeAppbarSection({Key? key}) : super(key: key);
  SkeletonHomeController controller = Get.find();

  /// Function Name: [_openHeaderIcon]
  ///
  /// Purpose: Do what a pinned app-bar icon stands for — run its action, or
  ///          open its page.
  ///
  /// FIXED 23/8/2026. The tap handler was commented out, so every pinned icon
  /// was inert. Uncommenting it alone would not have been enough: the item the
  /// cubit restores from Firebase carries only the asset path, and its
  /// `navigateTo` is a stand-in placeholder (see `HeaderIconItem.fromSvgPath`)
  /// — pushing it would have opened a blank crosshatched screen. The real
  /// destination is looked up in the icon catalog by asset path instead.
  ///
  /// Action icons (English, AR, light/dark) come first: they have no page at
  /// all, and before `HeaderIconItem.onTap` existed they could only be
  /// described as a `Placeholder`, which is why tapping one showed its tooltip
  /// and did nothing else.
  ///
  /// Parameters:
  /// - [context]: Build context used to resolve the catalog and push the route.
  /// - [icon]: The pinned icon that was tapped.
  void _openHeaderIcon(BuildContext context, HeaderIconItem icon) {
    final HeaderIconItem? catalogEntry =
        headerIconForSvgPath(context, icon.svgPath);
    if (catalogEntry == null) return;

    final void Function(BuildContext)? action = catalogEntry.onTap;
    if (action != null) {
      action(context);
      return;
    }

    final Widget destination = catalogEntry.navigateTo(context);

    // Some catalog entries are still `const Placeholder()` — the module behind
    // them does not exist yet. Opening a blank screen reads as a crash, so
    // those stay inert until a destination is decided.
    if (destination is Placeholder) return;

    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (BuildContext _) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;

    final homeCubit = context.read<AppHomeCubit>();
    bool orientation =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Padding(
      padding: EdgeInsets.only(top: 17.sp),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: SvgPicture.asset(
                        "assets/icons_assets/roles_assets/calendar.svg",
                        height: orientation ? 20.h : 25.h,
                        color: lightMode ? AppColors.blackButton : AppColors.white
                      ),
                    ),
                    SizedBox(width: 10.sp),
                    GestureDetector(
                      onTap: (){
                     //   navigateTo(context, AnimationsShowcaseScreen());
                      },
                      child: Text(
                        controller.getCurrentDate(isEnglish: context.isEnglish),
                        style: StyleText.fontSize20Weight600.copyWith(
                          color: lightMode ? AppColors.blackButton : AppColors.white
                        )
                      ),
                    ),
                  ],
                ),
              ),

              Spacer(),
              // Header icons
              if (homeCubit.selectedHeaderIcons.isNotEmpty)
                Row(
                  spacing: 8.sp,
                  children: [
                    for (var icon in homeCubit.selectedHeaderIcons)
                      InkWell(
                        onTap: () => _openHeaderIcon(context, icon),
                        borderRadius: BorderRadius.circular(8.r),
                        child: Tooltip(
                          message: icon.title(context),
                          child: Container(
                            width: 48.sp,
                            height: 48.sp,
                            padding: EdgeInsets.all(8.sp),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: CustomSvgImage(
                              assetPath: icon.svgPath,
                              fit: BoxFit.contain,
                              color: AppColors.textButton,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
          SizedBox(height: 20.h),
          GestureDetector(
            // onTap: (){
            //   Navigator.push(
            //     context,
            //     MaterialPageRoute(builder: (context) =>  HrDashboard()),
            //   );
            // },
            child: Text(
              "${DateTime.now().hour < 12 ? S.of(context).goodMorning : DateTime.now().hour < 14 ? S.of(context).goodAfternoon : S.of(context).goodEvening} ${context.isEnglish ? employee!.firstName!.last!.capitalize : employee!.firstNameInArabic!.last!}",
              style: StyleText.fontSize24Weight600.copyWith(
                color: lightMode ? AppColors.blackButton : AppColors.white
              )
            ),
          ),
          SizedBox(height: 20.h),
          GestureDetector(
              onTap: () async {
               // // final locale = context.read<ThemeCubit>().isArabic ? 'ar' : 'en';
               //  await TwilioRepository().sendOTP("amrmesbah33@gmail.com", "email", 'en');
               //  await TwilioRepository().sendOTP("+201124753420", "sms", 'en');
               //
               //
               //  //  await TwilioRepository().testTwilioAuth();
              },
              child: GradientContainer()),
        ],
      ),
    );
  }
}
