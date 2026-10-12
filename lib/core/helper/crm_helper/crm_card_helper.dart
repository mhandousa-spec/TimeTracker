// ****************** FILE INFO ******************
// File Name: crm_card_helper.dart
// Purpose: Shared helper for CRM cards (creator name resolution, metadata row, status chip)
// Author: Mohand Adel
// Created At: 16/08/2026

import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

abstract class CrmCardHelper {
  /// Resolves the human-readable employee name from email or raw identifier.
  static String resolveCreatorName(
    String updatedBy, {
    required bool isArabic,
  }) {
    if (updatedBy.trim().isEmpty) return '-';

    if (Get.isRegistered<MainCoreEmployeeController>()) {
      final MainCoreEmployeeController controller =
          Get.find<MainCoreEmployeeController>();
      final String employeeName = isArabic
          ? controller.getEmployeeNameEnglishArabic(
              updatedBy.trim().toLowerCase(),
              false,
            )
          : controller.getEmployeeName(updatedBy.trim().toLowerCase());
      final String normalizedName = employeeName.trim();
      if (normalizedName.isNotEmpty &&
          normalizedName.toLowerCase() != 'no name') {
        return normalizedName;
      }
    }

    return extractFirstAndLastName(updatedBy);
  }

  /// Extracts capitalized First and Last Name from email or identifier string.
  static String extractFirstAndLastName(String rawValue) {
    String normalized = rawValue.trim();
    if (normalized.contains('@')) {
      normalized = normalized.split('@').first;
    }
    normalized = normalized.replaceAll(RegExp(r'[._-]'), ' ');

    final List<String> words = normalized
        .split(' ')
        .map((String word) => word.trim())
        .where(
          (String word) => word.isNotEmpty && !RegExp(r'^\d+$').hasMatch(word),
        )
        .toList();

    if (words.isEmpty) return rawValue;

    final String firstName = FormatHelper.capitalize(words.first);
    if (words.length == 1) return firstName;

    final String lastName = FormatHelper.capitalize(words[1]);
    return '$firstName $lastName'.trim();
  }

  /// Builds the 3-column metadata row (Count, By, Last Update) for CRM cards.
  static Widget buildCardMetaRow({
    required BuildContext context,
    required String countLabel,
    required String countValue,
    required String countIcon,
    required String creator,
    required String lastUpdate,
    required bool isArabic,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          flex: 2,
          child: CardInfoRow(
            fontSize: 13.sp,
            info: CardInfo(
              label: countLabel,
              value: countValue,
              icon: CustomSvgImage(
                assetPath: countIcon,
                width: 14.sp,
                height: 14.sp,
                color: AppColors.black,
                fit: BoxFit.scaleDown,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: CardInfoRow(
            fontSize: 13.sp,
            info: CardInfo(
              label: isArabic ? 'بواسطة:' : 'By:',
              value: creator,
              icon: CustomSvgImage(
                assetPath: AppAssets.crmGroup,
                width: 14.sp,
                height: 14.sp,
                color: AppColors.black,
                fit: BoxFit.scaleDown,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: CardInfoRow(
            fontSize: 13.sp,
            info: CardInfo(
              label: isArabic ? 'آخر تحديث:' : 'Last Update:',
              value: lastUpdate,
              icon: CustomSvgImage(
                assetPath: AppAssets.timeSelectorIcon,
                width: 14.sp,
                height: 14.sp,
                color: AppColors.black,
                fit: BoxFit.scaleDown,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the positioned active/inactive status chip.
  static Widget buildPositionedStatusChip({
    required bool isActive,
    required bool isArabic,
  }) {
    return Positioned(
      top: 14.sp,
      left: isArabic ? 14.sp : null,
      right: isArabic ? null : 14.sp,
      child: buildInlineStatusChip(
        isActive: isActive,
        isArabic: isArabic,
      ),
    );
  }

  /// Builds an inline active/inactive status chip.
  static Widget buildInlineStatusChip({
    required bool isActive,
    required bool isArabic,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 4.sp),
      decoration: BoxDecoration(
        color: isActive ? AppColors.green : AppColors.orange,
        borderRadius: BorderRadius.circular(4.sp),
      ),
      child: Text(
        isActive
            ? (isArabic ? 'نشط' : 'Active')
            : (isArabic ? 'غير نشط' : 'Inactive'),
        style: StyleText.fontSize10Weight600.copyWith(color: Colors.white).copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Returns responsive cross-axis count for CRM grid cards:
  /// - Mobile (< 600px): 1 in a row
  /// - Medium / Tablet (600px – 1199px): 2 in a row
  /// - Large / Desktop (≥ 1200px): 3 in a row
  static int getCrossAxisCountForCards(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return 1;
    } else if (screenWidth < 1200) {
      return 2;
    } else {
      return 3;
    }
  }
}
