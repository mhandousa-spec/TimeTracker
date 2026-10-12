/// Module: roles / r5_system_logs / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: download_logs_dialog.dart
/// Purpose: Declares `SystemLogsDownloadDialog`.
/// Author: Knowticed Plus team
/// Created At: 12/8/2026
/// Updated: 21/9/2026 - REBUILT. "When press export in system log" opened an
///          empty grey box (bug report p.7). The old body sized everything with
///          fractional ScreenUtil values — `0.021.h` font sizes, `0.3.w` insets,
///          `0.015.h` padding — which ScreenUtil reads as design pixels, so the
///          title, field and buttons all rendered at almost 0px. It is now the
///          same layout as `UserManagementExportDialog` (card, file-name field,
///          Discard / Export CSV), built on the shared theme tokens. The export
///          itself and its result dialogs are unchanged: the cubit runs it and
///          `SystemLogsTable._handleSystemLogsState` presents the outcome and
///          closes this dialog.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class SystemLogsDownloadDialog extends StatefulWidget {
  const SystemLogsDownloadDialog({super.key});

  @override
  State<SystemLogsDownloadDialog> createState() =>
      _SystemLogsDownloadDialogState();
}

class _SystemLogsDownloadDialogState extends State<SystemLogsDownloadDialog> {
  final TextEditingController fileName = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (fileName.text.isEmpty) {
      // File names stay ASCII ('en') whatever the UI language.
      final String date = DateFormat('dd MMM yyyy', 'en').format(DateTime.now());
      fileName.text = '${S.of(context).systemsLogs}_$date';
    }
  }

  @override
  void dispose() {
    fileName.dispose();
    super.dispose();
  }

  void _export() {
    final String name = fileName.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          backgroundColor: AppColors.orange,
          behavior: SnackBarBehavior.floating,
          content: Text(S.of(context).pleaseEnterAFileName,
              style: TextStyle(color: AppColors.white)),
        ));
      return;
    }

    // This dialog is its own route, so set the locale here too rather than
    // relying on the page below.
    AppControllers.systemLogs.exportInArabic = context.isArabic;

    // CHANGED 21/9/2026 — the dialog closes FIRST, then the export runs: the
    // page's listener shows the loading overlay while the file is written and
    // the success (or error) dialog when it is done. It used to stay open
    // behind the spinner and be closed by the listener afterwards.
    Navigator.of(context).pop();
    AppControllers.systemLogs.exportSystemLogs(name);
  }

  @override
  Widget build(BuildContext context) {
    final double buttonWidth = context.isPhone ? 120.sp : 150.sp;

    return Dialog(
      backgroundColor: AppColors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      child: Container(
        width: 411.sp,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8.r),
        ),
        padding: EdgeInsets.all(20.sp),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 30.sp,
                  height: 30.sp,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                  ),
                  child: Center(
                    child: CustomSvgImage(
                      assetPath:
                          "assets/icons_assets/main_icons_assets/assets_export.svg",
                      width: 16.sp,
                      height: 16.sp,
                      color: AppColors.textButton,
                    ),
                  ),
                ),
                SizedBox(width: 8.sp),
                Expanded(
                  child: Text(
                    S.of(context).downloadingFile,
                    style: StyleText.fontSize16Weight500
                        .copyWith(color: AppColors.text),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15.sp),
            CustomTextField(
              label: S.of(context).fileName,
              hint: S.of(context).textHere,
              controller: fileName,
              height: 36,
            ),
            SizedBox(height: 20.sp),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                customButton(
                  title: S.of(context).discard,
                  width: buttonWidth,
                  height: 38,
                  color: AppColors.secondaryButton,
                  radius: 8.r,
                  textStyle: StyleText.fontSize16Weight500
                      .copyWith(color: AppColors.blackButton),
                  function: () => Navigator.pop(context),
                ),
                customButton(
                  title: S.of(context).exportCsv,
                  width: buttonWidth,
                  height: 38,
                  color: AppColors.primary,
                  radius: 8.r,
                  textStyle: StyleText.fontSize16Weight500
                      .copyWith(color: AppColors.textButton),
                  function: _export,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
