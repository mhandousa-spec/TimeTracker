/// Module: settings/main_controller
///
///*************************** FILE INFO ****************************///
/// File Name: settings_layout.dart
/// Purpose: The settings menu, and — on tablet — the detail pane beside it.
/// Author: Amr Mesbah
/// Created at: 10/11/2024
/// Updated: 11/8/2026 - CR-SKEL-SEMAIN-N16: the four inline MaterialPageRoutes
///          are gone; destinations are named routes resolved through
///          `AppPages`. Unused locals and the unused onboarding import removed.
/// Updated: 31/8/2026 - Row order now follows the Figma settings frame: the
///          "App Customization" card was folded into the card above it, and a
///          Notification switch was added. Haptic Feedback, Watermark and
///          Comments and Feedbacks became permission-gated, so nine of the
///          eleven SettingsPermissions now hide a row here.
/// Updated: 2/9/2026 - The menu now matches the Figma settings frame exactly,
///          in both grouping and row text order. Three cards instead of two:
///          (1) Personal Information, Health Insurance, Social Information,
///          Requests; (2) Company Information, Home Layout, Branding and Theme,
///          WaterMark; (3) Language, Comments and Feedbacks, About This App,
///          Privacy Statement, Terms and Conditions. No row was added or
///          removed and every index, route and permission gate is unchanged —
///          only position. The cards are separated by 7.h so the grouping is
///          visible rather than reading as one flat list.
/// Updated: 9/10/2026 - Health Insurance and Social Information re-enabled
///          (hidden since 28/9/2026). Social follows the role's
///          Share_Social_Information switch; Health is always listed.

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/helper/main_helper/biometric_controller.dart';
import 'package:knowticed_plus/core/helper/main_helper/device_policy_controller.dart';
import 'package:knowticed_plus/core/helper/main_helper/notification_controller.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

import 'package:knowticed_plus/core/theme/app_font_size.dart';
// ADDED 8/9/2026 for StyleText, used by the mobile page title below.
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/theme_controller.dart';
import 'package:knowticed_plus/features/settings/main_controller/presentation/ui/widgets/restart_widget.dart';
import 'package:knowticed_plus/features/settings/main_controller/presentation/controller/settings_controller.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/settings/main_controller/presentation/ui/widgets/custom_cards.dart';
import 'package:knowticed_plus/features/settings/main_controller/presentation/ui/widgets/restricted_location_countries.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/presentation/ui/pages/language_screen.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/presentation/ui/pages/terms_and_conditions.dart';
import 'package:knowticed_plus/features/settings/main_controller/presentation/ui/widgets/settings_appbar.dart';
import 'package:knowticed_plus/features/settings/se3_company/presentation/ui/pages/employee_branding_screen.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/settings/settings_permissions.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/settings/settings_permissions_sections.dart';
// ADDED 9/10/2026 — gates the re-enabled Social Information row.
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/settings/social_permissions.dart';
import 'package:knowticed_plus/features/settings/se3_company/presentation/ui/widgets/sections/company_info.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/presentation/ui/pages/about_this_app_screen.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/presentation/ui/pages/comments_and_feedback_screen.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/presentation/ui/pages/privacy_Statement.dart';
import 'package:knowticed_plus/features/settings/se6_requests/presentation/ui/pages/request_page.dart';
import 'package:knowticed_plus/features/settings/se2_social/presentation/ui/pages/social_screen.dart';
import 'package:knowticed_plus/features/settings/se3_company/presentation/ui/pages/company_info_screen.dart';
// REMOVED 31/8/2026 — watermark_screen.dart import. WatermarkScreen is no
// longer built inline here; it is reached only through Routes.settingsWatermark.
import 'package:knowticed_plus/features/settings/se8_watermark/presentation/ui/widgets/watermark_layer.dart';
import 'package:knowticed_plus/features/settings/se1_profile/presentation/ui/pages/personal_info_screen.dart';
import 'package:knowticed_plus/features/settings/se4_health_insurance/presentation/ui/pages/settings_health_insurance.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/network/message_module/routes/app_routes.dart';
import 'package:knowticed_plus/core/network/message_module/routes/get_pages.dart';

class SettingsLayout extends StatefulWidget {
  const SettingsLayout({super.key});

  @override
  State<SettingsLayout> createState() => _SettingsLayoutState();
}

class _SettingsLayoutState extends State<SettingsLayout> {
  final SettingsController settingsController = Get.find();


  final ThemeController themeController = Get.find();

  /// Function Name: [_open]
  ///
  /// Purpose: Push a settings destination by name.
  ///
  /// Parameters:
  /// - [routeName]: a `Routes.settingsX` constant.
  ///
  /// The page builders live in `core/network/message_module/routes` (§14).
  /// This also works inside the tablet pane's nested Navigator, which resolves
  /// the same table via `AppPages.maybeRoute`.
  void _open(BuildContext context, String routeName) {
    Navigator.of(context).push(AppPages.route(routeName));
  }

