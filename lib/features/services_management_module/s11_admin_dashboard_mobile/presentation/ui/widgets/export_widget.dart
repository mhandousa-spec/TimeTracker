// ******************* FILE INFO *******************
// File Name: export_widget
// Description: Export widget.
// Module: services_management_module / presentation/s11_admin_dashboard_mobile/ui/widgets
// *************************************************

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:permission_handler/permission_handler.dart';

// =============================================
// FileNameDialog Widget - Shows dialog to enter file name
// =============================================
class FileNameDialog {
  static Future<String?> show(
      BuildContext context, {
        required String exportText,
        required String fileNameText,
        required String textHereHint,
        required String discardText,
        required String downloadText,
        Color? primaryColor,
        Color? backgroundColor,
        Color? textColor,
        Color? buttonTextColor,
      }) async {
    final TextEditingController controller = TextEditingController();
    final lightMode = Theme.of(context).brightness == Brightness.light;

    final bgColor = backgroundColor ??
        (lightMode ? AppColors.white : AppColors.darkGrey!);
    final txtColor = textColor ?? (lightMode ? AppColors.black.withOpacity(0.87) : AppColors.white.withOpacity(0.70));
    final btnTxtColor = buttonTextColor ?? AppColors.white;
    final primColor = primaryColor ?? Theme.of(context).primaryColor;

    return await showDialog<String>(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8.r),
            ),
            width: 411.sp,
           // height: 200.sp,
            child: Padding(
              padding: EdgeInsets.all(15.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 30.sp,
                        height: 30.sp,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primColor,
                        ),
                        child: SizedBox(
                          child: CustomSvgImage(assetPath: "assets/icons_assets/main_icons_assets/export_arrow.svg",color: AppColors.textButton,width: 10.w,height: 10.h,fit: BoxFit.scaleDown,),
                        )
                      ),
                      SizedBox(width: 8.sp),
                      Text(
                        exportText,
                        style: StyleText.fontSize14Weight400.copyWith(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: txtColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.sp),

                  // File name label
                  Text(
                    fileNameText,
                    style: StyleText.fontSize14Weight400.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: txtColor,
                    ),
                  ),
                  SizedBox(height: 8.sp),

