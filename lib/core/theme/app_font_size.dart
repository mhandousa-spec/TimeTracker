/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: app_font_size.dart
/// Purpose: Declares `FontConstants`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'dart:math';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import './app_theme.dart';

class FontConstants {
  // Uses StyleText which reads from storage, same as AppColors.font
  static String get cairoFontFamily => StyleText.englishFontFamily;

  static double fontSize07 = 0.007;
  static double fontSize09 = 0.009;
  static double fontSize010 = 0.010;
  static double fontSize011 = 0.011;
  static double fontSize012 = 0.012;
  static double fontSize013 = 0.013;
  static double fontSize014 = 0.014;
  static double fontSize015 = 0.015;
  static double fontSize016 = 0.016;
  static double fontSize017 = 0.017;
  static double fontSize018 = 0.018;
  static double fontSize019 = 0.019;
  static double fontSize020 = 0.020;
  static double fontSize021 = 0.021;
  static double fontSize022 = 0.022;
  static double fontSize023 = 0.023;
  static double fontSize024 = 0.024;
  static double fontSize025 = 0.025;
  static double fontSize026 = 0.026;
  static double fontSize027 = 0.027;
  static double fontSize028 = 0.028;
  static double fontSize029 = 0.029;
  static double fontSize030 = 0.030;
  static double fontSize031 = 0.031;
  static double fontSize032 = 0.032;
  static double fontSize033 = 0.033;
  static double fontSize035 = 0.035;
  static double fontSize036 = 0.036;
  static double fontSize037 = 0.037;
  static double fontSize038 = 0.038;
  static double fontSize040 = 0.040;
  static double fontSize043 = 0.043;
  static double fontSize045 = 0.045;
  static double fontSize050 = 0.050;
  static double fontSize055 = 0.055;
  static double fontSize057 = 0.057;
  static double fontSize060 = 0.060;
}
class AppFontStyle {
  static TextStyle cairoRegularStyle = TextStyle(
    color: Colors.black,
    fontFamily: Get.locale.toString().contains('ar')
        ? storage.read('font_arabic') ?? 'Vazirmatn'
        : storage.read('font') ?? 'Cairo',
    fontWeight: FontWeight.normal,
    fontSize: 17,
  );
}
extension ScreenSizeExtension on double {
  double get r {
    return min(Get.height, Get.width) * this;
  }

  double get w {
    return Get.width * this;
  }

  double get h {
    return Get.height * this;
  }
}