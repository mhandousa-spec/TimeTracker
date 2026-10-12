// lib/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_weight_dialog.dart
/// Module: GRC Control Bulk Upload
/// Description: Blocking Yes/No dialog shown the first time the user
///              initiates a file upload on ControlBulkUploadPage (Browse
///              Files tap or a file drop), before the file picker/parser
///              runs, asking whether every department gets an equal weight
///              share for this whole uploaded batch. The question asks
///              whether weights are DISTINCT: Yes → returns false (use the
///              per-row Department Weight column), No → returns true (equal
///              split, 100 / department count per row). The answer applies to the whole batch, not
///              per row, and isn't editable once the dialog closes.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-22
/// Dependencies: flutter/material, AppColors, StyleText, customButton
library;

import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:flutter/material.dart' hide Border, BorderStyle;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// function name: [showControlBulkWeightDialog]
///
/// purpose: block the Control Bulk Upload page behind a non-dismissible
///          Yes/No dialog until the user answers whether every department
///          should get an equal weight share for the whole uploaded batch.
///
/// parameters:
///            [BuildContext] context: the page's context to show the dialog over
///
/// return type: [Future<bool>] - true = equal split (answered No), false = distinct weights (answered Yes)
Future<bool> showControlBulkWeightDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierColor: AppColors.totalBlack.withOpacity(0.4),
    builder: (dialogContext) => PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: AppColors.transparent,
        child: Container(
          width: 420.w,
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                S.of(context).doesEachDepartmentCarryADistinctWeighting,
                textAlign: TextAlign.center,
                style: StyleText.fontSize16Weight600.copyWith(color: AppColors.text),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    // FIXED 28/9/2026 (GRC bug report p19). The question is
                    // "does each department carry a DISTINCT weighting?", but
                    // No used to pop false (= distinct) and Yes true (= equal)
                    // — the answer did the opposite of what the user said.
                    // This function returns "equal weights", so:
                    // No → not distinct → equal (true).
                    child: customButton(
                      title: S.of(context).no,
                      function: () => Navigator.of(dialogContext).pop(true),
                      height: 38.h,
                      // Secondary button, same as Discard elsewhere.
                      color: AppColors.darkGrey,
                      textStyle: StyleText.fontSize16Weight600
                          .copyWith(color: AppColors.white),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: customButton(
                      title: S.of(context).yes,
                      // Yes → distinct → NOT equal (false).
                      function: () => Navigator.of(dialogContext).pop(false),
                      height: 38.h,
                      color: AppColors.primary,
                      textStyle: StyleText.fontSize16Weight600
                          .copyWith(color: AppColors.textButton),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
  return result ?? false;
}
