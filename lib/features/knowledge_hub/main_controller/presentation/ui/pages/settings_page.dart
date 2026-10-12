/// Module: knowledge_hub_module / core/settings/presentation/ui/pages/settings_page.dart
/// ************************* FILE INFO *************************** ///
/// File Name: settings_page.dart
/// Purpose: Settings page — knowledge_hub_module core/widgets.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';

// MIGRATED 12/9/2026 — this page hand-rolled its own back-arrow + title row
// (`_buildAppBar`, now removed). Every other page in the module wears the
// app-wide frame, so this one does too: same fixed header, same back chevron,
// same title size and side padding on a phone.
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../settings/utils/color_palette.dart';
import '../settings/utils/fonts_lists.dart';
import '../../controller/settings_controller.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  SettingsController settingsController = Get.find<SettingsController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SideFrameMasterServices(
          titleText: S.of(context).knowledge_hub,
          secondTitle: "Settings".tr,
          onFirstTap: () => Navigator.of(context).pop(),
          // The frame supplies the side padding (15.sp) and, on a phone, the
          // scroll view's outer column — the page's own EdgeInsets.all(16) is
          // gone so this page is inset exactly like every other one.
          child: SingleChildScrollView(
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10.h,
            children: [
              Row(
                children: [
                  Text("Dark Mode",
                      style: StyleText.fontSize16Weight400),
                  Spacer(),
                  FlutterSwitch(
                    value: settingsController.isDarkMode.value,
                    onToggle: (_) {
                      settingsController.toggleTheme(context);
                    },
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
              Row(
                children: [
                  Text("Language",
                      style: StyleText.fontSize16Weight400),
                  Spacer(),
                  FlutterSwitch(
                    value: settingsController.isEnglish,
                    onToggle: (_) {
                      setState(() {});
                      settingsController.toggleLanguage();
                    },
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
              Row(
                children: [
                  Text("Animation",
                      style: StyleText.fontSize16Weight400),
                  //  horizontalSpace(16.w),
                  Spacer(),
                  FlutterSwitch(
                    value: settingsController.isAnimated,
                    onToggle: (_) {
                      setState(() {});

                      settingsController.toggleAnimation();
                    },
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
              SizedBox(height: 10.sp),
              Text("Colors", style: StyleText.fontSize16Weight400),
              Text('Primary Color',style: StyleText.fontSize16Weight400),
              Wrap(
                  spacing: 10.w,
                  runSpacing: 10.h,
                  children: List.generate(
                      ColorPallet.colors.length,
                      (index) => InkWell(
                            onTap: () {
                              settingsController.updatePrimaryColor(
                                  ColorPallet.colors[index]);
                            },
                            splashColor: AppColors.transparent,
                            child: CircleAvatar(
                              radius: 16.sp,
                              backgroundColor: ColorPallet.colors[index],
                            ),
                          ))),
              Text('Secondary Color', style: StyleText.fontSize16Weight400),
              Wrap(
                  spacing: 10.w,
                  runSpacing: 10.h,
                  children: List.generate(
                      ColorPallet.colors.length,
                      (index) => InkWell(
                            onTap: () {
                              settingsController.updateSecondaryColor(
                                  ColorPallet.colors[index]);
                            },
                            splashColor: AppColors.transparent,
                            child: CircleAvatar(
                              radius: 16.sp,
                              backgroundColor: ColorPallet.colors[index],
                            ),
                          ))),
              Text("Fonts", style: StyleText.fontSize16Weight400),
              Text('English Fonts', style: StyleText.fontSize16Weight400),
              Wrap(
                  spacing: 10.w,
                  runSpacing: 10.h,
                  children: List.generate(
                      FontsLists.englishList.length,
                      (index) => InkWell(
                            onTap: () {
                              // StyleText.englishFontFamily =
                              //     FontsLists.englishList[index];
                              // Get.forceAppUpdate();
                            },
                            splashColor: AppColors.transparent,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 8.h, horizontal: 16.w),
                              decoration: BoxDecoration(
                                  color: AppColors.card,
                                  borderRadius: BorderRadius.circular(10.r)),
                              child: Text(FontsLists.englishList[index],
                                  style: StyleText.fontSize16Weight400),
                            ),
                          ))),
              Text('Arabic Fonts'.tr, style: StyleText.fontSize16Weight400),
              Wrap(
                  spacing: 10.w,
                  runSpacing: 10.h,
                  children: List.generate(
                      FontsLists.arabicList.length,
                          (index) => InkWell(
                        onTap: () {
                          // StyleText.arabicFontFamily =
                          // FontsLists.arabicList[index];
                          // Get.forceAppUpdate();
                        },
                        splashColor: AppColors.transparent,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 8.h, horizontal: 16.w),
                          decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(10.r)),
                          child: Text(FontsLists.arabicList[index],
                              style: StyleText.fontSize16Weight400),
                        ),
                      ))),
            ],
          ),
          ),
        ),
      ),
    );
  }
}
/*

// settings_localization.dart
class SettingsLocalization {
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'Settings': 'Settings',
      'Dark Mode': 'Dark Mode',
      'Language': 'Language',
      'Animation': 'Animation',
      'Colors': 'Colors',
      'Primary Color': 'Primary Color',
      'Secondary Color': 'Secondary Color',
      'Fonts': 'Fonts',
      'English Fonts': 'English Fonts',
      'Arabic Fonts': 'Arabic Fonts',
    },
    'ar': {
      'Settings': 'الإعدادات',
      'Dark Mode': 'الوضع الليلي',
      'Language': 'اللغة',
      'Animation': 'الحركات',
      'Colors': 'الألوان',
      'Primary Color': 'اللون الأساسي',
      'Secondary Color': 'اللون الثانوي',
      'Fonts': 'الخطوط',
      'English Fonts': 'خطوط الإنجليزية',
      'Arabic Fonts': 'خطوط العربية',
    },
  };



*
* */