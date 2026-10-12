/// Module: services_management_module
/// Description: CSV export dialog + flow for the service-details "export"
///              action (file-name prompt, permission check, CSV write,
///              success/failure feedback).
/// Author: Knowticed Team
/// Date: 2026-07-02
/// Dependencies: cloud_firestore (Timestamp only), permission_handler, CSVHelper
/// Revision History: Replaced Get.snackbar with the project's themed
///                    ScaffoldMessenger snackbar; extracted the two hardcoded
///                    EN strings (permission-denied title/body) to named
///                    constants with a TODO to add proper localization keys
///                    once the .arb files can be regenerated (audit fix #5c).

// ----------------------------- 📤 Export to CSV -----------------------------
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/features/services_management_module/s5_service_details/presentation/ui/widgets/success_dialog.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/helper/csv_helper.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';

// TODO(i18n): promote these to S.of(context) keys once new .arb entries can
// be regenerated — kept as named constants rather than inline literals so
// the intent is explicit and there's a single place to swap them out.
const String _kPermissionDeniedTitle = 'Permission Denied';
const String _kStoragePermissionRequiredBody =
    'Storage permission is required to export CSV.';

void _showThemedSnackBar(
  BuildContext context, {
  required String title,
  required String message,
  required Color backgroundColor,
}) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: backgroundColor,
      duration: const Duration(seconds: 3),
      content: Text(
        '$title: $message',
        style: StyleText.fontSize14Weight400.copyWith(color: AppColors.white),
      ),
    ),
  );
}

String formatStartDate(dynamic timestampOrDateTime) {
  if (timestampOrDateTime == null) return '-';

  DateTime date;

  if (timestampOrDateTime is Timestamp) {
    date = timestampOrDateTime.toDate();
  } else if (timestampOrDateTime is DateTime) {
    date = timestampOrDateTime;
  } else {
    return '-';
  }

  final formatted = DateFormat('dd MMM yyyy').format(date);
  return formatted;
}
Future<void> exportToCSV(
    BuildContext context,
    List<dynamic> filteredModel,
    Map selectedProviders,
    String fileName,
    ) async {
  await showLoadingIndicator(context);

  try {
    // ✅ Request storage permission (Android 11+)
    final status = await Permission.manageExternalStorage.request();
    if (!status.isGranted) {
      hideLoadingIndicator();
      _showThemedSnackBar(
        context,
        title: _kPermissionDeniedTitle,
        message: _kStoragePermissionRequiredBody,
        backgroundColor: AppColors.orange,
      );
      return;
    }

    // ✅ Build CSV rows
    List<List<dynamic>> rows = [];
    rows.add([
      'No',
      'Service Name (EN)',
      'Service Name (AR)',
      'Description (EN)',
      'Description (AR)',
      'Status',
      'Duration',
      'Time Unit',
      'Limit Availability',
      'Requires Approval',
      'Start Date',
      'Service Provider',
    ]);

    for (int i = 0; i < filteredModel.length; i++) {
      final item = filteredModel[i];
      final provider = selectedProviders[item.id];
      final providerName =
      provider != null
          ? "${provider['firstName'] ?? ''} ${provider['lastName'] ?? ''}"
          : "No Provider";

      rows.add([
        i + 1,
        item.serviceNameEnglish ?? '',
        item.serviceNameArabic ?? '',
        item.serviceDescriptionEnglish ?? '',
        item.serviceDescriptionArabic ?? '',
        "Approved",
        item.durationOfServices ?? '',
        item.selectedDurationUnit ?? '',
        item.selectDepartment!.isEmpty ? "No" : "Yes",
        item.approvalCycle!.isEmpty ? "No" : "Yes",
        formatStartDate(item.durationOfServicesTimestamp),
        providerName,
      ]);
    }

    await CSVHelper().exportToCSV(rows, fileName);
    hideLoadingIndicator();

    await showDownloadSuccessDialog(context);

  } catch (e) {
    hideLoadingIndicator();
    if (context.mounted) {
      _showThemedSnackBar(
        context,
        title: S.of(context).exportFailed,
        message: 'Could not export data',
        backgroundColor: AppColors.red,
      );
    }
  }
}

Future<String?> showFileNameDialog(BuildContext context) async {
  var lightMode = Theme.of(context).brightness == Brightness.light;
  final TextEditingController controller = TextEditingController();

  return await showDialog<String>(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Container(
          decoration: BoxDecoration(
            color:
            lightMode
                ? AppColors.white
                : AppColors.chatBackground,
            borderRadius: BorderRadius.circular(8.r),
          ),
          width: 411.sp, // 🔵 Set your desired width
          height: 213.sp,
          child: Padding(
            padding: EdgeInsets.all(20.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // image & export
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
                        child: SvgPicture.asset(
                          "assets/icons_assets/main_icons_assets/export_arrow.svg",
                          width: 13.sp,
                          height: 13.sp,
                          color: AppColors.textButton,
                          fit: BoxFit.fill  ,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.sp),
                    Text(
                      S.of(context).export,
                      style: StyleText.fontSize16Weight500.copyWith(
                        color:
                        lightMode
                            ? AppColors.blackButton
                            : AppColors.white,
                      ),
                    ),
                  ],
                ),
                // space
                SizedBox(height: 20.sp),

                // File Name title
                Text(
                  S.of(context).fileName,
                  style: StyleText.fontSize14Weight500.copyWith(
                    color:
                    lightMode
                        ? AppColors.blackButton
                        : AppColors.white,
                  ),
                ),

                SizedBox(height: 8.sp),

                Container(
                  height: 36.sp,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.r)
                  ),
                  child: CustomTextField(
                    controller: controller,
                    hint: S.of(context).Texthere,
                    fillColor: AppColors.background,
                    borderRadius: BorderRadius.circular(4.r),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 9.sp, vertical: 13.sp),
                    valueStyle: StyleText.fontSize14Weight400.copyWith(
                      color: lightMode ? AppColors.blackButton : AppColors.white,
                    ),
                    hintStyle: StyleText.fontSize12Weight400.copyWith(
                      color: lightMode ? AppColors.secondaryText : AppColors.grey,
                    ),
                  ),
                ),

                // space
                SizedBox(height: 20.sp),
                // Discard and Download
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    customButton(
                      title: S.of(context).discard,
                      width: 120.w,
                      color: AppColors.secondaryAction,
                      height: 38.h,
                      textStyle: StyleText.fontSize16Weight500.copyWith(
                        color: AppColors.onSecondaryAction,
                      ),
                      radius: 8.r,
                      function: () {
                        Navigator.pop(context);
                      },
                    ),

                    customButton(
                      title: S.of(context).download,
                      width: 120.w,
                      color: AppColors.primary,
                      height: 38.h,
                      textStyle: StyleText.fontSize18Weight500.copyWith(
                        color: AppColors.textButton,
                      ),
                      radius: 8.r,
                      function: () {
                        final name = controller.text.trim();
                        if (name.isNotEmpty) {
                          Navigator.pop(context, name);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
OverlayEntry? _overlayEntry;
Future<void> showLoadingIndicator(BuildContext context) async {
  // Services mobile QA p.21 ("remove this loading"): the dark 70pt spinner
  // box stayed on screen behind the phone's Save sheet for as long as the
  // sheet was open. The save sheet (and the Export button's own busy state)
  // is the feedback now, so no overlay is shown.
  // Intentionally empty; kept so the existing callers (and
  // hideLoadingIndicator) stay unchanged.
}

void hideLoadingIndicator() {
  _overlayEntry?.remove();
  _overlayEntry = null;
}
