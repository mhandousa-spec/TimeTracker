/// Module: knowledge_hub / core/settings/presentation/controller/settings_controller.dart
/// ************************* FILE INFO *************************** ///
/// File Name: settings_controller.dart
/// Purpose: Settings controller — knowledge_hub core/widgets.
/// Author: Knowticed Team
/// Created At: 11/10/2025

  import 'package:flutter/cupertino.dart';
  import 'package:flutter/material.dart';
  import 'package:get/get.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';





  class SettingsController extends GetxController {
    onInit() {
      super.onInit();
      isDarkMode = AppTheme.isDark.obs;
    }

    late RxBool isDarkMode;
    bool isEnglish = true;
    bool isAnimated = false;

    toggleTheme(BuildContext context) async {
      AppTheme.toggleTheme();
      isDarkMode.value = AppTheme.isDark;
      update();

      // call restart widget to apply theme changes
      // Get.changeThemeMode(isDarkMode ? ThemeMode.dark : ThemeMode.light);
    }

    void toggleLanguage() {
      if (isEnglish) {
        Get.updateLocale(const Locale('ar', 'EG'));
      } else {
        Get.updateLocale(const Locale('en', 'US'));
      }
      isEnglish = !isEnglish;
    }

    toggleAnimation() {
      isAnimated = !isAnimated;
      //AppTheme.toggleAnimation();
    }

    void updateSecondaryColor(Color color) {
      AppTheme.interfaceUpdateBrandingColors(AppColors.primary, color );
      setCurrentThemeColors();
    }

    void updatePrimaryColor(Color color) {
      AppTheme.interfaceUpdateBrandingColors(color, AppColors.secondaryPrimary);
      Get.forceAppUpdate();
    }

    static void setCurrentThemeColors() {
      AppColors.currentThemeColors = AppTheme.isDark ? AppTheme.darkThemeColors : AppTheme.lightThemeColors;
      Get.changeTheme(AppTheme.isDark ? AppTheme.darkTheme : AppTheme.lightTheme);
      Get.forceAppUpdate(); // ✅ this is the key
    }
  }
