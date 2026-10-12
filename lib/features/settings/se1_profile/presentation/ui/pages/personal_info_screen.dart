/// Module: settings/se1_profile
///
///*************************** FILE INFO ****************************///
/// File Name: personal_info_screen.dart
/// Purpose: Responsive personal-information screen (phone + tablet in one page).
/// Author: Amr Mesbah
/// Created at: 11/11/2024
/// Updated: 11/8/2026 - CR-SKEL-SE1-N10/N11: the `section` / `whatChanged` /
///          `hapticController` library-scope globals moved into the State, the
///          `isEnglish` field computed from `Get.locale` is gone, and the
///          hardcoded "Personal Information" title now comes from S.of(context).
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/37-custom_navigate.dart';
import 'package:knowticed_plus/features/settings/se1_profile/presentation/ui/widgets/fields/personal_information_fields.dart';
import 'package:knowticed_plus/features/settings/se6_requests/presentation/ui/pages/edit_page_request.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PersonalInfoScreenState createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  /// Was `Get.put(HapticController())` at library scope, so importing this file
  /// registered a controller as a side effect (CR-SKEL-SE1-N10).
  final HapticController _hapticController = Get.put(HapticController());

  @override
  Widget build(BuildContext context) {
    return ContextExtension(context).isPhone
        ? _buildPhone(context)
        : _buildTablet(context);
  }

  /// Phone design (formerly mobile_personal_info_screen.dart)
  Widget _buildPhone(BuildContext context) {
    // SideFrameMasterServices supplies the mobile Scaffold, the breadcrumb
    // header (back chevron + page title) and the scroll view, so this method
    // only provides the page body.
    return SideFrameMasterServices(
      titleText: S.of(context).settings,
      onFirstTap: () => Navigator.of(context).maybePop(),
      secondTitle: S.of(context).personalInformation,
      child: Column(
                  children: [
                    Container(
                        child: const PersonalInformationFields()),
                    SizedBox(height: ContextExtension(context).isPhone ?  15.sp : 0.sp),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        customButtonWithSvg(
                          // `fixedWidth`, not `width`: `width:` is accepted and
                          // ignored by customButtonWithSvg so the app-wide
                          // ButtonSizing rule wins over the stale `width:`
                          // arguments left at dozens of call sites.
                          // `fixedWidth` is the opt-in override.
                          fixedWidth: 200.sp,
                          title: S.of(context).requestToChange,
                          function: () {
                            _hapticController.triggerHapticFeedback(
                                vibration: VibrateType.mediumImpact,
                                hapticFeedback: HapticFeedback.mediumImpact);
                            navigateTo(context, EditPageRequest());
                          },
                          color: AppColors.primary,
                          colorBorder: AppColors.transparent,
                          textStyle: StyleText.fontSize16Weight500
                              .copyWith(color: AppColors.textButton),
                          image: 'assets/icons_assets/settings_assets/request_change_document.svg',
                          svgColor: AppColors.textButton,
                          widthImage: 16.w,
                          heightImage: 23.h,
                        ),
                      ],
                    ),
                    SizedBox(height: ContextExtension(context).isPhone ?  15.sp : 0.sp),
                  ],
                ),
    );
  }

  /// Tablet design (formerly tablet_personal_info_screen.dart)
  Widget _buildTablet(BuildContext context) {
    // Was wrapped in GetBuilder<RequestController>, whose only purpose was to
    // rebuild on RequestController.update(). Those calls came from the four
    // write methods, which were unreachable and are now deleted
    // (CR-SKEL-SE6-N09), so the wrapper rebuilt on nothing.
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8),
          ),
          height: 470.h,
          clipBehavior: Clip.antiAlias,
          child: ScrollConfiguration(
            behavior: const ScrollBehavior().copyWith(scrollbars: false),
            child: SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [PersonalInformationFields()],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 15.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            customButtonWithSvg(
              // Was `width: 220.sp`, which customButtonWithSvg ignores — the
              // button actually rendered at the 135.sp tablet default.
              fixedWidth: 250.w,
              title: S.of(context).requestToChange,
              function: () {
                _hapticController.triggerHapticFeedback(
                    vibration: VibrateType.heavyImpact,
                    hapticFeedback: HapticFeedback.heavyImpact);
                navigateTo(context, EditPageRequest());
              },
              color: AppColors.primary,
              colorBorder: AppColors.transparent,
              textStyle: StyleText.fontSize16Weight500
                  .copyWith(color: AppColors.textButton),
              image: 'assets/icons_assets/settings_assets/request_change_document.svg',
              svgColor: AppColors.textButton,
              widthImage: 16,
              heightImage: 23,
            ),
          ],
        ),
      ],
    );
  }
}
