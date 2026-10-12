/// Module: GRC Policy Management
/// Description: Header row widget with avatar and Arabic version toggle.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-01
/// Dependencies: Flutter SDK, AppColors, FlutterSwitch, CustomImagePicker
/// Revision History: 2026-07-01 - Initial creation
///                   2026-07-14 - Replaced the static avatar placeholder with
///                                CustomImagePicker for real image picking
library;

/// ************************* FILE INFO *************************** ///
/// File Name: policy_header_widget.dart
/// Purpose: Contains PolicyHeaderWidget, the policy image picker and
///          "Create Arabic Version" toggle row at the top of the policy form.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 1/7/2026

import 'dart:io';

import 'package:knowticed_plus/core/custom/38-custom_responsive.dart';
import 'package:knowticed_plus/core/custom/46-custom_image_picker.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// class name: [PolicyHeaderWidget]
///
/// purpose: row containing the policy image picker (backed by
///          [CustomImagePicker]) and the "Create Arabic Version" toggle. The
///          owning page holds the isArabicEnabled/imageFile state and
///          receives changes via onArabicToggle/onImagePicked.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 1/7/2026
class PolicyHeaderWidget extends StatelessWidget {
  final bool isArabicEnabled;
  final ValueChanged<bool> onArabicToggle;
  final File? imageFile;
  final ValueChanged<File> onImagePicked;

  const PolicyHeaderWidget({
    super.key,
    required this.isArabicEnabled,
    required this.onArabicToggle,
    required this.onImagePicked,
    this.imageFile,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = screenSizeOf(context) == ScreenSize.mobile;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomImagePicker(
          radius: 30.r,
          badgeRadius: 11.r,
          imageFile: imageFile,
          onImagePicked: onImagePicked,
        ),
        Row(
          children: [
            // Phone: 12.sp label and a switch 2.sp smaller all round.
            Text(
              S.of(context).createArabicVersion,
              style: isMobile
                  ? StyleText.fontSize12Weight500
                      .copyWith(color: AppColors.text, fontSize: 12.sp)
                  : null,
            ),
            SizedBox(width: 10.w),
            FlutterSwitch(
              width: isMobile ? 36.sp : 38.sp,
              height: isMobile ? 20.sp : 22.sp,
              padding: 3.sp,
              borderRadius: 20.sp,
              toggleSize: isMobile ? 14.sp : 16.sp,
              activeColor: AppColors.secondaryPrimary,
              inactiveColor: Colors.grey.withOpacity(.16),
              value: isArabicEnabled,
              onToggle: onArabicToggle,
            ),
          ],
        ),
      ],
    );
  }
}
