import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';

Widget creatingKnowledgeConfirmation(
  BuildContext context, {
  required bool isUploading,
  required Future<void> Function() submitForApproval,
}) {
  final isMobile = ContextExtension(context).isPhone;
  final lightMode = Theme.of(context).brightness == Brightness.light;
  return Material(
    color: Colors.transparent,
    child: StatefulBuilder(
      builder: (context, setState) {
        return Container(
          width: isMobile ? double.infinity : 411.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            color: lightMode
                ? AppColors.white
                : AppColors.background,
          ),
          padding: EdgeInsets.all(20.r),
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/lottie_assets/main_lottie_assets/lottie_confirmation.json',
                height: 70.h,
                width: 70.w,
              ),
              SizedBox(height: 20.h),
              Text(
                S.of(context).creating_knowledge_hub,
                style: StyleText.fontSize20Weight500.copyWith(
                  color: lightMode
                      ? AppColors.blackButton
                      : AppColors.white,
                ),
              ),
              SizedBox(height: 18.h),
              Text(
                S.of(context).are_you_sure_submit,
                style: StyleText.fontSize14Weight500.copyWith(
                  color: lightMode
                      ? AppColors.secondaryText
                      : AppColors.grey,
                ),
              ),
              SizedBox(height: 15.h),

              // Show loading indicator when uploading
              if (isUploading)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: Column(
                    children: [
                      // CHANGED 22/9/2026 — "same loading indicator like whole
                      // app". Every other wait in Knowledge Hub (and the rest
                      // of the app) shows [CircleProgressMaster]; this dialog
                      // and the resubmit one were the two places still raising
                      // Material's default spinner, so submitting a document
                      // looked like a different product for the few seconds
                      // the upload took.
                      CircleProgressMaster(),
                      SizedBox(height: 10.h),
                      Text(
                        S.of(
                          context,
                        )!.uploading, // Add this to your localization
                        style: StyleText.fontSize14Weight500.copyWith(
                          color: lightMode
                              ? AppColors.secondaryText
                              : AppColors.grey,
                        ),
                        // style: TextStyles.font14BlackCairoSemiBold.copyWith(
                        //   color: AppColors.grey,
                        // ),
                      ),
                    ],
                  ),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: customButton(
                        title: S.of(context).no,
                        textStyle: StyleText.fontSize16Weight500,
                        height: 38.h,
                        width: 135.w,
                        color: lightMode?Colors.grey[400]:Colors.grey[700],
                        textColor: lightMode? Colors.black:Colors.white,
                        function: () {
                          Navigator.of(context).pop();
                        },
                        radius: 4.r,
                      ),
                    ),
                    SizedBox(width: 45.w),
                    Expanded(
                      child: customButton(
                        color: AppColors.primary,
                        height: 38.h,
                        width: 135.w,
                        title: S.of(context).yes,
                        textStyle: StyleText.fontSize16Weight500.copyWith(
                          color: AppColors.textButton
                        ),
                        textColor:AppColors.textButton,
                        function: () async {
                          setState(() {}); // Trigger rebuild to show loading
                          await submitForApproval();
                        },
                        radius: 4.r,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    ),
  );
}
