// ignore_for_file: sdk_version_since
/// Module: core/custom
///
///*************************** FILE INFO ****************************///
/// File Name: custom_appbar.dart
/// Purpose: Declares `CustomAppBar`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
/// Updated: 9/10/2026 - DEBUG-ONLY test-employee badge + avatar menu
///          (compile-time `kDebugTestEmployeeSwitchBuild`).


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';
import 'package:knowticed_plus/features/notification/presentation/controller/app_notification_cubit.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/76-date_time_in_arabic.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';


// REMOVED_MODULE: import 'package:knowticed_plus/features/skeleton/controllers/notification_controller.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/core/helper/data_grc_module/core/extensions/extensions.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/core/helper/inventory_module/core/navigate.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/services_mangment_module/core/new_theme.dart';
import 'package:knowticed_plus/features/settings/main_controller/presentation/ui/pages/settings_screen.dart';

import 'package:knowticed_plus/features/home/h3_app_drawer/presentation/controller/app_drawer_cubit.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/pages/notification_page.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/helper/main_helper/arabic_number_format.dart';
import 'package:knowticed_plus/core/helper/main_helper/extensions.dart' hide ContextExtension;
// ADDED 9/10/2026 — DEBUG-ONLY test-employee badge + avatar menu.
import 'package:knowticed_plus/features/onboarding/o3_authentication/data/utils/debug_test_employee_switch.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/presentation/ui/widgets/debug_test_employee_widgets.dart';

// ignore: must_be_immutable
class CustomAppBar extends StatefulWidget {
  final bool isNotifications;
  ValueChanged<bool>? isNotState;

  CustomAppBar({
    Key? key,
    this.isNotifications = false,
    this.isNotState,
  }) : super(key: key);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

AppNotificationCubit appNotificationController =
Get.put(AppNotificationCubit());

class _CustomAppBarState extends State<CustomAppBar> {
  final HapticController hapticController = Get.put(HapticController());

  AppDrawerCubit drawerController = Get.find();
  /// "First Last" for the signed-in employee, in the active language.
  ///
  /// Every level is optional. A record with no Arabic name falls back to the
  /// English one (and vice versa) rather than rendering an empty header, and
  /// a record with neither renders empty rather than throwing.
  String _employeeDisplayName(BuildContext context) {
    // Typed `List<String>?`, NOT `dynamic`. `lastOrNull` is resolved
    // statically; with a dynamic receiver the call becomes a dynamic
    // invocation that no list can service, which is exactly the
    // NoSuchMethodError this helper caused on its first version. `.isEmpty`
    // and `.last` below are real core Iterable members, so they would be
    // safe either way — the static type is what makes that true by
    // construction rather than by luck.
    String? tail(List<String>? values) {
      if (values == null || values.isEmpty) return null;
      final String value = values.last.trim();
      return value.isEmpty ? null : value;
    }

    String? pick(List<String>? preferred, List<String>? fallback) =>
        tail(preferred) ?? tail(fallback);

    final bool english = context.isEnglish;

    String? first = pick(
      english ? employee?.firstName : employee?.firstNameInArabic,
      english ? employee?.firstNameInArabic : employee?.firstName,
    );
    String? last = pick(
      english ? employee?.lastName : employee?.lastNameInArabic,
      english ? employee?.lastNameInArabic : employee?.lastName,
    );

    // `.capitalize` is GetX's String extension and is only meaningful for
    // Latin script, so it stays on the English path only.
    if (english) {
      first = first?.capitalize;
      last = last?.capitalize;
    }

    return <String?>[first, last]
        .whereType<String>()
        .join(' ')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    bool orientation =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return BlocBuilder<AppDrawerCubit, AppDrawerState>(
      bloc: Get.find<AppDrawerCubit>(),
      builder: (context, _) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.transparent),
            color: AppColors.card,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(0.r),
            ),
          ),
          height: 90.sp,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // ADDED 9/10/2026 — DEBUG-ONLY "DEBUG: test employee" badge,
              // visible only during a debug-switch session. Compile-time
              // constant: absent from release/profile builds.
              if (kDebugTestEmployeeSwitchBuild) ...[
                const DebugTestEmployeeBadge(),
                SizedBox(width: orientation ? 12.w : 20.h),
              ],

