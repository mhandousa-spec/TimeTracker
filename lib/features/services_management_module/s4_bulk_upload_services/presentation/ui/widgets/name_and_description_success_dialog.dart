// ******************* FILE INFO *******************
// File Name: name_and_description_success_dialog
// Description: Name and description success dialog.
// Module: services_management_module / presentation/s4_bulk_upload_services/ui/widgets
// *************************************************

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';


class SuccessDialog extends StatelessWidget {
  final String? message;

  const SuccessDialog({this.message, super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: SizedBox(
          width: 410.sp,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/lottie_assets/main_lottie_assets/lottie_approved.json',
                width: 100.sp,
                height: 100.sp,
                fit: BoxFit.scaleDown,
                repeat: true,
                animate: true,
              ),
              SizedBox(height: 20.sp),
              Text(
                message ?? S.of(context).changingStatus,
                style: StyleText.fontSize20Weight500.copyWith(
                  color: AppColors.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DuplicateNameDialog extends StatelessWidget {
  const DuplicateNameDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      title: Column(
        children: [
          Lottie.asset(
            'assets/lottie_assets/main_lottie_assets/lottie_rejected.json',
            width: 70.sp,
            height: 70.sp,
            fit: BoxFit.scaleDown,
            repeat: true,
            animate: true,
          ),
          SizedBox(height: 12.sp),
          Text(
            FormatHelper.capitalize(
              "Service name already exists. Please choose a different one",
            ),
            textAlign: TextAlign.center,
            style: StyleText.fontSize15Weight400.copyWith(
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}