// ******************* FILE INFO *******************
// File Name: dashboard_admin_details_export_widget.dart
// Description: CSV export functionality for service requests
// Module: services_management_module / presentation / s9_admin_dashboard / ui / widgets
// Created by: Amr Mesbah
// Last Update: 30/8/2025

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

import 'package:knowticed_plus/features/services_management_module/main_controller/data/helper/csv_helper.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/services_management_module/s11_admin_dashboard_mobile/presentation/ui/widgets/dialog.dart';

class ServiceRequestExportHelper {
  OverlayEntry? _overlayEntry;

  /// Show file name dialog and return the entered name
  Future<String?> showFileNameDialog(BuildContext context) async {
    final TextEditingController controller = TextEditingController();

    return await showDialog<String>(
      context: context,
      builder: (context) {
        final lightMode = Theme.of(context).brightness == Brightness.light;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: lightMode ? AppColors.white : AppColors.chatBackground,
              borderRadius: BorderRadius.circular(8.r),
            ),
            width: 411.sp,
            height: 210.sp,
            child: Padding(
              padding: EdgeInsets.all(15.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildDialogHeader(context, lightMode),
                  SizedBox(height: 10.sp),

                  // File name label
                  Text(
                    S.of(context).fileName,
                    style: StyleText.fontSize14Weight500.copyWith(
                      color: lightMode ? AppColors.blackButton : AppColors.white,
                    ),
                  ),
                  SizedBox(height: 8.sp),

                  // Text field
                  _buildTextField(context, controller, lightMode),
                  SizedBox(height: 20.sp),

                  // Buttons
                  _buildDialogButtons(context, controller),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogHeader(BuildContext context, bool lightMode) {
    return Row(
      children: [
        Container(
          width: 30.sp,
          height: 30.sp,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
          ),
          child: SvgPicture.asset(
            "assets/icons_assets/main_icons_assets/export_arrow.svg",
            width: 12.sp,
            height: 12.sp,
            fit: BoxFit.scaleDown,
            color: lightMode ? AppColors.textButton : AppColors.textButton,
            semanticsLabel: 'Export',
          ),
        ),
        SizedBox(width: 8.sp),
        Text(
          S.of(context).export,
          style: StyleText.fontSize16Weight500.copyWith(
            color: lightMode ? AppColors.blackButton : AppColors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(BuildContext context, TextEditingController controller, bool lightMode) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: lightMode ? AppColors.background : AppColors.background,
        hintText: S.of(context).Texthere,
        hoverColor: AppColors.transparent,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.r),
        ),
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
      ),
    );
  }

  Widget _buildDialogButtons(BuildContext context, TextEditingController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Discard button
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
                S.of(context).discard,
                style: StyleText.fontSize14Weight600.copyWith(
                  color: AppColors.onSecondaryAction,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 10.sp),

        // Download button
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
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Center(
              child: Text(
                S.of(context).download,
                style: StyleText.fontSize14Weight600.copyWith(
                  color: AppColors.textButton,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Export filtered items to CSV
  Future<void> exportFilteredItemsToCSV(
      BuildContext context,
      List<dynamic> filteredItems,
      String fileName,
      String locale,
      Map<String, String> enToArDepartments,
      ) async {
    await showLoadingIndicator(context);

    try {
      // Request storage permission
      final status = await Permission.manageExternalStorage.request();
      if (!status.isGranted) {
        hideLoadingIndicator();
        Get.snackbar(
          'Permission Denied',
          'Storage permission is required to export CSV.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.orange,
          colorText: AppColors.white,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      // Build CSV data
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

      // Data rows
      for (int i = 0; i < filteredItems.length; i++) {
        final item = filteredItems[i];
        final selectedProvider = item["selectedProvider"] ?? {};

        final providerName = _getProviderName(selectedProvider, locale);
        final department = _getDepartmentName(item["department"], locale, enToArDepartments);
        final serviceName = _getServiceName(item, locale);
        final requestor = _getRequestorName(item, locale);
        final status = _getLocalizedStatus(context, item["status"], locale);

        rows.add([
          item["no"] ?? (i + 1),
          department,
          serviceName,
          requestor,
          item["requestDate"] ?? '',
          status,
          providerName.isNotEmpty ? providerName : 'N/A',
        ]);
      }

      // Export to CSV
      await CSVHelper().exportToCSV(rows, fileName);
      hideLoadingIndicator();

      // Show success dialog
      showSuccessMaster(
        context,
        lottiePath: 'assets/lottie_assets/main_lottie_assets/lottie_approved.json',
        title: S.of(context).exportSuccessful,
        message: S.of(context).csvFileSaved,
        onConfirm: () {},
      );
    } catch (e) {
      hideLoadingIndicator();
      Get.snackbar(
        '❌ Export Failed',
        'Could not export data',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.red,
        colorText: AppColors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Show loading indicator overlay
  Future<void> showLoadingIndicator(BuildContext context) async {
    _overlayEntry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          ModalBarrier(
            dismissible: false,
            color: AppColors.black.withOpacity(0.3),
          ),
          Center(
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.black.withOpacity(0.87),
                borderRadius: BorderRadius.circular(12),
              ),
              child:  CircularProgressIndicator(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  /// Hide loading indicator
  void hideLoadingIndicator() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  // ==================== HELPER METHODS ====================

  String _getProviderName(Map<String, dynamic> selectedProvider, String locale) {
    if (locale == 'ar') {
      final arabicFirst = selectedProvider['firstNameInArabic']?.toString()?.trim() ?? '';
      final arabicLast = selectedProvider['lastNameInArabic']?.toString()?.trim() ?? '';
      final arabicName = '$arabicFirst $arabicLast'.trim();

      if (arabicName.isNotEmpty && arabicName != 'null null') {
        return arabicName;
      }
    }

    final englishFirst = selectedProvider['firstName']?.toString()?.trim() ?? '';
    final englishLast = selectedProvider['lastName']?.toString()?.trim() ?? '';
    final englishName = '$englishFirst $englishLast'.trim();

    return englishName.isNotEmpty && englishName != 'null null' ? englishName : '';
  }

  String _getDepartmentName(
      String? department,
      String locale,
      Map<String, String> enToArDepartments,
      ) {
    if (department == null || department.isEmpty) return '';

    if (locale == 'ar') {
      return enToArDepartments[department] ?? department;
    }

    return department;
  }

  String _getServiceName(Map<String, dynamic> item, String locale) {
    if (locale == 'ar') {
      return item["serviceNameArabic"] ?? item["serviceName"] ?? '';
    }
    return item["serviceName"] ?? '';
  }

  String _getRequestorName(Map<String, dynamic> item, String locale) {
    if (locale == 'ar') {
      return item["requestorArabic"] ?? '';
    }
    return item["requestor"] ?? '';
  }

  String _getLocalizedStatus(BuildContext context, dynamic status, String locale) {
    final statusStr = (status ?? '').toString().toLowerCase();

    if (locale == 'ar') {
      if (statusStr == "done") return S.of(context).Done;
      if (statusStr == "pending") return S.of(context).Pending;
      if (statusStr == "inprogress") return S.of(context).Inprogress;
      if (statusStr == "branchsla") return S.of(context).BreachedSLA;
      if (statusStr == "breached sla") return S.of(context).BreachedSLA;
      if (statusStr == "rejected") return S.of(context).Rejected;
      if (statusStr == "canceled") return S.of(context).Canceled;
      if (statusStr == "cancel") return S.of(context).Canceled;
      if (statusStr == "approved") return S.of(context).Approved;
    }

    return statusStr.isNotEmpty ? statusStr : "-";
  }
}