                  // Text field
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.background,
                      hintText: textHereHint,
                      hintStyle: StyleText.fontSize16Weight400.copyWith(
                        color: AppColors.secondaryText
                      ),
                      hoverColor: AppColors.transparent,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                  SizedBox(height: 20.sp),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Discard
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 130.sp,
                          height: 38.sp,
                          decoration: BoxDecoration(
                            color: AppColors.secondaryAction,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Center(
                            child: Text(
                              discardText,
                              style: StyleText.fontSize14Weight400.copyWith(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSecondaryAction,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.sp),

                      // Download
                      GestureDetector(
                        onTap: () {
                          final name = controller.text.trim();
                          if (name.isNotEmpty) {
                            Navigator.pop(context, name);
                          }
                        },
                        child: Container(
                          width: 130.sp,
                          height: 38.sp,
                          decoration: BoxDecoration(
                            color: primColor,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Center(
                            child: Text(
                              downloadText,
                              style: StyleText.fontSize14Weight400.copyWith(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: btnTxtColor,
                              ),
                            ),
                          ),
                        ),
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
}

// =============================================
// CSVExporter - Handles CSV export functionality
// =============================================
class CSVExporter {
  OverlayEntry? _overlayEntry;

  // Show loading indicator
  Future<void> showLoadingIndicator(BuildContext context) async {
    // Services mobile QA p.21 ("remove this loading"): the dark 70pt spinner
    // box stayed on screen behind the phone's Save sheet for as long as the
    // sheet was open. The save sheet (and the Export button's own busy state)
    // is the feedback now, so no overlay is shown.
    // Intentionally empty; kept so the existing callers (and
    // hideLoadingIndicator) stay unchanged.
  }

  // Hide loading indicator
  void hideLoadingIndicator() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  // Export filtered items to CSV
  Future<void> exportFilteredItemsToCSV(
      BuildContext context, {
        required List<dynamic> filteredItems,
        required String fileName,
        required String locale,
        required Map<String, String> enToArDepartments,
        required Function(List<List<dynamic>>, String) csvExportFunction,
        required String doneText,
        required String pendingText,
        required String inprogressText,
        required String breachedSLAText,
        required String rejectedText,
        required String canceledText,
        required String approvedText,
        String permissionDeniedTitle = 'Permission Denied',
        String permissionDeniedMessage = 'Storage permission is required to export CSV.',
        String exportSuccessTitle = '✅ Export Successful',
        String exportSuccessMessage = 'Your CSV file has been saved',
        String exportFailedTitle = '❌ Export Failed',
        String exportFailedMessage = 'Could not export data',
      }) async {
    await showLoadingIndicator(context);

    try {
      final status = await Permission.manageExternalStorage.request();
      if (!status.isGranted) {
        hideLoadingIndicator();
        Get.snackbar(
          permissionDeniedTitle,
          permissionDeniedMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.orange,
          colorText: AppColors.white,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      List<List<dynamic>> rows = [];

      // Table Headers
      rows.add([
        'No',
        'Department',
        'Service Name',
        'Requestor',
        'Request Date',
        'Status',
        'Service Provider',
      ]);

      for (int i = 0; i < filteredItems.length; i++) {
        final item = filteredItems[i];
        final selectedProvider = item["selectedProvider"] ?? {};

        final providerName = locale == 'ar'
            ? '${selectedProvider['firstNameInArabic'] ?? ''} ${selectedProvider['lastNameInArabic'] ?? ''}'
            .trim()
            : '${selectedProvider['firstName'] ?? ''} ${selectedProvider['lastName'] ?? ''}'
            .trim();

        final department = locale == 'ar'
            ? enToArDepartments[item["department"]] ?? item["department"] ?? ''
            : item["department"] ?? '';

        final serviceName = locale == 'ar'
            ? item["serviceNameArabic"] ?? item["serviceName"] ?? ''
            : item["serviceName"] ?? '';

        final requestor = locale == 'ar'
            ? item["requestorArabic"] ?? ''
            : item["requestor"] ?? '';

        final status = (item["status"] ?? '').toString().toLowerCase();
        final isArabic = locale == 'ar';
        final localizedStatus = _getLocalizedStatus(
          status,
          isArabic,
          doneText,
          pendingText,
          inprogressText,
          breachedSLAText,
          rejectedText,
          canceledText,
          approvedText,
        );

        rows.add([
          item["no"] ?? (i + 1),
          department,
          serviceName,
          requestor,
          item["requestDate"] ?? '',
          localizedStatus,
          providerName.isNotEmpty ? providerName : 'N/A',
        ]);
      }

      await csvExportFunction(rows, fileName);
      hideLoadingIndicator();

      Get.snackbar(
        exportSuccessTitle,
        exportSuccessMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.green,
        colorText: AppColors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      hideLoadingIndicator();
      Get.snackbar(
        exportFailedTitle,
        exportFailedMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.red,
        colorText: AppColors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  String _getLocalizedStatus(
      String status,
      bool isArabic,
      String doneText,
      String pendingText,
      String inprogressText,
      String breachedSLAText,
      String rejectedText,
      String canceledText,
      String approvedText,
      ) {
    if (isArabic) {
      switch (status) {
        case "done":
          return doneText;
        case "pending":
          return pendingText;
        case "inprogress":
          return inprogressText;
        case "branchsla":
          return breachedSLAText;
        case "rejected":
          return rejectedText;
        case "canceled":
          return canceledText;
        case "approved":
          return approvedText;
      }
    }
    return status.isNotEmpty ? status : "-";
  }
}

// Usage Example:
/*
// 1. Show File Name Dialog
final fileName = await FileNameDialog.show(
  context,
  exportText: S.of(context).export,
  fileNameText: S.of(context).fileName,
  textHereHint: S.of(context).Texthere,
  discardText: S.of(context).discard,
  downloadText: S.of(context).download,
  primaryColor: AppColors.primary,
  buttonTextColor: AppColors.textButton,
);

if (fileName != null && fileName.isNotEmpty) {
  // 2. Export CSV
  final exporter = CSVExporter();
  await exporter.exportFilteredItemsToCSV(
    context,
    filteredItems: filteredItems,
    fileName: fileName,
    locale: Localizations.localeOf(context).languageCode,
    enToArDepartments: enToArDepartments,
    csvExportFunction: (rows, name) => CSVHelper().exportToCSV(rows, name),
    doneText: S.of(context).Done,
    pendingText: S.of(context).Pending,
    inprogressText: S.of(context).Inprogress,
    breachedSLAText: S.of(context).BreachedSLA,
    rejectedText: S.of(context).Rejected,
    canceledText: S.of(context).Canceled,
    approvedText: S.of(context).Approved,
  );
}
*/