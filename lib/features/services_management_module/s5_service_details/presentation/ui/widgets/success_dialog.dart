// ******************* FILE INFO *******************
// File Name: success_dialog
// Description: Success dialog.
// Module: services_management_module / presentation/s5_service_details/ui/widgets
// *************************************************

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';


Future<void> showDownloadSuccessDialog(BuildContext context) async {
  final lightMode = Theme.of(context).brightness == Brightness.light;

  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (ctx) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 411.sp,
          padding: EdgeInsets.all(16.sp),
          decoration: BoxDecoration(
            color: lightMode ? AppColors.white : AppColors.chatBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/lottie_assets/main_lottie_assets/lottie_approved.json',
                width: 70.sp,
                height: 70.sp,
                repeat: true,
              ),
              SizedBox(height: 12.sp),
              Text(
                S.of(context).downloadSuccessTitle,
                style: StyleText.fontSize20Weight500.copyWith(
                  color: lightMode ? AppColors.blackButton : AppColors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 6.sp),
              Text(
                S.of(context).downloadSuccessMessage,
                style: StyleText.fontSize14Weight500.copyWith(
                  color: lightMode ? AppColors.secondaryText : AppColors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    },
  );
}