  String _getEmployeeName() {
    final mainCoreEmployeeController = Get.find<MainCoreEmployeeController>();

    if (mainCoreEmployeeController.employeeEntity == null) return '';

    final isEnglish = Get.locale.toString().contains('en');

    final firstName = isEnglish
        ? (mainCoreEmployeeController.employeeEntity?.firstName ?? '').capitalize
        : mainCoreEmployeeController.employeeEntity?.firstNameInArabic ?? '';

    final lastName = isEnglish
        ? (mainCoreEmployeeController.employeeEntity?.lastName ?? '').capitalize
        : mainCoreEmployeeController.employeeEntity?.lastNameInArabic ?? '';

    return "$firstName $lastName".trim();
  }



  /// FIXED 13/8/2026: this build read `settingsController.selectedContainerIndex`
  /// (for the row highlight, and at the bottom of this file to choose the
  /// content pane) but subscribed to nothing, so the pane never changed when a
  /// menu row was tapped on tablet/desktop. `CustomCard` calls
  /// `SettingsScreenState.setSelectedContainerIndex`, whose `setState` rebuilds
  /// *that* State — not this one, which sits inside the nested Navigator's
  /// route and is therefore not on its rebuild path.
  ///
  /// The cubit now emits on selection (see `SettingsController`), and this
  /// BlocBuilder is what turns that emit into a rebuild. The body is unchanged
  /// and lives in [_buildContent].
  @override
  Widget build(BuildContext context) {
    // ADDED 25/8/2026 — the settings shell is stamped as a whole, which covers
    // the destination list AND every right-hand panel embedded in it on
    // desktop and tablet. The pushed routes are stamped separately, in
    // get_pages.dart. Between those two places, every settings destination is
    // covered without wrapping any of them individually.
    // `module: Modules.settings` ADDED 2/9/2026, alongside the Settings tile in
    // the watermark module grid. Without it this layer stamps unconditionally
    // and that tile controls nothing.
    return WatermarkLayer(
      module: Modules.settings,
      child: BlocBuilder<SettingsController, SettingsState>(
        bloc: settingsController,
        builder: (BuildContext context, SettingsState state) =>
            _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    var isMobile = ContextExtension(context).isPhone;
    SettingsController settingsController = Get.find();
    final HapticController hapticController = Get.put(HapticController());
    final BiometricController biometricController = Get.put(BiometricController());
    // Reuse the instance main() registered at boot. Get.put here would build
    // a fresh controller on every rebuild, replacing the registered one and
    // leaking its screen-capture listener.
    final DevicePolicyController devicePolicyController =
        Get.isRegistered<DevicePolicyController>()
            ? Get.find<DevicePolicyController>()
            : Get.put(DevicePolicyController());
    // Same reuse rule as DevicePolicyController above: find the registered
    // instance if there is one, so the stored flag is not re-read into a fresh
    // controller on every rebuild.
    final NotificationController notificationController =
        Get.isRegistered<NotificationController>()
            ? Get.find<NotificationController>()
            : Get.put(NotificationController());
    final MainCoreEmployeeController mainCoreEmployeeController = Get.find();

    bool orientation = MediaQuery.of(context).orientation == Orientation.portrait;

    // Check permissions for each item
    bool hasPersonalInfo = true; // Usually always visible
    // CHANGED 9/10/2026 — Health Insurance and Social Information are back
    // (owner request; the Settings schema of 9 Oct keeps both as LIVE
    // sections). They had been hard-coded `false` on 28/9/2026, which hid the
    // two rows AND their right-hand panels on phone and on iPad portrait /
    // landscape alike.
    //
    //  * Health Insurance has no Settings permission of its own, so — like
    //    Personal Information and Requests — it is always listed. Viewing is
    //    harmless (it is the employee's own record); every edit goes through
    //    a change request that only a `Users_Requests` holder can approve.
    //  * Social Information is gated by Social Permissions →
    //    Share_Social_Information: the same master switch SocialScreen reads
    //    to decide whether it has anything to show or save. Without it the
    //    page would open empty, so the row is hidden instead.
    bool hasHealthInsurance = true;
    bool hasSocialInfo = mainCoreEmployeeController.isHasPermission(
      module: Modules.settings,
      section: SettingsPermissionsSections.socialPermissions,
      permission: SocialPermissions.shareSocialInformation,
    );
    bool hasRequests = true; // Usually always visible

    // Permission-based visibility checks
    bool hasBrandingTheme = mainCoreEmployeeController.isHasPermission(
      module: Modules.settings,
      section: SettingsPermissionsSections.settings,
      permission: SettingsPermissions.branding,
    );

    bool hasHomeLayout = true; // Usually always visible

    // ADDED 31/8/2026 — Watermark now has its own permission instead of
    // riding on `hasHomeLayout` (hardcoded true), which left the row
    // permanently visible whatever the role said.
    bool hasWatermark = mainCoreEmployeeController.isHasPermission(
      module: Modules.settings,
      section: SettingsPermissionsSections.settings,
      permission: SettingsPermissions.watermark,
    );

    bool hasCompanyInfo = mainCoreEmployeeController.isHasPermission(
      module: Modules.settings,
      section: SettingsPermissionsSections.settings,
      permission: SettingsPermissions.companyInformation,
    );

    bool hasLanguage = true; // Usually always visible

    bool hasCommentsAndFeedbacks = mainCoreEmployeeController.isHasPermission(
      module: Modules.settings,
      section: SettingsPermissionsSections.settings,
      permission: SettingsPermissions.commentAndFeedback,
    );

    bool hasAboutApp = true; // Usually always visible
    bool hasTermsConditions = true; // Usually always visible
    bool hasPrivacyStatement = true; // Usually always visible

    bool hasAnimation = mainCoreEmployeeController.isHasPermission(
      module: Modules.settings,
      section: SettingsPermissionsSections.settings,
      permission: SettingsPermissions.animation,
    );

    bool hasBiometrics = mainCoreEmployeeController.isHasPermission(
      module: Modules.settings,
      section: SettingsPermissionsSections.settings,
      permission: SettingsPermissions.biometricsForLogin,
    );

    // ADDED 31/8/2026 — Haptic Feedback and Notification. Both rows used to be
    // ungated: Haptic rendered unconditionally, and Notification did not exist
    // in this list at all.
    bool hasHaptic = mainCoreEmployeeController.isHasPermission(
      module: Modules.settings,
      section: SettingsPermissionsSections.settings,
      permission: SettingsPermissions.haptic,
    );

    bool hasNotification = mainCoreEmployeeController.isHasPermission(
      module: Modules.settings,
      section: SettingsPermissionsSections.settings,
      permission: SettingsPermissions.notification,
    );

    // Restricted Location. Unlike the gated menu entries above this does not
    // hide an existing menu entry — it gates a device behaviour, so it gets
    // its own switch tile in System Preferences below and the permission
    // decides whether the employee may see and change it.
    //
    // REMOVED 31/8/2026 — the `hasScreenShot` / `hasScreenShare` permission
    // lookups. Their tiles are gone from System Preferences (see below), so
    // the lookups had no reader left. SettingsPermissions.takeScreenShot and
    // .screenShare still exist on the role side; re-add the lookups here if
    // the tiles ever come back.
    // CHANGED 28/9/2026 — Restricted Location is no longer an employee
    // setting. The switch and its country picker moved to the role editor's
    // third page (Edit Role Settings Permissions, `settings_switches_page.dart`)
    // and are enforced for everyone holding that role by
    // `RestrictedLocationGuard`. The tile below is therefore never shown; the
    // branch is left in place only so this change stays a one-line revert.
    const bool hasRestrictedLocation = false;

    // NOTE: every hasX in this method that is hardcoded `true` is NOT
    // permission-gated. The gated ones are Company Information, Branding,
    // Notification, Haptic, Animation, Biometrics, Restricted Location,
    // Watermark and Comments and Feedbacks — nine of the eleven
    // SettingsPermissions, in the order the role page lists them. The other
    // two, Screen Share and Take Screen Shot, no longer have a row here (their
    // tiles were removed on 31/8/2026); they gate the device policy instead.
    // ADDED 9/10/2026: Social Information is also gated, but by a Social
    // Permissions switch (Share_Social_Information), not a SettingsPermission.
    // If one of these items goes missing, the cause is the role: no 'settings'
    // module access, or that flag turned off on the Edit Role Settings
    // Permissions screen.

    final lightMode = themeController.currentTheme.value.brightness == Brightness.light;
    var isArabic = Localizations.localeOf(context).languageCode == 'ar';

    // **FIXED: Use theme controller instead of context for theme**
    return Container(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [


          isMobile ?  SizedBox(height: 50.sp):  SizedBox(height: 20.h),

          // ADDED 8/9/2026 — the page title, mobile only.
          //
          // Every other mobile page in the app gets its name from
          // SideFrameMasterServices, which draws a breadcrumb row above its
          // content. This page does not use that frame — it is pushed straight
          // as SettingsScreen -> SettingsLayout — so it opened with the profile
          // card at the top and nothing naming the screen.
          //
          // Tablet is unaffected: there the settings menu sits in the left
          // column of a two-pane layout whose right pane already carries the
          // page title, so a second "Settings" heading would just repeat it.
          //
          // Same style as the frame's own title (fontSize24Weight600) so the
          // heading matches the pages this list pushes to.
          //
          // BACK CHEVRON ADDED 8/9/2026 — same asset, rotation and pop as
          // SideFrameMasterServices uses, so this row reads as the frame's
          // breadcrumb even though the page does not use the frame. It renders
          // only when there is something to pop: reached from the app-bar gear
          // this page sits on the tab's navigator and can go back, but if it
          // ever becomes a tab root the chevron would be dead, and a back
          // button that does nothing is worse than none.
          if (isMobile) ...<Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.sp),
              child: Row(
                children: <Widget>[
                  if (Navigator.of(context).canPop()) ...<Widget>[
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        HapticController.low(); // top-of-page navigation
                        Navigator.of(context).maybePop();
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.sp),
                        child: Transform.rotate(
                          // The asset points right; in LTR "back" is left.
                          angle: isArabic ? 0 : 3.1416,
                          child: SvgPicture.asset(
                            'assets/icons_assets/main_icons_assets/chevron_right.svg',
                            width: 24.sp,
                            height: 24.sp,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.sp),
                  ],
                  Expanded(
                    child: Text(
                      FormatHelper.capitalize(S.of(context).settings),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: StyleText.fontSize24Weight600
                          .copyWith(color: AppColors.text),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 0.sp),
          ],

          SettingsAppBar(
            startDate: settingsController.employee?.firstLogin,
            superVisor: settingsController.employee?.supervisor?.lastOrNull,
            image: settingsController.employee?.photo?.lastOrNull,
            name: _getEmployeeName(),
            role: settingsController.employee?.role?.lastOrNull?.capitalize ?? '',
          ),
          isMobile ? SizedBox(height: 10.sp)  : SizedBox(height: orientation ? 0.05.h : 0.02.h),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                    child: SingleChildScrollView(
                      child: Container(

                        child: Padding(
                          padding: EdgeInsets.only(
                            left:isArabic ? isMobile ? 10.sp : 0.sp : 10.w,
                            right: isArabic ?  10.w :isMobile ? 10.sp : 0.w,
                          ),
                          child: Column(
                            children: [
                              // First Section (Figma order): Personal
                              // Information, Health Insurance, Social
                              // Information, Requests.
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 0.h),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    color: AppColors.background,
                                    child: Column(
                                      children: [
                                        if (hasPersonalInfo)
                                          Container(

                                            color: settingsController.selectedContainerIndex == 0
                                                ? lightMode ?  AppColors.primary.withOpacity(.1) :  AppColors.primary.withOpacity(.08)
                                                : AppColors.card,
                                            child: CustomCard(
                                              name: S.of(context).personalInformation,
                                              icon: SvgPicture.asset(
                                                  width: 15.w,
                                                  height: 15.h,
                                                  fit: BoxFit.fill,
                                                  'assets/icons_assets/settings_assets/employee_id_card.svg',
                                                  color: settingsController.selectedContainerIndex == 0
                                                      ? AppColors.secondaryPrimary
                                                      : AppColors.secondaryPrimary
                                              ),
                                              index: 0,
                                              selectIndex: settingsController.selectedContainerIndex,
                                              isSelected: settingsController.selectedContainerIndex == 0,
                                              onTap: isMobile
                                                  ? () {
                                                _open(context, Routes.settingsPersonalInfo);
                                              }
                                                  : null, // Null for tablet - will use default selection behavior
                                            ),
                                          ),
                                        if (hasHealthInsurance)
                                          Container(
                                            color: settingsController.selectedContainerIndex == 10
                                                ? lightMode ?  AppColors.primary.withOpacity(.1) :  AppColors.primary.withOpacity(.08)
                                                : AppColors.card,
                                            child: CustomCard(
                                              name: S.of(context).healthInsurance,
                                              icon: SvgPicture.asset(
                                                  width: 20.w,
                                                  height:  18.h,
                                                  fit: BoxFit.fill,
                                                  'assets/icons_assets/main_icons_assets/health_insurance_card.svg',
                                                  color: settingsController.selectedContainerIndex == 10
                                                      ? AppColors.secondaryPrimary
                                                      : AppColors.secondaryPrimary
                                              ),
                                              index: 10,
                                              selectIndex: settingsController.selectedContainerIndex,
                                              onTap: isMobile
                                                  ? () => _open(context, Routes.settingsHealthInsurance)
                                                  : null,
                                            ),
                                          ),
                                        if (hasSocialInfo)
                                          Container(
                                            color: settingsController.selectedContainerIndex == 12
                                                ? lightMode ?  AppColors.primary.withOpacity(.1) :  AppColors.primary.withOpacity(.08)
                                                : AppColors.card,
                                            child: CustomCard(
                                              name: S.of(context).socialInformation,
                                              icon: SvgPicture.asset(
                                                  width: 20.w,
                                                  height:  18.h,
                                                  fit: BoxFit.fill,
                                                  'assets/icons_assets/settings_assets/social_interests_person.svg',
                                                  color: settingsController.selectedContainerIndex == 12
                                                      ? AppColors.secondaryPrimary
                                                      : AppColors.secondaryPrimary
                                              ),
                                              index: 12,
                                              selectIndex: settingsController.selectedContainerIndex,
                                              onTap: isMobile
                                                  ? () => _open(context, Routes.settingsSocial)
                                                  : null,
                                            ),
                                          ),
                                        if (hasRequests)
                                          Container(
                                            color: settingsController.selectedContainerIndex == 13
                                                ? lightMode ?  AppColors.primary.withOpacity(.1) :  AppColors.primary.withOpacity(.08)
                                                : AppColors.card,
                                            child: CustomCard(
                                              name: S.of(context).requests,
                                              icon: SvgPicture.asset(
                                                  width: 20.w,
                                                  height:  18.h,
                                                  fit: BoxFit.fill,
                                                  'assets/icons_assets/settings_assets/requests_edit_document.svg',
                                                  color: settingsController.selectedContainerIndex == 13
                                                      ? AppColors.secondaryPrimary
                                                      : AppColors.secondaryPrimary
                                              ),
                                              index: 13,
                                              selectIndex: settingsController.selectedContainerIndex,
                                              onTap: isMobile
                                                  ? () => _open(context, Routes.settingsRequests)
                                                  : null,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: 7.h),

                              // Second Section (Figma order): Company
                              // Information, Home Layout, Branding and Theme,
                              // WaterMark.
                              //
                              // RESTORED 2/9/2026 — these four rows had been
                              // folded into the First Section on 31/8/2026 as a
                              // single flat eight-row card. The Figma settings
                              // frame draws them as their own group, separate
                              // from the profile rows above and the support
                              // rows below, so the card boundary is back and
                              // the row order now follows the design exactly:
                              // Home Layout BEFORE Branding and Theme, with
                              // Watermark last.
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 0.h),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    color: AppColors.background,
                                    child: Column(
                                      children: [
                                        if (hasCompanyInfo)
                                          Container(
                                            color: settingsController.selectedContainerIndex == 8
                                                ? lightMode ?  AppColors.primary.withOpacity(.1) :  AppColors.primary.withOpacity(.08)
                                                : AppColors.card,
                                            child: CustomCard(
                                              name: S.of(context).companyInformation,
                                              icon: SvgPicture.asset(
                                                  width: 20.w,
                                                  height:  18.h,
                                                  fit: BoxFit.fill,
                                                  'assets/icons_assets/settings_assets/company_information_cards.svg',
                                                  color: settingsController.selectedContainerIndex == 8
                                                      ? AppColors.secondaryPrimary
                                                      : AppColors.secondaryPrimary
                                              ),
                                              index: 8,
                                              selectIndex: settingsController.selectedContainerIndex,
                                              onTap: isMobile
                                                  ? () => _open(context, Routes.settingsCompanyInfo)
                                                  : null,
                                            ),
                                          ),
                                        if (hasHomeLayout)
                                          Container(
                                            color: settingsController.selectedContainerIndex == 15
                                                ? lightMode ?  AppColors.primary.withOpacity(.1) :  AppColors.primary.withOpacity(.08)
                                                : AppColors.card,
                                            child: CustomCard(
                                              onTap: () {
                                                _open(context, Routes.settingsHomeLayout);
                                              },
                                              name:  S.of(context).homeLayout,
                                              icon: SvgPicture.asset(
                                                width: 20.w,
                                                height:  18.h,
                                                fit: BoxFit.fill,
                                                'assets/icons_assets/settings_assets/home_layout_floorplan.svg',
                                                color: AppColors.secondaryPrimary,
                                              ),
                                              index: 15,
                                              selectIndex: settingsController.selectedContainerIndex,
                                            ),
                                          ),
                                        if (hasBrandingTheme)
                                          Container(
                                            color: settingsController.selectedContainerIndex == 14
                                                ? lightMode ?  AppColors.primary.withOpacity(.1) :  AppColors.primary.withOpacity(.08)
                                                : AppColors.card,
                                            child: CustomCard(
                                              name: S.of(context).brandingAndTheme,
                                              icon: SvgPicture.asset(
                                                  width: 20.w,
                                                  height:  18.h,
                                                  fit: BoxFit.fill,
                                                  'assets/icons_assets/settings_assets/branding_theme_badge.svg',
                                                  color: settingsController.selectedContainerIndex == 14
                                                      ? AppColors.secondaryPrimary
                                                      : AppColors.secondaryPrimary
                                              ),
                                              index: 14,
                                              selectIndex: settingsController.selectedContainerIndex,
                                              onTap: isMobile
                                                  ? () => _open(context, Routes.settingsBrandingAndTheme)
                                                  : null,
                                            ),
                                          ),
                                        // ADDED 25/8/2026 — Settings > Home
                                        // Layout > Watermark (Figma
                                        // 7524:14303). Sits directly under
                                        // Home Layout because it configures
                                        // what is drawn OVER the layout.
                                        //
                                        // CHANGED 31/8/2026 — always pushes a
                                        // full route, exactly like Home Layout
                                        // (index 15) directly above it. The
                                        // Figma frame (4717:8596) is a full
                                        // 1024-wide page — a 280 controls
                                        // column PLUS a preview pane wide
                                        // enough to read a tiled stamp.
                                        // Squeezed into the settings right-hand
                                        // panel the preview collapsed and the
                                        // design stopped being legible. A
                                        // watermark you cannot see is a
                                        // watermark you cannot tune.
                                        //
                                        // CHANGED 31/8/2026 — gated by its own
                                        // `hasWatermark` permission. It used to
                                        // ride on `hasHomeLayout`, which is
                                        // hardcoded true, so the row was
                                        // unhideable.
                                        //
                                        // `onTap` is unconditional, so `index`
                                        // is now only used for the pressed
                                        // highlight — nothing renders against
                                        // selectedContainerIndex == 18 any more.
                                        if (hasWatermark)
                                          Container(
                                            color: settingsController.selectedContainerIndex == 18
                                                ? lightMode ?  AppColors.primary.withOpacity(.1) :  AppColors.primary.withOpacity(.08)
                                                : AppColors.card,
                                            child: CustomCard(
                                              onTap: () {
                                                _open(context, Routes.settingsWatermark);
                                              },
                                              name: S.of(context).watermark,
                                              icon: SvgPicture.asset(
                                                width: 20.w,
                                                height: 18.h,
                                                fit: BoxFit.fill,
                                                'assets/icons_assets/watermark/Group.svg',
                                                color: AppColors.secondaryPrimary,
                                              ),
                                              index: 18,
                                              selectIndex: settingsController.selectedContainerIndex,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // Third Section (Figma order): Language, Comments
                              // and Feedbacks, About This App, Privacy
                              // Statement, Terms and Conditions.
                              //
                              // CHANGED 2/9/2026 — Privacy Statement now sits
                              // ABOVE Terms and Conditions, which is the order
                              // the Figma settings frame lists them in. The
                              // code had them the other way round.
                              //
                              // FIXED 23/8/2026: the five rows below took the
                              // dark-mode selected background from
                              // `AppColors.background` while the First and
                              // Second sections both use
                              // `AppColors.primary.withOpacity(.08)`. That made
                              // a selected row here read as a plain page-coloured
                              // block instead of the tinted highlight the rest of
                              // the list uses — and in dark mode `background` is
                              // close enough to `card` that the selection was
                              // barely visible at all. All five now match.
                              SizedBox(height: 7.h),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 0.h),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    color: AppColors.card,
                                    child: Column(
                                      children: [
                                        if (hasLanguage)
                                          Container(
                                            color: settingsController.selectedContainerIndex == 2
                                                ? lightMode ?  AppColors.primary.withOpacity(.1) :  AppColors.primary.withOpacity(.08)
                                                : AppColors.card,
                                            child: CustomCard(
                                              icon: SvgPicture.asset(
                                                  width: 20.w,
                                                  height:  18.h,
                                                  fit: BoxFit.fill,
                                                  'assets/icons_assets/settings_assets/language_translate_bubbles.svg',
                                                  color: settingsController.selectedContainerIndex == 2
                                                      ? AppColors.secondaryPrimary
                                                      : AppColors.secondaryPrimary
                                              ),
                                              name: S.of(context).language,
                                              index: 2,
                                              selectIndex: settingsController.selectedContainerIndex,
                                              onTap: isMobile
                                                  ? () => _open(context, Routes.settingsLanguage)
                                                  : null,
                                            ),
                                          ),
                                        if (hasCommentsAndFeedbacks)
                                          Container(
                                            color: settingsController.selectedContainerIndex == 4
                                                ? lightMode ?  AppColors.primary.withOpacity(.1) :  AppColors.primary.withOpacity(.08)
                                                : AppColors.card,
                                            child: CustomCard(
                                              icon: SvgPicture.asset(
                                                  'assets/icons_assets/settings_assets/feedback_stamp.svg',
                                                  width: 20.w,
                                                  height:  18.h,
                                                  fit: BoxFit.fill,
                                                  color: settingsController.selectedContainerIndex == 4
                                                      ? AppColors.secondaryPrimary
                                                      : AppColors.secondaryPrimary
                                              ),
                                              name: S.of(context).commentsAndFeedbacks,
                                              index: 4,
                                              selectIndex: settingsController.selectedContainerIndex,
                                              onTap: isMobile
                                                  ? () => _open(context, Routes.settingsCommentsAndFeedback)
                                                  : null,
                                            ),
                                          ),
                                        if (hasAboutApp)
                                          Container(
                                            color: settingsController.selectedContainerIndex == 5
                                                ? lightMode ?  AppColors.primary.withOpacity(.1) :  AppColors.primary.withOpacity(.08)
                                                : AppColors.card,
                                            child: CustomCard(
                                              icon: SvgPicture.asset(
                                                  'assets/icons_assets/settings_assets/about_app_info_book.svg',
                                                  width: 20.w,
                                                  height:  18.h,
                                                  fit: BoxFit.fill,
                                                  color: settingsController.selectedContainerIndex == 5
                                                      ? AppColors.secondaryPrimary
                                                      : AppColors.secondaryPrimary
                                              ),
                                              name: FormatHelper.capitalize(S.of(context).aboutThisPlatform),
                                              index: 5,
                                              selectIndex: settingsController.selectedContainerIndex,
                                              onTap: isMobile
                                                  ? () => _open(context, Routes.settingsAboutThisApp)
                                                  : null,
                                            ),
                                          ),
                                        if (hasPrivacyStatement)
                                          Container(
                                            color: settingsController.selectedContainerIndex == 16
                                                ? lightMode ?  AppColors.primary.withOpacity(.1) :  AppColors.primary.withOpacity(.08)
                                                : AppColors.card,
                                            child: CustomCard(
                                              icon: SvgPicture.asset(
                                                  'assets/icons_assets/settings_assets/privacy_clipboard_lock.svg',
                                                  width: 22.w,
                                                  height:  22.h,
                                                  fit: BoxFit.fill,
                                                  color: settingsController.selectedContainerIndex == 16
                                                      ? AppColors.secondaryPrimary
                                                      : AppColors.secondaryPrimary
                                              ),
                                              name: S.of(context).privacyStatement,
                                              index: 16,
                                              selectIndex: settingsController.selectedContainerIndex,
                                              onTap: isMobile
                                                  ? () => _open(context, Routes.settingsPrivacyStatement)
                                                  : null,
                                            ),
                                          ),
                                        if (hasTermsConditions)
                                          Container(
                                            color: settingsController.selectedContainerIndex == 6
                                                ? lightMode ?  AppColors.primary.withOpacity(.1) :  AppColors.primary.withOpacity(.08)
                                                : AppColors.card,
                                            child: CustomCard(
                                              icon: SvgPicture.asset(
                                                  'assets/icons_assets/settings_assets/terms_and_conditions_document.svg',
                                                  width: 20.w,
                                                  height:  18.h,
                                                  fit: BoxFit.fill,
                                                  color: settingsController.selectedContainerIndex == 6
                                                      ? AppColors.secondaryPrimary
                                                      : AppColors.secondaryPrimary
                                              ),
                                              name: S.of(context).termsAndConditions2,
                                              index: 6,
                                              selectIndex: settingsController.selectedContainerIndex,
                                              onTap: isMobile
                                                  ? () => _open(context, Routes.settingsTermsAndConditions)
                                                  : null,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // Fourth Section: System Preferences (Haptic Feedback, Biometrics, Dark Mode, Animation)
                              SizedBox(height: 0),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 7.h),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(

                                   color:  AppColors.card,
                                    child: Column(
                                      children: [
                                        if (hasHaptic)
                                          CustomCard(
                                            icon: Center(
                                              child: SvgPicture.asset(
                                                'assets/icons_assets/settings_assets/haptic_vibration_phone.svg',
                                                width: 20.w,
                                                height:  18.h,
                                                fit: BoxFit.fill,
                                                color: AppColors.secondaryPrimary,
                                              ),
                                            ),
                                            name: S.of(context).hapticFeedback,
                                            isSwitchTile: true,
                                            currentValue: hapticController.isHapticEnabled.value == true,
                                            onSwitchChanged: (Value) {
                                              hapticController.toggleHapticFeedback(Value);
                                              RestartWidget.restartApp(context);
                                            },
                                          ),
                                        if (hasBiometrics)
                                          CustomCard(
                                            icon: Center(
                                              child: SvgPicture.asset(
                                                'assets/icons_assets/settings_assets/biometrics_auth.svg',
                                                width: 20.w,
                                                height:  18.h,
                                                fit: BoxFit.fill,
                                                color: AppColors.secondaryPrimary,
                                              ),
                                            ),
                                            name: S.of(context).biometrics,
                                            isSwitchTile: true,
                                            currentValue: biometricController.isBiometricEnabled.value == true,
                                            onSwitchChanged: (Value) {
                                              hapticController.triggerHapticFeedback(
                                                  vibration: VibrateType.mediumImpact,
                                                  hapticFeedback: HapticFeedback.mediumImpact
                                              );
                                              biometricController.toggleBiometricFeedback(Value);
                                              RestartWidget.restartApp(context);
                                            },
                                          ),
                                        CustomCard(
                                          icon: Center(
                                            child: SvgPicture.asset(
                                              'assets/icons_assets/settings_assets/dark_mode_toggle_moon.svg',
                                              width: 20.w,
                                              height:  18.h,
                                              fit: BoxFit.fill,
                                              color: AppColors.secondaryPrimary,
                                            ),
                                          ),
                                          name: S.of(context).darkMode,
                                          isSwitchTile: true,
                                          currentValue: themeController.currentTheme.value == AppColors.darkTheme,
                                          onSwitchChanged: (Value) {
                                            if (!mounted) return; // ✅ Add mounted check

                                            hapticController.triggerHapticFeedback(
                                                vibration: VibrateType.mediumImpact,
                                                hapticFeedback: HapticFeedback.mediumImpact
                                            );
                                            // Only toggle if the value actually changed
                                            bool isDarkMode = themeController.currentTheme.value == AppColors.darkTheme;
                                            if (Value != isDarkMode) {
                                              themeController.toggleTheme();
                                              // Consider removing RestartWidget if not necessary
                                              // RestartWidget.restartApp(context);
                                            }
                                          },
                                        ),
                                        if (hasAnimation)
                                          CustomCard(
                                            icon: Center(
                                              child: SvgPicture.asset(
                                                'assets/icons_assets/settings_assets/animation_motion_circles.svg',
                                                width: 20.w,
                                                height:  18.h,
                                                fit: BoxFit.fill,
                                                color: AppColors.secondaryPrimary,
                                              ),
                                            ),
                                            name: S.of(context).animation,
                                            isSwitchTile: true,
                                            currentValue: false,
                                            onSwitchChanged: (Value) {
                                              hapticController.triggerHapticFeedback(
                                                  vibration: VibrateType.mediumImpact,
                                                  hapticFeedback: HapticFeedback.mediumImpact
                                              );
                                            },
                                          ),
                                        // ADDED 31/8/2026 — Notification. Last
                                        // row of this card in the Figma frame,
                                        // directly under Animation. It stores a
                                        // preference and nothing more: see the
                                        // SCOPE note in NotificationController.
                                        if (hasNotification)
                                          CustomCard(
                                            icon: Center(
                                              child: SvgPicture.asset(
                                                'assets/icons_assets/settings_assets/notification_announcement.svg',
                                                width: 20.w,
                                                height: 18.h,
                                                fit: BoxFit.fill,
                                                color: AppColors.secondaryPrimary,
                                              ),
                                            ),
                                            name: S.of(context).notification,
                                            isSwitchTile: true,
                                            currentValue: notificationController
                                                .isNotificationEnabled.value,
                                            onSwitchChanged: (Value) {
                                              hapticController.triggerHapticFeedback(
                                                  vibration: VibrateType.mediumImpact,
                                                  hapticFeedback: HapticFeedback.mediumImpact
                                              );
                                              notificationController
                                                  .toggleNotification(Value);
                                            },
                                          ),
                                        // REMOVED 31/8/2026 — the "Take Screen
                                        // Shot" switch tile. The device policy
                                        // itself (devicePolicyController
                                        // .toggleScreenShot / isScreenShotEnabled)
                                        // is untouched and still applied; only
                                        // the user-facing tile is gone.
                                        //
                                        // Restricted Location is not in the
                                        // Figma frame either, so it keeps its
                                        // place at the end of this card, after
                                        // Notification.
                                        //
                                        // Obx, unlike the switches above it:
                                        // the country picker has to appear and
                                        // disappear with the toggle, and the
                                        // tile's own internal state does not
                                        // rebuild this Column.
                                        if (hasRestrictedLocation)
                                          Obx(
                                            () => Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                CustomCard(
                                                  icon: Center(
                                                    child: SvgPicture.asset(
                                                      'assets/icons_assets/settings_assets/location_city_pin.svg',
                                                      width: 20.w,
                                                      height: 18.h,
                                                      fit: BoxFit.fill,
                                                      color: AppColors.secondaryPrimary,
                                                    ),
                                                  ),
                                                  name: S.of(context).restrictedLocation,
                                                  isSwitchTile: true,
                                                  currentValue: devicePolicyController
                                                      .isRestrictedLocationEnabled.value,
                                                  onSwitchChanged: (Value) {
                                                    hapticController.triggerHapticFeedback(
                                                        vibration: VibrateType.mediumImpact,
                                                        hapticFeedback: HapticFeedback.mediumImpact
                                                    );
                                                    devicePolicyController
                                                        .toggleRestrictedLocation(Value);
                                                  },
                                                ),
                                                // Which countries the app may be
                                                // opened from. Only meaningful
                                                // while the restriction is on.
                                                if (devicePolicyController
                                                    .isRestrictedLocationEnabled.value)
                                                  RestrictedLocationCountries(
                                                    controller: devicePolicyController,
                                                  ),
                                              ],
                                            ),
                                          ),
                                        // REMOVED 31/8/2026 — the "Screen Share"
                                        // switch tile, same as Take Screen Shot
                                        // above: the policy still runs, the
                                        // tile is no longer shown.
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                isMobile ?  SizedBox() :  Container(

                  width: orientation ? 0.5.w : 0.58.w,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r)
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                        right: Get.locale.toString().contains('en') ? 0.01.h : 10.w,
                        left: 10.w,
                        top: orientation
                            ? Get.locale.toString().contains('en') ? 6 : 18
                            : 2),
                    // Exactly one of these branches renders at a time, and each
                    // is a full settings page. They must be Expanded: the
                    // Column has a bounded height here, so a page that sizes
                    // itself (e.g. MyRequestPage's fixed SizedBox height) can
                    // come out a few pixels taller than the space available and
                    // overflow. Expanded hands each page a tight height instead
                    // of letting it pick its own.
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        if (settingsController.selectedContainerIndex == 0 && hasPersonalInfo)
                          const Expanded(child: PersonalInfoScreen()),
                        if (settingsController.selectedContainerIndex == 2 && hasLanguage)
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.r)
                              ),
                              width: double.infinity,
                              child: const LanguageScreen(),
                            ),
                          ),
                        if (settingsController.selectedContainerIndex == 4 && hasCommentsAndFeedbacks)
                          const Expanded(child: CommentsAndFeedbackScreen()),
                        if (settingsController.selectedContainerIndex == 5 && hasAboutApp)
                          const Expanded(child: AboutThisAppScreen()),
                        if (settingsController.selectedContainerIndex == 6 && hasTermsConditions)
                          const Expanded(child: TermsConditions()),
                        if (settingsController.selectedContainerIndex == 8 && hasCompanyInfo)
                          Expanded(child: CompanyScreenInfo()),
                        if (settingsController.selectedContainerIndex == 9)
                          Expanded(child: Container()),
                        if (settingsController.selectedContainerIndex == 10 && hasHealthInsurance)
                          Expanded(child: SettingsHealthInsurance()),
                        if (settingsController.selectedContainerIndex == 12 && hasSocialInfo)
                          Expanded(child: SocialScreen()),
                        if (settingsController.selectedContainerIndex == 13 && hasRequests)
                          Expanded(child: MyRequestPage()),
                        if (settingsController.selectedContainerIndex == 14 && hasBrandingTheme)
                          Expanded(child: CompanyInfoScreen()),
                        if (settingsController.selectedContainerIndex == 16 && hasPrivacyStatement)
                          const Expanded(child: PrivacyStatementPage()),

                        // ✅ FIXED: Wrapped with Expanded and SingleChildScrollView
                        if (settingsController.selectedContainerIndex == 17)
                          Expanded(
                            child: SingleChildScrollView(
                              child: const EmployeeBrandingScreen(),
                            ),
                          ),

                        // REMOVED 31/8/2026 — the Watermark right-hand panel.
                        //
                        // Watermark is a pushed page now (Routes.settingsWatermark),
                        // the same as Home Layout above it. Leaving this branch in
                        // would give the screen two homes: tapping the card would
                        // push the route AND arm this panel behind it, so popping
                        // back landed on a second copy of the screen instead of the
                        // settings list. The `const Expanded(child: WatermarkScreen())`
                        // that lived here is gone; the route in get_pages.dart is the
                        // single entry point.
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}