              GestureDetector(
                onTap: () {
                  hapticController.triggerHapticFeedback(
                      vibration: VibrateType.mediumImpact,
                      hapticFeedback: HapticFeedback.mediumImpact);

                  // Update the drawer to show notifications instead of navigating
                  drawerController.updateSelectedIndex(19);
                },
                child: Container(
                  width: (isPortrait ? 40.h : 60.h),
                  height: (isPortrait ? 40.h : 60.h),
                  decoration: BoxDecoration(
                      color: drawerController.selectedIndex == 19
                          ? AppColors.transparent
                          : null,
                      borderRadius: BorderRadius.circular(8)),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: appNotificationController
                        .getUnseenNotificationsStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(
                          child: SvgPicture.asset(
                            width: 35.w,
                            height: 35.h,
                            fit: BoxFit.fill,
                            'assets/icons_assets/main_icons_assets/notification_bell_badge_red.svg',
                            color: drawerController.selectedIndex == 19
                                ? AppColors.textButton
                                : Theme.of(context).colorScheme.scrim,
                          ),
                        );
                      } else if (snapshot.hasError ||
                          snapshot.data?.docs.isEmpty == true) {
                        return Center(
                          child: SvgPicture.asset(
                            width: 35.w,
                            height: 35.h,
                            fit: BoxFit.fill,
                            'assets/icons_assets/main_icons_assets/notification_bell_badge_red.svg',
                            // color: drawerController.selectedIndex == 19
                            //     ? AppColors.textButton
                            //     : Theme.of(context).colorScheme.scrim,
                          ),
                        );
                      } else {
                        final unseenCount = snapshot.data?.docs.length ?? 0;
                        return Badge(
                          textColor: Colors.white,
                          label: Text(
                            context.isEnglish
                                ? '$unseenCount'
                                : ArabicDigits('$unseenCount').toArabicNumbers(),
                          ),
                          largeSize: isPortrait
                              ? 19
                              : 25.h, //  largeSize:isPortrait? 0.02.h : 0.025.h,
                          textStyle: AppFontStyle.cairoRegularStyle.copyWith(
                            fontSize: isPortrait
                                ? FontConstants.fontSize012.h
                                : FontConstants.fontSize018.h,
                            fontWeight: FontWeight.w600,
                            height: isPortrait ? 1.3 : 1.2,
                            color:
                            Theme.of(context).colorScheme.inverseSurface,
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              width: 35.w,
                              height: 35.h,
                              fit: BoxFit.fill,
                              'assets/icons_assets/main_icons_assets/notification_bell.svg',
                              // color: drawerController.selectedIndex == 19
                              //     ? AppColors.textButton
                              //     : Theme.of(context).colorScheme.scrim,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
              SizedBox(width: orientation ? 20.w : 40.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 10.sp,
                    children: [
                      Text(
                        // FIXED 15/8/2026: this line force-unwrapped FIVE
                        // nullable levels — firstName!, .last!, lastName!,
                        // firstNameInArabic!, lastNameInArabic! — and threw
                        // "Null check operator used on a null value" whenever
                        // any of them was absent.
                        //
                        // In Arabic the app reads firstNameInArabic /
                        // lastNameInArabic, and an employee record without
                        // Arabic names (the Demo account) made the whole
                        // AppBar throw. Flutter then substitutes a
                        // RenderErrorBox, which is a FIXED 100000px tall —
                        // that is where "RenderFlex overflowed by 99347
                        // pixels" came from, and why the header did not
                        // appear at all.
                        //
                        // Lines below already guard with `?.lastOrNull ?? ''`
                        // and `employee?.photo == null || ...`; this line was
                        // the only one in the widget that did not. A missing
                        // name is a blank name, not a crashed shell.
                        _employeeDisplayName(context),
                          style:StyleText.fontSize18Weight500.copyWith(
                              color: AppColors.text
                          )
                      ),
                      Text(
                        // FIXED 18/8/2026: was `employee!.titleInArabic` /
                        // `employee!.title`. The `?.lastOrNull ?? ''` guarded
                        // the LIST being null but not `employee` itself, so
                        // this threw "Null check operator used on a null
                        // value" while building the AppBar's BlocBuilder —
                        // the header is built before the signed-in employee
                        // has landed. No employee is an empty title, not a
                        // crashed shell.
                        FormatHelper.capitalize(
                          ContextExtension(context).isArabic
                              ? employee?.titleInArabic?.lastOrNull ?? ''
                              : employee?.title?.lastOrNull ?? '',
                        ),
                        style:StyleText.fontSize16Weight500.copyWith(
                          color: AppColors.text
                        )
                      ),
                    ],
                  ),
                  SizedBox(width: 20.h),
                  // FIXED 18/8/2026: the `employee?.photo == null` test short-
                  // circuited to the avatar branch when `employee` was null,
                  // and that branch then read `employee!.gender` — so a null
                  // employee crashed here too, on the very path meant to
                  // handle "no photo". Resolved once into a local so every
                  // read below is null-safe and the placeholder avatar shows.
                  Builder(builder: (context) {
                    final signedIn = employee;
                    final String? photoUrl = signedIn?.photo?.lastOrNull;
                    final bool hasPhoto =
                        photoUrl != null && photoUrl.isNotEmpty;

                    final Widget avatar = CircleAvatar(
                      backgroundColor: AppColors.transparent,
                      radius: orientation ? 20.h : 30.h,
                      backgroundImage: hasPhoto
                          ? NetworkImage(photoUrl) as ImageProvider
                          : AssetImage(
                              signedIn?.gender?.lastOrNull == 'female'
                                  ? 'assets/icons_assets/main_icons_assets/female_avatar.png'
                                  : 'assets/icons_assets/main_icons_assets/male_avatar.png',
                            ),
                    );
                    // ADDED 9/10/2026 — DEBUG-ONLY avatar menu with
                    // "🧪 Switch to test employee". Compile-time constant:
                    // release/profile keep the plain avatar.
                    if (kDebugTestEmployeeSwitchBuild) {
                      return DebugTestEmployeeAvatarMenu(child: avatar);
                    }
                    return avatar;
                  })

                  // Texts
                ],
              ),
              SizedBox(width: 15.w),
            ],
          ),
        );
      },
    );
  }
}